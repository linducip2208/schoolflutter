import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';
import 'app_localizations_id.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
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
    Locale('id')
  ];

  /// No description provided for @appName.
  ///
  /// In id, this message translates to:
  /// **'Sikad Pro'**
  String get appName;

  /// No description provided for @welcome.
  ///
  /// In id, this message translates to:
  /// **'Selamat datang'**
  String get welcome;

  /// No description provided for @login.
  ///
  /// In id, this message translates to:
  /// **'Masuk'**
  String get login;

  /// No description provided for @logout.
  ///
  /// In id, this message translates to:
  /// **'Keluar'**
  String get logout;

  /// No description provided for @email.
  ///
  /// In id, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In id, this message translates to:
  /// **'Kata Sandi'**
  String get password;

  /// No description provided for @schoolCode.
  ///
  /// In id, this message translates to:
  /// **'Kode Sekolah'**
  String get schoolCode;

  /// No description provided for @forgotPassword.
  ///
  /// In id, this message translates to:
  /// **'Lupa kata sandi?'**
  String get forgotPassword;

  /// No description provided for @home.
  ///
  /// In id, this message translates to:
  /// **'Beranda'**
  String get home;

  /// No description provided for @schedule.
  ///
  /// In id, this message translates to:
  /// **'Jadwal'**
  String get schedule;

  /// No description provided for @classroom.
  ///
  /// In id, this message translates to:
  /// **'Kelas'**
  String get classroom;

  /// No description provided for @chat.
  ///
  /// In id, this message translates to:
  /// **'Chat'**
  String get chat;

  /// No description provided for @profile.
  ///
  /// In id, this message translates to:
  /// **'Profil'**
  String get profile;

  /// No description provided for @attendance.
  ///
  /// In id, this message translates to:
  /// **'Kehadiran'**
  String get attendance;

  /// No description provided for @marks.
  ///
  /// In id, this message translates to:
  /// **'Nilai'**
  String get marks;

  /// No description provided for @fees.
  ///
  /// In id, this message translates to:
  /// **'Tagihan'**
  String get fees;

  /// No description provided for @exam.
  ///
  /// In id, this message translates to:
  /// **'Ujian'**
  String get exam;

  /// No description provided for @library.
  ///
  /// In id, this message translates to:
  /// **'Perpustakaan'**
  String get library;

  /// No description provided for @notice.
  ///
  /// In id, this message translates to:
  /// **'Pengumuman'**
  String get notice;

  /// No description provided for @notifications.
  ///
  /// In id, this message translates to:
  /// **'Notifikasi'**
  String get notifications;

  /// No description provided for @today.
  ///
  /// In id, this message translates to:
  /// **'Hari Ini'**
  String get today;

  /// No description provided for @save.
  ///
  /// In id, this message translates to:
  /// **'Simpan'**
  String get save;

  /// No description provided for @cancel.
  ///
  /// In id, this message translates to:
  /// **'Batal'**
  String get cancel;

  /// No description provided for @send.
  ///
  /// In id, this message translates to:
  /// **'Kirim'**
  String get send;

  /// No description provided for @loading.
  ///
  /// In id, this message translates to:
  /// **'Memuat...'**
  String get loading;

  /// No description provided for @noData.
  ///
  /// In id, this message translates to:
  /// **'Belum ada data'**
  String get noData;

  /// No description provided for @retry.
  ///
  /// In id, this message translates to:
  /// **'Coba lagi'**
  String get retry;

  /// No description provided for @settings.
  ///
  /// In id, this message translates to:
  /// **'Pengaturan'**
  String get settings;

  /// No description provided for @language.
  ///
  /// In id, this message translates to:
  /// **'Bahasa'**
  String get language;

  /// No description provided for @changePassword.
  ///
  /// In id, this message translates to:
  /// **'Ubah kata sandi'**
  String get changePassword;

  /// No description provided for @welcomeTitle.
  ///
  /// In id, this message translates to:
  /// **'Selamat Datang di Sikad Pro'**
  String get welcomeTitle;

  /// No description provided for @welcomeSubtitle.
  ///
  /// In id, this message translates to:
  /// **'Platform digital sekolah terpadu'**
  String get welcomeSubtitle;

  /// No description provided for @welcomeDescription.
  ///
  /// In id, this message translates to:
  /// **'Mendukung kegiatan akademik, komunikasi, dan operasional sekolah.'**
  String get welcomeDescription;

  /// No description provided for @welcomeStart.
  ///
  /// In id, this message translates to:
  /// **'Mulai Menggunakan'**
  String get welcomeStart;

  /// No description provided for @welcomeContact.
  ///
  /// In id, this message translates to:
  /// **'Hubungi Kami via WhatsApp'**
  String get welcomeContact;

  /// No description provided for @welcomeClose.
  ///
  /// In id, this message translates to:
  /// **'Tutup'**
  String get welcomeClose;

  /// No description provided for @about.
  ///
  /// In id, this message translates to:
  /// **'Tentang Sikad Pro'**
  String get about;

  /// No description provided for @contactUs.
  ///
  /// In id, this message translates to:
  /// **'Hubungi Kami'**
  String get contactUs;

  /// No description provided for @appVersion.
  ///
  /// In id, this message translates to:
  /// **'Versi aplikasi'**
  String get appVersion;
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
      <String>['ar', 'en', 'id'].contains(locale.languageCode);

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
    case 'id':
      return AppLocalizationsId();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
