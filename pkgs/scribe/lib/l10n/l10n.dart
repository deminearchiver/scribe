import 'package:material/material.dart';

import 'app_localizations.dart' as l10n;
export 'app_localizations.dart' show lookupAppLocalizations;

abstract final class LocalizationsRegistry {
  static l10n.AppLocalizations? of(BuildContext context) {
    return Localizations.of<l10n.AppLocalizations>(
      context,
      l10n.AppLocalizations,
    );
  }

  static const LocalizationsDelegate<l10n.AppLocalizations> delegate =
      l10n.AppLocalizations.delegate;

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
      l10n.AppLocalizations.localizationsDelegates;

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales =
      l10n.AppLocalizations.supportedLocales;
}
