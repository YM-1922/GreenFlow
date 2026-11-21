# Green Flow – Demo & Development Accounts

> **IMPORTANT SECURITY NOTICE:**
> The accounts and credentials listed below are strictly for **local testing, evaluation, and demonstration purposes**. In this prototype, passwords are encrypted using local salted hash tokens and verified through `AuthService`. Never use these demo credentials in production environments.

---

## Pre-Configured Demo Accounts

| Role | Username | Full Name (EN / AR) | Password | Account Status | Assigned Scope |
|---|---|---|---|---|---|
| **Super Admin** | `admin` | System Administrator<br>المدير العام للنظام | `SuperAdmin@2026` | `Approved` | Global Platform Control |
| **Farm Owner (Approved)** | `farmer_ahmed` | Ahmed Al-Nour<br>أحمد النور | `Farmer@2026` | `Approved` | `farm-001` (Al-Amal Farm) |
| **Farm Owner (Pending)** | `farmer_khalid` | Khalid Al-Mansoor<br>خالد المنصور | `Pending@2026` | `PendingApproval` | Awaiting Admin Approval |
| **Field Technician** | `tech_kareem` | Kareem Mahmoud<br>م. كريم محمود | `Tech@2026` | `Approved` | `farm-001`, `farm-002` |
| **Agricultural Worker** | `worker_hassan` | Hassan Ibrahim<br>عم حسن إبراهيم | `Worker@2026` | `Approved` | `farm-001` (Al-Amal Farm) |
| **Finance Manager** | `finance_mona` | Mona Al-Sayed<br>أ. منى السيد | `Finance@2026` | `Approved` | Billing & Pricing Catalog |

---

## How to Test Each Role

### 1. Super Admin Experience
1. Open the app and navigate to the **Sign In** screen.
2. Tap the **Super Admin** demo chip (or enter username: `admin`, password: `SuperAdmin@2026`).
3. Tap **Sign In**.
4. You are routed to the **Super Admin Management Console** (`/admin`).
5. **Key Tests**:
   - Review overview KPIs (Total Accounts, Pending Farmers, Active Farms, Quotations).
   - Review pending farmer registrations and tap **Approve** or **Reject**.
   - Review the **User Directory** and toggle user active/suspended status with the real-time switch.
   - Tap the **+** button in the AppBar to open the **Create User Account** dialog, generate temporary credentials, and assign internal roles.

### 2. Approved Farmer Experience
1. On the **Sign In** screen, tap the **Farmer** demo chip (username: `farmer_ahmed`, password: `Farmer@2026`).
2. Tap **Sign In**.
3. You are routed to the **Farmer Dashboard** (`/home`).
4. **Key Tests**:
   - View telemetry for Al-Amal Farm (45 Feddans, Olive & Date Palms).
   - Check soil moisture, temperature, humidity, and water consumption.
   - Control zone irrigation valves.
   - Access **Weather AI** recommendations and **Subscriptions**.

### 3. Pending Farmer Experience
1. On the **Sign In** screen, tap the **Pending** demo chip (username: `farmer_khalid`, password: `Pending@2026`).
2. Tap **Sign In**.
3. You are routed directly to the **Approval Waiting Room** (`/approvalWaiting`).
4. **Key Tests**:
   - Notice that access to the main dashboard is restricted until approved.
   - Tap **Simulate Approval & Enter Dashboard** to instantly test the approval transition.

### 4. Field Technician Experience
1. On the **Sign In** screen, tap the **Technician** demo chip (username: `tech_kareem`, password: `Tech@2026`).
2. Tap **Sign In**.
3. You are routed directly to the **Field Technician Dashboard** (`/technicianDashboard`).
4. **Key Tests**:
   - View assigned farms and engineering surveys.
   - Tap an inspection request to open the **Technical Assessment Form**.
   - Fill out engineering notes and submit the assessment to forward it to Finance.

### 5. Agricultural Worker Experience
1. On the **Sign In** screen, tap the **Worker** demo chip (username: `worker_hassan`, password: `Worker@2026`).
2. Tap **Sign In**.
3. You are routed directly to the **Agricultural Worker Dashboard** (`/workerDashboard`).
4. **Key Tests**:
   - View assigned farm hero banner and details.
   - Tap **Open Assigned Farm Irrigation Controls** for direct irrigation shortcut.
   - Check off completed daily field tasks in the interactive checklist.

### 6. Finance & Pricing Manager Experience
1. On the **Sign In** screen, tap the **Finance** demo chip (username: `finance_mona`, password: `Finance@2026`).
2. Tap **Sign In**.
3. You are routed directly to the **Finance & Pricing Dashboard** (`/financeDashboard`).
4. **Key Tests**:
   - View total revenue, recurring subscription revenue, and installation revenue.
   - Browse the **Hardware Catalog** with cost, selling price, and profit margins.
   - Review **Commercial Quotations** with automated 14% Egyptian VAT calculation.
   - View **Invoices & Payments** ledger and tap unpaid invoices to simulate payment via Paymob, Fawry, InstaPay, or Vodafone Cash.
