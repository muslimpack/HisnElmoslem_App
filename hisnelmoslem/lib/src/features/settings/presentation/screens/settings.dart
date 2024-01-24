import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/managers/email_manager.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/src/core/utils/get_snackbar.dart';
import 'package:hisnelmoslem/src/core/utils/open_url.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/about/presentation/screens/about.dart';
import 'package:hisnelmoslem/src/features/alarm/presentation/screens/alarms_page.dart';
import 'package:hisnelmoslem/src/features/settings/data/data_source/app_data.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/components/app_language_page/app_language_page.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/components/font_family_page/font_family_page.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/components/rearrange_dashboard/rearrange_dashboard_page.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/components/sound_manager/sounds_manager_page.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/settings_controller.dart';
import 'package:hisnelmoslem/src/features/theme/presentation/screens/themes_manager_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SettingsController>(
      init: SettingsController(),
      builder: (controller) {
        return Scaffold(
          appBar: AppBar(
            centerTitle: true,
            elevation: 0,
            title: Text(
              S.of(context).settings,
              style: const TextStyle(fontFamily: "Uthmanic"),
            ),
            // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Title(title: S.of(context).general),
              if (!appData.isCardReadMode)
                ListTile(
                  leading: Icon(MdiIcons.bookOpenPageVariant),
                  title: Text(S.of(context).page_mode),
                  onTap: () {
                    appData.toggleReadModeStatus();
                    controller.update();
                  },
                )
              else
                ListTile(
                  leading: Icon(MdiIcons.card),
                  title: Text(S.of(context).card_mode),
                  onTap: () {
                    appData.toggleReadModeStatus();
                    controller.update();
                  },
                ),
              ListTile(
                title: Text(S.of(context).theme_manager),
                leading: const Icon(Icons.palette),
                onTap: () {
                  transitionAnimation.fromBottom2Top(
                    context: context,
                    goToPage: const ThemeManagerPage(),
                  );
                },
              ),
              ListTile(
                title: Text(S.of(context).effect_manager),
                leading: const Icon(
                  Icons.speaker_group,
                ),
                onTap: () {
                  transitionAnimation.fromBottom2Top(
                    context: context,
                    goToPage: const SoundsManagerPage(),
                  );
                },
              ),
              ListTile(
                title: Text(S.of(context).dashboard_arrangement),
                leading: const Icon(
                  Icons.view_array,
                ),
                onTap: () {
                  transitionAnimation.fromBottom2Top(
                    context: context,
                    goToPage: const RearrangeDashboardPage(),
                  );
                },
              ),
              ListTile(
                title: Text(S.of(context).app_language),
                leading: const Icon(
                  Icons.translate,
                ),
                onTap: () {
                  transitionAnimation.fromBottom2Top(
                    context: context,
                    goToPage: const AppLanguagePage(),
                  );
                },
              ),
              ListTile(
                title: Text(S.of(context).font_type),
                leading: const Icon(
                  Icons.font_download,
                ),
                onTap: () {
                  transitionAnimation.fromBottom2Top(
                    context: context,
                    goToPage: const FontFamilyPage(),
                  );
                },
              ),
              const Divider(),
              Title(title: S.of(context).font_settings),
              TextSample(
                controllerToUpdate: controller,
              ),
              FontSettingsToolbox(
                controllerToUpdate: controller,
              ),
              const Divider(),
              /**/
              Title(title: S.of(context).reminders),
              ListTile(
                title: Text(S.of(context).reminders_manager),
                leading: const Icon(
                  Icons.alarm_add_rounded,
                ),
                onTap: () {
                  transitionAnimation.fromBottom2Top(
                    context: context,
                    goToPage: const AlarmsPages(),
                  );
                },
              ),
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.person,
                  ),
                  title: Text(
                    S.of(context).fasting_mondays_and_thursdays_reminder,
                  ),
                ),
                activeColor: mainColor,
                value: appData.isFastAlarmEnabled,
                onChanged: (value) {
                  appData.changFastAlarmStatus(value: value);

                  if (appData.isFastAlarmEnabled) {
                    getSnackbar(
                      message:
                          "${S.of(context).activate} | ${S.of(context).fasting_mondays_and_thursdays_reminder}",
                    );
                  } else {
                    getSnackbar(
                      message:
                          "${S.of(context).deactivate} | ${S.of(context).fasting_mondays_and_thursdays_reminder}",
                    );
                  }
                  controller.update();
                },
              ),
              SwitchListTile(
                title: ListTile(
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.alarm,
                  ),
                  title: Text(S.of(context).sura_al_kahf_reminder),
                ),
                activeColor: mainColor,
                value: appData.isCaveAlarmEnabled,
                onChanged: (value) {
                  appData.changCaveAlarmStatus(value: value);

                  if (appData.isCaveAlarmEnabled) {
                    getSnackbar(
                      message:
                          "${S.of(context).activate} | ${S.of(context).sura_al_kahf_reminder}",
                    );
                  } else {
                    getSnackbar(
                      message:
                          "${S.of(context).deactivate} | ${S.of(context).sura_al_kahf_reminder}",
                    );
                  }
                  controller.update();
                },
              ),
              const Divider(),
              /**/
              Title(title: S.of(context).contact),
              ListTile(
                leading: const Icon(Icons.star),
                title: Text(S.of(context).report_bugs_and_request_new_features),
                onTap: () {
                  EmailManager.sendFeedbackForm();
                },
              ),
              ListTile(
                leading: Icon(MdiIcons.gmail),
                title: Text(S.of(context).send_email),
                onTap: () {
                  EmailManager.messageUS();
                },
              ),
              ListTile(
                leading: Icon(MdiIcons.github),
                trailing: const Icon(Icons.keyboard_arrow_left),
                title: Text(S.of(context).github),
                onTap: () async {
                  await openURL(
                    'https://github.com/muslimpack/HisnElmoslem_App',
                  );
                },
              ),
              ListTile(
                leading: Icon(MdiIcons.information),
                trailing: const Icon(Icons.keyboard_arrow_left),
                title: Text(S.of(context).about_us),
                onTap: () {
                  transitionAnimation.fromBottom2Top(
                    context: context,
                    goToPage: const About(),
                  );
                },
              ),
              const Divider(),
            ],
          ),
        );
      },
    );
  }
}

class Title extends StatelessWidget {
  final String title;

  const Title({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      // leading: Icon(Icons.bookmark_border),

      title: Text(
        title,
        style: TextStyle(fontSize: 20, color: mainColor),
      ),
    );
  }
}
