import 'package:flutter/foundation.dart';
import '../../domain/entities/finance_entities.dart';

/// Centralized Data Source for Products, Services, Quotations, and Invoices.
/// Provides consistent financial data shared across Farmer, Finance, and Super Admin views.
class FinanceMockDataSource extends ChangeNotifier {
  static final FinanceMockDataSource _instance = FinanceMockDataSource._internal();
  factory FinanceMockDataSource() => _instance;

  late List<ProductEntity> _products;
  late List<ServiceEntity> _services;
  late List<CommercialQuotation> _quotations;
  late List<InvoiceEntity> _invoices;

  FinanceMockDataSource._internal() {
    _initData();
  }

  List<ProductEntity> get products => List.unmodifiable(_products);
  List<ServiceEntity> get services => List.unmodifiable(_services);
  List<CommercialQuotation> get quotations => List.unmodifiable(_quotations);
  List<InvoiceEntity> get invoices => List.unmodifiable(_invoices);

  void _initData() {
    // 1. Products Catalog
    _products = [
      const ProductEntity(
        id: 'prod-esp-01',
        nameEn: 'ESP32 Smart Gateway Controller',
        nameAr: 'متحكم وبوابة ESP32 الذكية',
        category: ProductCategory.controller,
        descriptionEn: 'Dual-core MCU with Wi-Fi, LoRa, RS485 Modbus, and solar charger.',
        descriptionAr: 'معالج ثنائي النواة مزود بـ Wi-Fi و LoRa و RS485 ومتحكم شحن شمسي.',
        unit: 'Unit / قطعة',
        costPriceEgp: 420.0,
        sellingPriceEgp: 650.0,
        stockQuantity: 45,
      ),
      const ProductEntity(
        id: 'prod-sensor-soil',
        nameEn: 'FDR Capacitive Soil Moisture Sensor',
        nameAr: 'مستشعر رطوبة وملوحة التربة السعوي',
        category: ProductCategory.sensor,
        descriptionEn: 'Measures VWC 0-100%, temperature, and EC for deep and surface root zones.',
        descriptionAr: 'يقيس رطوبة التربة الحجمية وحرارة وملوحة الجذور عند الأعماق.',
        unit: 'Sensor / مجس',
        costPriceEgp: 160.0,
        sellingPriceEgp: 280.0,
        stockQuantity: 120,
      ),
      const ProductEntity(
        id: 'prod-sensor-dht',
        nameEn: 'Digital Temperature & Humidity Sensor',
        nameAr: 'مستشعر حرارة ورطوبة الهواء الرقمي',
        category: ProductCategory.sensor,
        descriptionEn: 'IP67 shielded environmental weather probe with high precision.',
        descriptionAr: 'مستشعر طقس محمي IP67 عالي الدقة للبيوت المحمية والحقول المفتوحة.',
        unit: 'Sensor / مجس',
        costPriceEgp: 110.0,
        sellingPriceEgp: 190.0,
        stockQuantity: 80,
      ),
      const ProductEntity(
        id: 'prod-valve-solenoid',
        nameEn: '2-Inch Solenoid Irrigation Valve 24VAC',
        nameAr: 'محبس ري كهرومغناطيسي 2 بوصة',
        category: ProductCategory.actuator,
        descriptionEn: 'Heavy-duty industrial nylon body for precision zone flow control.',
        descriptionAr: 'محبس نايلون صناعي ثقيل للتحكم الدقيق في تدفق مياه القطاعات.',
        unit: 'Valve / محبس',
        costPriceEgp: 310.0,
        sellingPriceEgp: 490.0,
        stockQuantity: 65,
      ),
      const ProductEntity(
        id: 'prod-solar-panel',
        nameEn: '550W Monocrystalline Solar Panel',
        nameAr: 'لوح طاقة شمسية مونوكريستال 550 واط',
        category: ProductCategory.solar,
        descriptionEn: 'High-efficiency Tier 1 photovoltaic panel with anti-PID protection.',
        descriptionAr: 'خلية شمسية عالية الكفاءة مقاومة لدرجات الحرارة الصحراوية المرتفعة.',
        unit: 'Panel / لوح',
        costPriceEgp: 3200.0,
        sellingPriceEgp: 4400.0,
        stockQuantity: 28,
      ),
      const ProductEntity(
        id: 'prod-battery-lithium',
        nameEn: '48V 100Ah LiFePO4 Battery Bank',
        nameAr: 'بطارية ليثيوم فوسفات الحديد 48 فولت 100 أمبير',
        category: ProductCategory.solar,
        descriptionEn: '6000 cycles with integrated smart BMS and RS485 telemetry port.',
        descriptionAr: 'عمر تشغيلي 6000 دورة مزودة بنظام إدارة BMS ومنفذ بيانات Modbus.',
        unit: 'Bank / بنك',
        costPriceEgp: 18500.0,
        sellingPriceEgp: 24000.0,
        stockQuantity: 14,
      ),
    ];

    // 2. Services Catalog
    _services = [
      const ServiceEntity(
        id: 'srv-inspect-01',
        nameEn: 'Initial Field & Soil Inspection Visit',
        nameAr: 'معاينة ميدانية وفحص التربة والمصادر',
        descriptionEn: 'Engineering survey of soil type, topography, well salinity, and water pressure.',
        descriptionAr: 'مسح هندسي لنوعية التربة، والطبوجرافيا، وملوحة الآبار وضغط الشبكة.',
        defaultPriceEgp: 200.0,
      ),
      const ServiceEntity(
        id: 'srv-install-01',
        nameEn: 'ESP32 IoT & Valve Commissioning Labor',
        nameAr: 'تركيب وبرمجة بوابات ESP32 والمحابس',
        descriptionEn: 'Field installation of solar controllers, wiring, and actuator calibration.',
        descriptionAr: 'تركيب ميداني لوحدات التحكم بالطاقة والمحابس وبرمجة الشبكة.',
        defaultPriceEgp: 500.0,
      ),
      const ServiceEntity(
        id: 'srv-maint-01',
        nameEn: 'Emergency On-Site Maintenance Visit',
        nameAr: 'زيارة صيانة طارئة وتبديل قطع',
        descriptionEn: 'Field technician rapid response within 24 hours for hardware fault resolution.',
        descriptionAr: 'استجابة سريعة من الفني الميداني خلال 24 ساعة لحل الأعطال.',
        defaultPriceEgp: 350.0,
      ),
    ];

    // 3. Initial Quotations
    _quotations = [
      CommercialQuotation(
        id: 'quot-001',
        quotationNumber: 'GF-QT-2026-001',
        farmerId: 'usr-farmer-01',
        farmerName: 'Ahmed Al-Nour',
        farmId: 'farm-001',
        farmName: 'مزرعة الأمل للزيتون والنخيل',
        inspectionId: 'INS-2026-081',
        items: const [
          QuotationLineItem(
            productId: 'prod-esp-01',
            nameEn: 'ESP32 Smart Gateway Controller',
            nameAr: 'متحكم وبوابة ESP32 الذكية',
            quantity: 2,
            unitPriceEgp: 650.0,
          ),
          QuotationLineItem(
            productId: 'prod-sensor-soil',
            nameEn: 'FDR Capacitive Soil Moisture Sensor',
            nameAr: 'مستشعر رطوبة وملوحة التربة السعوي',
            quantity: 6,
            unitPriceEgp: 280.0,
          ),
          QuotationLineItem(
            productId: 'prod-valve-solenoid',
            nameEn: '2-Inch Solenoid Irrigation Valve 24VAC',
            nameAr: 'محبس ري كهرومغناطيسي 2 بوصة',
            quantity: 4,
            unitPriceEgp: 490.0,
          ),
        ],
        installationServiceFeeEgp: 500.0,
        inspectionServiceFeeEgp: 200.0,
        discountEgp: 200.0,
        taxPercent: 14.0,
        status: QuotationStatus.accepted,
        createdAt: DateTime(2026, 2, 10),
        validUntil: DateTime(2026, 3, 10),
      ),
      CommercialQuotation(
        id: 'quot-002',
        quotationNumber: 'GF-QT-2026-002',
        farmerId: 'usr-farmer-02',
        farmerName: 'Khalid Al-Bahr',
        farmId: 'farm-002',
        farmName: 'واحة النخيل العضوي',
        inspectionId: 'INS-2026-082',
        items: const [
          QuotationLineItem(
            productId: 'prod-esp-01',
            nameEn: 'ESP32 Smart Gateway Controller',
            nameAr: 'متحكم وبوابة ESP32 الذكية',
            quantity: 1,
            unitPriceEgp: 650.0,
          ),
          QuotationLineItem(
            productId: 'prod-sensor-soil',
            nameEn: 'FDR Capacitive Soil Moisture Sensor',
            nameAr: 'مستشعر رطوبة وملوحة التربة السعوي',
            quantity: 4,
            unitPriceEgp: 280.0,
          ),
        ],
        installationServiceFeeEgp: 400.0,
        inspectionServiceFeeEgp: 200.0,
        discountEgp: 0.0,
        taxPercent: 14.0,
        status: QuotationStatus.sentToFarmer,
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        validUntil: DateTime.now().add(const Duration(days: 28)),
      ),
    ];

    // 4. Initial Invoices
    _invoices = [
      InvoiceEntity(
        id: 'inv-001',
        invoiceNumber: 'INV-2026-041',
        farmerId: 'usr-farmer-01',
        farmerName: 'Ahmed Al-Nour',
        farmId: 'farm-001',
        farmName: 'مزرعة الأمل للزيتون والنخيل',
        type: InvoiceType.hardwareAndInstallation,
        amountEgp: 5802.60,
        status: InvoiceStatus.paid,
        paymentMethodEn: 'InstaPay Transfer',
        paymentMethodAr: 'تحويل شبكة انستاباي',
        issueDate: DateTime(2026, 2, 12),
        dueDate: DateTime(2026, 2, 26),
        paidAt: DateTime(2026, 2, 15),
        transactionReference: 'IP-EG-889922',
      ),
      InvoiceEntity(
        id: 'inv-002',
        invoiceNumber: 'INV-2026-042',
        farmerId: 'usr-farmer-01',
        farmerName: 'Ahmed Al-Nour',
        farmId: 'farm-001',
        farmName: 'مزرعة الأمل للزيتون والنخيل',
        type: InvoiceType.monthlySubscription,
        amountEgp: 399.0,
        status: InvoiceStatus.paid,
        paymentMethodEn: 'Paymob / Visa',
        paymentMethodAr: 'بيموب / بطاقة فيزا',
        issueDate: DateTime(2026, 3, 1),
        dueDate: DateTime(2026, 3, 15),
        paidAt: DateTime(2026, 3, 2),
        transactionReference: 'PM-CARD-991024',
      ),
      InvoiceEntity(
        id: 'inv-003',
        invoiceNumber: 'INV-2026-043',
        farmerId: 'usr-farmer-01',
        farmerName: 'Ahmed Al-Nour',
        farmId: 'farm-001',
        farmName: 'مزرعة الأمل للزيتون والنخيل',
        type: InvoiceType.monthlySubscription,
        amountEgp: 399.0,
        status: InvoiceStatus.issued, // Pending
        paymentMethodEn: 'Vodafone Cash / Fawry',
        paymentMethodAr: 'فودافون كاش / فوري',
        issueDate: DateTime.now().subtract(const Duration(days: 3)),
        dueDate: DateTime.now().add(const Duration(days: 11)),
      ),
    ];
  }

  // --- Products CRUD ---
  void addProduct(ProductEntity product) {
    _products.add(product);
    notifyListeners();
  }

  void updateProduct(ProductEntity product) {
    final idx = _products.indexWhere((p) => p.id == product.id);
    if (idx != -1) {
      _products[idx] = product;
      notifyListeners();
    }
  }

  void toggleProductActive(String productId) {
    final idx = _products.indexWhere((p) => p.id == productId);
    if (idx != -1) {
      _products[idx] = _products[idx].copyWith(isActive: !_products[idx].isActive);
      notifyListeners();
    }
  }

  // --- Services CRUD ---
  void updateService(ServiceEntity service) {
    final idx = _services.indexWhere((s) => s.id == service.id);
    if (idx != -1) {
      _services[idx] = service;
      notifyListeners();
    }
  }

  // --- Quotations Management ---
  void createQuotation(CommercialQuotation quotation) {
    _quotations.insert(0, quotation);
    notifyListeners();
  }

  void updateQuotationStatus(String quotationId, QuotationStatus status) {
    final idx = _quotations.indexWhere((q) => q.id == quotationId);
    if (idx != -1) {
      final updated = _quotations[idx].copyWith(status: status);
      _quotations[idx] = updated;

      // If accepted, generate hardware/installation invoice automatically
      if (status == QuotationStatus.accepted) {
        final newInvoice = InvoiceEntity(
          id: 'inv-${DateTime.now().millisecondsSinceEpoch}',
          invoiceNumber: 'INV-2026-${100 + _invoices.length}',
          farmerId: updated.farmerId,
          farmerName: updated.farmerName,
          farmId: updated.farmId,
          farmName: updated.farmName,
          type: InvoiceType.hardwareAndInstallation,
          amountEgp: updated.grandTotalOneTimeEgp,
          status: InvoiceStatus.issued,
          issueDate: DateTime.now(),
          dueDate: DateTime.now().add(const Duration(days: 14)),
        );
        _invoices.insert(0, newInvoice);
      }
      notifyListeners();
    }
  }

  // --- Invoices & Simulated Payment Execution ---
  void simulateInvoicePayment(String invoiceId, String methodEn, String methodAr) {
    final idx = _invoices.indexWhere((i) => i.id == invoiceId);
    if (idx != -1) {
      final updated = _invoices[idx].copyWith(
        status: InvoiceStatus.paid,
        paidAt: DateTime.now(),
        paymentMethodEn: methodEn,
        paymentMethodAr: methodAr,
        transactionReference: 'SIM-TX-${100000 + DateTime.now().millisecond}',
      );
      _invoices[idx] = updated;
      notifyListeners();
    }
  }

  /// Get Invoices strictly for a specific farmer (Data isolation)
  List<InvoiceEntity> getInvoicesForFarmer(String farmerId) {
    return _invoices.where((i) => i.farmerId == farmerId).toList();
  }

  /// Get Quotations strictly for a specific farmer (Data isolation)
  List<CommercialQuotation> getQuotationsForFarmer(String farmerId) {
    return _quotations.where((q) => q.farmerId == farmerId).toList();
  }
}
