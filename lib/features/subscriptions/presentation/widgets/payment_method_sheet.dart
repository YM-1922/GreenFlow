import 'dart:math';
import 'package:flutter/material.dart';
import '../../domain/entities/subscription_entities.dart';

void showPaymentMethodSheet(BuildContext context, double amount) {
  final effectiveAmount = amount <= 0 ? 399.0 : amount;
  showModalBottomSheet(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (ctx) => _PaymentMethodSheet(amount: effectiveAmount),
  );
}

class _PaymentMethodSheet extends StatelessWidget {
  final double amount;

  const _PaymentMethodSheet({required this.amount});

  static const Color _primaryGreen = Color(0xFF10B981);
  static const Color _navyBlue = Color(0xFF0F172A);

  String _t(BuildContext context, String en, String ar) {
    final locale = Localizations.localeOf(context);
    return locale.languageCode == 'ar' ? ar : en;
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? const Color(0xFF1E293B) : Colors.white;

    final methods = [
      _PaymentOption(
        method: PaymentMethod.paymobCard,
        icon: Icons.credit_card,
        nameEn: 'Paymob – Credit/Debit Card',
        nameAr: 'بيموب – بطاقة ائتمانية/خصم',
        color: const Color(0xFF6366F1),
      ),
      _PaymentOption(
        method: PaymentMethod.paymobWallet,
        icon: Icons.account_balance_wallet,
        nameEn: 'Paymob – Mobile Wallet',
        nameAr: 'بيموب – محفظة موبايل',
        color: const Color(0xFF8B5CF6),
      ),
      _PaymentOption(
        method: PaymentMethod.fawry,
        icon: Icons.store,
        nameEn: 'Fawry Pay',
        nameAr: 'فوري باي',
        color: const Color(0xFFF97316),
      ),
      _PaymentOption(
        method: PaymentMethod.instaPay,
        icon: Icons.send,
        nameEn: 'InstaPay',
        nameAr: 'انستا باي',
        color: const Color(0xFF06B6D4),
      ),
      _PaymentOption(
        method: PaymentMethod.vodafoneCash,
        icon: Icons.phone_android,
        nameEn: 'Vodafone Cash',
        nameAr: 'فودافون كاش',
        color: const Color(0xFFEF4444),
      ),
    ];

    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(height: 12),
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _t(context, 'Choose Payment Method', 'اختر طريقة الدفع'),
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : _navyBlue,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _t(context, 'Amount to pay', 'المبلغ المراد دفعه'),
                          style: TextStyle(
                            fontSize: 12,
                            color: isDark ? Colors.white60 : Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: _primaryGreen.withAlpha(26),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: _primaryGreen.withAlpha(76)),
                    ),
                    child: Text(
                      '${amount.toInt()} ${_t(context, 'EGP', 'ج.م')}',
                      style: const TextStyle(
                        color: _primaryGreen,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            Divider(color: isDark ? Colors.white12 : Colors.grey[200], height: 1),
            ...methods.map(
              (option) => _buildMethodTile(context, option, isDark),
            ),
            Divider(color: isDark ? Colors.white12 : Colors.grey[200], height: 1),
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.lock, size: 14, color: isDark ? Colors.white38 : Colors.grey[500]),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      _t(
                        context,
                        '🔒 Payments processed via Paymob & Fawry – Demo mode active',
                        '🔒 المدفوعات تتم عبر بيموب وفوري – وضع تجريبي نشط',
                      ),
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark ? Colors.white38 : Colors.grey[500],
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMethodTile(BuildContext context, _PaymentOption option, bool isDark) {
    return InkWell(
      onTap: () => _onMethodSelected(context, option),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: option.color.withAlpha(26),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(option.icon, color: option.color, size: 22),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _t(context, option.nameEn, option.nameAr),
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                      color: isDark ? Colors.white : _navyBlue,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 14,
              color: isDark ? Colors.white38 : Colors.grey[400],
            ),
          ],
        ),
      ),
    );
  }

  void _onMethodSelected(BuildContext context, _PaymentOption option) {
    Navigator.of(context).pop();
    final txId = 'DEMO-${100000 + Random().nextInt(900000)}';
    final methodName = _t(context, option.nameEn, option.nameAr);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('🧪 Demo Mode'),
        content: Text(
          _t(
            context,
            'Payment via $methodName\nAmount: ${amount.toInt()} EGP\n\nIn production, this connects to Paymob/Fawry APIs.\n\nTransaction ID: $txId',
            'الدفع عبر $methodName\nالمبلغ: ${amount.toInt()} ج.م\n\nفي بيئة الإنتاج، يتصل بواجهات بيموب/فوري.\n\nرقم المعاملة: $txId',
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(),
            style: ElevatedButton.styleFrom(backgroundColor: _primaryGreen),
            child: Text(
              _t(context, 'OK', 'حسناً'),
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}

class _PaymentOption {
  final PaymentMethod method;
  final IconData icon;
  final String nameEn;
  final String nameAr;
  final Color color;

  const _PaymentOption({
    required this.method,
    required this.icon,
    required this.nameEn,
    required this.nameAr,
    required this.color,
  });
}
