#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Green Flow - ESP32 Smart Agriculture Virtual Hardware & Live Bridge
====================================================================
Simulates the 5 Farm Devices + Live Two-Way Sync with Flutter Web App.

HOW IT WORKS:
  - Shows all 5 IoT devices from the Devices Page when it starts.
  - Runs an HTTP bridge on http://127.0.0.1:8088
  - Flutter app sends slider values → POST /control
  - Flutter app reads live state   → GET  /telemetry
  - If soilMoisture < 30%  → Pump AUTO-ON, moisture rises ~4%/sec
  - When moisture reaches 60%     → Pump AUTO-STOPS

USAGE:
  python hardware_simulation/virtual_esp32.py
  (or double-click run_greenflow.bat to launch everything)
"""

import sys
import time
import json
import random
import threading
from http.server import HTTPServer, BaseHTTPRequestHandler

# ── Windows UTF-8 fix ───────────────────────────────────────────────────────
if sys.platform == 'win32':
    try:
        sys.stdout.reconfigure(encoding='utf-8')
        sys.stderr.reconfigure(encoding='utf-8')
    except Exception:
        pass

# ── ANSI Colors ─────────────────────────────────────────────────────────────
GREEN   = "\033[92m"
BLUE    = "\033[94m"
CYAN    = "\033[96m"
YELLOW  = "\033[93m"
RED     = "\033[91m"
MAGENTA = "\033[95m"
BOLD    = "\033[1m"
DIM     = "\033[2m"
RESET   = "\033[0m"

LOCAL_PORT = 8088

# ── 5 Devices from the Green Flow Devices Page ──────────────────────────────
CONNECTED_DEVICES = [
    {
        "id":      "dev-001",
        "name":    "بوابة المزرعة الرئيسية — ESP32 Industrial Gateway",
        "type":    "بوابة رئيسية (Master Unit)",
        "ip":      "192.168.1.150",
        "battery": "98%",
        "status":  "ONLINE 🟢",
    },
    {
        "id":      "dev-002",
        "name":    "مجس LoRa اللاسلكي — قطاع الزيتون الشرقي",
        "type":    "مجس رطوبة وحرارة التربة (LoRa 915MHz)",
        "ip":      "LoRa-Node-01A",
        "battery": "91%",
        "status":  "ONLINE 🟢",
    },
    {
        "id":      "dev-003",
        "name":    "مجس LoRa اللاسلكي — نخيل البرحي",
        "type":    "مجس رطوبة وحرارة التربة (LoRa 915MHz)",
        "ip":      "LoRa-Node-02B",
        "battery": "86%",
        "status":  "ONLINE 🟢",
    },
    {
        "id":      "dev-004",
        "name":    "وحدة التحكم بريليهات المحابس — 8-Channel RS485",
        "type":    "مجمع محابس الري الإلكترونية",
        "ip":      "RS485-Bank-01",
        "battery": "100%",
        "status":  "ONLINE 🟢",
    },
    {
        "id":      "dev-005",
        "name":    "مستشعر منسوب مياه البئر — Hydrostatic",
        "type":    "حساس ضغط الأعماق (4-20mA)",
        "ip":      "Analog-Ch1",
        "battery": "95%",
        "status":  "ONLINE 🟢",
    },
]

# ── Shared simulation state ──────────────────────────────────────────────────
lock  = threading.Lock()
state = {
    "soilMoisture":     44.5,
    "temperature":      28.5,
    "humidity":         55.0,
    "pumpStatus":       False,
    "autoMode":         True,
    "deviceStatus":     "online",
    "_lastSliderValue": None,   # tracks last value sent from Flutter slider
}

# ── Helper: progress bar ─────────────────────────────────────────────────────
def _bar(pct: float, width: int = 30) -> str:
    filled = int(pct / 100 * width)
    color  = RED if pct < 30 else (GREEN if pct < 60 else BLUE)
    return f"{color}{'█' * filled}{'░' * (width - filled)}{RESET}"

# ── Startup banner ───────────────────────────────────────────────────────────
def print_banner_and_devices():
    w = 88
    bar_top    = "╔" + "═" * (w - 2) + "╗"
    bar_mid    = "║" + " " * (w - 2) + "║"
    bar_bot    = "╚" + "═" * (w - 2) + "╝"
    div        = "─" * w

    print(f"\n{GREEN}{BOLD}{bar_top}")
    print(f"║{'🌿  GREEN FLOW — محاكي إنترنت الأشياء للزراعة الذكية':^{w-2}}║")
    print(f"║{'ESP32 Smart Agriculture Simulator  •  Python Bridge v3.0':^{w-2}}║")
    print(f"{bar_bot}{RESET}\n")

    print(f"{BOLD}{CYAN}{'الجهاز':<42} {'النوع':<35} {'البطارية':>8}  {'الحالة'}{RESET}")
    print(div)
    for d in CONNECTED_DEVICES:
        name    = d['name'][:41]
        devtype = d['type'][:34]
        bat     = d['battery']
        st      = d['status']
        print(f"{CYAN}{name:<42}{RESET} {DIM}{devtype:<35}{RESET} {GREEN}{bat:>8}{RESET}  {st}")
    print(div)

    print(f"\n{GREEN}✅  {BOLD}5/5 أجهزة متصلة ومشتغلة{RESET}")
    print(f"{BLUE}🌐  HTTP Bridge يستمع على: http://127.0.0.1:{LOCAL_PORT}{RESET}")
    print(f"{YELLOW}📱  افتح التطبيق → المحاكي المدمج → حرّك مقياس الرطوبة{RESET}\n")
    print(div)
    print(f"  {DIM}threshold: رطوبة < 30% ← المضخة تشتغل | رطوبة >= 60% ← المضخة تقف{RESET}")
    print(div + "\n")

# ── HTTP Handler ─────────────────────────────────────────────────────────────
class BridgeHandler(BaseHTTPRequestHandler):

    def _cors(self, code: int):
        self.send_response(code)
        self.send_header("Content-Type", "application/json")
        self.send_header("Access-Control-Allow-Origin",  "*")
        self.send_header("Access-Control-Allow-Methods", "GET, POST, OPTIONS")
        self.send_header("Access-Control-Allow-Headers", "Content-Type")
        self.end_headers()

    def do_OPTIONS(self):
        self._cors(204)

    def do_GET(self):
        if self.path == "/telemetry":
            with lock:
                snap = dict(state)
            snap.pop("_lastSliderValue", None)
            self._cors(200)
            self.wfile.write(json.dumps(snap).encode())
        elif self.path == "/health":
            self._cors(200)
            self.wfile.write(b'{"status":"ok","devices":5}')
        else:
            self._cors(404)
            self.wfile.write(b'{"error":"not found"}')

    def do_POST(self):
        if self.path != "/control":
            self._cors(404)
            self.wfile.write(b'{"error":"not found"}')
            return

        length = int(self.headers.get("Content-Length", 0))
        body   = self.rfile.read(length)
        now    = time.strftime("%H:%M:%S")

        try:
            cmd = json.loads(body)
        except Exception:
            self._cors(400)
            self.wfile.write(b'{"error":"bad json"}')
            return

        with lock:
            # 1. Soil moisture from Flutter slider
            if "soilMoisture" in cmd:
                new_soil = float(cmd["soilMoisture"])
                old_soil = state["soilMoisture"]
                state["soilMoisture"]     = round(new_soil, 1)
                state["_lastSliderValue"] = round(new_soil, 1)

                # Decide color
                c = RED if new_soil < 30 else (GREEN if new_soil < 60 else BLUE)
                bar = _bar(new_soil)
                label = "جافة ⚠️" if new_soil < 30 else ("مثالية ✅" if new_soil < 60 else "رطبة كافية 💧")
                print(f"\r  {c}📡 [من التطبيق {now}] رطوبة التربة: [{bar}] {new_soil:5.1f}%  {label}{RESET}",
                      end="", flush=True)

                # Auto threshold logic (immediate response)
                auto = state["autoMode"]
                if auto:
                    pump = state["pumpStatus"]
                    if new_soil < 30.0 and not pump:
                        state["pumpStatus"] = True
                        print(f"\n\n{RED}{BOLD}  💦 [{now}] تشغيل تلقائي للمضخة! رطوبة {new_soil:.1f}% < 30%{RESET}")
                        print(f"  {BLUE}  ► الرطوبة ستبدأ في الارتفاع تدريجياً حتى 60%...{RESET}\n")
                    elif new_soil >= 60.0 and pump:
                        state["pumpStatus"] = False
                        print(f"\n\n{GREEN}{BOLD}  ⏸️  [{now}] إيقاف تلقائي للمضخة! رطوبة {new_soil:.1f}% >= 60%{RESET}\n")

            # 2. Pump command from Flutter (manual)
            if "pumpCommand" in cmd or "pumpStatus" in cmd:
                raw = cmd.get("pumpCommand") or ("ON" if cmd.get("pumpStatus") else "OFF")
                if isinstance(raw, bool):
                    new_pump = raw
                else:
                    new_pump = str(raw).upper() == "ON"
                state["pumpStatus"] = new_pump
                label = f"{BLUE}تعمل 💦{RESET}" if new_pump else f"{YELLOW}متوقفة ⏸️{RESET}"
                print(f"\n  🔧 [{now}] أمر مضخة من التطبيق: {label}")

            # 3. Auto-mode toggle
            if "autoMode" in cmd:
                new_auto = bool(cmd["autoMode"])
                state["autoMode"] = new_auto
                mode_label = f"{GREEN}تلقائي (Automatic){RESET}" if new_auto else f"{YELLOW}يدوي (Manual){RESET}"
                print(f"\n  🔄 [{now}] تغيير الوضع إلى: {mode_label}")

            # 4. Temperature / humidity (silent update)
            if "temperature" in cmd:
                state["temperature"] = float(cmd["temperature"])
            if "humidity" in cmd:
                state["humidity"] = float(cmd["humidity"])

        self._cors(200)
        self.wfile.write(b'{"status":"ok"}')

    def log_message(self, fmt, *args):
        pass   # silence HTTP access log

# ── HTTP server thread ───────────────────────────────────────────────────────
def run_server():
    try:
        srv = HTTPServer(("127.0.0.1", LOCAL_PORT), BridgeHandler)
        srv.serve_forever()
    except OSError as e:
        print(f"\n{RED}[Bridge Error] Port {LOCAL_PORT} busy or denied: {e}{RESET}")
        print(f"{YELLOW}  → Close any other process using port {LOCAL_PORT} and retry.{RESET}\n")

# ── Main simulation loop ─────────────────────────────────────────────────────
def main():
    print_banner_and_devices()

    t = threading.Thread(target=run_server, daemon=True)
    t.start()

    tick      = 0
    RISE_MIN  = 3.5     # % per cycle when pump is ON
    RISE_MAX  = 5.5
    DRY_RATE  = 0.15    # % per cycle when pump is OFF
    CYCLE_SEC = 1.5

    # Print first status line immediately
    with lock:
        soil = state["soilMoisture"]
    c   = RED if soil < 30 else (GREEN if soil < 60 else BLUE)
    bar = _bar(soil)
    print(f"[{time.strftime('%H:%M:%S')}] حالة الأجهزة: 5/5 متصلة 🟢 | رطوبة التربة: {c}{soil:5.1f}% [{bar}]{RESET} | المضخة: متوقفة ⏸️\n")

    while True:
        time.sleep(CYCLE_SEC)
        now = time.strftime("%H:%M:%S")
        tick += 1

        with lock:
            pump = state["pumpStatus"]
            soil = state["soilMoisture"]
            auto = state["autoMode"]

            if pump:
                # Moisture rises
                rise = round(random.uniform(RISE_MIN, RISE_MAX), 1)
                soil = min(round(soil + rise, 1), 85.0)
                state["soilMoisture"] = soil
                bar = _bar(soil)
                print(f"  {BLUE}💦 [المضخة تعمل {now}] رطوبة التربة ترتفع: [{bar}] {soil:5.1f}%{RESET}", flush=True)

                # Auto-stop at 60%
                if auto and soil >= 60.0:
                    state["pumpStatus"] = False
                    w = 72
                    print(f"\n{GREEN}{BOLD}╔{'═' * (w-2)}╗")
                    print(f"║{'✅  تم الوصول للنسبة المطلوبة!':^{w-2}}║")
                    print(f"║{'':^{w-2}}║")
                    print(f"║{f'   رطوبة التربة وصلت إلى {soil:.1f}%  >=  60.0%':^{w-2}}║")
                    print(f"║{'   → تم إيقاف المضخة تلقائياً ⏸️':^{w-2}}║")
                    print(f"╚{'═' * (w-2)}╝{RESET}\n")

            else:
                # Drying slowly
                soil = max(round(soil - DRY_RATE, 1), 10.0)
                state["soilMoisture"] = soil

                # Auto-start if drops below 30%
                if auto and soil < 30.0:
                    state["pumpStatus"] = True
                    print(f"\n  {RED}{BOLD}💦 [{now}] رطوبة التربة انخفضت إلى {soil:.1f}% < 30% → تشغيل تلقائي للمضخة!{RESET}")
                    print(f"  {BLUE}  ► الرطوبة ستبدأ في الارتفاع تدريجياً حتى 60%...{RESET}\n")

            cur_soil = state["soilMoisture"]
            cur_pump = state["pumpStatus"]

        # Print status every ~12 seconds (every 8 cycles) only when pump is off
        if tick % 8 == 0 and not cur_pump:
            c   = RED if cur_soil < 30 else (GREEN if cur_soil < 60 else BLUE)
            bar = _bar(cur_soil)
            pump_label = "تعمل 💦" if cur_pump else "متوقفة ⏸️"
            print(f"[{now}] الأجهزة: 5/5 🟢 | رطوبة التربة: {c}{cur_soil:5.1f}% [{bar}]{RESET} | المضخة: {pump_label}")


if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{YELLOW}[Exit] تم إيقاف المحاكي. مع السلامة! 👋{RESET}\n")
        sys.exit(0)
