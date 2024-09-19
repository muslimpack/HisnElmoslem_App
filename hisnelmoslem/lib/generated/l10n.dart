// GENERATED CODE - DO NOT MODIFY BY HAND
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'intl/messages_all.dart';

// **************************************************************************
// Generator: Flutter Intl IDE plugin
// Made by Localizely
// **************************************************************************

// ignore_for_file: non_constant_identifier_names, lines_longer_than_80_chars
// ignore_for_file: join_return_with_assignment, prefer_final_in_for_each
// ignore_for_file: avoid_redundant_argument_values, avoid_escaping_inner_quotes

class S {
  S();

  static S? _current;

  static S get current {
    assert(_current != null,
        'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate = AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false)
        ? locale.languageCode
        : locale.toString();
    final localeName = Intl.canonicalizedLocale(name);
    return initializeMessages(localeName).then((_) {
      Intl.defaultLocale = localeName;
      final instance = S();
      S._current = instance;

      return instance;
    });
  }

  static S of(BuildContext context) {
    final instance = S.maybeOf(context);
    assert(instance != null,
        'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `About Us`
  String get aboutUs {
    return Intl.message(
      'About Us',
      name: 'aboutUs',
      desc: '',
      args: [],
    );
  }

  /// `Activate`
  String get activate {
    return Intl.message(
      'Activate',
      name: 'activate',
      desc: '',
      args: [],
    );
  }

  /// `To activate counter go to counters then click to counter icon beside the counter you want`
  String get activateCounterInstructions {
    return Intl.message(
      'To activate counter go to counters then click to counter icon beside the counter you want',
      name: 'activateCounterInstructions',
      desc: '',
      args: [],
    );
  }

  /// `Active tally`
  String get activeTally {
    return Intl.message(
      'Active tally',
      name: 'activeTally',
      desc: '',
      args: [],
    );
  }

  /// `Add a name to your counter`
  String get addNameToCounter {
    return Intl.message(
      'Add a name to your counter',
      name: 'addNameToCounter',
      desc: '',
      args: [],
    );
  }

  /// `Add new counter`
  String get addNewCounter {
    return Intl.message(
      'Add new counter',
      name: 'addNewCounter',
      desc: '',
      args: [],
    );
  }

  /// `Add reminder`
  String get addReminder {
    return Intl.message(
      'Add reminder',
      name: 'addReminder',
      desc: '',
      args: [],
    );
  }

  /// `Allow`
  String get allow {
    return Intl.message(
      'Allow',
      name: 'allow',
      desc: '',
      args: [],
    );
  }

  /// `Allow app to send notifications?`
  String get allowNotifications {
    return Intl.message(
      'Allow app to send notifications?',
      name: 'allowNotifications',
      desc: '',
      args: [],
    );
  }

  /// `App Language`
  String get appLanguage {
    return Intl.message(
      'App Language',
      name: 'appLanguage',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure?`
  String get areYouSure {
    return Intl.message(
      'Are you sure?',
      name: 'areYouSure',
      desc: '',
      args: [],
    );
  }

  /// `Azkar Filters`
  String get azkarFilters {
    return Intl.message(
      'Azkar Filters',
      name: 'azkarFilters',
      desc: '',
      args: [],
    );
  }

  /// `Background color`
  String get backgroundColor {
    return Intl.message(
      'Background color',
      name: 'backgroundColor',
      desc: '',
      args: [],
    );
  }

  /// `Card index`
  String get cardIndex {
    return Intl.message(
      'Card index',
      name: 'cardIndex',
      desc: '',
      args: [],
    );
  }

  /// `Card Mode`
  String get cardMode {
    return Intl.message(
      'Card Mode',
      name: 'cardMode',
      desc: '',
      args: [],
    );
  }

  /// `In App Notification`
  String get channelInAppName {
    return Intl.message(
      'In App Notification',
      name: 'channelInAppName',
      desc: '',
      args: [],
    );
  }

  /// `For internal notifications`
  String get channelInAppNameDesc {
    return Intl.message(
      'For internal notifications',
      name: 'channelInAppNameDesc',
      desc: '',
      args: [],
    );
  }

  /// `Scheduled Notifications`
  String get channelScheduledName {
    return Intl.message(
      'Scheduled Notifications',
      name: 'channelScheduledName',
      desc: '',
      args: [],
    );
  }

  /// `For scheduled notifications`
  String get channelScheduledNameDesc {
    return Intl.message(
      'For scheduled notifications',
      name: 'channelScheduledNameDesc',
      desc: '',
      args: [],
    );
  }

  /// `Hisn ELmoslem App | Chat`
  String get chat {
    return Intl.message(
      'Hisn ELmoslem App | Chat',
      name: 'chat',
      desc: '',
      args: [],
    );
  }

  /// `Please choose time for the reminder`
  String get chooseTimeForReminder {
    return Intl.message(
      'Please choose time for the reminder',
      name: 'chooseTimeForReminder',
      desc: '',
      args: [],
    );
  }

  /// `Complete circle every`
  String get circleEvery {
    return Intl.message(
      'Complete circle every',
      name: 'circleEvery',
      desc: '',
      args: [],
    );
  }

  /// `Click here`
  String get clickHere {
    return Intl.message(
      'Click here',
      name: 'clickHere',
      desc: '',
      args: [],
    );
  }

  /// `Click to set the time`
  String get clickToChooseTime {
    return Intl.message(
      'Click to set the time',
      name: 'clickToChooseTime',
      desc: '',
      args: [],
    );
  }

  /// `Close`
  String get close {
    return Intl.message(
      'Close',
      name: 'close',
      desc: '',
      args: [],
    );
  }

  /// `Fadl`
  String get commentaryBenefit {
    return Intl.message(
      'Fadl',
      name: 'commentaryBenefit',
      desc: '',
      args: [],
    );
  }

  /// `Hadith`
  String get commentaryHadith {
    return Intl.message(
      'Hadith',
      name: 'commentaryHadith',
      desc: '',
      args: [],
    );
  }

  /// `Commentary`
  String get commentarySharh {
    return Intl.message(
      'Commentary',
      name: 'commentarySharh',
      desc: '',
      args: [],
    );
  }

  /// `Contact`
  String get contact {
    return Intl.message(
      'Contact',
      name: 'contact',
      desc: '',
      args: [],
    );
  }

  /// `Contact to Dev`
  String get contactDev {
    return Intl.message(
      'Contact to Dev',
      name: 'contactDev',
      desc: '',
      args: [],
    );
  }

  /// `Copied to clipboard`
  String get copiedToClipboard {
    return Intl.message(
      'Copied to clipboard',
      name: 'copiedToClipboard',
      desc: '',
      args: [],
    );
  }

  /// `Copy`
  String get copy {
    return Intl.message(
      'Copy',
      name: 'copy',
      desc: '',
      args: [],
    );
  }

  /// `Counter circle must be higher than zero`
  String get counterCircleMustBeGreaterThanZero {
    return Intl.message(
      'Counter circle must be higher than zero',
      name: 'counterCircleMustBeGreaterThanZero',
      desc: '',
      args: [],
    );
  }

  /// `The counter circle is set to zero when reach this number`
  String get counterCircleSetToZero {
    return Intl.message(
      'The counter circle is set to zero when reach this number',
      name: 'counterCircleSetToZero',
      desc: '',
      args: [],
    );
  }

  /// `Counter name`
  String get counterName {
    return Intl.message(
      'Counter name',
      name: 'counterName',
      desc: '',
      args: [],
    );
  }

  /// `Counters`
  String get counters {
    return Intl.message(
      'Counters',
      name: 'counters',
      desc: '',
      args: [],
    );
  }

  /// `This counter will be deleted.`
  String get counterWillBeDeleted {
    return Intl.message(
      'This counter will be deleted.',
      name: 'counterWillBeDeleted',
      desc: '',
      args: [],
    );
  }

  /// `Current version`
  String get currentVersion {
    return Intl.message(
      'Current version',
      name: 'currentVersion',
      desc: '',
      args: [],
    );
  }

  /// `Daily`
  String get daily {
    return Intl.message(
      'Daily',
      name: 'daily',
      desc: '',
      args: [],
    );
  }

  /// `Dark Theme`
  String get darkTheme {
    return Intl.message(
      'Dark Theme',
      name: 'darkTheme',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard Arrangement`
  String get dashboardArrangement {
    return Intl.message(
      'Dashboard Arrangement',
      name: 'dashboardArrangement',
      desc: '',
      args: [],
    );
  }

  /// `Deactivate`
  String get deactivate {
    return Intl.message(
      'Deactivate',
      name: 'deactivate',
      desc: '',
      args: [],
    );
  }

  /// `Delete`
  String get delete {
    return Intl.message(
      'Delete',
      name: 'delete',
      desc: '',
      args: [],
    );
  }

  /// `A digital copy of Hisn Elmoslem was used from the Aloka Network.`
  String get digitalCopyOfHisnElmoslem {
    return Intl.message(
      'A digital copy of Hisn Elmoslem was used from the Aloka Network.',
      name: 'digitalCopyOfHisnElmoslem',
      desc: '',
      args: [],
    );
  }

  /// `I don't like about this app:`
  String get dislikeAboutApp {
    return Intl.message(
      'I don\'t like about this app:',
      name: 'dislikeAboutApp',
      desc: '',
      args: [],
    );
  }

  /// `Dismiss`
  String get dismiss {
    return Intl.message(
      'Dismiss',
      name: 'dismiss',
      desc: '',
      args: [],
    );
  }

  /// `Done`
  String get done {
    return Intl.message(
      'Done',
      name: 'done',
      desc: '',
      args: [],
    );
  }

  /// `Dr. Saeed bin Ali bin Wahf Al-Qahtani`
  String get drSaeedBinAliBinWahf {
    return Intl.message(
      'Dr. Saeed bin Ali bin Wahf Al-Qahtani',
      name: 'drSaeedBinAliBinWahf',
      desc: '',
      args: [],
    );
  }

  /// `Edit`
  String get edit {
    return Intl.message(
      'Edit',
      name: 'edit',
      desc: '',
      args: [],
    );
  }

  /// `Edit counter`
  String get editCounter {
    return Intl.message(
      'Edit counter',
      name: 'editCounter',
      desc: '',
      args: [],
    );
  }

  /// `Edit image size`
  String get editImageSize {
    return Intl.message(
      'Edit image size',
      name: 'editImageSize',
      desc: '',
      args: [],
    );
  }

  /// `Edit reminder`
  String get editReminder {
    return Intl.message(
      'Edit reminder',
      name: 'editReminder',
      desc: '',
      args: [],
    );
  }

  /// `Effect Control`
  String get effectManager {
    return Intl.message(
      'Effect Control',
      name: 'effectManager',
      desc: '',
      args: [],
    );
  }

  /// `Enable Azkar filters`
  String get enableAzkarFilters {
    return Intl.message(
      'Enable Azkar filters',
      name: 'enableAzkarFilters',
      desc: '',
      args: [],
    );
  }

  /// `Enable wake lock`
  String get enableWakeLock {
    return Intl.message(
      'Enable wake lock',
      name: 'enableWakeLock',
      desc: '',
      args: [],
    );
  }

  /// `End of Surah Ali 'Imran`
  String get endSuraAliImran {
    return Intl.message(
      'End of Surah Ali \'Imran',
      name: 'endSuraAliImran',
      desc: '',
      args: [],
    );
  }

  /// `Every Friday`
  String get everyFriday {
    return Intl.message(
      'Every Friday',
      name: 'everyFriday',
      desc: '',
      args: [],
    );
  }

  /// `Every Monday`
  String get everyMonday {
    return Intl.message(
      'Every Monday',
      name: 'everyMonday',
      desc: '',
      args: [],
    );
  }

  /// `Every Saturday`
  String get everySaturday {
    return Intl.message(
      'Every Saturday',
      name: 'everySaturday',
      desc: '',
      args: [],
    );
  }

  /// `Every Sunday`
  String get everySunday {
    return Intl.message(
      'Every Sunday',
      name: 'everySunday',
      desc: '',
      args: [],
    );
  }

  /// `Every Thursday`
  String get everyThursday {
    return Intl.message(
      'Every Thursday',
      name: 'everyThursday',
      desc: '',
      args: [],
    );
  }

  /// `Every Tuesday`
  String get everyTuesday {
    return Intl.message(
      'Every Tuesday',
      name: 'everyTuesday',
      desc: '',
      args: [],
    );
  }

  /// `Every Wednesday`
  String get everyWednesday {
    return Intl.message(
      'Every Wednesday',
      name: 'everyWednesday',
      desc: '',
      args: [],
    );
  }

  /// `Fake Hadith`
  String get fakeHadith {
    return Intl.message(
      'Fake Hadith',
      name: 'fakeHadith',
      desc: '',
      args: [],
    );
  }

  /// `Fasting Mondays and Thursdays Reminder`
  String get fastingMondaysThursdaysReminder {
    return Intl.message(
      'Fasting Mondays and Thursdays Reminder',
      name: 'fastingMondaysThursdaysReminder',
      desc: '',
      args: [],
    );
  }

  /// `favorites`
  String get favoritesContent {
    return Intl.message(
      'favorites',
      name: 'favoritesContent',
      desc: '',
      args: [],
    );
  }

  /// `Favourite Zikr`
  String get favoritesZikr {
    return Intl.message(
      'Favourite Zikr',
      name: 'favoritesZikr',
      desc: '',
      args: [],
    );
  }

  /// `Features I hope to be added:`
  String get featuresToBeAdded {
    return Intl.message(
      'Features I hope to be added:',
      name: 'featuresToBeAdded',
      desc: '',
      args: [],
    );
  }

  /// `Fixed size mode`
  String get fixedSizeMode {
    return Intl.message(
      'Fixed size mode',
      name: 'fixedSizeMode',
      desc: '',
      args: [],
    );
  }

  /// `Font Settings`
  String get fontSettings {
    return Intl.message(
      'Font Settings',
      name: 'fontSettings',
      desc: '',
      args: [],
    );
  }

  /// `Font Type`
  String get fontType {
    return Intl.message(
      'Font Type',
      name: 'fontType',
      desc: '',
      args: [],
    );
  }

  /// `Free, ad-free and open source app`
  String get freeAdFreeAndOpenSourceApp {
    return Intl.message(
      'Free, ad-free and open source app',
      name: 'freeAdFreeAndOpenSourceApp',
      desc: '',
      args: [],
    );
  }

  /// `Annual`
  String get freqAnnual {
    return Intl.message(
      'Annual',
      name: 'freqAnnual',
      desc: '',
      args: [],
    );
  }

  /// `Daily`
  String get freqDaily {
    return Intl.message(
      'Daily',
      name: 'freqDaily',
      desc: '',
      args: [],
    );
  }

  /// `Monthly`
  String get freqMonthly {
    return Intl.message(
      'Monthly',
      name: 'freqMonthly',
      desc: '',
      args: [],
    );
  }

  /// `Weekly`
  String get freqWeekly {
    return Intl.message(
      'Weekly',
      name: 'freqWeekly',
      desc: '',
      args: [],
    );
  }

  /// `General`
  String get general {
    return Intl.message(
      'General',
      name: 'general',
      desc: '',
      args: [],
    );
  }

  /// `Github source code`
  String get github {
    return Intl.message(
      'Github source code',
      name: 'github',
      desc: '',
      args: [],
    );
  }

  /// `Go to`
  String get goTo {
    return Intl.message(
      'Go to',
      name: 'goTo',
      desc: '',
      args: [],
    );
  }

  /// `Read`
  String get haveBeenRead {
    return Intl.message(
      'Read',
      name: 'haveBeenRead',
      desc: '',
      args: [],
    );
  }

  /// `You haven't opened the app for a long time.`
  String get haveNotOpenedAppLongTime {
    return Intl.message(
      'You haven\'t opened the app for a long time.',
      name: 'haveNotOpenedAppLongTime',
      desc: '',
      args: [],
    );
  }

  /// `You haven't read anything yet`
  String get haveNotReadAnythingYet {
    return Intl.message(
      'You haven\'t read anything yet',
      name: 'haveNotReadAnythingYet',
      desc: '',
      args: [],
    );
  }

  /// `Hisn Elmoslem`
  String get hisnElmoslem {
    return Intl.message(
      'Hisn Elmoslem',
      name: 'hisnElmoslem',
      desc: '',
      args: [],
    );
  }

  /// `Hisn Elmoslem App`
  String get hisnElmoslemApp {
    return Intl.message(
      'Hisn Elmoslem App',
      name: 'hisnElmoslemApp',
      desc: '',
      args: [],
    );
  }

  /// `Hisn ELmoslem App Version`
  String get hisnElmoslemAppVersion {
    return Intl.message(
      'Hisn ELmoslem App Version',
      name: 'hisnElmoslemAppVersion',
      desc: '',
      args: [],
    );
  }

  /// `Athar`
  String get hokmAthar {
    return Intl.message(
      'Athar',
      name: 'hokmAthar',
      desc: '',
      args: [],
    );
  }

  /// `Weak`
  String get hokmDaeif {
    return Intl.message(
      'Weak',
      name: 'hokmDaeif',
      desc: '',
      args: [],
    );
  }

  /// `Good`
  String get hokmHasan {
    return Intl.message(
      'Good',
      name: 'hokmHasan',
      desc: '',
      args: [],
    );
  }

  /// `Fabricated`
  String get hokmMawdue {
    return Intl.message(
      'Fabricated',
      name: 'hokmMawdue',
      desc: '',
      args: [],
    );
  }

  /// `Authentic`
  String get hokmSahih {
    return Intl.message(
      'Authentic',
      name: 'hokmSahih',
      desc: '',
      args: [],
    );
  }

  /// `Image quality`
  String get imageQuality {
    return Intl.message(
      'Image quality',
      name: 'imageQuality',
      desc: '',
      args: [],
    );
  }

  /// `Image width`
  String get imageWidth {
    return Intl.message(
      'Image width',
      name: 'imageWidth',
      desc: '',
      args: [],
    );
  }

  /// `Index`
  String get index {
    return Intl.message(
      'Index',
      name: 'index',
      desc: '',
      args: [],
    );
  }

  /// `Later`
  String get later {
    return Intl.message(
      'Later',
      name: 'later',
      desc: '',
      args: [],
    );
  }

  /// `Light Theme`
  String get lightTheme {
    return Intl.message(
      'Light Theme',
      name: 'lightTheme',
      desc: '',
      args: [],
    );
  }

  /// `I like about this app:`
  String get likeAboutApp {
    return Intl.message(
      'I like about this app:',
      name: 'likeAboutApp',
      desc: '',
      args: [],
    );
  }

  /// `Message`
  String get message {
    return Intl.message(
      'Message',
      name: 'message',
      desc: '',
      args: [],
    );
  }

  /// `Hisn ELmoslem App | Misspelled`
  String get misspelled {
    return Intl.message(
      'Hisn ELmoslem App | Misspelled',
      name: 'misspelled',
      desc: '',
      args: [],
    );
  }

  /// `More apps`
  String get moreApps {
    return Intl.message(
      'More apps',
      name: 'moreApps',
      desc: '',
      args: [],
    );
  }

  /// `New`
  String get newText {
    return Intl.message(
      'New',
      name: 'newText',
      desc: '',
      args: [],
    );
  }

  /// `No`
  String get no {
    return Intl.message(
      'No',
      name: 'no',
      desc: '',
      args: [],
    );
  }

  /// `No active counter`
  String get noActiveCounter {
    return Intl.message(
      'No active counter',
      name: 'noActiveCounter',
      desc: '',
      args: [],
    );
  }

  /// `No alarm has been set for any zikr If you want to set an alarm, click on the alarm sign next to the zikr title`
  String get noAlarmSetForAnyZikr {
    return Intl.message(
      'No alarm has been set for any zikr If you want to set an alarm, click on the alarm sign next to the zikr title',
      name: 'noAlarmSetForAnyZikr',
      desc: '',
      args: [],
    );
  }

  /// `No reminders found`
  String get noRemindersFound {
    return Intl.message(
      'No reminders found',
      name: 'noRemindersFound',
      desc: '',
      args: [],
    );
  }

  /// `Notes`
  String get notes {
    return Intl.message(
      'Notes',
      name: 'notes',
      desc: '',
      args: [],
    );
  }

  /// `Nothing found in favorites`
  String get nothingFoundInFavorites {
    return Intl.message(
      'Nothing found in favorites',
      name: 'nothingFoundInFavorites',
      desc: '',
      args: [],
    );
  }

  /// `Hisn ELmoslem need notification permission to send zikr reminders.`
  String get notificationPermissionRequired {
    return Intl.message(
      'Hisn ELmoslem need notification permission to send zikr reminders.',
      name: 'notificationPermissionRequired',
      desc: '',
      args: [],
    );
  }

  /// `No title from the index is marked as a favourite. Click on the Favorites icon at any index title`
  String get noTitleMarkedAsFavorite {
    return Intl.message(
      'No title from the index is marked as a favourite. Click on the Favorites icon at any index title',
      name: 'noTitleMarkedAsFavorite',
      desc: '',
      args: [],
    );
  }

  /// `No title with this name`
  String get noTitleWithName {
    return Intl.message(
      'No title with this name',
      name: 'noTitleWithName',
      desc: '',
      args: [],
    );
  }

  /// `No zikr has been selected as a favorite Click on the heart icon on any internal zikr`
  String get noZikrSelectedAsFavorite {
    return Intl.message(
      'No zikr has been selected as a favorite Click on the heart icon on any internal zikr',
      name: 'noZikrSelectedAsFavorite',
      desc: '',
      args: [],
    );
  }

  /// `Official Website`
  String get officialWebsite {
    return Intl.message(
      'Official Website',
      name: 'officialWebsite',
      desc: '',
      args: [],
    );
  }

  /// `Optimized Dark Theme`
  String get optimizeDarkTheme {
    return Intl.message(
      'Optimized Dark Theme',
      name: 'optimizeDarkTheme',
      desc: '',
      args: [],
    );
  }

  /// `Optimized Light Theme`
  String get optimizeLightTheme {
    return Intl.message(
      'Optimized Light Theme',
      name: 'optimizeLightTheme',
      desc: '',
      args: [],
    );
  }

  /// `Our Products`
  String get ourProducts {
    return Intl.message(
      'Our Products',
      name: 'ourProducts',
      desc: '',
      args: [],
    );
  }

  /// `Page Mode`
  String get pageMode {
    return Intl.message(
      'Page Mode',
      name: 'pageMode',
      desc: '',
      args: [],
    );
  }

  /// `Phone vibration at every praise`
  String get phoneVibrationAtEveryPraise {
    return Intl.message(
      'Phone vibration at every praise',
      name: 'phoneVibrationAtEveryPraise',
      desc: '',
      args: [],
    );
  }

  /// `Phone vibration at single zikr end`
  String get phoneVibrationAtSingleZikrEnd {
    return Intl.message(
      'Phone vibration at single zikr end',
      name: 'phoneVibrationAtSingleZikrEnd',
      desc: '',
      args: [],
    );
  }

  /// `Phone vibration when all zikr end`
  String get phoneVibrationWhenAllZikrEnd {
    return Intl.message(
      'Phone vibration when all zikr end',
      name: 'phoneVibrationWhenAllZikrEnd',
      desc: '',
      args: [],
    );
  }

  /// `Pray for us and our parents.`
  String get prayForUsAndParents {
    return Intl.message(
      'Pray for us and our parents.',
      name: 'prayForUsAndParents',
      desc: '',
      args: [],
    );
  }

  /// `Praise with volume keys`
  String get prefPraiseWithVolumeKeys {
    return Intl.message(
      'Praise with volume keys',
      name: 'prefPraiseWithVolumeKeys',
      desc: '',
      args: [],
    );
  }

  /// `Praise with volume keys in page mode and tally`
  String get prefPraiseWithVolumeKeysDesc {
    return Intl.message(
      'Praise with volume keys in page mode and tally',
      name: 'prefPraiseWithVolumeKeysDesc',
      desc: '',
      args: [],
    );
  }

  /// `Your progress will be deleted and you can't undo that`
  String get progressDeletedCannotUndo {
    return Intl.message(
      'Your progress will be deleted and you can\'t undo that',
      name: 'progressDeletedCannotUndo',
      desc: '',
      args: [],
    );
  }

  /// `The Prophet (may Allah’s peace and blessings be upon him) said: "Whoever tells lies about me intentionally should take his seat in Hellfire."`
  String get prophetSaidLiesIntentional {
    return Intl.message(
      'The Prophet (may Allah’s peace and blessings be upon him) said: "Whoever tells lies about me intentionally should take his seat in Hellfire."',
      name: 'prophetSaidLiesIntentional',
      desc: '',
      args: [],
    );
  }

  /// `Quran pages are from android quran`
  String get quranPagesFromAndroidQuran {
    return Intl.message(
      'Quran pages are from android quran',
      name: 'quranPagesFromAndroidQuran',
      desc: '',
      args: [],
    );
  }

  /// `Hisn ELmoslem App | Rate the app`
  String get rateTheApp {
    return Intl.message(
      'Hisn ELmoslem App | Rate the app',
      name: 'rateTheApp',
      desc: '',
      args: [],
    );
  }

  /// `You have read all content`
  String get readAllContent {
    return Intl.message(
      'You have read all content',
      name: 'readAllContent',
      desc: '',
      args: [],
    );
  }

  /// `Reminder Removed`
  String get reminderRemoved {
    return Intl.message(
      'Reminder Removed',
      name: 'reminderRemoved',
      desc: '',
      args: [],
    );
  }

  /// `Reminders`
  String get reminders {
    return Intl.message(
      'Reminders',
      name: 'reminders',
      desc: '',
      args: [],
    );
  }

  /// `Reminders Control`
  String get remindersManager {
    return Intl.message(
      'Reminders Control',
      name: 'remindersManager',
      desc: '',
      args: [],
    );
  }

  /// `Report bugs and request new features`
  String get reportBugsRequestFeatures {
    return Intl.message(
      'Report bugs and request new features',
      name: 'reportBugsRequestFeatures',
      desc: '',
      args: [],
    );
  }

  /// `Requires app restart`
  String get requiresAppRestart {
    return Intl.message(
      'Requires app restart',
      name: 'requiresAppRestart',
      desc: '',
      args: [],
    );
  }

  /// `Reset all counters?`
  String get resetAllCounters {
    return Intl.message(
      'Reset all counters?',
      name: 'resetAllCounters',
      desc: '',
      args: [],
    );
  }

  /// `Please review the index of the book`
  String get reviewIndexOfBook {
    return Intl.message(
      'Please review the index of the book',
      name: 'reviewIndexOfBook',
      desc: '',
      args: [],
    );
  }

  /// `Search`
  String get search {
    return Intl.message(
      'Search',
      name: 'search',
      desc: '',
      args: [],
    );
  }

  /// `Select`
  String get select {
    return Intl.message(
      'Select',
      name: 'select',
      desc: '',
      args: [],
    );
  }

  /// `Select hokm of Azakr`
  String get selectAzkarHokmFilters {
    return Intl.message(
      'Select hokm of Azakr',
      name: 'selectAzkarHokmFilters',
      desc: '',
      args: [],
    );
  }

  /// `Select source of Azkar`
  String get selectAzkarSource {
    return Intl.message(
      'Select source of Azkar',
      name: 'selectAzkarSource',
      desc: '',
      args: [],
    );
  }

  /// `Select color`
  String get selectColor {
    return Intl.message(
      'Select color',
      name: 'selectColor',
      desc: '',
      args: [],
    );
  }

  /// `Send Email`
  String get sendEmail {
    return Intl.message(
      'Send Email',
      name: 'sendEmail',
      desc: '',
      args: [],
    );
  }

  /// `Set message for yourself`
  String get setMessageForYou {
    return Intl.message(
      'Set message for yourself',
      name: 'setMessageForYou',
      desc: '',
      args: [],
    );
  }

  /// `Settings`
  String get settings {
    return Intl.message(
      'Settings',
      name: 'settings',
      desc: '',
      args: [],
    );
  }

  /// `Share as image`
  String get shareAsImage {
    return Intl.message(
      'Share as image',
      name: 'shareAsImage',
      desc: '',
      args: [],
    );
  }

  /// `It should be:`
  String get shouldBe {
    return Intl.message(
      'It should be:',
      name: 'shouldBe',
      desc: '',
      args: [],
    );
  }

  /// `Show fadl`
  String get showFadl {
    return Intl.message(
      'Show fadl',
      name: 'showFadl',
      desc: '',
      args: [],
    );
  }

  /// `Show source of zikr`
  String get showSourceOfZikr {
    return Intl.message(
      'Show source of zikr',
      name: 'showSourceOfZikr',
      desc: '',
      args: [],
    );
  }

  /// `Show zikr index`
  String get showZikrIndex {
    return Intl.message(
      'Show zikr index',
      name: 'showZikrIndex',
      desc: '',
      args: [],
    );
  }

  /// `Shuffle Mode Activated`
  String get shuffleModeActivated {
    return Intl.message(
      'Shuffle Mode Activated',
      name: 'shuffleModeActivated',
      desc: '',
      args: [],
    );
  }

  /// `Shuffle Mode Deactivated`
  String get shuffleModeDeactivated {
    return Intl.message(
      'Shuffle Mode Deactivated',
      name: 'shuffleModeDeactivated',
      desc: '',
      args: [],
    );
  }

  /// `Skip`
  String get skip {
    return Intl.message(
      'Skip',
      name: 'skip',
      desc: '',
      args: [],
    );
  }

  /// `Sound effect at every praise`
  String get soundEffectAtEveryPraise {
    return Intl.message(
      'Sound effect at every praise',
      name: 'soundEffectAtEveryPraise',
      desc: '',
      args: [],
    );
  }

  /// `Sound effect at single zikr end`
  String get soundEffectAtSingleZikrEnd {
    return Intl.message(
      'Sound effect at single zikr end',
      name: 'soundEffectAtSingleZikrEnd',
      desc: '',
      args: [],
    );
  }

  /// `Sound Effect volume`
  String get soundEffectVolume {
    return Intl.message(
      'Sound Effect volume',
      name: 'soundEffectVolume',
      desc: '',
      args: [],
    );
  }

  /// `Sound effect when all zikr end`
  String get soundEffectWhenAllZikrEnd {
    return Intl.message(
      'Sound effect when all zikr end',
      name: 'soundEffectWhenAllZikrEnd',
      desc: '',
      args: [],
    );
  }

  /// `Sunan Abi Dawud`
  String get sourceAbuDawood {
    return Intl.message(
      'Sunan Abi Dawud',
      name: 'sourceAbuDawood',
      desc: '',
      args: [],
    );
  }

  /// `Sunan al-Darimi`
  String get sourceAdDarami {
    return Intl.message(
      'Sunan al-Darimi',
      name: 'sourceAdDarami',
      desc: '',
      args: [],
    );
  }

  /// `Musnad Ahmad ibn Hanbal`
  String get sourceAhmad {
    return Intl.message(
      'Musnad Ahmad ibn Hanbal',
      name: 'sourceAhmad',
      desc: '',
      args: [],
    );
  }

  /// `Al-Sunan al-Sughra by al-Nasa'i`
  String get sourceAnNasai {
    return Intl.message(
      'Al-Sunan al-Sughra by al-Nasa\'i',
      name: 'sourceAnNasai',
      desc: '',
      args: [],
    );
  }

  /// `Athr`
  String get sourceAthar {
    return Intl.message(
      'Athr',
      name: 'sourceAthar',
      desc: '',
      args: [],
    );
  }

  /// `Sunan al-Tirmidhi`
  String get sourceAtTirmidhi {
    return Intl.message(
      'Sunan al-Tirmidhi',
      name: 'sourceAtTirmidhi',
      desc: '',
      args: [],
    );
  }

  /// `Sunan al-Bayhaqi`
  String get sourceBayhaqi {
    return Intl.message(
      'Sunan al-Bayhaqi',
      name: 'sourceBayhaqi',
      desc: '',
      args: [],
    );
  }

  /// `Al-Mustadrak ala al-Sahihayn`
  String get sourceHakim {
    return Intl.message(
      'Al-Mustadrak ala al-Sahihayn',
      name: 'sourceHakim',
      desc: '',
      args: [],
    );
  }

  /// `Sunan IbnMajah`
  String get sourceIbnMajah {
    return Intl.message(
      'Sunan IbnMajah',
      name: 'sourceIbnMajah',
      desc: '',
      args: [],
    );
  }

  /// `IbnSunny`
  String get sourceIbnSunny {
    return Intl.message(
      'IbnSunny',
      name: 'sourceIbnSunny',
      desc: '',
      args: [],
    );
  }

  /// `Muwatta Imam Malik`
  String get sourceMalik {
    return Intl.message(
      'Muwatta Imam Malik',
      name: 'sourceMalik',
      desc: '',
      args: [],
    );
  }

  /// `Quran`
  String get sourceQuran {
    return Intl.message(
      'Quran',
      name: 'sourceQuran',
      desc: '',
      args: [],
    );
  }

  /// `Sahih al-Bukhari`
  String get sourceSahihBukhari {
    return Intl.message(
      'Sahih al-Bukhari',
      name: 'sourceSahihBukhari',
      desc: '',
      args: [],
    );
  }

  /// `Sahih Muslim`
  String get sourceSahihMuslim {
    return Intl.message(
      'Sahih Muslim',
      name: 'sourceSahihMuslim',
      desc: '',
      args: [],
    );
  }

  /// `There is a spelling error in`
  String get spellingErrorIn {
    return Intl.message(
      'There is a spelling error in',
      name: 'spellingErrorIn',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start {
    return Intl.message(
      'Start',
      name: 'start',
      desc: '',
      args: [],
    );
  }

  /// `Subject`
  String get subject {
    return Intl.message(
      'Subject',
      name: 'subject',
      desc: '',
      args: [],
    );
  }

  /// `Subtitle color`
  String get subtitleColor {
    return Intl.message(
      'Subtitle color',
      name: 'subtitleColor',
      desc: '',
      args: [],
    );
  }

  /// `Surah Al-Kahf`
  String get suraAlKahf {
    return Intl.message(
      'Surah Al-Kahf',
      name: 'suraAlKahf',
      desc: '',
      args: [],
    );
  }

  /// `Surah Al-Kahf Reminder`
  String get suraAlKahfReminder {
    return Intl.message(
      'Surah Al-Kahf Reminder',
      name: 'suraAlKahfReminder',
      desc: '',
      args: [],
    );
  }

  /// `Surah Al-Mulk`
  String get suraAlMulk {
    return Intl.message(
      'Surah Al-Mulk',
      name: 'suraAlMulk',
      desc: '',
      args: [],
    );
  }

  /// `Surah As-Sajdah`
  String get suraAsSajdah {
    return Intl.message(
      'Surah As-Sajdah',
      name: 'suraAsSajdah',
      desc: '',
      args: [],
    );
  }

  /// `Tally`
  String get tally {
    return Intl.message(
      'Tally',
      name: 'tally',
      desc: '',
      args: [],
    );
  }

  /// `Text`
  String get text {
    return Intl.message(
      'Text',
      name: 'text',
      desc: '',
      args: [],
    );
  }

  /// `Text color`
  String get textColor {
    return Intl.message(
      'Text color',
      name: 'textColor',
      desc: '',
      args: [],
    );
  }

  /// `App Color`
  String get themeAppColor {
    return Intl.message(
      'App Color',
      name: 'themeAppColor',
      desc: '',
      args: [],
    );
  }

  /// `Background Color`
  String get themeBackgroundColor {
    return Intl.message(
      'Background Color',
      name: 'themeBackgroundColor',
      desc: '',
      args: [],
    );
  }

  /// `Dark Mode`
  String get themeDarkMode {
    return Intl.message(
      'Dark Mode',
      name: 'themeDarkMode',
      desc: '',
      args: [],
    );
  }

  /// `Theme Control`
  String get themeManager {
    return Intl.message(
      'Theme Control',
      name: 'themeManager',
      desc: '',
      args: [],
    );
  }

  /// `Override Background`
  String get themeOverrideBackground {
    return Intl.message(
      'Override Background',
      name: 'themeOverrideBackground',
      desc: '',
      args: [],
    );
  }

  /// `Select Color`
  String get themeSelectColor {
    return Intl.message(
      'Select Color',
      name: 'themeSelectColor',
      desc: '',
      args: [],
    );
  }

  /// `Use Material3`
  String get themeUseMaterial3 {
    return Intl.message(
      'Use Material3',
      name: 'themeUseMaterial3',
      desc: '',
      args: [],
    );
  }

  /// `User Old Theme`
  String get themeUserOldTheme {
    return Intl.message(
      'User Old Theme',
      name: 'themeUserOldTheme',
      desc: '',
      args: [],
    );
  }

  /// `Times`
  String get times {
    return Intl.message(
      'Times',
      name: 'times',
      desc: '',
      args: [],
    );
  }

  /// `Title`
  String get title {
    return Intl.message(
      'Title',
      name: 'title',
      desc: '',
      args: [],
    );
  }

  /// `Title color`
  String get titleColor {
    return Intl.message(
      'Title color',
      name: 'titleColor',
      desc: '',
      args: [],
    );
  }

  /// `True black Theme`
  String get trueBlackTheme {
    return Intl.message(
      'True black Theme',
      name: 'trueBlackTheme',
      desc: '',
      args: [],
    );
  }

  /// `Updates History`
  String get updatesHistory {
    return Intl.message(
      'Updates History',
      name: 'updatesHistory',
      desc: '',
      args: [],
    );
  }

  /// `Use Hindi Digits`
  String get useHindiDigits {
    return Intl.message(
      'Use Hindi Digits',
      name: 'useHindiDigits',
      desc: '',
      args: [],
    );
  }

  /// `Version`
  String get version {
    return Intl.message(
      'Version',
      name: 'version',
      desc: '',
      args: [],
    );
  }

  /// `Yes`
  String get yes {
    return Intl.message(
      'Yes',
      name: 'yes',
      desc: '',
      args: [],
    );
  }

  /// `Zikr Index`
  String get zikrIndex {
    return Intl.message(
      'Zikr Index',
      name: 'zikrIndex',
      desc: '',
      args: [],
    );
  }

  /// `We found a previous session, would you like to restore it?`
  String get zikrViewerRestoreSessionMsg {
    return Intl.message(
      'We found a previous session, would you like to restore it?',
      name: 'zikrViewerRestoreSessionMsg',
      desc: '',
      args: [],
    );
  }
}

class AppLocalizationDelegate extends LocalizationsDelegate<S> {
  const AppLocalizationDelegate();

  List<Locale> get supportedLocales {
    return const <Locale>[
      Locale.fromSubtags(languageCode: 'en'),
      Locale.fromSubtags(languageCode: 'ar'),
    ];
  }

  @override
  bool isSupported(Locale locale) => _isSupported(locale);
  @override
  Future<S> load(Locale locale) => S.load(locale);
  @override
  bool shouldReload(AppLocalizationDelegate old) => false;

  bool _isSupported(Locale locale) {
    for (var supportedLocale in supportedLocales) {
      if (supportedLocale.languageCode == locale.languageCode) {
        return true;
      }
    }
    return false;
  }
}
