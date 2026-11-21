import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/datasources/finance_mock_data_source.dart';
import '../../domain/entities/finance_entities.dart';

/// Farmer Quotations Screen (Commercial review and approval).
/// Allows the farmer to inspect itemized hardware, services, taxes,
/// and officially accept or decline commercial quotations.
class FarmerQuotationsScreen extends StatefulWidget {
  final String? farmerId;

  const FarmerQuotationsScreen({super.key, this.farmerId});

  @override
  State<FarmerQuotationsScreen> createState() => _FarmerQuotationsScreenState();
}

class _FarmerQuotationsScreenState extends State<FarmerQuotationsScreen> {
  final FinanceMockDataSource _financeDataSource = FinanceMockDataSource();

  @override
  void initState() {
    super.initState();
    _financeDataSource.addListener(_onDataChanged);
  }

  @override
  void dispose() {
    _financeDataSource.removeListener(_onDataChanged);
    super.dispose();
  }

  void _onDataChanged() {
    if (mounted) setState(() {});
  }

  void _respondToQuotation(CommercialQuotation quotation, bool accept) {
    final isAr = AppStrings.isArabic(context);
    final newStatus = accept ? QuotationStatus.accepted : QuotationStatus.rejected;

    _financeDataSource.updateQuotationStatus(quotation.id, newStatus);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: accept ? AppColors.primaryGreen : Colors.redAccent,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Text(
          accept
              ? (isAr
                  ? 'تم قبول المقايسة بنجاح! تم إصدار فاتورة التركيب في سجل فواتيرك.'
                  : 'Quotation accepted! Installation invoice has been generated in your billing ledger.')
              : (isAr ? 'تم رفض عرض السعر.' : 'Quotation declined.'),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = AppStrings.isArabic(context);

    // Isolated quotations for current farmer
    final quotations = widget.farmerId != null
        ? _financeDataSource.getQuotationsForFarmer(widget.farmerId!)
        : _financeDataSource.quotations;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isAr ? 'المقايسات وعروض الأسعار' : 'Commercial Quotations',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: quotations.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.request_quote_outlined, size: 54, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      isAr ? 'لا توجد مقايسات صادرة حالياً' : 'No quotations issued yet.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: quotations.length,
                itemBuilder: (context, index) {
                  final q = quotations[index];
                  final isPendingAction = q.status == QuotationStatus.sentToFarmer;

                  return Card(
                    margin: const EdgeInsets.only(bottom: 16),
                    color: isDark ? AppColors.cardDark : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: q.status == QuotationStatus.accepted
                            ? AppColors.primaryGreen.withValues(alpha: 0.5)
                            : (isDark ? AppColors.borderDark : AppColors.borderLight),
                      ),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(q.quotationNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: q.status == QuotationStatus.accepted
                                      ? AppColors.primaryGreen.withValues(alpha: 0.15)
                                      : Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isAr ? q.status.labelAr : q.status.labelEn,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: q.status == QuotationStatus.accepted ? AppColors.primaryGreen : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(q.farmName, style: const TextStyle(fontSize: 13, color: Colors.grey)),
                          const Divider(height: 24),

                          // Itemized hardware list summary
                          Text(
                            isAr ? 'بنود العتاد والمستشعرات المطلوبة:' : 'Required Hardware & IoT Nodes:',
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(height: 8),
                          ...q.items.map((item) {
                            return Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Text('• ${isAr ? item.nameAr : item.nameEn} (×${item.quantity})', style: const TextStyle(fontSize: 12)),
                                  Text('${item.totalEgp.toStringAsFixed(0)} EGP', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                                ],
                              ),
                            );
                          }),

                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isAr ? 'رسوم التركيب والمعاينة:' : 'Installation & Survey Fees:'),
                              Text('${q.servicesSubtotalEgp.toStringAsFixed(0)} EGP', style: const TextStyle(fontWeight: FontWeight.bold)),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(isAr ? 'ضريبة القيمة المضافة (14% VAT):' : 'Egyptian VAT (14%):'),
                              Text('${q.taxAmountEgp.toStringAsFixed(2)} EGP', style: const TextStyle(color: Colors.grey)),
                            ],
                          ),
                          const Divider(height: 16),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                isAr ? 'الإجمالي النهائي:' : 'Grand Total:',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                              ),
                              Text(
                                '${q.grandTotalOneTimeEgp.toStringAsFixed(2)} EGP',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17, color: AppColors.primaryGreen),
                              ),
                            ],
                          ),

                          if (isPendingAction) ...[
                            const SizedBox(height: 18),
                            Row(
                              children: [
                                Expanded(
                                  child: OutlinedButton(
                                    style: OutlinedButton.styleFrom(foregroundColor: Colors.redAccent),
                                    onPressed: () => _respondToQuotation(q, false),
                                    child: Text(isAr ? 'رفض المقايسة' : 'Decline'),
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primaryGreen,
                                      foregroundColor: Colors.white,
                                    ),
                                    onPressed: () => _respondToQuotation(q, true),
                                    child: Text(isAr ? 'قبول واعتماد' : 'Accept Quotation'),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
