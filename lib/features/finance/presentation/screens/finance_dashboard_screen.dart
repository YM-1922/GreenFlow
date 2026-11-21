import 'package:flutter/material.dart';
import '../../../../app/routes/app_routes.dart';
import '../../../../core/auth/auth.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/datasources/finance_mock_data_source.dart';
import '../../domain/entities/finance_entities.dart';

/// Dedicated Dashboard for Finance & Pricing Manager.
/// Manages Products catalog, Services pricing, Quotations builder, and Invoices.
class FinanceDashboardScreen extends StatefulWidget {
  const FinanceDashboardScreen({super.key});

  @override
  State<FinanceDashboardScreen> createState() => _FinanceDashboardScreenState();
}

class _FinanceDashboardScreenState extends State<FinanceDashboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final FinanceMockDataSource _financeDataSource = FinanceMockDataSource();
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _financeDataSource.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _financeDataSource.removeListener(_onDataChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  void _openAddProductDialog() {
    final isAr = AppStrings.isArabic(context);
    final nameEnCtrl = TextEditingController();
    final nameArCtrl = TextEditingController();
    final costCtrl = TextEditingController();
    final priceCtrl = TextEditingController();
    final stockCtrl = TextEditingController(text: '20');

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isAr ? 'إضافة منتج / مكون للأجهزة' : 'Add Hardware Component'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameEnCtrl,
                decoration: const InputDecoration(labelText: 'Name (English)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: nameArCtrl,
                decoration: const InputDecoration(labelText: 'الاسم (بالعربية)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: costCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Cost Price / سعر التكلفة (EGP)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: priceCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Selling Price / سعر البيع (EGP)'),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: stockCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Available Stock / الكمية المتاحة'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text(isAr ? 'إلغاء' : 'Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
            onPressed: () {
              final newProd = ProductEntity(
                id: 'prod-${DateTime.now().millisecondsSinceEpoch}',
                nameEn: nameEnCtrl.text.trim().isNotEmpty ? nameEnCtrl.text.trim() : 'IoT Node',
                nameAr: nameArCtrl.text.trim().isNotEmpty ? nameArCtrl.text.trim() : 'عقدة مستشعر',
                category: ProductCategory.sensor,
                descriptionEn: 'Smart agricultural sensor module',
                descriptionAr: 'مستشعر ذكي لشبكة الري',
                unit: 'Unit / قطعة',
                costPriceEgp: double.tryParse(costCtrl.text) ?? 150.0,
                sellingPriceEgp: double.tryParse(priceCtrl.text) ?? 250.0,
                stockQuantity: int.tryParse(stockCtrl.text) ?? 20,
              );
              _financeDataSource.addProduct(newProd);
              Navigator.pop(ctx);
            },
            child: Text(isAr ? 'حفظ' : 'Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = AppStrings.isArabic(context);

    final products = _financeDataSource.products;
    final quotations = _financeDataSource.quotations;
    final invoices = _financeDataSource.invoices;

    final totalRevenue = invoices.where((i) => i.isPaid).fold(0.0, (sum, i) => sum + i.amountEgp);

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isAr ? 'الإدارة المالية والتسعير' : 'Finance & Pricing Dashboard',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            tooltip: isAr ? 'خروج' : 'Logout',
            onPressed: () {
              _authService.logout();
              Navigator.of(context).pushReplacementNamed(AppRoutes.login);
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.primaryGreen,
          labelColor: AppColors.primaryGreen,
          isScrollable: true,
          tabs: [
            Tab(text: isAr ? 'نظرة مالية عامة' : 'Revenue Overview'),
            Tab(text: isAr ? 'كتالوج المنتجات والأسعار' : 'Hardware Catalog'),
            Tab(text: isAr ? 'المقايسات وعروض الأسعار' : 'Quotations Builder'),
            Tab(text: isAr ? 'الفواتير والتحصيل' : 'Invoices & Payments'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab 1: Financial Overview
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF1E293B), const Color(0xFF0F172A)]
                        : [const Color(0xFFECFDF5), Colors.white],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.primaryGreen.withValues(alpha: 0.3)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isAr ? 'إجمالي الإيرادات المحصلة' : 'Total Collected Revenue',
                      style: const TextStyle(fontSize: 13, color: Colors.grey),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      '${totalRevenue.toStringAsFixed(2)} ${isAr ? "ج.م" : "EGP"}',
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      isAr
                          ? 'شامل مبيعات الأجهزة، التركيبات، والاشتراكات الشهرية المعتمدة'
                          : 'Includes hardware sales, labor commissioning & active recurring subscriptions',
                      style: const TextStyle(fontSize: 11, color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _MetricCard(
                    title: isAr ? 'عروض معتمدة' : 'Accepted Quotes',
                    value: '${quotations.where((q) => q.status == QuotationStatus.accepted).length}',
                    color: AppColors.primaryGreen,
                  ),
                  const SizedBox(width: 12),
                  _MetricCard(
                    title: isAr ? 'فواتير معلقة' : 'Pending Invoices',
                    value: '${invoices.where((i) => !i.isPaid).length}',
                    color: const Color(0xFFF59E0B),
                  ),
                ],
              ),
            ],
          ),

          // Tab 2: Hardware & Pricing Catalog
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    isAr ? 'قائمة المنتجات وهامش الربح' : 'Catalog & Profit Margins',
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryGreen, foregroundColor: Colors.white),
                    icon: const Icon(Icons.add, size: 16),
                    label: Text(isAr ? 'إضافة منتج' : 'Add Item'),
                    onPressed: _openAddProductDialog,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...products.map((p) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 10),
                  color: isDark ? AppColors.cardDark : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                    side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: ListTile(
                    title: Text(isAr ? p.nameAr : p.nameEn, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text(
                      '${isAr ? "تكلفة:" : "Cost:"} ${p.costPriceEgp} EGP • ${isAr ? "بيع:" : "Selling:"} ${p.sellingPriceEgp} EGP (${p.profitMarginPercent.toStringAsFixed(0)}% Margin)',
                    ),
                    trailing: Text(
                      '${p.stockQuantity} ${isAr ? "قطعة" : "Units"}',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                    ),
                  ),
                );
              }),
            ],
          ),

          // Tab 3: Quotations Builder
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                isAr ? 'عروض الأسعار والمقايسات الصادرة' : 'Issued Commercial Quotations',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...quotations.map((q) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isDark ? AppColors.cardDark : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(q.quotationNumber, style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text(
                              isAr ? q.status.labelAr : q.status.labelEn,
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: q.status == QuotationStatus.accepted ? AppColors.primaryGreen : Colors.orange,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 6),
                        Text('${q.farmerName} • ${q.farmName}', style: const TextStyle(fontSize: 13, color: Colors.grey)),
                        const Divider(height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(isAr ? 'الإجمالي (شامل الضريبة 14%):' : 'Grand Total (incl. 14% VAT):'),
                            Text(
                              '${q.grandTotalOneTimeEgp.toStringAsFixed(2)} EGP',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primaryGreen),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              }),
            ],
          ),

          // Tab 4: Invoices & Payments
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text(
                isAr ? 'سجل الفواتير وعمليات الدفع المحاكية' : 'Invoices & Simulated Payments Ledger',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              ...invoices.map((inv) {
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  color: isDark ? AppColors.cardDark : Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: isDark ? AppColors.borderDark : AppColors.borderLight),
                  ),
                  child: ListTile(
                    leading: Icon(
                      inv.isPaid ? Icons.check_circle_rounded : Icons.pending_rounded,
                      color: inv.isPaid ? AppColors.primaryGreen : Colors.orange,
                      size: 28,
                    ),
                    title: Text('${inv.invoiceNumber} • ${inv.farmerName}'),
                    subtitle: Text('${inv.amountEgp.toStringAsFixed(2)} EGP • ${isAr ? inv.paymentMethodAr : inv.paymentMethodEn}'),
                    trailing: inv.isPaid
                        ? Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: AppColors.primaryGreen.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              isAr ? 'مدفوعة' : 'Paid',
                              style: const TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.bold, fontSize: 11),
                            ),
                          )
                        : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.primaryGreen,
                              foregroundColor: Colors.white,
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                            ),
                            onPressed: () {
                              _financeDataSource.simulateInvoicePayment(inv.id, 'Paymob Card', 'بطاقة فيزا بيموب');
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(isAr ? 'تم تسجيل تحصيل الفاتورة تجريبياً' : 'Simulated payment recorded successfully'),
                                  backgroundColor: AppColors.primaryGreen,
                                ),
                              );
                            },
                            child: Text(isAr ? 'تسجيل سداد' : 'Record Pay'),
                          ),
                  ),
                );
              }),
            ],
          ),
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _MetricCard({required this.title, required this.value, required this.color});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
          ],
        ),
      ),
    );
  }
}
