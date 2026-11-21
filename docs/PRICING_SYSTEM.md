# Green Flow – Pricing, Hardware Catalog & Quotation Engine

This document details the pricing formulas, hardware margin models, Egyptian payment gateways, and automated quotation calculations.

---

## 1. Hardware & Component Catalog

All items are stored in `FinanceMockDataSource` and categorized by function:

| Item Code | Item Name (EN / AR) | Category | Unit Cost (EGP) | Selling Price (EGP) | Margin | Default Stock |
|---|---|---|---|---|---|---|
| `prod-esp-01` | ESP32 Smart Gateway Controller<br>متحكم وبوابة ESP32 الذكية | Controller | 420.00 | 650.00 | +54.8% | 45 |
| `prod-sensor-soil` | FDR Capacitive Soil Moisture Sensor<br>مستشعر رطوبة وملوحة التربة السعوي | Sensor | 160.00 | 280.00 | +75.0% | 120 |
| `prod-sensor-dht` | Digital Temperature & Humidity Sensor<br>مستشعر حرارة ورطوبة الهواء الرقمي | Sensor | 110.00 | 190.00 | +72.7% | 80 |
| `prod-valve-solenoid` | 2-Inch Solenoid Irrigation Valve 24VAC<br>محبس ري كهرومغناطيسي 2 بوصة | Actuator | 310.00 | 490.00 | +58.1% | 65 |
| `prod-solar-panel` | 550W Monocrystalline Solar Panel<br>لوح طاقة شمسية مونوكريستال 550 واط | Solar | 4,200.00 | 5,400.00 | +28.6% | 30 |
| `prod-relay-8ch` | 8-Channel Industrial Optocoupler Relay<br>وحدة ريليه 8 قنوات معزولة ضوئياً | Controller | 180.00 | 290.00 | +61.1% | 50 |

---

## 2. Professional Engineering & Labor Services

| Service Code | Service Title | Description | Standard Rate (EGP) |
|---|---|---|---|
| `srv-survey` | Field Engineering Inspection | Topographic survey, soil depth sampling, well water test | 250.00 |
| `srv-install` | Professional IoT Installation | Mounting nodes, running shielded cables, testing antennas | 600.00 |
| `srv-commission` | Gateway Pairing & Zone Calibration | Modbus RTU binding, cloud provisioning, valve timing | 350.00 |

---

## 3. Subscription Packages

| Plan Name | Monthly Rate (EGP) | Annual Rate (EGP) | Max Farms | Max Nodes | Solar Monitoring | AI Weather Index |
|---|---|---|---|---|:---:|:---:|
| **Basic IoT Care** | 199.00 | 1,990.00 | 1 Farm | 5 Nodes | ❌ | Basic |
| **Pro Solar Farm** | 399.00 | 3,990.00 | 3 Farms | 15 Nodes | ✅ | Advanced |
| **Enterprise Agri** | 899.00 | 8,990.00 | Unlimited | Unlimited | ✅ (Multi-Inverter) | Real-time Agronomic AI |

---

## 4. Quotation Calculation Engine

The Commercial Quotation builder implements the following formula:

$$\text{Subtotal}_{\text{Hardware}} = \sum (\text{Quantity}_i \times \text{SellingPrice}_i)$$

$$\text{Subtotal}_{\text{Services}} = \sum \text{ServiceRate}_j$$

$$\text{Gross Total} = \text{Subtotal}_{\text{Hardware}} + \text{Subtotal}_{\text{Services}} - \text{Discount}$$

$$\text{Egyptian VAT (14\%)} = \text{Gross Total} \times 0.14$$

$$\text{Grand Total (One-Time)} = \text{Gross Total} + \text{Egyptian VAT}$$

### Concrete Example (Al-Amal Farm - Quote QUO-2026-089):
- 4x FDR Soil Moisture Sensors @ 280 EGP = 1,120.00 EGP
- 1x ESP32 Gateway Controller @ 650 EGP = 650.00 EGP
- 2x Solenoid Valves (2") @ 490 EGP = 980.00 EGP
- 1x Initial Engineering Field Inspection = 250.00 EGP
- 1x Professional IoT Installation Service = 600.00 EGP
- **Hardware & Labor Subtotal**: 3,600.00 EGP
- **Promotional Discount**: -200.00 EGP
- **Net Subtotal**: 3,400.00 EGP
- **Egyptian VAT (14%)**: 476.00 EGP
- **Grand Total**: **3,876.00 EGP**

---

## 5. Egyptian Payment Gateways (Simulated)

All transactions in the demo environment support real-world Egyptian payment channels:
1. **Paymob**: Cards (Visa / Mastercard), digital wallets.
2. **Fawry**: Reference payment codes (Pay at retail POS).
3. **InstaPay**: Instant bank-to-bank settlement via Central Bank of Egypt IPN network.
4. **Vodafone Cash**: Mobile wallet debit with instant SMS confirmation simulation.
