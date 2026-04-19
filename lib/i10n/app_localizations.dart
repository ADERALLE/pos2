import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_fr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'i10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('en'),
    Locale('fr')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Coffee POS'**
  String get appTitle;

  /// No description provided for @menu.
  ///
  /// In en, this message translates to:
  /// **'Menu'**
  String get menu;

  /// No description provided for @orders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get orders;

  /// No description provided for @cart.
  ///
  /// In en, this message translates to:
  /// **'Cart'**
  String get cart;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search coffee...'**
  String get search;

  // ── navigation ──────────────────────────────────────────────────────────────
  String get navHome;
  String get navOrders;
  String get navAlerts;
  String get navSettings;

  // ── login ────────────────────────────────────────────────────────────────────
  String get welcome;
  String get enterPinFor;
  String get wrongPin;

  // ── home ─────────────────────────────────────────────────────────────────────
  String get goodMorning;
  String get goodAfternoon;
  String get goodEvening;
  String get noActiveShift;
  String get startShiftSubtitle;
  String get startShift;
  String get shiftActive;
  String get elapsed;
  String get close;
  String get newOrder;
  String get todaysOrders;
  String get noOrdersYet;
  String get uncompletedOrdersTitle;
  String get uncompletedOrdersMessage;
  String get ok;
  String get editOrder;
  String get markDone;
  String get start;
  String get closeShift;

  // ── orders ───────────────────────────────────────────────────────────────────
  String get activeOrders;
  String get history;
  String get noActiveOrders;
  String get noOrderHistory;
  String get searchOrders;
  String get cancelOrder;
  String get comboLabel;

  // ── notifications ────────────────────────────────────────────────────────────
  String get notifications;
  String get markAllRead;
  String get failedToLoadNotifications;
  String get retry;
  String get noNotificationsYet;
  String get noUnreadNotifications;

  // ── payment dialog ───────────────────────────────────────────────────────────
  String get completeOrder;
  String get total;
  String get cash;
  String get card;
  String get split;
  String get tipCardSide;
  String get amountsMatchTotal;
  String get cancel;
  String get cardConfirmed;

  // ── offline banner ───────────────────────────────────────────────────────────
  String get backOnlineSyncing;
  String get operation;
  String get operations;
  String get offlineNoQueue;
  String get offline;
  String get queued;

  // ── settings ─────────────────────────────────────────────────────────────────
  String get analyticsReports;
  String get dailyShopDashboard;
  String get dailyShopDashboardSubtitle;
  String get staffDashboard;
  String get staffDashboardSubtitle;
  String get management;
  String get staff;
  String get staffSubtitle;
  String get menuSubtitle;
  String get comboMenusSubtitle;
  String get system;
  String get logout;
  String get language;
  String get languageSubtitle;
  String get appearance;
  String get appearanceSubtitle;

  // ── combo menu (already existed) ─────────────────────────────────────────────
  String get comboMenus;
  String get newCombo;
  String get editCombo;
  String get comboName;
  String get comboPrice;
  String get includedItems;
  String get createCombo;
  String get saveChanges;
  String get items;
  String get combos;

  // ── shift summary ────────────────────────────────────────────────────────────
  String get shiftSummary;
  String get dashboard;
  String get shiftClosed;
  String get started;
  String get closed;
  String get passation;
  String get done;
  String get cancelled;
  String get totalRevenue;
  String get tipsCard;
  String get cashToHandOver;
  String get takeaway;
  String get ordersCount;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en', 'fr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
    case 'fr':
      return AppLocalizationsFr();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
