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

  /// No description provided for @all.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get all;

  /// No description provided for @cancelEdit.
  ///
  /// In en, this message translates to:
  /// **'Cancel edit'**
  String get cancelEdit;

  /// No description provided for @errorLoadingMenu.
  ///
  /// In en, this message translates to:
  /// **'Error loading menu'**
  String get errorLoadingMenu;

  /// No description provided for @errorLoadingCombos.
  ///
  /// In en, this message translates to:
  /// **'Error loading combos'**
  String get errorLoadingCombos;

  /// No description provided for @noItemsFoundInCategory.
  ///
  /// In en, this message translates to:
  /// **'No items found in this category'**
  String get noItemsFoundInCategory;

  /// No description provided for @noCombosAvailable.
  ///
  /// In en, this message translates to:
  /// **'No combos available'**
  String get noCombosAvailable;

  /// No description provided for @currentOrder.
  ///
  /// In en, this message translates to:
  /// **'Current Order'**
  String get currentOrder;

  /// No description provided for @clearAll.
  ///
  /// In en, this message translates to:
  /// **'Clear all'**
  String get clearAll;

  /// No description provided for @clearCartQuestion.
  ///
  /// In en, this message translates to:
  /// **'Clear cart?'**
  String get clearCartQuestion;

  /// No description provided for @clearCartMessage.
  ///
  /// In en, this message translates to:
  /// **'All items will be removed from the current order.'**
  String get clearCartMessage;

  /// No description provided for @clear.
  ///
  /// In en, this message translates to:
  /// **'Clear'**
  String get clear;

  /// No description provided for @cartIsEmpty.
  ///
  /// In en, this message translates to:
  /// **'Cart is empty'**
  String get cartIsEmpty;

  /// No description provided for @tableCustomerLabel.
  ///
  /// In en, this message translates to:
  /// **'Table / Customer label'**
  String get tableCustomerLabel;

  /// No description provided for @addNonSupplementItem.
  ///
  /// In en, this message translates to:
  /// **'Add at least one non-supplement item to place this order.'**
  String get addNonSupplementItem;

  /// No description provided for @updateOrder.
  ///
  /// In en, this message translates to:
  /// **'Update Order'**
  String get updateOrder;

  /// No description provided for @placeOrder.
  ///
  /// In en, this message translates to:
  /// **'Place Order'**
  String get placeOrder;

  /// No description provided for @customize.
  ///
  /// In en, this message translates to:
  /// **'Customize'**
  String get customize;

  /// No description provided for @chooseYour.
  ///
  /// In en, this message translates to:
  /// **'Choose your'**
  String get chooseYour;

  /// No description provided for @addToOrder.
  ///
  /// In en, this message translates to:
  /// **'Add to order'**
  String get addToOrder;

  /// No description provided for @manageCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage categories'**
  String get manageCategories;

  /// No description provided for @addItem.
  ///
  /// In en, this message translates to:
  /// **'Add Item'**
  String get addItem;

  /// No description provided for @somethingWentWrong.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get somethingWentWrong;

  /// No description provided for @noItemsInCategory.
  ///
  /// In en, this message translates to:
  /// **'No items in this category'**
  String get noItemsInCategory;

  /// No description provided for @noMenuItemsYet.
  ///
  /// In en, this message translates to:
  /// **'No menu items yet'**
  String get noMenuItemsYet;

  /// No description provided for @uncategorised.
  ///
  /// In en, this message translates to:
  /// **'Uncategorised'**
  String get uncategorised;

  /// No description provided for @supplementBadge.
  ///
  /// In en, this message translates to:
  /// **'SUPP'**
  String get supplementBadge;

  /// No description provided for @tapBelowAddFirstItem.
  ///
  /// In en, this message translates to:
  /// **'Tap below to add your first item'**
  String get tapBelowAddFirstItem;

  /// No description provided for @addMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Add Menu Item'**
  String get addMenuItem;

  /// No description provided for @inactive.
  ///
  /// In en, this message translates to:
  /// **'Inactive'**
  String get inactive;

  /// No description provided for @remove.
  ///
  /// In en, this message translates to:
  /// **'Remove'**
  String get remove;

  /// No description provided for @removeMenuItemQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove menu item?'**
  String get removeMenuItemQuestion;

  /// No description provided for @permanentlyRemoveFromMenu.
  ///
  /// In en, this message translates to:
  /// **'This will permanently remove'**
  String get permanentlyRemoveFromMenu;

  /// No description provided for @fromTheMenu.
  ///
  /// In en, this message translates to:
  /// **'from the menu.'**
  String get fromTheMenu;

  /// No description provided for @editMenuItem.
  ///
  /// In en, this message translates to:
  /// **'Edit Menu Item'**
  String get editMenuItem;

  /// No description provided for @save.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get save;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @tapToAddPhoto.
  ///
  /// In en, this message translates to:
  /// **'Tap to add photo'**
  String get tapToAddPhoto;

  /// No description provided for @itemName.
  ///
  /// In en, this message translates to:
  /// **'Item Name'**
  String get itemName;

  /// No description provided for @exampleChickenBurger.
  ///
  /// In en, this message translates to:
  /// **'e.g. Chicken Burger'**
  String get exampleChickenBurger;

  /// No description provided for @requiredField.
  ///
  /// In en, this message translates to:
  /// **'Required'**
  String get requiredField;

  /// No description provided for @price.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get price;

  /// No description provided for @invalidPrice.
  ///
  /// In en, this message translates to:
  /// **'Invalid price'**
  String get invalidPrice;

  /// No description provided for @category.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get category;

  /// No description provided for @selectCategory.
  ///
  /// In en, this message translates to:
  /// **'Select a category'**
  String get selectCategory;

  /// No description provided for @noCategory.
  ///
  /// In en, this message translates to:
  /// **'No category'**
  String get noCategory;

  /// No description provided for @categories.
  ///
  /// In en, this message translates to:
  /// **'Categories'**
  String get categories;

  /// No description provided for @addNewCategory.
  ///
  /// In en, this message translates to:
  /// **'ADD NEW CATEGORY'**
  String get addNewCategory;

  /// No description provided for @categoryName.
  ///
  /// In en, this message translates to:
  /// **'Category name'**
  String get categoryName;

  /// No description provided for @supplementCategory.
  ///
  /// In en, this message translates to:
  /// **'Supplement category'**
  String get supplementCategory;

  /// No description provided for @itemsCannotBeOrderedAlone.
  ///
  /// In en, this message translates to:
  /// **'Items cannot be ordered alone'**
  String get itemsCannotBeOrderedAlone;

  /// No description provided for @noCategoriesYet.
  ///
  /// In en, this message translates to:
  /// **'No categories yet'**
  String get noCategoriesYet;

  /// No description provided for @existingCategories.
  ///
  /// In en, this message translates to:
  /// **'EXISTING CATEGORIES'**
  String get existingCategories;

  /// No description provided for @supplement.
  ///
  /// In en, this message translates to:
  /// **'Supplement'**
  String get supplement;

  /// No description provided for @manageComboCategories.
  ///
  /// In en, this message translates to:
  /// **'Manage combo categories'**
  String get manageComboCategories;

  /// No description provided for @noCombosYet.
  ///
  /// In en, this message translates to:
  /// **'No combos yet'**
  String get noCombosYet;

  /// No description provided for @createFirstComboMenu.
  ///
  /// In en, this message translates to:
  /// **'Create your first combo menu'**
  String get createFirstComboMenu;

  /// No description provided for @removeComboQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove combo?'**
  String get removeComboQuestion;

  /// No description provided for @fromYourMenu.
  ///
  /// In en, this message translates to:
  /// **'from your menu.'**
  String get fromYourMenu;

  /// No description provided for @addOneItemToCombo.
  ///
  /// In en, this message translates to:
  /// **'Add at least one item to the combo'**
  String get addOneItemToCombo;

  /// No description provided for @create.
  ///
  /// In en, this message translates to:
  /// **'Create'**
  String get create;

  /// No description provided for @comboNameField.
  ///
  /// In en, this message translates to:
  /// **'Combo Name'**
  String get comboNameField;

  /// No description provided for @exampleFamilyMeal.
  ///
  /// In en, this message translates to:
  /// **'e.g. Family Meal'**
  String get exampleFamilyMeal;

  /// No description provided for @invalidNumber.
  ///
  /// In en, this message translates to:
  /// **'Invalid number'**
  String get invalidNumber;

  /// No description provided for @descriptionOptional.
  ///
  /// In en, this message translates to:
  /// **'Description (optional)'**
  String get descriptionOptional;

  /// No description provided for @shortDescription.
  ///
  /// In en, this message translates to:
  /// **'Short description...'**
  String get shortDescription;

  /// No description provided for @categoryOptional.
  ///
  /// In en, this message translates to:
  /// **'Category (optional)'**
  String get categoryOptional;

  /// No description provided for @includedItemsUpper.
  ///
  /// In en, this message translates to:
  /// **'INCLUDED ITEMS'**
  String get includedItemsUpper;

  /// No description provided for @selected.
  ///
  /// In en, this message translates to:
  /// **'selected'**
  String get selected;

  /// No description provided for @choiceGroup.
  ///
  /// In en, this message translates to:
  /// **'Choice group'**
  String get choiceGroup;

  /// No description provided for @choiceGroupHint.
  ///
  /// In en, this message translates to:
  /// **'Long-press a selected item to assign a choice group (e.g. \"drink\"). Items sharing the same group become pick-one options.'**
  String get choiceGroupHint;

  /// No description provided for @choiceGroupDescription.
  ///
  /// In en, this message translates to:
  /// **'Items sharing the same group name become pick-one choices. Leave empty for a fixed item.'**
  String get choiceGroupDescription;

  /// No description provided for @choiceGroupExample.
  ///
  /// In en, this message translates to:
  /// **'e.g. drink, dessert...'**
  String get choiceGroupExample;

  /// No description provided for @removeGroup.
  ///
  /// In en, this message translates to:
  /// **'Remove group'**
  String get removeGroup;

  /// No description provided for @comboCategories.
  ///
  /// In en, this message translates to:
  /// **'Combo Categories'**
  String get comboCategories;

  /// No description provided for @newCategory.
  ///
  /// In en, this message translates to:
  /// **'NEW CATEGORY'**
  String get newCategory;

  /// No description provided for @addStaff.
  ///
  /// In en, this message translates to:
  /// **'Add Staff'**
  String get addStaff;

  /// No description provided for @managers.
  ///
  /// In en, this message translates to:
  /// **'Managers'**
  String get managers;

  /// No description provided for @team.
  ///
  /// In en, this message translates to:
  /// **'Team'**
  String get team;

  /// No description provided for @noPin.
  ///
  /// In en, this message translates to:
  /// **'No PIN'**
  String get noPin;

  /// No description provided for @digitPin.
  ///
  /// In en, this message translates to:
  /// **'digit PIN'**
  String get digitPin;

  /// No description provided for @removeStaffMemberQuestion.
  ///
  /// In en, this message translates to:
  /// **'Remove staff member?'**
  String get removeStaffMemberQuestion;

  /// No description provided for @fromTheTeam.
  ///
  /// In en, this message translates to:
  /// **'from the team. This action cannot be undone.'**
  String get fromTheTeam;

  /// No description provided for @noStaffYet.
  ///
  /// In en, this message translates to:
  /// **'No staff yet'**
  String get noStaffYet;

  /// No description provided for @addFirstTeamMember.
  ///
  /// In en, this message translates to:
  /// **'Add your first team member to get started'**
  String get addFirstTeamMember;

  /// No description provided for @addStaffMember.
  ///
  /// In en, this message translates to:
  /// **'Add Staff Member'**
  String get addStaffMember;

  /// No description provided for @editStaffMember.
  ///
  /// In en, this message translates to:
  /// **'Edit Staff Member'**
  String get editStaffMember;

  /// No description provided for @fullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get fullName;

  /// No description provided for @exampleJohnDoe.
  ///
  /// In en, this message translates to:
  /// **'e.g. John Doe'**
  String get exampleJohnDoe;

  /// No description provided for @nameIsRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get nameIsRequired;

  /// No description provided for @role.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get role;

  /// No description provided for @selectRole.
  ///
  /// In en, this message translates to:
  /// **'Select role'**
  String get selectRole;

  /// No description provided for @pinLength.
  ///
  /// In en, this message translates to:
  /// **'PIN Length'**
  String get pinLength;

  /// No description provided for @pin.
  ///
  /// In en, this message translates to:
  /// **'PIN'**
  String get pin;

  /// No description provided for @digits.
  ///
  /// In en, this message translates to:
  /// **'digits'**
  String get digits;

  /// No description provided for @manager.
  ///
  /// In en, this message translates to:
  /// **'Manager'**
  String get manager;

  /// No description provided for @optional.
  ///
  /// In en, this message translates to:
  /// **'Optional'**
  String get optional;

  /// No description provided for @enterDigitPinOptional.
  ///
  /// In en, this message translates to:
  /// **'Enter digit PIN (optional)'**
  String get enterDigitPinOptional;

  /// No description provided for @pinExactDigitsPrefix.
  ///
  /// In en, this message translates to:
  /// **'PIN must be exactly'**
  String get pinExactDigitsPrefix;

  /// No description provided for @pinExactDigitsSuffix.
  ///
  /// In en, this message translates to:
  /// **'digits'**
  String get pinExactDigitsSuffix;

  /// No description provided for @pinDigitsOnly.
  ///
  /// In en, this message translates to:
  /// **'PIN must contain digits only'**
  String get pinDigitsOnly;

  /// No description provided for @noPinNotice.
  ///
  /// In en, this message translates to:
  /// **'If no PIN is set, this staff member can log in without entering one.'**
  String get noPinNotice;

  /// No description provided for @managerPinNoticePrefix.
  ///
  /// In en, this message translates to:
  /// **'Manager accounts use a'**
  String get managerPinNoticePrefix;

  /// No description provided for @managerPinNoticeSuffix.
  ///
  /// In en, this message translates to:
  /// **'digit PIN for enhanced security. You can adjust the length above.'**
  String get managerPinNoticeSuffix;

  /// No description provided for @staffDashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff dashboard'**
  String get staffDashboardTitle;

  /// No description provided for @lastShift.
  ///
  /// In en, this message translates to:
  /// **'Last Shift'**
  String get lastShift;

  /// No description provided for @allShifts.
  ///
  /// In en, this message translates to:
  /// **'All Shifts'**
  String get allShifts;

  /// No description provided for @noShiftsYet.
  ///
  /// In en, this message translates to:
  /// **'No shifts yet'**
  String get noShiftsYet;

  /// No description provided for @shiftHistory.
  ///
  /// In en, this message translates to:
  /// **'Shift history'**
  String get shiftHistory;

  /// No description provided for @activeShift.
  ///
  /// In en, this message translates to:
  /// **'Active shift'**
  String get activeShift;

  /// No description provided for @closedShift.
  ///
  /// In en, this message translates to:
  /// **'Closed shift'**
  String get closedShift;

  /// No description provided for @end.
  ///
  /// In en, this message translates to:
  /// **'End'**
  String get end;

  /// No description provided for @pending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get pending;

  /// No description provided for @revenue.
  ///
  /// In en, this message translates to:
  /// **'Revenue'**
  String get revenue;

  /// No description provided for @tips.
  ///
  /// In en, this message translates to:
  /// **'Tips'**
  String get tips;

  /// No description provided for @overview.
  ///
  /// In en, this message translates to:
  /// **'Overview'**
  String get overview;

  /// No description provided for @shifts.
  ///
  /// In en, this message translates to:
  /// **'Shifts'**
  String get shifts;

  /// No description provided for @avgShift.
  ///
  /// In en, this message translates to:
  /// **'Avg shift'**
  String get avgShift;

  /// No description provided for @revenueBreakdown.
  ///
  /// In en, this message translates to:
  /// **'Revenue breakdown'**
  String get revenueBreakdown;

  /// No description provided for @ordersByHour.
  ///
  /// In en, this message translates to:
  /// **'Orders by hour'**
  String get ordersByHour;

  /// No description provided for @topItems.
  ///
  /// In en, this message translates to:
  /// **'Top items'**
  String get topItems;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selectYear.
  ///
  /// In en, this message translates to:
  /// **'Select year'**
  String get selectYear;

  /// No description provided for @avgOrder.
  ///
  /// In en, this message translates to:
  /// **'Avg order'**
  String get avgOrder;

  /// No description provided for @noOrdersFor.
  ///
  /// In en, this message translates to:
  /// **'No orders for'**
  String get noOrdersFor;

  /// No description provided for @failedToLoadSummary.
  ///
  /// In en, this message translates to:
  /// **'Failed to load summary'**
  String get failedToLoadSummary;

  /// No description provided for @selectStartOf7DayWindow.
  ///
  /// In en, this message translates to:
  /// **'Select start of 7-day window'**
  String get selectStartOf7DayWindow;

  /// No description provided for @selectAnyDayInWeek.
  ///
  /// In en, this message translates to:
  /// **'Select any day in the week'**
  String get selectAnyDayInWeek;

  /// No description provided for @searchByOrderId.
  ///
  /// In en, this message translates to:
  /// **'Search by order ID...'**
  String get searchByOrderId;

  /// No description provided for @typeToSearchOrders.
  ///
  /// In en, this message translates to:
  /// **'Type to search orders'**
  String get typeToSearchOrders;

  /// No description provided for @noOrdersMatch.
  ///
  /// In en, this message translates to:
  /// **'No orders match'**
  String get noOrdersMatch;

  /// No description provided for @error.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get error;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @markAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as paid'**
  String get markAsPaid;

  /// No description provided for @reviewOrder.
  ///
  /// In en, this message translates to:
  /// **'Review order'**
  String get reviewOrder;

  /// No description provided for @noteOptional.
  ///
  /// In en, this message translates to:
  /// **'Note (optional)'**
  String get noteOptional;

  /// No description provided for @passationAmount.
  ///
  /// In en, this message translates to:
  /// **'Passation amount'**
  String get passationAmount;

  /// No description provided for @cashTakenFromRegister.
  ///
  /// In en, this message translates to:
  /// **'Cash taken from register at shift start'**
  String get cashTakenFromRegister;

  /// No description provided for @logoutQuestion.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to logout?'**
  String get logoutQuestion;

  /// No description provided for @justNow.
  ///
  /// In en, this message translates to:
  /// **'Just now'**
  String get justNow;

  /// No description provided for @minutesAgoSuffix.
  ///
  /// In en, this message translates to:
  /// **'m ago'**
  String get minutesAgoSuffix;

  /// No description provided for @hoursAgoSuffix.
  ///
  /// In en, this message translates to:
  /// **'h ago'**
  String get hoursAgoSuffix;

  /// No description provided for @daysAgoSuffix.
  ///
  /// In en, this message translates to:
  /// **'d ago'**
  String get daysAgoSuffix;

  /// No description provided for @totalShort.
  ///
  /// In en, this message translates to:
  /// **'total'**
  String get totalShort;

  /// No description provided for @sum.
  ///
  /// In en, this message translates to:
  /// **'Sum'**
  String get sum;
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
