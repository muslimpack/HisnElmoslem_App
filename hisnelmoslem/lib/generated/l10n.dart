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
    assert(_current != null, 'No instance of S was loaded. Try to initialize the S delegate before accessing S.current.');
    return _current!;
  }

  static const AppLocalizationDelegate delegate =
    AppLocalizationDelegate();

  static Future<S> load(Locale locale) {
    final name = (locale.countryCode?.isEmpty ?? false) ? locale.languageCode : locale.toString();
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
    assert(instance != null, 'No instance of S present in the widget tree. Did you add S.delegate in localizationsDelegates?');
    return instance!;
  }

  static S? maybeOf(BuildContext context) {
    return Localizations.of<S>(context, S);
  }

  /// `About Us`
  String get about_us {
    return Intl.message(
      'About Us',
      name: 'about_us',
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

  /// `Active tally`
  String get active_tallly {
    return Intl.message(
      'Active tally',
      name: 'active_tallly',
      desc: '',
      args: [],
    );
  }

  /// `Add a name to your counter`
  String get add_a_name_to_your_counter {
    return Intl.message(
      'Add a name to your counter',
      name: 'add_a_name_to_your_counter',
      desc: '',
      args: [],
    );
  }

  /// `Add new counter`
  String get add_new_counter {
    return Intl.message(
      'Add new counter',
      name: 'add_new_counter',
      desc: '',
      args: [],
    );
  }

  /// `Add reminder`
  String get add_reminder {
    return Intl.message(
      'Add reminder',
      name: 'add_reminder',
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
  String get allow_app_to_send_notifications {
    return Intl.message(
      'Allow app to send notifications?',
      name: 'allow_app_to_send_notifications',
      desc: '',
      args: [],
    );
  }

  /// `App Language`
  String get app_language {
    return Intl.message(
      'App Language',
      name: 'app_language',
      desc: '',
      args: [],
    );
  }

  /// `Are you sure?`
  String get are_you_sure {
    return Intl.message(
      'Are you sure?',
      name: 'are_you_sure',
      desc: '',
      args: [],
    );
  }

  /// `Background color`
  String get background_color {
    return Intl.message(
      'Background color',
      name: 'background_color',
      desc: '',
      args: [],
    );
  }

  /// `Card index`
  String get card_index {
    return Intl.message(
      'Card index',
      name: 'card_index',
      desc: '',
      args: [],
    );
  }

  /// `Card Mode`
  String get card_mode {
    return Intl.message(
      'Card Mode',
      name: 'card_mode',
      desc: '',
      args: [],
    );
  }

  /// `Complete circle every`
  String get circle_every {
    return Intl.message(
      'Complete circle every',
      name: 'circle_every',
      desc: '',
      args: [],
    );
  }

  /// `Click here`
  String get click_here {
    return Intl.message(
      'Click here',
      name: 'click_here',
      desc: '',
      args: [],
    );
  }

  /// `Click to set the time`
  String get click_to_choose_time {
    return Intl.message(
      'Click to set the time',
      name: 'click_to_choose_time',
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
  String get commentary_benefit {
    return Intl.message(
      'Fadl',
      name: 'commentary_benefit',
      desc: '',
      args: [],
    );
  }

  /// `Hadith`
  String get commentary_hadith {
    return Intl.message(
      'Hadith',
      name: 'commentary_hadith',
      desc: '',
      args: [],
    );
  }

  /// `Commentary`
  String get commentary_sharh {
    return Intl.message(
      'Commentary',
      name: 'commentary_sharh',
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
  String get contact_to_dev {
    return Intl.message(
      'Contact to Dev',
      name: 'contact_to_dev',
      desc: '',
      args: [],
    );
  }

  /// `Copied to clipboard`
  String get copied_to_clipboard {
    return Intl.message(
      'Copied to clipboard',
      name: 'copied_to_clipboard',
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
  String get counter_circle_must_be_greater_than_zero {
    return Intl.message(
      'Counter circle must be higher than zero',
      name: 'counter_circle_must_be_greater_than_zero',
      desc: '',
      args: [],
    );
  }

  /// `The counter circle is set to zero when reach this number`
  String get counter_circle_set_to_zero_when_reach_this_number {
    return Intl.message(
      'The counter circle is set to zero when reach this number',
      name: 'counter_circle_set_to_zero_when_reach_this_number',
      desc: '',
      args: [],
    );
  }

  /// `Counter name`
  String get counter_name {
    return Intl.message(
      'Counter name',
      name: 'counter_name',
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

  /// `Current version`
  String get current_version {
    return Intl.message(
      'Current version',
      name: 'current_version',
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
  String get dark_theme {
    return Intl.message(
      'Dark Theme',
      name: 'dark_theme',
      desc: '',
      args: [],
    );
  }

  /// `Dashboard Arrangement`
  String get dashboard_arrangement {
    return Intl.message(
      'Dashboard Arrangement',
      name: 'dashboard_arrangement',
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
  String get digital_copy_of_hisn_elmoslem_used_from_aloka_network {
    return Intl.message(
      'A digital copy of Hisn Elmoslem was used from the Aloka Network.',
      name: 'digital_copy_of_hisn_elmoslem_used_from_aloka_network',
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
  String get dr_saeed_bin_ali_bin_wahf_al_qahtani {
    return Intl.message(
      'Dr. Saeed bin Ali bin Wahf Al-Qahtani',
      name: 'dr_saeed_bin_ali_bin_wahf_al_qahtani',
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
  String get edit_counter {
    return Intl.message(
      'Edit counter',
      name: 'edit_counter',
      desc: '',
      args: [],
    );
  }

  /// `Edit image size`
  String get edit_image_size {
    return Intl.message(
      'Edit image size',
      name: 'edit_image_size',
      desc: '',
      args: [],
    );
  }

  /// `Edit reminder`
  String get edit_reminder {
    return Intl.message(
      'Edit reminder',
      name: 'edit_reminder',
      desc: '',
      args: [],
    );
  }

  /// `Effect Control`
  String get effect_manager {
    return Intl.message(
      'Effect Control',
      name: 'effect_manager',
      desc: '',
      args: [],
    );
  }

  /// `End of Surah Ali 'Imran`
  String get end_sura_ali_imran {
    return Intl.message(
      'End of Surah Ali \'Imran',
      name: 'end_sura_ali_imran',
      desc: '',
      args: [],
    );
  }

  /// `Every Friday`
  String get every_friday {
    return Intl.message(
      'Every Friday',
      name: 'every_friday',
      desc: '',
      args: [],
    );
  }

  /// `Every Monday`
  String get every_monday {
    return Intl.message(
      'Every Monday',
      name: 'every_monday',
      desc: '',
      args: [],
    );
  }

  /// `Every Saturday`
  String get every_saturday {
    return Intl.message(
      'Every Saturday',
      name: 'every_saturday',
      desc: '',
      args: [],
    );
  }

  /// `Every Sunday`
  String get every_sunday {
    return Intl.message(
      'Every Sunday',
      name: 'every_sunday',
      desc: '',
      args: [],
    );
  }

  /// `Every Thursday`
  String get every_thursday {
    return Intl.message(
      'Every Thursday',
      name: 'every_thursday',
      desc: '',
      args: [],
    );
  }

  /// `Every Tuesday`
  String get every_tuesday {
    return Intl.message(
      'Every Tuesday',
      name: 'every_tuesday',
      desc: '',
      args: [],
    );
  }

  /// `Every Wednesday`
  String get every_wednesday {
    return Intl.message(
      'Every Wednesday',
      name: 'every_wednesday',
      desc: '',
      args: [],
    );
  }

  /// `Fake Hadith`
  String get fake_hadith {
    return Intl.message(
      'Fake Hadith',
      name: 'fake_hadith',
      desc: '',
      args: [],
    );
  }

  /// `Fasting Mondays and Thursdays Reminder`
  String get fasting_mondays_and_thursdays_reminder {
    return Intl.message(
      'Fasting Mondays and Thursdays Reminder',
      name: 'fasting_mondays_and_thursdays_reminder',
      desc: '',
      args: [],
    );
  }

  /// `favorites`
  String get favorites_content {
    return Intl.message(
      'favorites',
      name: 'favorites_content',
      desc: '',
      args: [],
    );
  }

  /// `Favourite Zikr`
  String get favorites_zikr {
    return Intl.message(
      'Favourite Zikr',
      name: 'favorites_zikr',
      desc: '',
      args: [],
    );
  }

  /// `Features I hope to be added:`
  String get features_i_hope_to_be_added {
    return Intl.message(
      'Features I hope to be added:',
      name: 'features_i_hope_to_be_added',
      desc: '',
      args: [],
    );
  }

  /// `Fixed size mode`
  String get fixed_size_mode {
    return Intl.message(
      'Fixed size mode',
      name: 'fixed_size_mode',
      desc: '',
      args: [],
    );
  }

  /// `Font Settings`
  String get font_settings {
    return Intl.message(
      'Font Settings',
      name: 'font_settings',
      desc: '',
      args: [],
    );
  }

  /// `Font Type`
  String get font_type {
    return Intl.message(
      'Font Type',
      name: 'font_type',
      desc: '',
      args: [],
    );
  }

  /// `Free, ad-free and open source app`
  String get free_ad_free_and_open_source_app {
    return Intl.message(
      'Free, ad-free and open source app',
      name: 'free_ad_free_and_open_source_app',
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
  String get go_to {
    return Intl.message(
      'Go to',
      name: 'go_to',
      desc: '',
      args: [],
    );
  }

  /// `Read`
  String get have_been_read {
    return Intl.message(
      'Read',
      name: 'have_been_read',
      desc: '',
      args: [],
    );
  }

  /// `Hisn Elmoslem`
  String get hisn_elmoslem {
    return Intl.message(
      'Hisn Elmoslem',
      name: 'hisn_elmoslem',
      desc: '',
      args: [],
    );
  }

  /// `Hisn Elmoslem App`
  String get hisn_elmoslem_app {
    return Intl.message(
      'Hisn Elmoslem App',
      name: 'hisn_elmoslem_app',
      desc: '',
      args: [],
    );
  }

  /// `Hisn ELmoslem App | Chat`
  String get hisn_elmoslem_app_chat {
    return Intl.message(
      'Hisn ELmoslem App | Chat',
      name: 'hisn_elmoslem_app_chat',
      desc: '',
      args: [],
    );
  }

  /// `Hisn ELmoslem App | Misspelled`
  String get hisn_elmoslem_app_misspelled {
    return Intl.message(
      'Hisn ELmoslem App | Misspelled',
      name: 'hisn_elmoslem_app_misspelled',
      desc: '',
      args: [],
    );
  }

  /// `Hisn ELmoslem App | Rate the app`
  String get hisn_elmoslem_app_rate_the_app {
    return Intl.message(
      'Hisn ELmoslem App | Rate the app',
      name: 'hisn_elmoslem_app_rate_the_app',
      desc: '',
      args: [],
    );
  }

  /// `Hisn ELmoslem App Version`
  String get hisn_elmoslem_app_version {
    return Intl.message(
      'Hisn ELmoslem App Version',
      name: 'hisn_elmoslem_app_version',
      desc: '',
      args: [],
    );
  }

  /// `Hisn ELmoslem need notification permission to send zikr reminders.`
  String get hisn_elmoslem_need_notification_permission_to_send_zikr_reminders {
    return Intl.message(
      'Hisn ELmoslem need notification permission to send zikr reminders.',
      name: 'hisn_elmoslem_need_notification_permission_to_send_zikr_reminders',
      desc: '',
      args: [],
    );
  }

  /// `I don't like about this app:`
  String get i_dont_like_about_this_app {
    return Intl.message(
      'I don\'t like about this app:',
      name: 'i_dont_like_about_this_app',
      desc: '',
      args: [],
    );
  }

  /// `I like about this app:`
  String get i_like_about_this_app {
    return Intl.message(
      'I like about this app:',
      name: 'i_like_about_this_app',
      desc: '',
      args: [],
    );
  }

  /// `Image quality`
  String get image_quality {
    return Intl.message(
      'Image quality',
      name: 'image_quality',
      desc: '',
      args: [],
    );
  }

  /// `Image width`
  String get image_width {
    return Intl.message(
      'Image width',
      name: 'image_width',
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

  /// `It should be:`
  String get it_should_be {
    return Intl.message(
      'It should be:',
      name: 'it_should_be',
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
  String get light_theme {
    return Intl.message(
      'Light Theme',
      name: 'light_theme',
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

  /// `New`
  String get new {
    return Intl.message(
      'New',
      name: 'new',
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
  String get no_active_counter {
    return Intl.message(
      'No active counter',
      name: 'no_active_counter',
      desc: '',
      args: [],
    );
  }

  /// `No alarm has been set for any zikr If you want to set an alarm, click on the alarm sign next to the zikr title`
  String get no_alarm_set_for_any_zikr_if_you_want_set_alarm_click_on_alarm_sign_next_to_zikr_title {
    return Intl.message(
      'No alarm has been set for any zikr If you want to set an alarm, click on the alarm sign next to the zikr title',
      name: 'no_alarm_set_for_any_zikr_if_you_want_set_alarm_click_on_alarm_sign_next_to_zikr_title',
      desc: '',
      args: [],
    );
  }

  /// `No reminders found`
  String get no_reminders_found {
    return Intl.message(
      'No reminders found',
      name: 'no_reminders_found',
      desc: '',
      args: [],
    );
  }

  /// `No title from the index is marked as a favourite. Click on the Favorites icon at any index title`
  String get no_title_from_index_marked_as_favorite_click_favorites_icon_at_any_index_title {
    return Intl.message(
      'No title from the index is marked as a favourite. Click on the Favorites icon at any index title',
      name: 'no_title_from_index_marked_as_favorite_click_favorites_icon_at_any_index_title',
      desc: '',
      args: [],
    );
  }

  /// `No title with this name`
  String get no_title_with_this_name {
    return Intl.message(
      'No title with this name',
      name: 'no_title_with_this_name',
      desc: '',
      args: [],
    );
  }

  /// `No zikr has been selected as a favorite Click on the heart icon on any internal zikr`
  String get no_zikr_selected_as_favorite_click_heart_icon_on_any_internal_zikr {
    return Intl.message(
      'No zikr has been selected as a favorite Click on the heart icon on any internal zikr',
      name: 'no_zikr_selected_as_favorite_click_heart_icon_on_any_internal_zikr',
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
  String get nothing_found_in_favorites {
    return Intl.message(
      'Nothing found in favorites',
      name: 'nothing_found_in_favorites',
      desc: '',
      args: [],
    );
  }

  /// `Official Website`
  String get official_website {
    return Intl.message(
      'Official Website',
      name: 'official_website',
      desc: '',
      args: [],
    );
  }

  /// `Optimized Dark Theme`
  String get optimize_dark_theme {
    return Intl.message(
      'Optimized Dark Theme',
      name: 'optimize_dark_theme',
      desc: '',
      args: [],
    );
  }

  /// `Optimized Light Theme`
  String get optimize_light_theme {
    return Intl.message(
      'Optimized Light Theme',
      name: 'optimize_light_theme',
      desc: '',
      args: [],
    );
  }

  /// `Our Products`
  String get our_products {
    return Intl.message(
      'Our Products',
      name: 'our_products',
      desc: '',
      args: [],
    );
  }

  /// `Page Mode`
  String get page_mode {
    return Intl.message(
      'Page Mode',
      name: 'page_mode',
      desc: '',
      args: [],
    );
  }

  /// `Phone vibration at every praise`
  String get phone_vibration_at_every_praise {
    return Intl.message(
      'Phone vibration at every praise',
      name: 'phone_vibration_at_every_praise',
      desc: '',
      args: [],
    );
  }

  /// `Phone vibration at single zikr end`
  String get phone_vibration_at_single_zikr_end {
    return Intl.message(
      'Phone vibration at single zikr end',
      name: 'phone_vibration_at_single_zikr_end',
      desc: '',
      args: [],
    );
  }

  /// `Phone vibration when all zikr end`
  String get phone_vibration_when_all_zikr_end {
    return Intl.message(
      'Phone vibration when all zikr end',
      name: 'phone_vibration_when_all_zikr_end',
      desc: '',
      args: [],
    );
  }

  /// `Please choose time for the reminder`
  String get please_choose_time_for_the_reminder {
    return Intl.message(
      'Please choose time for the reminder',
      name: 'please_choose_time_for_the_reminder',
      desc: '',
      args: [],
    );
  }

  /// `Please review the index of the book`
  String get please_review_index_of_the_book {
    return Intl.message(
      'Please review the index of the book',
      name: 'please_review_index_of_the_book',
      desc: '',
      args: [],
    );
  }

  /// `Pray for us and our parents.`
  String get pray_for_us_and_our_parents {
    return Intl.message(
      'Pray for us and our parents.',
      name: 'pray_for_us_and_our_parents',
      desc: '',
      args: [],
    );
  }

  /// `Quran pages are from android quran`
  String get quran_pages_from_android_quran {
    return Intl.message(
      'Quran pages are from android quran',
      name: 'quran_pages_from_android_quran',
      desc: '',
      args: [],
    );
  }

  /// `Reminder Removed`
  String get reminder_removed {
    return Intl.message(
      'Reminder Removed',
      name: 'reminder_removed',
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
  String get reminders_manager {
    return Intl.message(
      'Reminders Control',
      name: 'reminders_manager',
      desc: '',
      args: [],
    );
  }

  /// `Report bugs and request new features`
  String get report_bugs_and_request_new_features {
    return Intl.message(
      'Report bugs and request new features',
      name: 'report_bugs_and_request_new_features',
      desc: '',
      args: [],
    );
  }

  /// `Reset all counters?.`
  String get reset_all_counters {
    return Intl.message(
      'Reset all counters?.',
      name: 'reset_all_counters',
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

  /// `Select color`
  String get select_color {
    return Intl.message(
      'Select color',
      name: 'select_color',
      desc: '',
      args: [],
    );
  }

  /// `Send Email`
  String get send_email {
    return Intl.message(
      'Send Email',
      name: 'send_email',
      desc: '',
      args: [],
    );
  }

  /// `Set message for yourself`
  String get set_message_for_yourself {
    return Intl.message(
      'Set message for yourself',
      name: 'set_message_for_yourself',
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
  String get share_as_image {
    return Intl.message(
      'Share as image',
      name: 'share_as_image',
      desc: '',
      args: [],
    );
  }

  /// `Show fadl`
  String get show_fadl {
    return Intl.message(
      'Show fadl',
      name: 'show_fadl',
      desc: '',
      args: [],
    );
  }

  /// `Show source of zikr`
  String get show_source_of_zikr {
    return Intl.message(
      'Show source of zikr',
      name: 'show_source_of_zikr',
      desc: '',
      args: [],
    );
  }

  /// `Show zikr index`
  String get show_zikr_index {
    return Intl.message(
      'Show zikr index',
      name: 'show_zikr_index',
      desc: '',
      args: [],
    );
  }

  /// `Shuffle Mode Activated`
  String get shuffle_mode_activated {
    return Intl.message(
      'Shuffle Mode Activated',
      name: 'shuffle_mode_activated',
      desc: '',
      args: [],
    );
  }

  /// `Shuffle Mode Deactivated`
  String get shuffle_mode_deactivated {
    return Intl.message(
      'Shuffle Mode Deactivated',
      name: 'shuffle_mode_deactivated',
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
  String get sound_effect_at_every_praise {
    return Intl.message(
      'Sound effect at every praise',
      name: 'sound_effect_at_every_praise',
      desc: '',
      args: [],
    );
  }

  /// `Sound effect at single zikr end`
  String get sound_effect_at_single_zikr_end {
    return Intl.message(
      'Sound effect at single zikr end',
      name: 'sound_effect_at_single_zikr_end',
      desc: '',
      args: [],
    );
  }

  /// `Sound Effect volume`
  String get sound_effect_volume {
    return Intl.message(
      'Sound Effect volume',
      name: 'sound_effect_volume',
      desc: '',
      args: [],
    );
  }

  /// `Sound effect when all zikr end`
  String get sound_effect_when_all_zikr_end {
    return Intl.message(
      'Sound effect when all zikr end',
      name: 'sound_effect_when_all_zikr_end',
      desc: '',
      args: [],
    );
  }

  /// `Start`
  String get start_ {
    return Intl.message(
      'Start',
      name: 'start_',
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
  String get subtitle_color {
    return Intl.message(
      'Subtitle color',
      name: 'subtitle_color',
      desc: '',
      args: [],
    );
  }

  /// `Surah Al-Kahf`
  String get sura_al_kahf {
    return Intl.message(
      'Surah Al-Kahf',
      name: 'sura_al_kahf',
      desc: '',
      args: [],
    );
  }

  /// `Surah Al-Kahf Reminder`
  String get sura_al_kahf_reminder {
    return Intl.message(
      'Surah Al-Kahf Reminder',
      name: 'sura_al_kahf_reminder',
      desc: '',
      args: [],
    );
  }

  /// `Surah Al-Mulk`
  String get sura_al_mulk {
    return Intl.message(
      'Surah Al-Mulk',
      name: 'sura_al_mulk',
      desc: '',
      args: [],
    );
  }

  /// `Surah As-Sajdah`
  String get sura_as_sajdah {
    return Intl.message(
      'Surah As-Sajdah',
      name: 'sura_as_sajdah',
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
  String get text_color {
    return Intl.message(
      'Text color',
      name: 'text_color',
      desc: '',
      args: [],
    );
  }

  /// `The Prophet (may Allah’s peace and blessings be upon him) said: "Whoever tells lies about me intentionally should take his seat in Hellfire."`
  String get the_prophet_said_whoever_tells_lies_about_me_intentionally_should_take_his_seat_in_hellfire {
    return Intl.message(
      'The Prophet (may Allah’s peace and blessings be upon him) said: "Whoever tells lies about me intentionally should take his seat in Hellfire."',
      name: 'the_prophet_said_whoever_tells_lies_about_me_intentionally_should_take_his_seat_in_hellfire',
      desc: '',
      args: [],
    );
  }

  /// `Theme Control`
  String get theme_manager {
    return Intl.message(
      'Theme Control',
      name: 'theme_manager',
      desc: '',
      args: [],
    );
  }

  /// `There is a spelling error in`
  String get there_is_spelling_error_in {
    return Intl.message(
      'There is a spelling error in',
      name: 'there_is_spelling_error_in',
      desc: '',
      args: [],
    );
  }

  /// `This counter will be deleted.`
  String get this_counter_will_be_deleted {
    return Intl.message(
      'This counter will be deleted.',
      name: 'this_counter_will_be_deleted',
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
  String get title_color {
    return Intl.message(
      'Title color',
      name: 'title_color',
      desc: '',
      args: [],
    );
  }

  /// `To activate counter go to counters then click to counter icon beside the counter you want`
  String get to_activate_counter_go_to_counters_then_click_counter_icon_beside_counter_you_want {
    return Intl.message(
      'To activate counter go to counters then click to counter icon beside the counter you want',
      name: 'to_activate_counter_go_to_counters_then_click_counter_icon_beside_counter_you_want',
      desc: '',
      args: [],
    );
  }

  /// `True black Theme`
  String get true_black_theme {
    return Intl.message(
      'True black Theme',
      name: 'true_black_theme',
      desc: '',
      args: [],
    );
  }

  /// `Updates History`
  String get updates_history {
    return Intl.message(
      'Updates History',
      name: 'updates_history',
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

  /// `You have read all content`
  String get you_have_read_all_content {
    return Intl.message(
      'You have read all content',
      name: 'you_have_read_all_content',
      desc: '',
      args: [],
    );
  }

  /// `You haven't opened the app for a long time.`
  String get you_havent_opened_app_for_long_time {
    return Intl.message(
      'You haven\'t opened the app for a long time.',
      name: 'you_havent_opened_app_for_long_time',
      desc: '',
      args: [],
    );
  }

  /// `You haven't read anything yet`
  String get you_havent_read_anything_yet {
    return Intl.message(
      'You haven\'t read anything yet',
      name: 'you_havent_read_anything_yet',
      desc: '',
      args: [],
    );
  }

  /// `Your progress will be deleted and you can't undo that`
  String get your_progress_will_be_deleted_and_cant_undo_that {
    return Intl.message(
      'Your progress will be deleted and you can\'t undo that',
      name: 'your_progress_will_be_deleted_and_cant_undo_that',
      desc: '',
      args: [],
    );
  }

  /// `Zikr Index`
  String get zikr_index {
    return Intl.message(
      'Zikr Index',
      name: 'zikr_index',
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