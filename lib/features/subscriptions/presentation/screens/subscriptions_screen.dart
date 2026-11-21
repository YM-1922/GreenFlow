import 'package:flutter/material.dart';
import '../../data/datasources/subscription_mock_data_source.dart';
import '../../domain/entities/subscription_entities.dart';
import '../widgets/payment_method_sheet.dart';

class SubscriptionsScreen extends StatefulWidget {
  const SubscriptionsScreen({super.key});

  @override
  State<SubscriptionsScreen> createState() => _SubscriptionsScreenState();
}

class _SubscriptionsScreenState extends State<SubscriptionsScreen> {
  static const Color _primaryGreen = Color(0xFF10B981);
  static const Color _primaryGreenDark = Color(0xFF059669);
  static const Color _navyBlue = Color(0xFF0F172A);
  static const Color _cyanAccent = Color(0xFF06B6D4);
  static const Color _gold = Color(0xFFF59E0B);

  late final List<SubscriptionPlanEntity> _plans;
  late final CustomerSubscriptionEntity _customer;

  bool get _isArabic {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar';
  }

  @override
  void initState() {
    super.initState();
    _plans = SubscriptionMockDataSource.getPlans();
    _customer = SubscriptionMockDataSource.getCustomerSubscription();
  }

  String _t(String en, String ar) {
    try {
      return _isArabic ? ar : en;
    } catch (_) {
      return en;
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E293B) : Colors.white;
    final surfaceColor = isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC);

    return Scaffold(
      backgroundColor: surfaceColor,
      appBar: AppBar(
        title: Text(
          _t('Subscription & Billing', 'الاشتراك والفواتير'),
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? _navyBlue : _primaryGreen,
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => showPaymentMethodSheet(context, _customer.paymentHistory
            .where((p) => p.status == PaymentStatus.pending)
            .fold(0.0, (sum, p) => sum + p.amountEgp)),
        backgroundColor: _primaryGreen,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.payment),
        label: Text(_t('Make Payment', 'إجراء الدفع')),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildCurrentPlanCard(cardColor, isDark),
            const SizedBox(height: 16),
            _buildHardwareFeeCard(cardColor, isDark),
            const SizedBox(height: 24),
            _buildSectionTitle(_t('Available Plans', 'الخطط المتاحة'), isDark),
            const SizedBox(height: 12),
            ..._plans.map((plan) => Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildPlanCard(plan, cardColor, isDark),
                )),
            const SizedBox(height: 8),
            _buildSectionTitle(_t('Payment History', 'سجل المدفوعات'), isDark),
            const SizedBox(height: 12),
            _buildPaymentHistory(cardColor, isDark),
            const SizedBox(height: 80),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : _navyBlue,
      ),
    );
  }

  Widget _buildCurrentPlanCard(Color cardColor, bool isDark) {
    final daysLeft = _customer.nextRenewalDate.difference(DateTime.now()).inDays;
    final currentPlan = _plans.firstWhere(
      (p) => p.tier == _customer.currentTier,
      orElse: () => _plans.first,
    );

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [_primaryGreen, _primaryGreenDark],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: _primaryGreen.withAlpha(76),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.verified, color: Colors.white, size: 20),
              const SizedBox(width: 8),
              Text(
                _t('Current Plan', 'الخطة الحالية'),
                style: const TextStyle(color: Colors.white70, fontSize: 13),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _customer.isActive
                      ? Colors.white.withAlpha(51)
                      : Colors.red.withAlpha(76),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white54),
                ),
                child: Text(
                  _customer.isActive
                      ? _t('Active', 'نشط')
                      : _t('Inactive', 'غير نشط'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            _t(currentPlan.nameEn, currentPlan.nameAr),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _t(currentPlan.descEn, currentPlan.descAr),
            style: const TextStyle(color: Colors.white70, fontSize: 13),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _buildInfoChip(
                Icons.attach_money,
                '${currentPlan.monthlyPriceEgp.toInt()} ${_t('EGP/mo', 'ج.م/شهر')}',
              ),
              const SizedBox(width: 12),
              _buildInfoChip(
                Icons.refresh,
                '$daysLeft ${_t('days left', 'يوم متبقي')}',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(IconData icon, String label) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withAlpha(38),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 4),
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHardwareFeeCard(Color cardColor, bool isDark) {
    final isPaid = _customer.outstandingHardwareFee <= 0;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isPaid
              ? _primaryGreen.withAlpha(76)
              : _gold.withAlpha(76),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: (isPaid ? _primaryGreen : _gold).withAlpha(26),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              Icons.hardware,
              color: isPaid ? _primaryGreen : _gold,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t('One-time Hardware Fee', 'رسوم الأجهزة لمرة واحدة'),
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: isDark ? Colors.white : _navyBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  isPaid
                      ? _t('Fully paid – no outstanding balance',
                          'مدفوع بالكامل – لا رصيد متأخر')
                      : _t(
                          'Outstanding: ${_customer.outstandingHardwareFee.toInt()} EGP',
                          'متأخر: ${_customer.outstandingHardwareFee.toInt()} ج.م',
                        ),
                  style: TextStyle(
                    fontSize: 12,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: (isPaid ? _primaryGreen : _gold).withAlpha(26),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              isPaid ? _t('Paid', 'مدفوع') : _t('Due', 'مستحق'),
              style: TextStyle(
                color: isPaid ? _primaryGreen : _gold,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPlanCard(SubscriptionPlanEntity plan, Color cardColor, bool isDark) {
    final isCurrentPlan = plan.isCurrentPlan;
    final borderColor = isCurrentPlan
        ? _primaryGreen
        : plan.isPopular
            ? _gold
            : (isDark ? Colors.white12 : Colors.grey[200]!);

    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderColor, width: isCurrentPlan ? 2 : 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (plan.isPopular)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(vertical: 6),
              decoration: BoxDecoration(
                color: _gold,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(14),
                  topRight: Radius.circular(14),
                ),
              ),
              child: Text(
                '⭐ ${_t('Most Popular', 'الأكثر شعبية')}',
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
            ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _t(plan.nameEn, plan.nameAr),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                              color: isDark ? Colors.white : _navyBlue,
                            ),
                          ),
                          Text(
                            _t(plan.descEn, plan.descAr),
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white60 : Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          '${plan.monthlyPriceEgp.toInt()}',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isCurrentPlan ? _primaryGreen : (isDark ? Colors.white : _navyBlue),
                          ),
                        ),
                        Text(
                          _t('EGP/mo', 'ج.م/شهر'),
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _t(
                    'Hardware: ${plan.hardwarePriceEgp.toInt()} EGP (one-time)',
                    'الأجهزة: ${plan.hardwarePriceEgp.toInt()} ج.م (مرة واحدة)',
                  ),
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white38 : Colors.grey[500],
                  ),
                ),
                const SizedBox(height: 12),
                Divider(color: isDark ? Colors.white12 : Colors.grey[200]),
                const SizedBox(height: 8),
                ...((_isArabic ? plan.featuresAr : plan.featuresEn)).map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Icon(Icons.check_circle, color: _primaryGreen, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            feature,
                            style: TextStyle(
                              fontSize: 13,
                              color: isDark ? Colors.white70 : Colors.grey[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: isCurrentPlan
                      ? Container(
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          decoration: BoxDecoration(
                            color: _primaryGreen.withAlpha(26),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Text(
                            _t('✓ Current Plan', '✓ الخطة الحالية'),
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: _primaryGreen,
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                        )
                      : ElevatedButton(
                          onPressed: () => _showUpgradeDialog(plan),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: plan.isPopular ? _gold : _cyanAccent,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          child: Text(
                            _t('Upgrade', 'ترقية'),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showUpgradeDialog(SubscriptionPlanEntity plan) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_t('Upgrade Plan', 'ترقية الخطة')),
        content: Text(
          _t(
            'Switch to ${plan.nameEn} for ${plan.monthlyPriceEgp.toInt()} EGP/month?\n\nThis is a demo – no actual charge will be made.',
            'الانتقال إلى ${plan.nameAr} مقابل ${plan.monthlyPriceEgp.toInt()} ج.م/شهر؟\n\nهذا عرض توضيحي – لن يتم أي خصم فعلي.',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text(_t('Cancel', 'إلغاء')),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(_t(
                    '🧪 Demo: Upgrade to ${plan.nameEn} initiated',
                    '🧪 تجريبي: بدأت ترقية إلى ${plan.nameAr}',
                  )),
                  backgroundColor: _primaryGreen,
                ),
              );
            },
            style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen),
            child: Text(_t('Confirm', 'تأكيد'),
                style: const TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  Widget _buildPaymentHistory(Color cardColor, bool isDark) {
    final payments = _customer.paymentHistory.reversed.take(5).toList();
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha(13),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        children: payments.asMap().entries.map((entry) {
          final i = entry.key;
          final payment = entry.value;
          final isLast = i == payments.length - 1;
          return Column(
            children: [
              _buildPaymentRow(payment, isDark),
              if (!isLast)
                Divider(
                  height: 1,
                  color: isDark ? Colors.white12 : Colors.grey[200],
                  indent: 64,
                ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildPaymentRow(PaymentRecordEntity payment, bool isDark) {
    final statusColor = switch (payment.status) {
      PaymentStatus.paid => _primaryGreen,
      PaymentStatus.pending => _gold,
      PaymentStatus.failed => Colors.red,
      PaymentStatus.refunded => _cyanAccent,
    };

    final methodIcon = switch (payment.method) {
      PaymentMethod.paymobCard => Icons.credit_card,
      PaymentMethod.paymobWallet => Icons.account_balance_wallet,
      PaymentMethod.fawry => Icons.store,
      PaymentMethod.instaPay => Icons.send,
      PaymentMethod.vodafoneCash => Icons.phone_android,
    };

    final methodLabel = switch (payment.method) {
      PaymentMethod.paymobCard => _t('Paymob Card', 'بطاقة بيموب'),
      PaymentMethod.paymobWallet => _t('Paymob Wallet', 'محفظة بيموب'),
      PaymentMethod.fawry => _t('Fawry', 'فوري'),
      PaymentMethod.instaPay => _t('InstaPay', 'انستا باي'),
      PaymentMethod.vodafoneCash => _t('Vodafone Cash', 'فودافون كاش'),
    };

    final statusLabel = switch (payment.status) {
      PaymentStatus.paid => _t('Paid', 'مدفوع'),
      PaymentStatus.pending => _t('Pending', 'معلق'),
      PaymentStatus.failed => _t('Failed', 'فاشل'),
      PaymentStatus.refunded => _t('Refunded', 'مسترد'),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: statusColor.withAlpha(26),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(methodIcon, color: statusColor, size: 20),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _t(payment.descriptionEn, payment.descriptionAr),
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                    color: isDark ? Colors.white : _navyBlue,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '$methodLabel · ${_formatDate(payment.date)}',
                  style: TextStyle(
                    fontSize: 11,
                    color: isDark ? Colors.white60 : Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${payment.amountEgp.toInt()} ${_t('EGP', 'ج.م')}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : _navyBlue,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: statusColor.withAlpha(26),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  statusLabel,
                  style: TextStyle(
                    color: statusColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}
