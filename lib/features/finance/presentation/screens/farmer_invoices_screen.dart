import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_strings.dart';
import '../../data/datasources/finance_mock_data_source.dart';
import '../../domain/entities/finance_entities.dart';

/// Farmer Invoices & Payment History Screen.
/// Displays itemized invoices, payment status, and supports simulated payments
/// via Egyptian payment channels (Paymob, Fawry, InstaPay, Vodafone Cash).
class FarmerInvoicesScreen extends StatefulWidget {
  final String? farmerId;

  const FarmerInvoicesScreen({super.key, this.farmerId});

  @override
  State<FarmerInvoicesScreen> createState() => _FarmerInvoicesScreenState();
}

class _FarmerInvoicesScreenState extends State<FarmerInvoicesScreen> {
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

  void _openPaymentDialog(InvoiceEntity invoice) {
    final isAr = AppStrings.isArabic(context);

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isAr ? 'سداد الفاتورة (محاكاة مصرية)' : 'Simulate Egyptian Payment',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  '${invoice.amountEgp.toStringAsFixed(2)} EGP',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.primaryGreen, fontSize: 16),
                ),
              ],
            ),
            const SizedBox(height: 6),
            Text(
              isAr ? 'اختر وسيلة الدفع المحلية المرغوبة:' : 'Select preferred Egyptian payment method:',
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const Divider(height: 24),

            _paymentOptionTile(
              title: 'InstaPay Transfer (شبكة المدفوعات اللحظية)',
              subtitle: 'Direct bank transfer / تحويل فوري',
              icon: Icons.account_balance_rounded,
              color: const Color(0xFF8B5CF6),
              onTap: () {
                Navigator.pop(ctx);
                _executeSimulatedPayment(invoice.id, 'InstaPay Transfer', 'تحويل شبكة انستاباي');
              },
            ),
            const SizedBox(height: 8),

            _paymentOptionTile(
              title: 'Vodafone Cash / Orange / Etisalat',
              subtitle: 'Mobile Wallet / المحافظ الإلكترونية',
              icon: Icons.phone_android_rounded,
              color: Colors.redAccent,
              onTap: () {
                Navigator.pop(ctx);
                _executeSimulatedPayment(invoice.id, 'Vodafone Cash Wallet', 'محفظة فودافون كاش');
              },
            ),
            const SizedBox(height: 8),

            _paymentOptionTile(
              title: 'Fawry Code (فوري)',
              subtitle: 'Pay at any retail POS / كود دفع فوري',
              icon: Icons.storefront_rounded,
              color: Colors.amber.shade800,
              onTap: () {
                Navigator.pop(ctx);
                _executeSimulatedPayment(invoice.id, 'Fawry Pay', 'مدفوعات فوري');
              },
            ),
            const SizedBox(height: 8),

            _paymentOptionTile(
              title: 'Paymob / Visa & Mastercard',
              subtitle: 'Debit or Credit Card / بطاقة بنكية',
              icon: Icons.credit_card_rounded,
              color: AppColors.flowBlue,
              onTap: () {
                Navigator.pop(ctx);
                _executeSimulatedPayment(invoice.id, 'Paymob Card Gateway', 'بوابة بي موب للبطاقات');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _paymentOptionTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return ListTile(
      tileColor: color.withValues(alpha: 0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(icon, color: color),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 11, color: Colors.grey)),
      trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14),
      onTap: onTap,
    );
  }

  void _executeSimulatedPayment(String invoiceId, String methodEn, String methodAr) {
    final isAr = AppStrings.isArabic(context);
    _financeDataSource.simulateInvoicePayment(invoiceId, methodEn, methodAr);

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: AppColors.primaryGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        content: Row(
          children: [
            const Icon(Icons.check_circle_rounded, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isAr
                    ? 'تم سداد الفاتورة بنجاح عبر $methodAr (محاكاة تجريبية)'
                    : 'Payment recorded via $methodEn (Demo simulation)',
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isAr = AppStrings.isArabic(context);

    final invoices = widget.farmerId != null
        ? _financeDataSource.getInvoicesForFarmer(widget.farmerId!)
        : _financeDataSource.invoices;

    return Scaffold(
      backgroundColor: isDark ? AppColors.backgroundDark : AppColors.backgroundLight,
      appBar: AppBar(
        title: Text(
          isAr ? 'سجل الفواتير والمدفوعات' : 'Invoices & Billing History',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
        ),
      ),
      body: SafeArea(
        child: invoices.isEmpty
            ? Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.receipt_long_outlined, size: 54, color: Colors.grey),
                    const SizedBox(height: 12),
                    Text(
                      isAr ? 'لا توجد فواتير مسجلة حالياً' : 'No invoices recorded yet.',
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              )
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: invoices.length,
                itemBuilder: (context, index) {
                  final inv = invoices[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    color: isDark ? AppColors.cardDark : Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                      side: BorderSide(
                        color: inv.isPaid
                            ? AppColors.primaryGreen.withValues(alpha: 0.4)
                            : Colors.orange.withValues(alpha: 0.4),
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
                              Text(inv.invoiceNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                              Container(
                                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: inv.isPaid
                                      ? AppColors.primaryGreen.withValues(alpha: 0.15)
                                      : Colors.orange.withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Text(
                                  isAr ? inv.status.labelAr : inv.status.labelEn,
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: inv.isPaid ? AppColors.primaryGreen : Colors.orange,
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 6),
                          Text(
                            '${isAr ? inv.type.labelAr : inv.type.labelEn} • ${inv.farmName}',
                            style: const TextStyle(fontSize: 12, color: Colors.grey),
                          ),
                          const Divider(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(isAr ? 'طريقة السداد:' : 'Payment Method:', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text(
                                    isAr ? (inv.paymentMethodAr.isNotEmpty ? inv.paymentMethodAr : 'في انتظار السداد') : (inv.paymentMethodEn.isNotEmpty ? inv.paymentMethodEn : 'Pending Payment'),
                                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(isAr ? 'المبلغ المستحق:' : 'Amount Due:', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                  const SizedBox(height: 2),
                                  Text(
                                    '${inv.amountEgp.toStringAsFixed(2)} EGP',
                                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppColors.primaryGreen),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          if (!inv.isPaid) ...[
                            const SizedBox(height: 14),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.primaryGreen,
                                  foregroundColor: Colors.white,
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                                ),
                                icon: const Icon(Icons.payment_rounded, size: 18),
                                label: Text(isAr ? 'سداد الفاتورة الآن (محاكاة)' : 'Pay Invoice Now (Simulate)'),
                                onPressed: () => _openPaymentDialog(inv),
                              ),
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
