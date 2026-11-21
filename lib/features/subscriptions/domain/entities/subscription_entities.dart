enum SubscriptionTier { basicIotCare, proSolarFarm, enterpriseAgri }
enum PaymentMethod { paymobCard, paymobWallet, fawry, instaPay, vodafoneCash }
enum PaymentStatus { paid, pending, failed, refunded }

class SubscriptionPlanEntity {
  final SubscriptionTier tier;
  final String nameEn;
  final String nameAr;
  final String descEn;
  final String descAr;
  final double monthlyPriceEgp;
  final double hardwarePriceEgp;
  final List<String> featuresEn;
  final List<String> featuresAr;
  final bool isCurrentPlan;
  final bool isPopular;

  const SubscriptionPlanEntity({
    required this.tier,
    required this.nameEn,
    required this.nameAr,
    required this.descEn,
    required this.descAr,
    required this.monthlyPriceEgp,
    required this.hardwarePriceEgp,
    required this.featuresEn,
    required this.featuresAr,
    this.isCurrentPlan = false,
    this.isPopular = false,
  });
}

class PaymentRecordEntity {
  final String id;
  final double amountEgp;
  final PaymentMethod method;
  final PaymentStatus status;
  final DateTime date;
  final String descriptionEn;
  final String descriptionAr;
  final bool isHardwareFee;

  const PaymentRecordEntity({
    required this.id,
    required this.amountEgp,
    required this.method,
    required this.status,
    required this.date,
    required this.descriptionEn,
    required this.descriptionAr,
    this.isHardwareFee = false,
  });
}

class CustomerSubscriptionEntity {
  final SubscriptionTier currentTier;
  final DateTime startDate;
  final DateTime nextRenewalDate;
  final bool isActive;
  final double outstandingHardwareFee;
  final List<PaymentRecordEntity> paymentHistory;

  const CustomerSubscriptionEntity({
    required this.currentTier,
    required this.startDate,
    required this.nextRenewalDate,
    required this.isActive,
    required this.outstandingHardwareFee,
    required this.paymentHistory,
  });
}
