// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Coffee POS';

  @override
  String get menu => 'Menu';

  @override
  String get orders => 'Orders';

  @override
  String get cart => 'Cart';

  @override
  String get settings => 'Settings';

  @override
  String get search => 'Search coffee...';
}
