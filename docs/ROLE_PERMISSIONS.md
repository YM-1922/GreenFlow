# Green Flow – Role-Based Access Control & Permissions Matrix

This document defines the Role-Based Access Control (RBAC) security architecture of the Green Flow Smart Agriculture IoT platform.

---

## 1. Primary Roles Overview

| Role | Identifier | Public Registration? | Description |
|---|---|---|---|
| **Super Admin** | `UserRole.superAdmin` | ❌ No (Predefined & protected) | Full administrative access to the entire system, team members, farmer approvals, and platform configurations. |
| **Farm Owner (Farmer)** | `UserRole.farmOwner` | ✅ Yes (Subject to Admin review) | Manages own farms, irrigation scheduling, telemetry, quotations, invoices, and field inspection requests. |
| **Field Technician** | `UserRole.technician` | ❌ No (Created by Super Admin) | Performs field engineering surveys, technical assessments, hardware installations, and node commissioning. |
| **Agricultural Worker** | `UserRole.farmWorker` | ❌ No (Created by Super Admin) | Executes daily field operations, irrigation rounds, and maintenance checklists for assigned farms. |
| **Finance & Pricing Manager** | `UserRole.financeManager` | ❌ No (Created by Super Admin) | Manages pricing catalogs, hardware margins, commercial quotations, Egyptian payment processing, and billing ledgers. |

---

## 2. Granular Permissions Matrix

| Capability / Module | Super Admin | Farm Owner (Farmer) | Field Technician | Farm Worker | Finance Manager |
|---|:---:|:---:|:---:|:---:|:---:|
| **Access System Admin Console** | ✅ Full | ❌ Denied | ❌ Denied | ❌ Denied | ❌ Denied |
| **Create & Manage User Accounts** | ✅ Full | ❌ Denied | ❌ Denied | ❌ Denied | ❌ Denied |
| **Approve / Reject Farmer Registrations** | ✅ Full | ❌ Denied | ❌ Denied | ❌ Denied | ❌ Denied |
| **Suspend / Reactivate User Accounts** | ✅ Full | ❌ Denied | ❌ Denied | ❌ Denied | ❌ Denied |
| **View All Farms in System** | ✅ All | ❌ Own Only | ❌ Assigned Only | ❌ Assigned Only | ✅ All (Financial) |
| **Add / Edit / Delete Farms** | ✅ Full | ✅ Own Farms | ❌ Denied | ❌ Denied | ❌ Denied |
| **Request Technical Field Survey** | ✅ Full | ✅ Own Farms | ❌ Denied | ❌ Denied | ❌ Denied |
| **Conduct Technical Field Assessment** | ✅ Full | ❌ Denied | ✅ Assigned Tasks | ❌ Denied | ❌ Denied |
| **Access Finance & Pricing Console** | ✅ Full | ❌ Denied | ❌ Denied | ❌ Denied | ✅ Full |
| **Manage Hardware & Service Catalog** | ✅ Full | ❌ Denied | ❌ Denied | ❌ Denied | ✅ Full |
| **Prepare & Issue Quotations** | ✅ Full | ❌ Denied | ❌ Denied | ❌ Denied | ✅ Full |
| **Accept / Reject Quotations** | ✅ Full | ✅ Own Quotes | ❌ Denied | ❌ Denied | ❌ Denied |
| **Simulate Invoice Payments** | ✅ Full | ✅ Own Invoices | ❌ Denied | ❌ Denied | ✅ Full |
| **Access Field Technician Dashboard** | ✅ Full | ❌ Denied | ✅ Full | ❌ Denied | ❌ Denied |
| **Access Worker Checklist Dashboard** | ✅ Full | ❌ Denied | ❌ Denied | ✅ Full | ❌ Denied |
| **Operate Farm Irrigation Valves & Pumps** | ✅ Full | ✅ Own Zones | ❌ Denied | ✅ Assigned Zones | ❌ Denied |
| **Solar Energy & Inverter Monitoring** | ✅ Full | ✅ Own (Pro Plan) | ❌ Denied | ❌ Denied | ❌ Denied |
| **Self-Change Assigned Role** | ❌ Strictly Prohibited | ❌ Strictly Prohibited | ❌ Strictly Prohibited | ❌ Strictly Prohibited | ❌ Strictly Prohibited |

---

## 3. Security Implementation Architecture

### 3.1 Centralized Authorization Service (`PermissionService`)
Found in `lib/core/auth/permission_service.dart`.
Every sensitive action, route dispatch, and data query evaluates against `PermissionService`:
- `canAccessSuperAdmin(UserRole role)`
- `canManageUsers(UserRole role)`
- `canApproveFarmers(UserRole role)`
- `canAccessFinance(UserRole role)`
- `canManagePricing(UserRole role)`
- `canManageQuotations(UserRole role)`
- `canManageInvoices(UserRole role)`
- `canAccessTechnicianDashboard(UserRole role)`
- `canAccessWorkerDashboard(UserRole role)`
- `canManageFarms(UserRole role)`
- `canAccessFarm(UserAccount user, String farmId)`

### 3.2 Route Guards & Navigation Integrity
In `lib/app/routes/app_routes.dart`:
- Direct URL/named-route navigation to `/admin`, `/finance`, `/technician`, or `/worker` checks the authenticated user's session.
- Unauthorized attempts are immediately redirected to `_accessDeniedRoute`, displaying a clear security warning with an option to return to the authorized dashboard.

### 3.3 Data Isolation Policy
- **Farmer Isolation**: A farmer query returns only records matching `user.id == quotation.farmerId` or `farm.id == user.assignedFarmId`. No farmer can view another farmer's telemetry, water usage, or commercial invoices.
- **Worker & Technician Scoping**: Workers and technicians are constrained strictly to farms enumerated in `user.assignedFarmIds`.
