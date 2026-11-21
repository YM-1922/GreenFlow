import '../../domain/entities/subscription_entities.dart';

class SubscriptionMockDataSource {
  static final DateTime _now = DateTime.now();

  static List<SubscriptionPlanEntity> getPlans() {
    return [
      SubscriptionPlanEntity(
        tier: SubscriptionTier.basicIotCare,
        nameEn: 'Basic IoT Care',
        nameAr: 'الرعاية الأساسية للإنترنت',
        descEn: 'Essential IoT monitoring for small farms',
        descAr: 'مراقبة إنترنت الأشياء الأساسية للمزارع الصغيرة',
        monthlyPriceEgp: 199,
        hardwarePriceEgp: 2500,
        featuresEn: [
          'Up to 5 IoT sensors',
          'Basic soil moisture monitoring',
          'Email alerts',
          'Monthly reports',
          '8/5 customer support',
        ],
        featuresAr: [
          'حتى 5 أجهزة استشعار إنترنت الأشياء',
          'مراقبة رطوبة التربة الأساسية',
          'تنبيهات بريد إلكتروني',
          'تقارير شهرية',
          'دعم العملاء 8/5',
        ],
        isCurrentPlan: false,
        isPopular: false,
      ),
      SubscriptionPlanEntity(
        tier: SubscriptionTier.proSolarFarm,
        nameEn: 'Pro Solar Farm',
        nameAr: 'مزرعة الطاقة الشمسية الاحترافية',
        descEn: 'Full solar & IoT management for growing farms',
        descAr: 'إدارة الطاقة الشمسية وإنترنت الأشياء الكاملة للمزارع المتنامية',
        monthlyPriceEgp: 399,
        hardwarePriceEgp: 8500,
        featuresEn: [
          'Up to 20 IoT sensors',
          'Solar energy monitoring & analytics',
          'Real-time SMS & push alerts',
          'Automated irrigation control',
          '24/7 customer support',
        ],
        featuresAr: [
          'حتى 20 جهاز استشعار إنترنت الأشياء',
          'مراقبة وتحليل الطاقة الشمسية',
          'تنبيهات فورية عبر الرسائل القصيرة والإشعارات',
          'التحكم الآلي في الري',
          'دعم العملاء 24/7',
        ],
        isCurrentPlan: true,
        isPopular: true,
      ),
      SubscriptionPlanEntity(
        tier: SubscriptionTier.enterpriseAgri,
        nameEn: 'Enterprise Agri',
        nameAr: 'المؤسسات الزراعية',
        descEn: 'Unlimited scale for large agricultural operations',
        descAr: 'نطاق غير محدود للعمليات الزراعية الكبيرة',
        monthlyPriceEgp: 899,
        hardwarePriceEgp: 22000,
        featuresEn: [
          'Unlimited IoT sensors',
          'AI-powered crop recommendations',
          'Multi-farm management dashboard',
          'Custom analytics & reporting',
          'Dedicated account manager',
        ],
        featuresAr: [
          'أجهزة استشعار إنترنت الأشياء غير محدودة',
          'توصيات المحاصيل بالذكاء الاصطناعي',
          'لوحة إدارة متعددة المزارع',
          'تحليلات وتقارير مخصصة',
          'مدير حساب مخصص',
        ],
        isCurrentPlan: false,
        isPopular: false,
      ),
    ];
  }

  static CustomerSubscriptionEntity getCustomerSubscription() {
    final startDate = DateTime(_now.year, _now.month - 3, _now.day);
    final nextRenewal = _now.add(const Duration(days: 27));

    final paymentHistory = [
      PaymentRecordEntity(
        id: 'PAY-001',
        amountEgp: 399,
        method: PaymentMethod.paymobCard,
        status: PaymentStatus.paid,
        date: _now.subtract(const Duration(days: 90)),
        descriptionEn: 'Pro Solar Farm – Monthly Subscription',
        descriptionAr: 'مزرعة الطاقة الشمسية الاحترافية – اشتراك شهري',
        isHardwareFee: false,
      ),
      PaymentRecordEntity(
        id: 'PAY-002',
        amountEgp: 8500,
        method: PaymentMethod.instaPay,
        status: PaymentStatus.paid,
        date: _now.subtract(const Duration(days: 88)),
        descriptionEn: 'Pro Solar Farm – Hardware Kit (One-time)',
        descriptionAr: 'مزرعة الطاقة الشمسية الاحترافية – طقم الأجهزة (مرة واحدة)',
        isHardwareFee: true,
      ),
      PaymentRecordEntity(
        id: 'PAY-003',
        amountEgp: 399,
        method: PaymentMethod.paymobCard,
        status: PaymentStatus.paid,
        date: _now.subtract(const Duration(days: 60)),
        descriptionEn: 'Pro Solar Farm – Monthly Subscription',
        descriptionAr: 'مزرعة الطاقة الشمسية الاحترافية – اشتراك شهري',
        isHardwareFee: false,
      ),
      PaymentRecordEntity(
        id: 'PAY-004',
        amountEgp: 399,
        method: PaymentMethod.paymobCard,
        status: PaymentStatus.paid,
        date: _now.subtract(const Duration(days: 30)),
        descriptionEn: 'Pro Solar Farm – Monthly Subscription',
        descriptionAr: 'مزرعة الطاقة الشمسية الاحترافية – اشتراك شهري',
        isHardwareFee: false,
      ),
      PaymentRecordEntity(
        id: 'PAY-005',
        amountEgp: 399,
        method: PaymentMethod.vodafoneCash,
        status: PaymentStatus.pending,
        date: _now.subtract(const Duration(days: 2)),
        descriptionEn: 'Pro Solar Farm – Monthly Subscription',
        descriptionAr: 'مزرعة الطاقة الشمسية الاحترافية – اشتراك شهري',
        isHardwareFee: false,
      ),
    ];

    return CustomerSubscriptionEntity(
      currentTier: SubscriptionTier.proSolarFarm,
      startDate: startDate,
      nextRenewalDate: nextRenewal,
      isActive: true,
      outstandingHardwareFee: 0,
      paymentHistory: paymentHistory,
    );
  }
}
