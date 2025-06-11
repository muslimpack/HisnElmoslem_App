import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of S
/// returned by `S.of(context)`.
///
/// Applications need to include `S.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'lang/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: S.localizationsDelegates,
///   supportedLocales: S.supportedLocales,
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
/// be consistent with the languages listed in the S.supportedLocales
/// property.
abstract class S {
  S(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static S of(BuildContext context) {
    return Localizations.of<S>(context, S)!;
  }

  static const LocalizationsDelegate<S> delegate = _SDelegate();

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
  ];

  /// No description provided for @aboutUs.
  ///
  /// In en, this message translates to:
  /// **'About Us'**
  String get aboutUs;

  /// No description provided for @activate.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get activate;

  /// No description provided for @activateCounterInstructions.
  ///
  /// In en, this message translates to:
  /// **'To activate counter go to counters then click to counter icon beside the counter you want'**
  String get activateCounterInstructions;

  /// No description provided for @activeTally.
  ///
  /// In en, this message translates to:
  /// **'Active tally'**
  String get activeTally;

  /// No description provided for @add.
  ///
  /// In en, this message translates to:
  /// **'Add'**
  String get add;

  /// No description provided for @addNameToCounter.
  ///
  /// In en, this message translates to:
  /// **'Add a name to your counter'**
  String get addNameToCounter;

  /// No description provided for @addNewCounter.
  ///
  /// In en, this message translates to:
  /// **'Add new counter'**
  String get addNewCounter;

  /// No description provided for @addReminder.
  ///
  /// In en, this message translates to:
  /// **'Add reminder'**
  String get addReminder;

  /// No description provided for @alarmEditor.
  ///
  /// In en, this message translates to:
  /// **'Alarm Editor'**
  String get alarmEditor;

  /// No description provided for @allow.
  ///
  /// In en, this message translates to:
  /// **'Allow'**
  String get allow;

  /// No description provided for @allowNotifications.
  ///
  /// In en, this message translates to:
  /// **'Allow app to send notifications?'**
  String get allowNotifications;

  /// No description provided for @allowZikrRestoreSession.
  ///
  /// In en, this message translates to:
  /// **'Allow Zikr session restoration'**
  String get allowZikrRestoreSession;

  /// No description provided for @allowZikrRestoreSessionDesc.
  ///
  /// In en, this message translates to:
  /// **'Popup menu to resume uncompleted Zikr session '**
  String get allowZikrRestoreSessionDesc;

  /// No description provided for @appLanguage.
  ///
  /// In en, this message translates to:
  /// **'App Language'**
  String get appLanguage;

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Hisn ELmoslem'**
  String get appTitle;

  /// No description provided for @areYouSure.
  ///
  /// In en, this message translates to:
  /// **'Are you sure?'**
  String get areYouSure;

  /// No description provided for @azkarFilters.
  ///
  /// In en, this message translates to:
  /// **'Azkar Filters'**
  String get azkarFilters;

  /// No description provided for @backgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background color'**
  String get backgroundColor;

  /// No description provided for @bookmark.
  ///
  /// In en, this message translates to:
  /// **'Bookmark'**
  String get bookmark;

  /// No description provided for @cardIndex.
  ///
  /// In en, this message translates to:
  /// **'Card index'**
  String get cardIndex;

  /// No description provided for @cardMode.
  ///
  /// In en, this message translates to:
  /// **'Card Mode'**
  String get cardMode;

  /// No description provided for @channelInAppName.
  ///
  /// In en, this message translates to:
  /// **'In App Notification'**
  String get channelInAppName;

  /// No description provided for @channelInAppNameDesc.
  ///
  /// In en, this message translates to:
  /// **'For internal notifications'**
  String get channelInAppNameDesc;

  /// No description provided for @channelScheduledName.
  ///
  /// In en, this message translates to:
  /// **'Scheduled Notifications'**
  String get channelScheduledName;

  /// No description provided for @channelScheduledNameDesc.
  ///
  /// In en, this message translates to:
  /// **'For scheduled notifications'**
  String get channelScheduledNameDesc;

  /// No description provided for @chat.
  ///
  /// In en, this message translates to:
  /// **'Hisn ELmoslem App | Chat'**
  String get chat;

  /// No description provided for @chooseTimeForReminder.
  ///
  /// In en, this message translates to:
  /// **'Please choose time for the reminder'**
  String get chooseTimeForReminder;

  /// No description provided for @circleEvery.
  ///
  /// In en, this message translates to:
  /// **'Complete circle every'**
  String get circleEvery;

  /// No description provided for @circular.
  ///
  /// In en, this message translates to:
  /// **'Circular'**
  String get circular;

  /// No description provided for @clickHere.
  ///
  /// In en, this message translates to:
  /// **'Click here'**
  String get clickHere;

  /// No description provided for @clickToChooseTime.
  ///
  /// In en, this message translates to:
  /// **'Click to set the time'**
  String get clickToChooseTime;

  /// No description provided for @close.
  ///
  /// In en, this message translates to:
  /// **'Close'**
  String get close;

  /// No description provided for @commentary.
  ///
  /// In en, this message translates to:
  /// **'Commentary'**
  String get commentary;

  /// No description provided for @commentaryBenefit.
  ///
  /// In en, this message translates to:
  /// **'Fadl'**
  String get commentaryBenefit;

  /// No description provided for @commentaryHadith.
  ///
  /// In en, this message translates to:
  /// **'Hadith'**
  String get commentaryHadith;

  /// No description provided for @commentarySharh.
  ///
  /// In en, this message translates to:
  /// **'Commentary'**
  String get commentarySharh;

  /// No description provided for @contact.
  ///
  /// In en, this message translates to:
  /// **'Contact'**
  String get contact;

  /// No description provided for @contactDev.
  ///
  /// In en, this message translates to:
  /// **'Contact to Dev'**
  String get contactDev;

  /// No description provided for @copiedToClipboard.
  ///
  /// In en, this message translates to:
  /// **'Copied to clipboard'**
  String get copiedToClipboard;

  /// No description provided for @copy.
  ///
  /// In en, this message translates to:
  /// **'Copy'**
  String get copy;

  /// No description provided for @count.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get count;

  /// No description provided for @counterCircleMustBeGreaterThanZero.
  ///
  /// In en, this message translates to:
  /// **'Counter circle must be higher than zero'**
  String get counterCircleMustBeGreaterThanZero;

  /// No description provided for @counterCircleSetToZero.
  ///
  /// In en, this message translates to:
  /// **'The counter circle is set to zero when reach this number'**
  String get counterCircleSetToZero;

  /// No description provided for @counterName.
  ///
  /// In en, this message translates to:
  /// **'Counter name'**
  String get counterName;

  /// No description provided for @counters.
  ///
  /// In en, this message translates to:
  /// **'Counters'**
  String get counters;

  /// No description provided for @counterWillBeDeleted.
  ///
  /// In en, this message translates to:
  /// **'This counter will be deleted.'**
  String get counterWillBeDeleted;

  /// No description provided for @currentVersion.
  ///
  /// In en, this message translates to:
  /// **'Current version'**
  String get currentVersion;

  /// No description provided for @daily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get daily;

  /// No description provided for @darkTheme.
  ///
  /// In en, this message translates to:
  /// **'Dark Theme'**
  String get darkTheme;

  /// No description provided for @dashboardArrangement.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Arrangement'**
  String get dashboardArrangement;

  /// No description provided for @deactivate.
  ///
  /// In en, this message translates to:
  /// **'Deactivate'**
  String get deactivate;

  /// No description provided for @decreae.
  ///
  /// In en, this message translates to:
  /// **'Decreae'**
  String get decreae;

  /// No description provided for @delete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get delete;

  /// No description provided for @digitalCopyOfHisnElmoslem.
  ///
  /// In en, this message translates to:
  /// **'A digital copy of Hisn Elmoslem was used from the Aloka Network.'**
  String get digitalCopyOfHisnElmoslem;

  /// No description provided for @dislikeAboutApp.
  ///
  /// In en, this message translates to:
  /// **'I don\'t like about this app:'**
  String get dislikeAboutApp;

  /// No description provided for @dismiss.
  ///
  /// In en, this message translates to:
  /// **'Dismiss'**
  String get dismiss;

  /// No description provided for @done.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get done;

  /// No description provided for @donnotAskAgain.
  ///
  /// In en, this message translates to:
  /// **'Don\'t ask again'**
  String get donnotAskAgain;

  /// No description provided for @drSaeedBinAliBinWahf.
  ///
  /// In en, this message translates to:
  /// **'Dr. Saeed bin Ali bin Wahf Al-Qahtani'**
  String get drSaeedBinAliBinWahf;

  /// No description provided for @edit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get edit;

  /// No description provided for @editCounter.
  ///
  /// In en, this message translates to:
  /// **'Edit counter'**
  String get editCounter;

  /// No description provided for @editImageSize.
  ///
  /// In en, this message translates to:
  /// **'Edit image size'**
  String get editImageSize;

  /// No description provided for @editReminder.
  ///
  /// In en, this message translates to:
  /// **'Edit reminder'**
  String get editReminder;

  /// No description provided for @effectManager.
  ///
  /// In en, this message translates to:
  /// **'Effect Control'**
  String get effectManager;

  /// No description provided for @enableAzkarFilters.
  ///
  /// In en, this message translates to:
  /// **'Enable Azkar filters'**
  String get enableAzkarFilters;

  /// No description provided for @enableWakeLock.
  ///
  /// In en, this message translates to:
  /// **'Enable wake lock'**
  String get enableWakeLock;

  /// No description provided for @endSuraAliImran.
  ///
  /// In en, this message translates to:
  /// **'End of Surah Ali \'Imran'**
  String get endSuraAliImran;

  /// No description provided for @errorEmailAppOpen.
  ///
  /// In en, this message translates to:
  /// **'Unable to open mail app'**
  String get errorEmailAppOpen;

  /// No description provided for @errorOccurred.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong!'**
  String get errorOccurred;

  /// No description provided for @everyFriday.
  ///
  /// In en, this message translates to:
  /// **'Every Friday'**
  String get everyFriday;

  /// No description provided for @everyMonday.
  ///
  /// In en, this message translates to:
  /// **'Every Monday'**
  String get everyMonday;

  /// No description provided for @everySaturday.
  ///
  /// In en, this message translates to:
  /// **'Every Saturday'**
  String get everySaturday;

  /// No description provided for @everySunday.
  ///
  /// In en, this message translates to:
  /// **'Every Sunday'**
  String get everySunday;

  /// No description provided for @everyThursday.
  ///
  /// In en, this message translates to:
  /// **'Every Thursday'**
  String get everyThursday;

  /// No description provided for @everyTuesday.
  ///
  /// In en, this message translates to:
  /// **'Every Tuesday'**
  String get everyTuesday;

  /// No description provided for @everyWednesday.
  ///
  /// In en, this message translates to:
  /// **'Every Wednesday'**
  String get everyWednesday;

  /// No description provided for @fakeHadith.
  ///
  /// In en, this message translates to:
  /// **'Fake Hadith'**
  String get fakeHadith;

  /// No description provided for @fastingMondaysThursdaysReminder.
  ///
  /// In en, this message translates to:
  /// **'Fasting Mondays and Thursdays Reminder'**
  String get fastingMondaysThursdaysReminder;

  /// No description provided for @favoritesContent.
  ///
  /// In en, this message translates to:
  /// **'favorites'**
  String get favoritesContent;

  /// No description provided for @favoritesZikr.
  ///
  /// In en, this message translates to:
  /// **'Favourite Zikr'**
  String get favoritesZikr;

  /// No description provided for @featuresToBeAdded.
  ///
  /// In en, this message translates to:
  /// **'Features I hope to be added:'**
  String get featuresToBeAdded;

  /// No description provided for @fixedSizeMode.
  ///
  /// In en, this message translates to:
  /// **'Fixed size mode'**
  String get fixedSizeMode;

  /// No description provided for @fontDecreaeSize.
  ///
  /// In en, this message translates to:
  /// **'Decreae font size'**
  String get fontDecreaeSize;

  /// No description provided for @fontIncreaeSize.
  ///
  /// In en, this message translates to:
  /// **'Increae font size'**
  String get fontIncreaeSize;

  /// No description provided for @fontResetSize.
  ///
  /// In en, this message translates to:
  /// **'Reset font size'**
  String get fontResetSize;

  /// No description provided for @fontSettings.
  ///
  /// In en, this message translates to:
  /// **'Font Settings'**
  String get fontSettings;

  /// No description provided for @fontType.
  ///
  /// In en, this message translates to:
  /// **'Font Type'**
  String get fontType;

  /// No description provided for @freeAdFreeAndOpenSourceApp.
  ///
  /// In en, this message translates to:
  /// **'Free, ad-free and open source app'**
  String get freeAdFreeAndOpenSourceApp;

  /// No description provided for @freqAnnual.
  ///
  /// In en, this message translates to:
  /// **'Annual'**
  String get freqAnnual;

  /// No description provided for @freqDaily.
  ///
  /// In en, this message translates to:
  /// **'Daily'**
  String get freqDaily;

  /// No description provided for @freqMonthly.
  ///
  /// In en, this message translates to:
  /// **'Monthly'**
  String get freqMonthly;

  /// No description provided for @freqWeekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get freqWeekly;

  /// No description provided for @general.
  ///
  /// In en, this message translates to:
  /// **'General'**
  String get general;

  /// No description provided for @github.
  ///
  /// In en, this message translates to:
  /// **'Github source code'**
  String get github;

  /// No description provided for @goTo.
  ///
  /// In en, this message translates to:
  /// **'Go to'**
  String get goTo;

  /// No description provided for @haveBeenRead.
  ///
  /// In en, this message translates to:
  /// **'Read'**
  String get haveBeenRead;

  /// No description provided for @haveNotOpenedAppLongTime.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t opened the app for a long time.'**
  String get haveNotOpenedAppLongTime;

  /// No description provided for @haveNotReadAnythingYet.
  ///
  /// In en, this message translates to:
  /// **'You haven\'t read anything yet'**
  String get haveNotReadAnythingYet;

  /// No description provided for @hisnElmoslem.
  ///
  /// In en, this message translates to:
  /// **'Hisn Elmoslem'**
  String get hisnElmoslem;

  /// No description provided for @hisnElmoslemApp.
  ///
  /// In en, this message translates to:
  /// **'Hisn Elmoslem App'**
  String get hisnElmoslemApp;

  /// No description provided for @hisnElmoslemAppVersion.
  ///
  /// In en, this message translates to:
  /// **'Hisn ELmoslem App Version'**
  String get hisnElmoslemAppVersion;

  /// No description provided for @hokmAthar.
  ///
  /// In en, this message translates to:
  /// **'Athar'**
  String get hokmAthar;

  /// No description provided for @hokmDaeif.
  ///
  /// In en, this message translates to:
  /// **'Weak'**
  String get hokmDaeif;

  /// No description provided for @hokmHasan.
  ///
  /// In en, this message translates to:
  /// **'Good'**
  String get hokmHasan;

  /// No description provided for @hokmMawdue.
  ///
  /// In en, this message translates to:
  /// **'Fabricated'**
  String get hokmMawdue;

  /// No description provided for @hokmSahih.
  ///
  /// In en, this message translates to:
  /// **'Authentic'**
  String get hokmSahih;

  /// No description provided for @imageQuality.
  ///
  /// In en, this message translates to:
  /// **'Image quality'**
  String get imageQuality;

  /// No description provided for @imageWidth.
  ///
  /// In en, this message translates to:
  /// **'Image width'**
  String get imageWidth;

  /// No description provided for @index.
  ///
  /// In en, this message translates to:
  /// **'Index'**
  String get index;

  /// No description provided for @later.
  ///
  /// In en, this message translates to:
  /// **'Later'**
  String get later;

  /// No description provided for @lightTheme.
  ///
  /// In en, this message translates to:
  /// **'Light Theme'**
  String get lightTheme;

  /// No description provided for @likeAboutApp.
  ///
  /// In en, this message translates to:
  /// **'I like about this app:'**
  String get likeAboutApp;

  /// No description provided for @message.
  ///
  /// In en, this message translates to:
  /// **'Message'**
  String get message;

  /// No description provided for @misspelled.
  ///
  /// In en, this message translates to:
  /// **'Misspelled'**
  String get misspelled;

  /// No description provided for @moreApps.
  ///
  /// In en, this message translates to:
  /// **'More apps'**
  String get moreApps;

  /// No description provided for @newText.
  ///
  /// In en, this message translates to:
  /// **'New'**
  String get newText;

  /// No description provided for @next.
  ///
  /// In en, this message translates to:
  /// **'Next'**
  String get next;

  /// No description provided for @no.
  ///
  /// In en, this message translates to:
  /// **'No'**
  String get no;

  /// No description provided for @noActiveCounter.
  ///
  /// In en, this message translates to:
  /// **'No active counter'**
  String get noActiveCounter;

  /// No description provided for @noAlarmSetForAnyZikr.
  ///
  /// In en, this message translates to:
  /// **'No alarm has been set for any zikr If you want to set an alarm, click on the alarm sign next to the zikr title'**
  String get noAlarmSetForAnyZikr;

  /// No description provided for @none.
  ///
  /// In en, this message translates to:
  /// **'None'**
  String get none;

  /// No description provided for @noRemindersFound.
  ///
  /// In en, this message translates to:
  /// **'No reminders found'**
  String get noRemindersFound;

  /// No description provided for @notes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get notes;

  /// No description provided for @nothingFoundInFavorites.
  ///
  /// In en, this message translates to:
  /// **'Nothing found in favorites'**
  String get nothingFoundInFavorites;

  /// No description provided for @notificationPermissionRequired.
  ///
  /// In en, this message translates to:
  /// **'Hisn ELmoslem need notification permission to send zikr reminders.'**
  String get notificationPermissionRequired;

  /// No description provided for @noTitleMarkedAsFavorite.
  ///
  /// In en, this message translates to:
  /// **'No title from the index is marked as a favourite. Click on the Favorites icon at any index title'**
  String get noTitleMarkedAsFavorite;

  /// No description provided for @noTitleWithName.
  ///
  /// In en, this message translates to:
  /// **'No title with this name'**
  String get noTitleWithName;

  /// No description provided for @noZikrSelectedAsFavorite.
  ///
  /// In en, this message translates to:
  /// **'No zikr has been selected as a favorite Click on the heart icon on any internal zikr'**
  String get noZikrSelectedAsFavorite;

  /// No description provided for @officialWebsite.
  ///
  /// In en, this message translates to:
  /// **'Official Website'**
  String get officialWebsite;

  /// No description provided for @optimizeDarkTheme.
  ///
  /// In en, this message translates to:
  /// **'Optimized Dark Theme'**
  String get optimizeDarkTheme;

  /// No description provided for @optimizeLightTheme.
  ///
  /// In en, this message translates to:
  /// **'Optimized Light Theme'**
  String get optimizeLightTheme;

  /// No description provided for @ourProducts.
  ///
  /// In en, this message translates to:
  /// **'Our Products'**
  String get ourProducts;

  /// No description provided for @pageMode.
  ///
  /// In en, this message translates to:
  /// **'Page Mode'**
  String get pageMode;

  /// No description provided for @phoneVibrationAtEveryPraise.
  ///
  /// In en, this message translates to:
  /// **'Phone vibration at every praise'**
  String get phoneVibrationAtEveryPraise;

  /// No description provided for @phoneVibrationAtSingleZikrEnd.
  ///
  /// In en, this message translates to:
  /// **'Phone vibration at single zikr end'**
  String get phoneVibrationAtSingleZikrEnd;

  /// No description provided for @phoneVibrationWhenAllZikrEnd.
  ///
  /// In en, this message translates to:
  /// **'Phone vibration when all zikr end'**
  String get phoneVibrationWhenAllZikrEnd;

  /// No description provided for @prayForUsAndParents.
  ///
  /// In en, this message translates to:
  /// **'Pray for us and our parents.'**
  String get prayForUsAndParents;

  /// No description provided for @prefPraiseWithVolumeKeys.
  ///
  /// In en, this message translates to:
  /// **'Praise with volume keys'**
  String get prefPraiseWithVolumeKeys;

  /// No description provided for @prefPraiseWithVolumeKeysDesc.
  ///
  /// In en, this message translates to:
  /// **'Praise with volume keys in page mode and tally'**
  String get prefPraiseWithVolumeKeysDesc;

  /// No description provided for @previous.
  ///
  /// In en, this message translates to:
  /// **'Previous'**
  String get previous;

  /// No description provided for @progressDeletedCannotUndo.
  ///
  /// In en, this message translates to:
  /// **'Your progress will be deleted and you can\'t undo that'**
  String get progressDeletedCannotUndo;

  /// No description provided for @prophetSaidLiesIntentional.
  ///
  /// In en, this message translates to:
  /// **'The Prophet (may Allah’s peace and blessings be upon him) said: \"Whoever tells lies about me intentionally should take his seat in Hellfire.\"'**
  String get prophetSaidLiesIntentional;

  /// No description provided for @quranPagesFromAndroidQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran pages are from android quran'**
  String get quranPagesFromAndroidQuran;

  /// No description provided for @rateTheApp.
  ///
  /// In en, this message translates to:
  /// **'Hisn ELmoslem App | Rate the app'**
  String get rateTheApp;

  /// No description provided for @readAllContent.
  ///
  /// In en, this message translates to:
  /// **'You have read all content'**
  String get readAllContent;

  /// No description provided for @reminderRemoved.
  ///
  /// In en, this message translates to:
  /// **'Reminder Removed'**
  String get reminderRemoved;

  /// No description provided for @reminders.
  ///
  /// In en, this message translates to:
  /// **'Reminders'**
  String get reminders;

  /// No description provided for @remindersManager.
  ///
  /// In en, this message translates to:
  /// **'Reminders Control'**
  String get remindersManager;

  /// No description provided for @report.
  ///
  /// In en, this message translates to:
  /// **'Report'**
  String get report;

  /// No description provided for @reportBugsRequestFeatures.
  ///
  /// In en, this message translates to:
  /// **'Report bugs and request new features'**
  String get reportBugsRequestFeatures;

  /// No description provided for @requiresAppRestart.
  ///
  /// In en, this message translates to:
  /// **'Requires app restart'**
  String get requiresAppRestart;

  /// No description provided for @reset.
  ///
  /// In en, this message translates to:
  /// **'Reset'**
  String get reset;

  /// No description provided for @resetAllCounters.
  ///
  /// In en, this message translates to:
  /// **'Reset all counters?'**
  String get resetAllCounters;

  /// No description provided for @resetZikr.
  ///
  /// In en, this message translates to:
  /// **'Reset Zikr'**
  String get resetZikr;

  /// No description provided for @reviewIndexOfBook.
  ///
  /// In en, this message translates to:
  /// **'Please review the index of the book'**
  String get reviewIndexOfBook;

  /// No description provided for @search.
  ///
  /// In en, this message translates to:
  /// **'Search'**
  String get search;

  /// No description provided for @select.
  ///
  /// In en, this message translates to:
  /// **'Select'**
  String get select;

  /// No description provided for @selectAzkarHokmFilters.
  ///
  /// In en, this message translates to:
  /// **'Select hokm of Azakr'**
  String get selectAzkarHokmFilters;

  /// No description provided for @selectAzkarSource.
  ///
  /// In en, this message translates to:
  /// **'Select source of Azkar'**
  String get selectAzkarSource;

  /// No description provided for @selectColor.
  ///
  /// In en, this message translates to:
  /// **'Select color'**
  String get selectColor;

  /// No description provided for @sendEmail.
  ///
  /// In en, this message translates to:
  /// **'Send Email'**
  String get sendEmail;

  /// No description provided for @setMessageForYou.
  ///
  /// In en, this message translates to:
  /// **'Set message for yourself'**
  String get setMessageForYou;

  /// No description provided for @settings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get settings;

  /// No description provided for @share.
  ///
  /// In en, this message translates to:
  /// **'Share'**
  String get share;

  /// No description provided for @shareAsImage.
  ///
  /// In en, this message translates to:
  /// **'Share as image'**
  String get shareAsImage;

  /// No description provided for @shareZikr.
  ///
  /// In en, this message translates to:
  /// **'Share Zikr'**
  String get shareZikr;

  /// No description provided for @shouldBe.
  ///
  /// In en, this message translates to:
  /// **'It should be:'**
  String get shouldBe;

  /// No description provided for @showDiacritics.
  ///
  /// In en, this message translates to:
  /// **'Show Diacritics'**
  String get showDiacritics;

  /// No description provided for @showFadl.
  ///
  /// In en, this message translates to:
  /// **'Show fadl'**
  String get showFadl;

  /// No description provided for @showSourceOfZikr.
  ///
  /// In en, this message translates to:
  /// **'Show source of zikr'**
  String get showSourceOfZikr;

  /// No description provided for @showZikrIndex.
  ///
  /// In en, this message translates to:
  /// **'Show zikr index'**
  String get showZikrIndex;

  /// No description provided for @shuffle.
  ///
  /// In en, this message translates to:
  /// **'Shuffle'**
  String get shuffle;

  /// No description provided for @shuffleModeActivated.
  ///
  /// In en, this message translates to:
  /// **'Shuffle Mode Activated'**
  String get shuffleModeActivated;

  /// No description provided for @shuffleModeDeactivated.
  ///
  /// In en, this message translates to:
  /// **'Shuffle Mode Deactivated'**
  String get shuffleModeDeactivated;

  /// No description provided for @skip.
  ///
  /// In en, this message translates to:
  /// **'Skip'**
  String get skip;

  /// No description provided for @soundEffectAtEveryPraise.
  ///
  /// In en, this message translates to:
  /// **'Sound effect at every praise'**
  String get soundEffectAtEveryPraise;

  /// No description provided for @soundEffectAtSingleZikrEnd.
  ///
  /// In en, this message translates to:
  /// **'Sound effect at single zikr end'**
  String get soundEffectAtSingleZikrEnd;

  /// No description provided for @soundEffectVolume.
  ///
  /// In en, this message translates to:
  /// **'Sound Effect volume'**
  String get soundEffectVolume;

  /// No description provided for @soundEffectWhenAllZikrEnd.
  ///
  /// In en, this message translates to:
  /// **'Sound effect when all zikr end'**
  String get soundEffectWhenAllZikrEnd;

  /// No description provided for @sourceAbuDawood.
  ///
  /// In en, this message translates to:
  /// **'Sunan Abi Dawud'**
  String get sourceAbuDawood;

  /// No description provided for @sourceAdDarami.
  ///
  /// In en, this message translates to:
  /// **'Sunan al-Darimi'**
  String get sourceAdDarami;

  /// No description provided for @sourceAhmad.
  ///
  /// In en, this message translates to:
  /// **'Musnad Ahmad ibn Hanbal'**
  String get sourceAhmad;

  /// No description provided for @sourceAnNasai.
  ///
  /// In en, this message translates to:
  /// **'Al-Sunan al-Sughra by al-Nasa\'i'**
  String get sourceAnNasai;

  /// No description provided for @sourceAthar.
  ///
  /// In en, this message translates to:
  /// **'Athr'**
  String get sourceAthar;

  /// No description provided for @sourceAtTabarani.
  ///
  /// In en, this message translates to:
  /// **'at-Tabarani'**
  String get sourceAtTabarani;

  /// No description provided for @sourceAtTirmidhi.
  ///
  /// In en, this message translates to:
  /// **'Sunan al-Tirmidhi'**
  String get sourceAtTirmidhi;

  /// No description provided for @sourceBayhaqi.
  ///
  /// In en, this message translates to:
  /// **'Sunan al-Bayhaqi'**
  String get sourceBayhaqi;

  /// No description provided for @sourceHakim.
  ///
  /// In en, this message translates to:
  /// **'Al-Mustadrak ala al-Sahihayn'**
  String get sourceHakim;

  /// No description provided for @sourceIbnMajah.
  ///
  /// In en, this message translates to:
  /// **'Sunan IbnMajah'**
  String get sourceIbnMajah;

  /// No description provided for @sourceIbnSunny.
  ///
  /// In en, this message translates to:
  /// **'IbnSunny'**
  String get sourceIbnSunny;

  /// No description provided for @sourceMalik.
  ///
  /// In en, this message translates to:
  /// **'Muwatta Imam Malik'**
  String get sourceMalik;

  /// No description provided for @sourceQuran.
  ///
  /// In en, this message translates to:
  /// **'Quran'**
  String get sourceQuran;

  /// No description provided for @sourceSahihBukhari.
  ///
  /// In en, this message translates to:
  /// **'Sahih al-Bukhari'**
  String get sourceSahihBukhari;

  /// No description provided for @sourceSahihMuslim.
  ///
  /// In en, this message translates to:
  /// **'Sahih Muslim'**
  String get sourceSahihMuslim;

  /// No description provided for @spellingErrorIn.
  ///
  /// In en, this message translates to:
  /// **'There is a spelling error in'**
  String get spellingErrorIn;

  /// No description provided for @start.
  ///
  /// In en, this message translates to:
  /// **'Start'**
  String get start;

  /// No description provided for @subject.
  ///
  /// In en, this message translates to:
  /// **'Subject'**
  String get subject;

  /// No description provided for @subtitleColor.
  ///
  /// In en, this message translates to:
  /// **'Subtitle color'**
  String get subtitleColor;

  /// No description provided for @suraAlKahf.
  ///
  /// In en, this message translates to:
  /// **'Surah Al-Kahf'**
  String get suraAlKahf;

  /// No description provided for @suraAlKahfReminder.
  ///
  /// In en, this message translates to:
  /// **'Surah Al-Kahf Reminder'**
  String get suraAlKahfReminder;

  /// No description provided for @suraAlMulk.
  ///
  /// In en, this message translates to:
  /// **'Surah Al-Mulk'**
  String get suraAlMulk;

  /// No description provided for @suraAsSajdah.
  ///
  /// In en, this message translates to:
  /// **'Surah As-Sajdah'**
  String get suraAsSajdah;

  /// No description provided for @tally.
  ///
  /// In en, this message translates to:
  /// **'Tally'**
  String get tally;

  /// No description provided for @tallyEditor.
  ///
  /// In en, this message translates to:
  /// **'Tally Editor'**
  String get tallyEditor;

  /// No description provided for @text.
  ///
  /// In en, this message translates to:
  /// **'Text'**
  String get text;

  /// No description provided for @textColor.
  ///
  /// In en, this message translates to:
  /// **'Text color'**
  String get textColor;

  /// No description provided for @themeAppColor.
  ///
  /// In en, this message translates to:
  /// **'App Color'**
  String get themeAppColor;

  /// No description provided for @themeBackgroundColor.
  ///
  /// In en, this message translates to:
  /// **'Background Color'**
  String get themeBackgroundColor;

  /// No description provided for @themeDarkMode.
  ///
  /// In en, this message translates to:
  /// **'Dark Mode'**
  String get themeDarkMode;

  /// No description provided for @themeManager.
  ///
  /// In en, this message translates to:
  /// **'Theme Control'**
  String get themeManager;

  /// No description provided for @themeOverrideBackground.
  ///
  /// In en, this message translates to:
  /// **'Override Background'**
  String get themeOverrideBackground;

  /// No description provided for @themeSelectColor.
  ///
  /// In en, this message translates to:
  /// **'Select Color'**
  String get themeSelectColor;

  /// No description provided for @themeUseMaterial3.
  ///
  /// In en, this message translates to:
  /// **'Use Material3'**
  String get themeUseMaterial3;

  /// No description provided for @themeUserOldTheme.
  ///
  /// In en, this message translates to:
  /// **'User Old Theme'**
  String get themeUserOldTheme;

  /// No description provided for @times.
  ///
  /// In en, this message translates to:
  /// **'Times'**
  String get times;

  /// No description provided for @title.
  ///
  /// In en, this message translates to:
  /// **'Title'**
  String get title;

  /// No description provided for @titleColor.
  ///
  /// In en, this message translates to:
  /// **'Title color'**
  String get titleColor;

  /// No description provided for @trueBlackTheme.
  ///
  /// In en, this message translates to:
  /// **'True black Theme'**
  String get trueBlackTheme;

  /// No description provided for @updatesHistory.
  ///
  /// In en, this message translates to:
  /// **'Updates History'**
  String get updatesHistory;

  /// No description provided for @useHindiDigits.
  ///
  /// In en, this message translates to:
  /// **'Use Hindi Digits'**
  String get useHindiDigits;

  /// No description provided for @version.
  ///
  /// In en, this message translates to:
  /// **'Version'**
  String get version;

  /// No description provided for @yes.
  ///
  /// In en, this message translates to:
  /// **'Yes'**
  String get yes;

  /// No description provided for @zikrIndex.
  ///
  /// In en, this message translates to:
  /// **'Zikr Index'**
  String get zikrIndex;

  /// No description provided for @zikrViewerRestoreSessionMsg.
  ///
  /// In en, this message translates to:
  /// **'We found a previous session, would you like to restore it?'**
  String get zikrViewerRestoreSessionMsg;
}

class _SDelegate extends LocalizationsDelegate<S> {
  const _SDelegate();

  @override
  Future<S> load(Locale locale) {
    return SynchronousFuture<S>(lookupS(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_SDelegate old) => false;
}

S lookupS(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return SAr();
    case 'en':
      return SEn();
  }

  throw FlutterError(
    'S.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
