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
    Locale('fr'),
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

  /// No description provided for @comboMenus.
  ///
  /// In en, this message translates to:
  /// **'Combo Menus'**
  String get comboMenus;

  /// No description provided for @newCombo.
  ///
  /// In en, this message translates to:
  /// **'New Combo'**
  String get newCombo;

  /// No description provided for @editCombo.
  ///
  /// In en, this message translates to:
  /// **'Edit Combo'**
  String get editCombo;

  /// No description provided for @comboName.
  ///
  /// In en, this message translates to:
  /// **'Combo name'**
  String get comboName;

  /// No description provided for @comboPrice.
  ///
  /// In en, this message translates to:
  /// **'Price (MAD)'**
  String get comboPrice;

  /// No description provided for @includedItems.
  ///
  /// In en, this message translates to:
  /// **'Included items'**
  String get includedItems;

  /// No description provided for @createCombo.
  ///
  /// In en, this message translates to:
  /// **'Create Combo'**
  String get createCombo;

  /// No description provided for @saveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get saveChanges;

  /// No description provided for @items.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get items;

  /// No description provided for @combos.
  ///
  /// In en, this message translates to:
  /// **'Combos'**
  String get combos;

  /// No description provided for @navHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get navHome;

  /// No description provided for @navOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get navOrders;

  /// No description provided for @navAlerts.
  ///
  /// In en, this message translates to:
  /// **'Alerts'**
  String get navAlerts;

  /// No description provided for @navSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get navSettings;

  /// No description provided for @welcome.
  ///
  /// In en, this message translates to:
  /// **'Welcome'**
  String get welcome;

  /// No description provided for @enterPinFor.
  ///
  /// In en, this message translates to:
  /// **'Enter PIN for'**
  String get enterPinFor;

  /// No description provided for @wrongPin.
  ///
  /// In en, this message translates to:
  /// **'Wrong PIN'**
  String get wrongPin;

  /// No description provided for @goodMorning.
  ///
  /// In en, this message translates to:
  /// **'Good morning'**
  String get goodMorning;

  /// No description provided for @goodAfternoon.
  ///
  /// In en, this message translates to:
  /// **'Good afternoon'**
  String get goodAfternoon;

  /// No description provided for @goodEvening.
  ///
  /// In en, this message translates to:
  /// **'Good evening'**
  String get goodEvening;

  /// No description provided for @noActiveShift.
  ///
  /// In en, this message translates to:
  /// **'No active shift'**
  String get noActiveShift;

  /// No description provided for @startShiftSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Start a shift to begin taking orders'**
  String get startShiftSubtitle;

  /// No description provided for @startShift.
  ///
  /// In en, this message translates to:
  /// **'Start shift'**
  String get startShift;

  /// No description provided for @shiftActive.
  ///
  /// In en, this message translates to:
  /// **'Shift active'**
  String get shiftActive;

  /// No description provided for @elapsed.
  ///
  /// In en, this message translates to:
  /// **'elapsed'**
  String get elapsed;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @newOrder.
  ///
  /// In en, this message translates to:
  /// **'New order'**
  String get newOrder;

  /// No description provided for @todaysOrders.
  ///
  /// In en, this message translates to:
  /// **'Today\'s orders'**
  String get todaysOrders;

  /// No description provided for @noOrdersYet.
  ///
  /// In en, this message translates to:
  /// **'No orders yet'**
  String get noOrdersYet;

  /// No description provided for @uncompletedOrdersTitle.
  ///
  /// In en, this message translates to:
  /// **'Uncompleted orders'**
  String get uncompletedOrdersTitle;

  /// No description provided for @uncompletedOrdersMessage.
  ///
  /// In en, this message translates to:
  /// **'order(s) are still pending or in progress.\nMark them as done or cancel before closing.'**
  String get uncompletedOrdersMessage;

  /// No description provided for @ok.
  ///
  /// In en, this message translates to:
  /// **'OK'**
  String get ok;

  /// No description provided for @editOrder.
  ///
  /// In en, this message translates to:
  /// **'Edit Order'**
  String get editOrder;

  /// No description provided for @markDone.
  ///
  /// In en, this message translates to:
  /// **'Mark done'**
  String get markDone;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @closeShift.
  ///
  /// In en, this message translates to:
  /// **'Close shift'**
  String get closeShift;

  /// No description provided for @activeOrders.
  ///
  /// In en, this message translates to:
  /// **'Active Orders'**
  String get activeOrders;

  /// No description provided for @history.
  ///
  /// In en, this message translates to:
  /// **'History'**
  String get history;

  /// No description provided for @noActiveOrders.
  ///
  /// In en, this message translates to:
  /// **'No active orders'**
  String get noActiveOrders;

  /// No description provided for @noOrderHistory.
  ///
  /// In en, this message translates to:
  /// **'No order history'**
  String get noOrderHistory;

  /// No description provided for @searchOrders.
  ///
  /// In en, this message translates to:
  /// **'Search orders'**
  String get searchOrders;

  /// No description provided for @cancelOrder.
  ///
  /// In en, this message translates to:
  /// **'Cancel Order'**
  String get cancelOrder;

  /// No description provided for @comboLabel.
  ///
  /// In en, this message translates to:
  /// **'COMBO'**
  String get comboLabel;

  /// No description provided for @notifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notifications;

  /// No description provided for @markAllRead.
  ///
  /// In en, this message translates to:
  /// **'Mark all read'**
  String get markAllRead;

  /// No description provided for @failedToLoadNotifications.
  ///
  /// In en, this message translates to:
  /// **'Failed to load notifications'**
  String get failedToLoadNotifications;

  /// No description provided for @retry.
  ///
  /// In en, this message translates to:
  /// **'Retry'**
  String get retry;

  /// No description provided for @noNotificationsYet.
  ///
  /// In en, this message translates to:
  /// **'No notifications yet'**
  String get noNotificationsYet;

  /// No description provided for @noUnreadNotifications.
  ///
  /// In en, this message translates to:
  /// **'No unread notifications'**
  String get noUnreadNotifications;

  /// No description provided for @completeOrder.
  ///
  /// In en, this message translates to:
  /// **'Complete order'**
  String get completeOrder;

  /// No description provided for @total.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get total;

  /// No description provided for @cash.
  ///
  /// In en, this message translates to:
  /// **'Cash'**
  String get cash;

  /// No description provided for @card.
  ///
  /// In en, this message translates to:
  /// **'Card'**
  String get card;

  /// No description provided for @split.
  ///
  /// In en, this message translates to:
  /// **'Split'**
  String get split;

  /// No description provided for @tipCardSide.
  ///
  /// In en, this message translates to:
  /// **'Tip (card side)'**
  String get tipCardSide;

  /// No description provided for @amountsMatchTotal.
  ///
  /// In en, this message translates to:
  /// **'Amounts match total'**
  String get amountsMatchTotal;

  /// No description provided for @cancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get cancel;

  /// No description provided for @cardConfirmed.
  ///
  /// In en, this message translates to:
  /// **'Card payment confirmed on terminal'**
  String get cardConfirmed;

  /// No description provided for @backOnlineSyncing.
  ///
  /// In en, this message translates to:
  /// **'Back online — syncing'**
  String get backOnlineSyncing;

  /// No description provided for @operation.
  ///
  /// In en, this message translates to:
  /// **'operation'**
  String get operation;

  /// No description provided for @operations.
  ///
  /// In en, this message translates to:
  /// **'operations'**
  String get operations;

  /// No description provided for @offlineNoQueue.
  ///
  /// In en, this message translates to:
  /// **'Offline — orders will sync when reconnected'**
  String get offlineNoQueue;

  /// No description provided for @offline.
  ///
  /// In en, this message translates to:
  /// **'Offline —'**
  String get offline;

  /// No description provided for @queued.
  ///
  /// In en, this message translates to:
  /// **'queued'**
  String get queued;

  /// No description provided for @analyticsReports.
  ///
  /// In en, this message translates to:
  /// **'Analytics & Reports'**
  String get analyticsReports;

  /// No description provided for @dailyShopDashboard.
  ///
  /// In en, this message translates to:
  /// **'Daily Shop Dashboard'**
  String get dailyShopDashboard;

  /// No description provided for @dailyShopDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'View revenue, trends, and top items by date'**
  String get dailyShopDashboardSubtitle;

  /// No description provided for @staffDashboard.
  ///
  /// In en, this message translates to:
  /// **'Staff Dashboard'**
  String get staffDashboard;

  /// No description provided for @staffDashboardSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Track shifts and revenue by team member'**
  String get staffDashboardSubtitle;

  /// No description provided for @management.
  ///
  /// In en, this message translates to:
  /// **'Management'**
  String get management;

  /// No description provided for @staff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staff;

  /// No description provided for @staffSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Manage your team and roles'**
  String get staffSubtitle;

  /// No description provided for @menuSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Edit items, categories, and pricing'**
  String get menuSubtitle;

  /// No description provided for @comboMenusSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Create and manage combo meals'**
  String get comboMenusSubtitle;

  /// No description provided for @system.
  ///
  /// In en, this message translates to:
  /// **'System'**
  String get system;

  /// No description provided for @logout.
  ///
  /// In en, this message translates to:
  /// **'Logout'**
  String get logout;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @languageSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Change the app language'**
  String get languageSubtitle;

  /// No description provided for @appearance.
  ///
  /// In en, this message translates to:
  /// **'Appearance'**
  String get appearance;

  /// No description provided for @appearanceSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Toggle light / dark mode'**
  String get appearanceSubtitle;

  /// No description provided for @shiftSummary.
  ///
  /// In en, this message translates to:
  /// **'Shift summary'**
  String get shiftSummary;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @shiftClosed.
  ///
  /// In en, this message translates to:
  /// **'Shift closed'**
  String get shiftClosed;

  /// No description provided for @started.
  ///
  /// In en, this message translates to:
  /// **'Started'**
  String get started;

  /// No description provided for @closed.
  ///
  /// In en, this message translates to:
  /// **'Closed'**
  String get closed;

  /// No description provided for @passation.
  ///
  /// In en, this message translates to:
  /// **'Passation'**
  String get passation;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @cancelled.
  ///
  /// In en, this message translates to:
  /// **'Cancelled'**
  String get cancelled;

  /// No description provided for @totalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total revenue'**
  String get totalRevenue;

  /// No description provided for @tipsCard.
  ///
  /// In en, this message translates to:
  /// **'Tips (card)'**
  String get tipsCard;

  /// No description provided for @cashToHandOver.
  ///
  /// In en, this message translates to:
  /// **'Cash to hand over'**
  String get cashToHandOver;

  /// No description provided for @takeaway.
  ///
  /// In en, this message translates to:
  /// **'Take away'**
  String get takeaway;

  /// No description provided for @ordersCount.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
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
    'that was used.',
  );
}
