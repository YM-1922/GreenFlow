#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
===========================================================================
  GREEN FLOW  -  ESP32 Smart Agriculture  -  Virtual Hardware Bridge
===========================================================================
  Simulates the 5 Farm IoT Devices + Live Two-Way Sync with the Flutter App.

  WHAT IT DOES:
    * Shows all 5 connected devices (from the Devices page) on startup.
    * Runs an HTTP bridge on http://127.0.0.1:8088
      - Flutter slider  -> POST /control  (sends soilMoisture, pumpStatus, autoMode)
      - Flutter polls   -> GET  /telemetry (reads live state)
    * "Start Irrigation Now" button on Home page -> triggers pump ON via /control
    * Built-in Simulator slider -> updates soilMoisture live in terminal
    * AUTO-IRRIGATION LOGIC:
        soilMoisture < 30%  -> Pump turns ON automatically
        Moisture rises ~4% per cycle (1.5 s) while pump is ON
        soilMoisture >= 60% -> Pump stops automatically
        Terminal shows live progress bar on every cycle

  USAGE:
    python hardware_simulation/virtual_esp32.py
    -- OR --
    Double-click  run_greenflow.bat  (launches simulator + Flutter together)

  REQUIREMENTS:  Python 3.8+  (stdlib only, no pip packages needed)
===========================================================================
"""

import sys
import time
import json
import random
import threading
from http.server import HTTPServer, BaseHTTPRequestHandler

# ---------------------------------------------------------------------------
# Windows UTF-8 fix (safe – ignored on Mac/Linux)
# ---------------------------------------------------------------------------
if sys.platform == "win32":
    try:
        sys.stdout.reconfigure(encoding="utf-8", line_buffering=True)
        sys.stderr.reconfigure(encoding="utf-8", line_buffering=True)
    except Exception:
        pass

# ---------------------------------------------------------------------------
# ANSI color codes
# ---------------------------------------------------------------------------
GREEN   = "\033[92m"
BLUE    = "\033[94m"
CYAN    = "\033[96m"
YELLOW  = "\033[93m"
RED     = "\033[91m"
MAGENTA = "\033[95m"
BOLD    = "\033[1m"
DIM     = "\033[2m"
RESET   = "\033[0m"

BRIDGE_PORT = 8088

# ---------------------------------------------------------------------------
# 5 Devices that appear on the Green Flow "Devices" page
# ---------------------------------------------------------------------------
DEVICES = [
    {
        "id":      "dev-001",
        "name":    "ESP32 Industrial Gateway  (Main Farm Hub)",
        "type":    "Master Gateway Unit",
        "ip":      "192.168.1.150",
        "battery": "98%",
        "signal":  "-65 dBm",
        "status":  "ONLINE",
    },
    {
        "id":      "dev-002",
        "name":    "LoRa Wireless Sensor  -  East Olive Zone",
        "type":    "Soil Moisture & Temperature  (LoRa 915 MHz)",
        "ip":      "LoRa-Node-01A",
        "battery": "91%",
        "signal":  "-74 dBm",
        "status":  "ONLINE",
    },
    {
        "id":      "dev-003",
        "name":    "LoRa Wireless Sensor  -  Barhi Palm Grove",
        "type":    "Soil Moisture & Temperature  (LoRa 915 MHz)",
        "ip":      "LoRa-Node-02B",
        "battery": "86%",
        "signal":  "-81 dBm",
        "status":  "ONLINE",
    },
    {
        "id":      "dev-004",
        "name":    "Irrigation Relay Bank  -  8-Channel RS-485",
        "type":    "Electronic Valve Controller",
        "ip":      "RS485-Bank-01",
        "battery": "100%",
        "signal":  "Wired",
        "status":  "ONLINE",
    },
    {
        "id":      "dev-005",
        "name":    "Well Water Level Sensor  -  Hydrostatic",
        "type":    "Depth Pressure Transducer  (4-20 mA)",
        "ip":      "Analog-Ch1",
        "battery": "95%",
        "signal":  "Wired",
        "status":  "ONLINE",
    },
]

# ---------------------------------------------------------------------------
# Shared simulation state  (all access must hold `state_lock`)
# ---------------------------------------------------------------------------
state_lock = threading.Lock()
state = {
    "soilMoisture":  44.5,
    "temperature":   28.5,
    "humidity":      55.0,
    "pumpStatus":    False,
    "autoMode":      True,
    "deviceStatus":  "online",
}

# ---------------------------------------------------------------------------
# Helpers
# ---------------------------------------------------------------------------
def _progress_bar(value: float, width: int = 32) -> str:
    """Return a colored ASCII progress bar string."""
    pct    = max(0.0, min(100.0, value))
    filled = int(pct / 100.0 * width)
    color  = RED if pct < 30 else (GREEN if pct < 60 else BLUE)
    return f"{color}{'█' * filled}{'░' * (width - filled)}{RESET}"


def _moisture_label(pct: float) -> str:
    if pct < 30:
        return f"{RED}DRY  - Needs Irrigation!{RESET}"
    if pct < 60:
        return f"{GREEN}OPTIMAL{RESET}"
    return f"{BLUE}WET  - Sufficient{RESET}"


def _pump_label(on: bool) -> str:
    return f"{BLUE}ON  💧{RESET}" if on else f"{YELLOW}OFF ⏸{RESET}"


# ---------------------------------------------------------------------------
# Startup banner
# ---------------------------------------------------------------------------
def print_startup():
    W = 90
    sep = "─" * W

    print(f"\n{GREEN}{BOLD}")
    print("╔" + "═" * (W - 2) + "╗")
    print("║" + "  🌿  GREEN FLOW  —  Smart Agriculture IoT Simulator  ".center(W - 2) + "║")
    print("║" + "  ESP32 Virtual Hardware Bridge  •  Python v3.0  ".center(W - 2) + "║")
    print("╚" + "═" * (W - 2) + f"╝{RESET}\n")

    # Device table header
    print(f"{BOLD}{CYAN}{'Device Name':<46} {'Type':<37} {'Battery':>7}  {'Status'}{RESET}")
    print(sep)
    for d in DEVICES:
        name    = d["name"][:45]
        dtype   = d["type"][:36]
        bat     = d["battery"]
        status  = f"{GREEN}● {d['status']}{RESET}"
        print(f"{CYAN}{name:<46}{RESET} {DIM}{dtype:<37}{RESET} {GREEN}{bat:>7}{RESET}  {status}")
    print(sep)

    print(f"\n  {GREEN}{BOLD}✅  5 / 5 Devices  CONNECTED{RESET}")
    print(f"  {BLUE}🌐  HTTP Bridge listening on: http://127.0.0.1:{BRIDGE_PORT}{RESET}")
    print(f"  {YELLOW}📱  Open the app → Home Page → press 'Start Irrigation Now'{RESET}")
    print(f"  {YELLOW}       or open the Built-in Simulator and move the slider.{RESET}")
    print(f"\n  {DIM}Auto-Irrigation Thresholds:  < 30%  → Pump ON  |  ≥ 60%  → Pump OFF{RESET}")
    print(sep + "\n")


# ---------------------------------------------------------------------------
# HTTP Request Handler
# ---------------------------------------------------------------------------
class BridgeHandler(BaseHTTPRequestHandler):

    # ── CORS pre-flight ────────────────────────────────────────────────────
    def _send_json(self, code: int, body: bytes):
        self.send_response(code)
        self.send_header("Content-Type",                         "application/json")
        self.send_header("Access-Control-Allow-Origin",          "*")
        self.send_header("Access-Control-Allow-Methods",         "GET, POST, PUT, OPTIONS")
        self.send_header("Access-Control-Allow-Headers",         "Content-Type, Authorization, X-Requested-With, Accept")
        self.send_header("Access-Control-Allow-Private-Network", "true")
        self.end_headers()
        self.wfile.write(body)

    def do_OPTIONS(self):
        self._send_json(200, b"")

    # ── GET /telemetry  &  GET /health ────────────────────────────────────
    def do_GET(self):
        if self.path == "/telemetry":
            with state_lock:
                snap = dict(state)
            self._send_json(200, json.dumps(snap).encode())

        elif self.path == "/health":
            self._send_json(200, b'{"status":"ok","devices":5}')

        else:
            self._send_json(404, b'{"error":"not found"}')

    # ── POST /control ──────────────────────────────────────────────────────
    def do_POST(self):
        if self.path != "/control":
            self._send_json(404, b'{"error":"not found"}')
            return

        length = int(self.headers.get("Content-Length", 0))
        raw    = self.rfile.read(length)
        now    = time.strftime("%H:%M:%S")

        try:
            cmd = json.loads(raw)
        except Exception:
            self._send_json(400, b'{"error":"invalid JSON"}')
            return

        with state_lock:
            changed = False

            # ── 1. Soil moisture update (from Flutter slider) ───────────
            if "soilMoisture" in cmd:
                new_soil = round(float(cmd["soilMoisture"]), 1)
                state["soilMoisture"] = new_soil
                bar = _progress_bar(new_soil)
                label = _moisture_label(new_soil)
                print(
                    f"\r  📡 [App → Bridge {now}]  Soil Moisture: "
                    f"[{bar}] {new_soil:5.1f}%  {label}",
                    end="", flush=True,
                )
                changed = True

                # Immediate threshold check:
                # Triggers in both Auto and Manual modes (Emergency Drought Protection)
                if new_soil < 30.0 and not state["pumpStatus"]:
                    state["pumpStatus"] = True
                    mode_tag = "AUTO-ON" if state["autoMode"] else "EMERGENCY DROUGHT PROTECTION (MANUAL MODE)"
                    print(
                        f"\n\n  {RED}{BOLD}[{now}] {mode_tag}  💧  "
                        f"Soil {new_soil:.1f}% < 30%  →  Pump STARTED automatically!{RESET}"
                    )
                    print(
                        f"  {BLUE}  ► Moisture will rise gradually until 60% ...{RESET}\n"
                    )
                elif new_soil >= 60.0 and state["pumpStatus"]:
                    state["pumpStatus"] = False
                    state["soilMoisture"] = 60.0
                    print(
                        f"\n\n  {GREEN}{BOLD}[{now}] TARGET REACHED (60.0%) ⏸  "
                        f"Soil {new_soil:.1f}% ≥ 60%  →  Pump STOPPED{RESET}\n"
                    )

            # ── 2. Pump command (from "Start / Stop Irrigation" button) ──
            if "pumpCommand" in cmd or "pumpStatus" in cmd:
                raw_cmd = cmd.get("pumpCommand") or ("ON" if cmd.get("pumpStatus") else "OFF")
                if isinstance(raw_cmd, bool):
                    new_pump = raw_cmd
                else:
                    new_pump = str(raw_cmd).strip().upper() == "ON"
                old_pump = state["pumpStatus"]
                state["pumpStatus"] = new_pump
                if new_pump != old_pump:
                    action = "STARTED" if new_pump else "STOPPED"
                    color  = BLUE if new_pump else YELLOW
                    src    = "Home Page Button" if "pumpCommand" in cmd else "App Command"
                    print(
                        f"\n  🔧 [{now}] Pump {action} via {src}  →  "
                        f"{color}Pump: {_pump_label(new_pump)}{RESET}"
                    )
                    if new_pump:
                        print(
                            f"  {BLUE}  ► Moisture will rise gradually until 60% ...{RESET}\n"
                        )
                changed = True

            # ── 3. Auto-mode toggle ────────────────────────────────────
            if "autoMode" in cmd:
                new_auto = bool(cmd["autoMode"])
                state["autoMode"] = new_auto
                label = f"{GREEN}AUTOMATIC{RESET}" if new_auto else f"{YELLOW}MANUAL{RESET}"
                print(f"\n  🔄 [{now}] Mode switched to: {label}")
                changed = True

            # ── 4. Temperature / Humidity (silent update) ──────────────
            if "temperature" in cmd:
                state["temperature"] = round(float(cmd["temperature"]), 1)
            if "humidity" in cmd:
                state["humidity"] = round(float(cmd["humidity"]), 1)

        self._send_json(200, b'{"status":"ok"}')

    def log_message(self, fmt, *args):
        pass   # silence HTTP access log


# ---------------------------------------------------------------------------
# HTTP server thread
# ---------------------------------------------------------------------------
def _run_server():
    try:
        # Bind to 0.0.0.0 so both 127.0.0.1 and localhost connect cleanly
        srv = HTTPServer(("0.0.0.0", BRIDGE_PORT), BridgeHandler)
        print(f"  {GREEN}[Bridge] HTTP server started on port {BRIDGE_PORT}{RESET}\n", flush=True)
        srv.serve_forever()
    except OSError as exc:
        print(
            f"\n{RED}[Bridge ERROR]  Port {BRIDGE_PORT} is already in use: {exc}{RESET}",
            flush=True,
        )
        print(
            f"{YELLOW}  → Close the other process using port {BRIDGE_PORT} and try again.{RESET}\n",
            flush=True,
        )


# ---------------------------------------------------------------------------
# Main simulation loop
# ---------------------------------------------------------------------------
def main():
    print_startup()

    # Start HTTP bridge in background thread
    t = threading.Thread(target=_run_server, daemon=True)
    t.start()
    time.sleep(0.3)   # let server bind before first status print

    # Initial status line
    with state_lock:
        soil = state["soilMoisture"]
        pump = state["pumpStatus"]
    bar = _progress_bar(soil)
    print(
        f"[{time.strftime('%H:%M:%S')}]  Devices: 5/5 ●  |  "
        f"Soil Moisture: {soil:5.1f}% [{bar}]  |  Pump: {_pump_label(pump)}\n"
    )

    CYCLE_S  = 1.5    # seconds per simulation tick
    RISE_MIN = 3.5    # % moisture gained per cycle when pump is ON
    RISE_MAX = 5.5
    DRY_RATE = 0.15   # % moisture lost per cycle when pump is OFF
    tick     = 0

    while True:
        time.sleep(CYCLE_S)
        tick += 1
        now = time.strftime("%H:%M:%S")

        with state_lock:
            pump = state["pumpStatus"]
            soil = state["soilMoisture"]
            auto = state["autoMode"]

            if pump:
                # ── Pump is ON → moisture rises ───────────────────────
                rise = round(random.uniform(RISE_MIN, RISE_MAX), 1)
                soil = min(round(soil + rise, 1), 85.0)
                state["soilMoisture"] = soil
                bar   = _progress_bar(soil)
                label = _moisture_label(soil)
                print(
                    f"  💧 [Pump ON  {now}]  Soil Moisture rising: "
                    f"[{bar}] {soil:5.1f}%  {label}",
                    flush=True,
                )

                # Target reached: stop pump automatically at 60%
                if soil >= 60.0:
                    state["pumpStatus"] = False
                    state["soilMoisture"] = 60.0
                    soil = 60.0
                    W = 72
                    print(f"\n{GREEN}{BOLD}╔{'═' * (W - 2)}╗", flush=True)
                    print(f"║{'':^{W-2}}║", flush=True)
                    print(f"║{'  ✅  TARGET REACHED! (60.0%)  ':^{W-2}}║", flush=True)
                    print(f"║{'':^{W-2}}║", flush=True)
                    print(f"║{f'  Soil Moisture: {soil:.1f}%  ≥  60.0%  →  Pump STOPPED automatically':^{W-2}}║", flush=True)
                    print(f"║{'':^{W-2}}║", flush=True)
                    print(f"╚{'═' * (W - 2)}╝{RESET}\n", flush=True)

            else:
                # ── Pump is OFF → soil dries slowly ───────────────────
                soil = max(round(soil - DRY_RATE, 1), 10.0)
                state["soilMoisture"] = soil

                # Auto-start if soil falls below threshold (both Auto and Manual drought protection)
                if soil < 30.0:
                    state["pumpStatus"] = True
                    mode_tag = "AUTO-ON" if auto else "EMERGENCY DROUGHT PROTECTION (MANUAL MODE)"
                    print(
                        f"\n  {RED}{BOLD}[{now}] {mode_tag}  💧  "
                        f"Soil {soil:.1f}% < 30%  →  Pump STARTED automatically{RESET}"
                    )
                    print(
                        f"  {BLUE}  ► Moisture will rise gradually until 60% ...{RESET}\n"
                    )

            cur_soil = state["soilMoisture"]
            cur_pump = state["pumpStatus"]

        # Print periodic status line every ~12 s (8 cycles) when pump is OFF
        if tick % 8 == 0 and not cur_pump:
            bar   = _progress_bar(cur_soil)
            label = _moisture_label(cur_soil)
            mode  = "AUTO" if auto else "MANUAL"
            print(
                f"[{now}]  Devices: 5/5 ●  |  "
                f"Soil: {cur_soil:5.1f}% [{bar}]  {label}  |  "
                f"Pump: {_pump_label(cur_pump)}  |  Mode: {mode}"
            )


# ---------------------------------------------------------------------------
if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print(f"\n{YELLOW}[Exit]  Simulator stopped.  Goodbye! 👋{RESET}\n")
        sys.exit(0)
