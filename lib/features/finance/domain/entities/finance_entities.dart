/// Finance & Pricing Models: Products, Services, Subscriptions, Quotations & Invoices.
library;

enum ProductCategory {
  controller,
  sensor,
  actuator,
  solar,
  accessories,
  materials;

  String get labelEn {
    switch (this) {
      case ProductCategory.controller:
        return 'ESP32 Controllers & Gateways';
      case ProductCategory.sensor:
        return 'Soil & Environmental Sensors';
      case ProductCategory.actuator:
        return 'Relays, Pumps & Valves';
      case ProductCategory.solar:
        return 'Solar Panels, Batteries & Inverters';
      case ProductCategory.accessories:
        return 'Cables, Enclosures & Fittings';
      case ProductCategory.materials:
        return 'Piping & Installation Materials';
    }
  }

  String get labelAr {
    switch (this) {
      case ProductCategory.controller:
        return 'متحكمات وبوابات ESP32';
      case ProductCategory.sensor:
        return 'حساسات التربة والبيئة';
      case ProductCategory.actuator:
        return 'مرحلات ومضخات ومحابس كهربائية';
      case ProductCategory.solar:
        return 'ألواح شمسية وبطاريات وإنفرتر';
      case ProductCategory.accessories:
        return 'كابلات وصناديق حماية وتوصيلات';
      case ProductCategory.materials:
        return 'أنابيب ومستلزمات تركيب';
    }
  }
}

/// Catalog product item with purchasing cost, selling price and stock.
class ProductEntity {
  final String id;
  final String nameEn;
  final String nameAr;
  final ProductCategory category;
  final String descriptionEn;
  final String descriptionAr;
  final String unit;
  final double costPriceEgp;
  final double sellingPriceEgp;
  final int stockQuantity;
  final bool isActive;

  const ProductEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.category,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.unit,
    required this.costPriceEgp,
    required this.sellingPriceEgp,
    required this.stockQuantity,
    this.isActive = true,
  });

  double get profitMarginEgp => sellingPriceEgp - costPriceEgp;
  double get profitMarginPercent => costPriceEgp > 0 ? (profitMarginEgp / costPriceEgp) * 100 : 0.0;

  ProductEntity copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    ProductCategory? category,
    String? descriptionEn,
    String? descriptionAr,
    String? unit,
    double? costPriceEgp,
    double? sellingPriceEgp,
    int? stockQuantity,
    bool? isActive,
  }) {
    return ProductEntity(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      category: category ?? this.category,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      unit: unit ?? this.unit,
      costPriceEgp: costPriceEgp ?? this.costPriceEgp,
      sellingPriceEgp: sellingPriceEgp ?? this.sellingPriceEgp,
      stockQuantity: stockQuantity ?? this.stockQuantity,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'category': category.index,
        'descriptionEn': descriptionEn,
        'descriptionAr': descriptionAr,
        'unit': unit,
        'costPriceEgp': costPriceEgp,
        'sellingPriceEgp': sellingPriceEgp,
        'stockQuantity': stockQuantity,
        'isActive': isActive,
      };

  factory ProductEntity.fromJson(Map<String, dynamic> json) => ProductEntity(
        id: json['id'] as String,
        nameEn: json['nameEn'] as String,
        nameAr: json['nameAr'] as String,
        category: ProductCategory.values[(json['category'] as int? ?? 0).clamp(0, ProductCategory.values.length - 1)],
        descriptionEn: json['descriptionEn'] as String,
        descriptionAr: json['descriptionAr'] as String,
        unit: json['unit'] as String,
        costPriceEgp: (json['costPriceEgp'] as num).toDouble(),
        sellingPriceEgp: (json['sellingPriceEgp'] as num).toDouble(),
        stockQuantity: (json['stockQuantity'] as num).toInt(),
        isActive: json['isActive'] as bool? ?? true,
      );
}

/// Technical services catalog managed by Finance (Inspection, Installation, Maintenance).
class ServiceEntity {
  final String id;
  final String nameEn;
  final String nameAr;
  final String descriptionEn;
  final String descriptionAr;
  final double defaultPriceEgp;
  final bool isActive;

  const ServiceEntity({
    required this.id,
    required this.nameEn,
    required this.nameAr,
    required this.descriptionEn,
    required this.descriptionAr,
    required this.defaultPriceEgp,
    this.isActive = true,
  });

  ServiceEntity copyWith({
    String? id,
    String? nameEn,
    String? nameAr,
    String? descriptionEn,
    String? descriptionAr,
    double? defaultPriceEgp,
    bool? isActive,
  }) {
    return ServiceEntity(
      id: id ?? this.id,
      nameEn: nameEn ?? this.nameEn,
      nameAr: nameAr ?? this.nameAr,
      descriptionEn: descriptionEn ?? this.descriptionEn,
      descriptionAr: descriptionAr ?? this.descriptionAr,
      defaultPriceEgp: defaultPriceEgp ?? this.defaultPriceEgp,
      isActive: isActive ?? this.isActive,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'descriptionEn': descriptionEn,
        'descriptionAr': descriptionAr,
        'defaultPriceEgp': defaultPriceEgp,
        'isActive': isActive,
      };

  factory ServiceEntity.fromJson(Map<String, dynamic> json) => ServiceEntity(
        id: json['id'] as String,
        nameEn: json['nameEn'] as String,
        nameAr: json['nameAr'] as String,
        descriptionEn: json['descriptionEn'] as String,
        descriptionAr: json['descriptionAr'] as String,
        defaultPriceEgp: (json['defaultPriceEgp'] as num).toDouble(),
        isActive: json['isActive'] as bool? ?? true,
      );
}

/// Item inside a Quotation
class QuotationLineItem {
  final String productId;
  final String nameEn;
  final String nameAr;
  final int quantity;
  final double unitPriceEgp;

  const QuotationLineItem({
    required this.productId,
    required this.nameEn,
    required this.nameAr,
    required this.quantity,
    required this.unitPriceEgp,
  });

  double get totalEgp => quantity * unitPriceEgp;

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'nameEn': nameEn,
        'nameAr': nameAr,
        'quantity': quantity,
        'unitPriceEgp': unitPriceEgp,
      };

  factory QuotationLineItem.fromJson(Map<String, dynamic> json) => QuotationLineItem(
        productId: json['productId'] as String,
        nameEn: json['nameEn'] as String,
        nameAr: json['nameAr'] as String,
        quantity: (json['quantity'] as num).toInt(),
        unitPriceEgp: (json['unitPriceEgp'] as num).toDouble(),
      );
}

enum QuotationStatus {
  draft,
  pendingApproval,
  sentToFarmer,
  accepted,
  rejected,
  expired;

  String get labelEn {
    switch (this) {
      case QuotationStatus.draft:
        return 'Draft';
      case QuotationStatus.pendingApproval:
        return 'Pending Approval';
      case QuotationStatus.sentToFarmer:
        return 'Sent to Farmer';
      case QuotationStatus.accepted:
        return 'Accepted by Farmer';
      case QuotationStatus.rejected:
        return 'Rejected';
      case QuotationStatus.expired:
        return 'Expired';
    }
  }

  String get labelAr {
    switch (this) {
      case QuotationStatus.draft:
        return 'مسودة';
      case QuotationStatus.pendingApproval:
        return 'بانتظار اعتماد الإدارة';
      case QuotationStatus.sentToFarmer:
        return 'مُرسل للمزارع للمراجعة';
      case QuotationStatus.accepted:
        return 'معتمد ومقبول من المزارع';
      case QuotationStatus.rejected:
        return 'مرفوض';
      case QuotationStatus.expired:
        return 'منتهي الصلاحية';
    }
  }
}

/// Complete Commercial Quotation Model
class CommercialQuotation {
  final String id;
  final String quotationNumber;
  final String farmerId;
  final String farmerName;
  final String farmId;
  final String farmName;
  final String? inspectionId;
  final List<QuotationLineItem> items;
  final double installationServiceFeeEgp;
  final double inspectionServiceFeeEgp;
  final double discountEgp;
  final double taxPercent; // e.g. 14% VAT
  final QuotationStatus status;
  final String subscriptionTierEn;
  final String subscriptionTierAr;
  final double monthlySubscriptionFeeEgp;
  final DateTime createdAt;
  final DateTime validUntil;
  final String? notes;

  const CommercialQuotation({
    required this.id,
    required this.quotationNumber,
    required this.farmerId,
    required this.farmerName,
    required this.farmId,
    required this.farmName,
    this.inspectionId,
    required this.items,
    this.installationServiceFeeEgp = 500.0,
    this.inspectionServiceFeeEgp = 200.0,
    this.discountEgp = 0.0,
    this.taxPercent = 14.0,
    this.status = QuotationStatus.sentToFarmer,
    this.subscriptionTierEn = 'Pro Solar Farm',
    this.subscriptionTierAr = 'مزرعة الطاقة الشمسية الاحترافية',
    this.monthlySubscriptionFeeEgp = 399.0,
    required this.createdAt,
    required this.validUntil,
    this.notes,
  });

  double get hardwareSubtotalEgp => items.fold(0.0, (sum, i) => sum + i.totalEgp);
  double get servicesSubtotalEgp => installationServiceFeeEgp + inspectionServiceFeeEgp;
  double get subtotalBeforeDiscount => hardwareSubtotalEgp + servicesSubtotalEgp;
  double get taxableAmount => (subtotalBeforeDiscount - discountEgp).clamp(0.0, double.infinity);
  double get taxAmountEgp => taxableAmount * (taxPercent / 100.0);
  double get grandTotalOneTimeEgp => taxableAmount + taxAmountEgp;

  CommercialQuotation copyWith({
    String? id,
    String? quotationNumber,
    String? farmerId,
    String? farmerName,
    String? farmId,
    String? farmName,
    String? inspectionId,
    List<QuotationLineItem>? items,
    double? installationServiceFeeEgp,
    double? inspectionServiceFeeEgp,
    double? discountEgp,
    double? taxPercent,
    QuotationStatus? status,
    String? subscriptionTierEn,
    String? subscriptionTierAr,
    double? monthlySubscriptionFeeEgp,
    DateTime? createdAt,
    DateTime? validUntil,
    String? notes,
  }) {
    return CommercialQuotation(
      id: id ?? this.id,
      quotationNumber: quotationNumber ?? this.quotationNumber,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmId: farmId ?? this.farmId,
      farmName: farmName ?? this.farmName,
      inspectionId: inspectionId ?? this.inspectionId,
      items: items ?? this.items,
      installationServiceFeeEgp: installationServiceFeeEgp ?? this.installationServiceFeeEgp,
      inspectionServiceFeeEgp: inspectionServiceFeeEgp ?? this.inspectionServiceFeeEgp,
      discountEgp: discountEgp ?? this.discountEgp,
      taxPercent: taxPercent ?? this.taxPercent,
      status: status ?? this.status,
      subscriptionTierEn: subscriptionTierEn ?? this.subscriptionTierEn,
      subscriptionTierAr: subscriptionTierAr ?? this.subscriptionTierAr,
      monthlySubscriptionFeeEgp: monthlySubscriptionFeeEgp ?? this.monthlySubscriptionFeeEgp,
      createdAt: createdAt ?? this.createdAt,
      validUntil: validUntil ?? this.validUntil,
      notes: notes ?? this.notes,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'quotationNumber': quotationNumber,
        'farmerId': farmerId,
        'farmerName': farmerName,
        'farmId': farmId,
        'farmName': farmName,
        'inspectionId': inspectionId,
        'items': items.map((e) => e.toJson()).toList(),
        'installationServiceFeeEgp': installationServiceFeeEgp,
        'inspectionServiceFeeEgp': inspectionServiceFeeEgp,
        'discountEgp': discountEgp,
        'taxPercent': taxPercent,
        'status': status.index,
        'subscriptionTierEn': subscriptionTierEn,
        'subscriptionTierAr': subscriptionTierAr,
        'monthlySubscriptionFeeEgp': monthlySubscriptionFeeEgp,
        'createdAt': createdAt.toIso8601String(),
        'validUntil': validUntil.toIso8601String(),
        'notes': notes,
      };

  factory CommercialQuotation.fromJson(Map<String, dynamic> json) => CommercialQuotation(
        id: json['id'] as String,
        quotationNumber: json['quotationNumber'] as String,
        farmerId: json['farmerId'] as String,
        farmerName: json['farmerName'] as String,
        farmId: json['farmId'] as String,
        farmName: json['farmName'] as String,
        inspectionId: json['inspectionId'] as String?,
        items: (json['items'] as List<dynamic>?)
                ?.map((e) => QuotationLineItem.fromJson(e as Map<String, dynamic>))
                .toList() ??
            [],
        installationServiceFeeEgp: (json['installationServiceFeeEgp'] as num?)?.toDouble() ?? 500.0,
        inspectionServiceFeeEgp: (json['inspectionServiceFeeEgp'] as num?)?.toDouble() ?? 200.0,
        discountEgp: (json['discountEgp'] as num?)?.toDouble() ?? 0.0,
        taxPercent: (json['taxPercent'] as num?)?.toDouble() ?? 14.0,
        status: QuotationStatus.values[(json['status'] as int? ?? 2).clamp(0, QuotationStatus.values.length - 1)],
        subscriptionTierEn: json['subscriptionTierEn'] as String? ?? 'Pro Solar Farm',
        subscriptionTierAr: json['subscriptionTierAr'] as String? ?? 'مزرعة الطاقة الشمسية الاحترافية',
        monthlySubscriptionFeeEgp: (json['monthlySubscriptionFeeEgp'] as num?)?.toDouble() ?? 399.0,
        createdAt: DateTime.parse(json['createdAt'] as String),
        validUntil: DateTime.parse(json['validUntil'] as String),
        notes: json['notes'] as String?,
      );
}

enum InvoiceType {
  hardwareAndInstallation,
  monthlySubscription,
  maintenanceService;

  String get labelEn {
    switch (this) {
      case InvoiceType.hardwareAndInstallation:
        return 'Hardware & Installation';
      case InvoiceType.monthlySubscription:
        return 'Monthly Subscription';
      case InvoiceType.maintenanceService:
        return 'Maintenance & Field Service';
    }
  }

  String get labelAr {
    switch (this) {
      case InvoiceType.hardwareAndInstallation:
        return 'الأجهزة والتركيب الميداني';
      case InvoiceType.monthlySubscription:
        return 'الاشتراك الشهري الذكي';
      case InvoiceType.maintenanceService:
        return 'الصيانة والخدمة الميدانية';
    }
  }
}

enum InvoiceStatus {
  draft,
  issued,
  paid,
  partiallyPaid,
  overdue,
  cancelled;

  String get labelEn {
    switch (this) {
      case InvoiceStatus.draft:
        return 'Draft';
      case InvoiceStatus.issued:
        return 'Issued';
      case InvoiceStatus.paid:
        return 'Paid';
      case InvoiceStatus.partiallyPaid:
        return 'Partially Paid';
      case InvoiceStatus.overdue:
        return 'Overdue';
      case InvoiceStatus.cancelled:
        return 'Cancelled';
    }
  }

  String get labelAr {
    switch (this) {
      case InvoiceStatus.draft:
        return 'مسودة';
      case InvoiceStatus.issued:
        return 'صادرة';
      case InvoiceStatus.paid:
        return 'مدفوعة';
      case InvoiceStatus.partiallyPaid:
        return 'مدفوعة جزئياً';
      case InvoiceStatus.overdue:
        return 'متأخرة السداد';
      case InvoiceStatus.cancelled:
        return 'ملغاة';
    }
  }
}

/// Invoice Entity generated from accepted quotations or subscriptions.
class InvoiceEntity {
  final String id;
  final String invoiceNumber;
  final String farmerId;
  final String farmerName;
  final String farmId;
  final String farmName;
  final InvoiceType type;
  final double amountEgp;
  final InvoiceStatus status;
  final String paymentMethodEn;
  final String paymentMethodAr;
  final DateTime issueDate;
  final DateTime dueDate;
  final DateTime? paidAt;
  final String? transactionReference;

  const InvoiceEntity({
    required this.id,
    required this.invoiceNumber,
    required this.farmerId,
    required this.farmerName,
    required this.farmId,
    required this.farmName,
    required this.type,
    required this.amountEgp,
    required this.status,
    this.paymentMethodEn = 'Paymob / Card',
    this.paymentMethodAr = 'بيموب / بطاقة بنكية',
    required this.issueDate,
    required this.dueDate,
    this.paidAt,
    this.transactionReference,
  });

  bool get isPaid => status == InvoiceStatus.paid;

  InvoiceEntity copyWith({
    String? id,
    String? invoiceNumber,
    String? farmerId,
    String? farmerName,
    String? farmId,
    String? farmName,
    InvoiceType? type,
    double? amountEgp,
    InvoiceStatus? status,
    String? paymentMethodEn,
    String? paymentMethodAr,
    DateTime? issueDate,
    DateTime? dueDate,
    DateTime? paidAt,
    String? transactionReference,
  }) {
    return InvoiceEntity(
      id: id ?? this.id,
      invoiceNumber: invoiceNumber ?? this.invoiceNumber,
      farmerId: farmerId ?? this.farmerId,
      farmerName: farmerName ?? this.farmerName,
      farmId: farmId ?? this.farmId,
      farmName: farmName ?? this.farmName,
      type: type ?? this.type,
      amountEgp: amountEgp ?? this.amountEgp,
      status: status ?? this.status,
      paymentMethodEn: paymentMethodEn ?? this.paymentMethodEn,
      paymentMethodAr: paymentMethodAr ?? this.paymentMethodAr,
      issueDate: issueDate ?? this.issueDate,
      dueDate: dueDate ?? this.dueDate,
      paidAt: paidAt ?? this.paidAt,
      transactionReference: transactionReference ?? this.transactionReference,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'invoiceNumber': invoiceNumber,
        'farmerId': farmerId,
        'farmerName': farmerName,
        'farmId': farmId,
        'farmName': farmName,
        'type': type.index,
        'amountEgp': amountEgp,
        'status': status.index,
        'paymentMethodEn': paymentMethodEn,
        'paymentMethodAr': paymentMethodAr,
        'issueDate': issueDate.toIso8601String(),
        'dueDate': dueDate.toIso8601String(),
        'paidAt': paidAt?.toIso8601String(),
        'transactionReference': transactionReference,
      };

  factory InvoiceEntity.fromJson(Map<String, dynamic> json) => InvoiceEntity(
        id: json['id'] as String,
        invoiceNumber: json['invoiceNumber'] as String,
        farmerId: json['farmerId'] as String,
        farmerName: json['farmerName'] as String,
        farmId: json['farmId'] as String,
        farmName: json['farmName'] as String,
        type: InvoiceType.values[(json['type'] as int? ?? 0).clamp(0, InvoiceType.values.length - 1)],
        amountEgp: (json['amountEgp'] as num).toDouble(),
        status: InvoiceStatus.values[(json['status'] as int? ?? 0).clamp(0, InvoiceStatus.values.length - 1)],
        paymentMethodEn: json['paymentMethodEn'] as String? ?? 'Paymob / Card',
        paymentMethodAr: json['paymentMethodAr'] as String? ?? 'بيموب / بطاقة بنكية',
        issueDate: DateTime.parse(json['issueDate'] as String),
        dueDate: DateTime.parse(json['dueDate'] as String),
        paidAt: json['paidAt'] != null ? DateTime.parse(json['paidAt'] as String) : null,
        transactionReference: json['transactionReference'] as String?,
      );
}
