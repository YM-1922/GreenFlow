# Green Flow – End-to-End Business Operations Workflow

This document illustrates the complete operational lifecycle connecting Farmers, Field Technicians, the Finance Manager, and the Super Admin.

---

## 1. Lifecycle State Machines

### 1.1 Farmer Account Lifecycle
```
[Public Registration]
        │
        ▼
   PendingApproval ──(Admin Reject)──► Rejected
        │
   (Admin Approve)
        │
        ▼
     Approved ◄──► Suspended ──► Inactive
```

### 1.2 Field Inspection Request Lifecycle
```
[Farmer Request]
        │
        ▼
    Pending ──► Scheduled ──► InProgress
                                  │
                                  ▼
                         InspectionCompleted ──► QuotationPending ──► Approved
```

### 1.3 Commercial Quotation Lifecycle
```
[Finance Draft from Technical Assessment]
        │
        ▼
  PendingApproval ──► SentToFarmer
                           │
             ┌─────────────┴─────────────┐
             ▼                           ▼
          Accepted                    Rejected
             │
      (Auto-Generates Invoice)
```

### 1.4 Invoice & Payment Lifecycle
```
[Invoice Issued]
        │
        ▼
      Issued ──► PartiallyPaid ──► Paid (via Paymob/InstaPay/Fawry/Vodafone)
        │
    (Overdue)
        │
        ▼
     Overdue / Cancelled
```

---

## 2. Step-by-Step Workflow Scenario

```mermaid
sequenceDiagram
    autonumber
    actor Farmer as Farm Owner
    actor Admin as Super Admin
    actor Tech as Field Technician
    actor Finance as Finance Manager

    Farmer->>Admin: 1. Submits Registration (Pending Approval)
    Admin->>Farmer: 2. Approves Account & Assigns Farm (farm-001)
    Farmer->>Admin: 3. Requests On-Site Farm Inspection
    Admin->>Tech: 4. Schedules & Assigns Inspection Task
    Tech->>Tech: 5. Conducts Field Survey & Root Depth Tests
    Tech->>Finance: 6. Submits Technical Assessment & Hardware Needs
    Finance->>Finance: 7. Builds Quotation (Hardware + Margin + Services + 14% VAT)
    Finance->>Farmer: 8. Issues Commercial Quotation (QUO-2026-089)
    Farmer->>Finance: 9. Reviews & Accepts Quotation
    Finance->>Farmer: 10. Generates Hardware/Installation Invoice (INV-2026-101)
    Farmer->>Finance: 11. Simulates Payment via InstaPay / Vodafone Cash
    Admin->>Tech: 12. Authorizes Field Installation & ESP32 Commissioning
    Tech->>Farmer: 13. Pairs IoT Nodes & Activates Automatic Monitoring
    Farmer->>Farmer: 14. Monitors Soil Moisture, Weather AI & Controls Valves
```

---

## 3. Data Integrity & Sync Across Dashboards

1. **Shared Single Source of Truth**:
   All entities are governed by centralized singleton data sources:
   - `AuthService`: Manages accounts, sessions, and role credentials.
   - `FarmsMockDataSource`: Manages farms, zones, and inspection requests.
   - `FinanceMockDataSource`: Manages product catalogs, commercial quotations, and invoices.

2. **Reactive Notification & State Updates**:
   - When a farmer accepts a quotation, `FinanceMockDataSource.updateQuotationStatus()` automatically creates an associated `InvoiceEntity` and notifies all listeners.
   - When an invoice is paid, the status instantly reflects on both the Farmer's billing page and the Finance Manager's revenue metrics.
