// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Arabic (`ar`).
class AppLocalizationsAr extends AppLocalizations {
  AppLocalizationsAr([String locale = 'ar']) : super(locale);

  @override
  String get appTitle => 'Coffee POS';

  @override
  String get menu => 'القائمة';

  @override
  String get orders => 'الطلبات';

  @override
  String get cart => 'السلة';

  @override
  String get settings => 'الإعدادات';

  @override
  String get search => 'ابحث عن قهوة...';

  // ── navigation ──────────────────────────────────────────────────────────────
  @override
  String get navHome => 'الرئيسية';

  @override
  String get navOrders => 'الطلبات';

  @override
  String get navAlerts => 'التنبيهات';

  @override
  String get navSettings => 'الإعدادات';

  // ── login ────────────────────────────────────────────────────────────────────
  @override
  String get welcome => 'مرحباً';

  @override
  String get enterPinFor => 'أدخل الرمز السري لـ';

  @override
  String get wrongPin => 'رمز سري خاطئ';

  // ── home ─────────────────────────────────────────────────────────────────────
  @override
  String get goodMorning => 'صباح الخير';

  @override
  String get goodAfternoon => 'مساء الخير';

  @override
  String get goodEvening => 'مساء النور';

  @override
  String get noActiveShift => 'لا توجد وردية نشطة';

  @override
  String get startShiftSubtitle => 'ابدأ وردية لبدء استقبال الطلبات';

  @override
  String get startShift => 'بدء الوردية';

  @override
  String get shiftActive => 'الوردية نشطة';

  @override
  String get elapsed => 'مضى';

  @override
  String get close => 'إغلاق';

  @override
  String get newOrder => 'طلب جديد';

  @override
  String get todaysOrders => 'طلبات اليوم';

  @override
  String get noOrdersYet => 'لا توجد طلبات';

  @override
  String get uncompletedOrdersTitle => 'طلبات غير مكتملة';

  @override
  String get uncompletedOrdersMessage =>
      'طلب(ات) لا تزال معلقة أو قيد التنفيذ.\nأكملها أو ألغها قبل الإغلاق.';

  @override
  String get ok => 'موافق';

  @override
  String get editOrder => 'تعديل الطلب';

  @override
  String get markDone => 'تحديد كمنتهٍ';

  @override
  String get start => 'بدء';

  @override
  String get closeShift => 'إغلاق الوردية';

  // ── orders ───────────────────────────────────────────────────────────────────
  @override
  String get activeOrders => 'الطلبات النشطة';

  @override
  String get history => 'السجل';

  @override
  String get noActiveOrders => 'لا توجد طلبات نشطة';

  @override
  String get noOrderHistory => 'لا يوجد سجل للطلبات';

  @override
  String get searchOrders => 'البحث في الطلبات';

  @override
  String get cancelOrder => 'إلغاء الطلب';

  @override
  String get comboLabel => 'كومبو';

  // ── notifications ────────────────────────────────────────────────────────────
  @override
  String get notifications => 'الإشعارات';

  @override
  String get markAllRead => 'تحديد الكل كمقروء';

  @override
  String get failedToLoadNotifications => 'فشل تحميل الإشعارات';

  @override
  String get retry => 'إعادة المحاولة';

  @override
  String get noNotificationsYet => 'لا توجد إشعارات';

  @override
  String get noUnreadNotifications => 'لا توجد إشعارات غير مقروءة';

  // ── payment dialog ───────────────────────────────────────────────────────────
  @override
  String get completeOrder => 'إتمام الطلب';

  @override
  String get total => 'الإجمالي';

  @override
  String get cash => 'نقداً';

  @override
  String get card => 'بطاقة';

  @override
  String get split => 'مختلط';

  @override
  String get tipCardSide => 'إكرامية (جانب البطاقة)';

  @override
  String get amountsMatchTotal => 'المبالغ تساوي الإجمالي';

  @override
  String get cancel => 'إلغاء';

  @override
  String get cardConfirmed => 'تم تأكيد الدفع بالبطاقة على الجهاز';

  // ── offline banner ───────────────────────────────────────────────────────────
  @override
  String get backOnlineSyncing => 'عودة الاتصال \u2014 مزامنة';

  @override
  String get operation => 'عملية';

  @override
  String get operations => 'عمليات';

  @override
  String get offlineNoQueue =>
      'غير متصل \u2014 ستتم المزامنة عند إعادة الاتصال';

  @override
  String get offline => 'غير متصل \u2014';

  @override
  String get queued => 'في الانتظار';

  // ── settings ─────────────────────────────────────────────────────────────────
  @override
  String get analyticsReports => 'التحليلات والتقارير';

  @override
  String get dailyShopDashboard => 'لوحة المتجر اليومية';

  @override
  String get dailyShopDashboardSubtitle =>
      'عرض الإيرادات والمواد الأكثر مبيعاً حسب التاريخ';

  @override
  String get staffDashboard => 'لوحة الموظفين';

  @override
  String get staffDashboardSubtitle =>
      'متابعة الورديات والإيرادات لكل موظف';

  @override
  String get management => 'الإدارة';

  @override
  String get staff => 'الموظفون';

  @override
  String get staffSubtitle => 'إدارة الفريق والأدوار';

  @override
  String get menuSubtitle => 'تعديل المواد والفئات والأسعار';

  @override
  String get comboMenusSubtitle => 'إنشاء وإدارة القوائم المركبة';

  @override
  String get system => 'النظام';

  @override
  String get logout => 'تسجيل الخروج';

  @override
  String get language => 'اللغة';

  @override
  String get languageSubtitle => 'تغيير لغة التطبيق';

  @override
  String get appearance => 'المظهر';

  @override
  String get appearanceSubtitle => 'التبديل بين الوضع الفاتح والداكن';

  // ── combo menu ───────────────────────────────────────────────────────────────
  @override
  String get comboMenus => 'القوائم المركبة';

  @override
  String get newCombo => 'كومبو جديد';

  @override
  String get editCombo => 'تعديل الكومبو';

  @override
  String get comboName => 'اسم الكومبو';

  @override
  String get comboPrice => 'السعر (درهم)';

  @override
  String get includedItems => 'العناصر المضمنة';

  @override
  String get createCombo => 'إنشاء الكومبو';

  @override
  String get saveChanges => 'حفظ التغييرات';

  @override
  String get items => 'العناصر';

  @override
  String get combos => 'الكومبوهات';

  // ── shift summary ────────────────────────────────────────────────────────────
  @override
  String get shiftSummary => 'ملخص الوردية';

  @override
  String get dashboard => 'لوحة القيادة';

  @override
  String get shiftClosed => 'الوردية مغلقة';

  @override
  String get started => 'بدأت';

  @override
  String get closed => 'أُغلقت';

  @override
  String get passation => 'تسليم';

  @override
  String get done => 'منتهٍ';

  @override
  String get cancelled => 'ملغى';

  @override
  String get totalRevenue => 'إجمالي الإيرادات';

  @override
  String get tipsCard => 'الإكراميات (بطاقة)';

  @override
  String get cashToHandOver => 'النقد للتسليم';

  @override
  String get takeaway => 'سفري';

  @override
  String get ordersCount => 'الطلبات';
}

