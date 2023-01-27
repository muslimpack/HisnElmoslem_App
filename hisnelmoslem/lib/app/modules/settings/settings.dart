import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/app/data/app_data.dart';
import 'package:hisnelmoslem/app/modules/about/about.dart';
import 'package:hisnelmoslem/app/modules/alarms_manager/alarms_page.dart';
import 'package:hisnelmoslem/app/modules/app_language_page/app_language_page.dart';
import 'package:hisnelmoslem/app/modules/font_family_page/font_family_page.dart';
import 'package:hisnelmoslem/app/modules/rearrange_dashboard/rearrange_dashboard_page.dart';
import 'package:hisnelmoslem/app/modules/settings/settings_controller.dart';
import 'package:hisnelmoslem/app/modules/sound_manager/sounds_manager_page.dart';
import 'package:hisnelmoslem/app/modules/theme_manager/themes_manager_page.dart';
import 'package:hisnelmoslem/app/shared/functions/get_snackbar.dart';
import 'package:hisnelmoslem/app/shared/functions/open_url.dart';
import 'package:hisnelmoslem/app/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/app/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/app/shared/widgets/scroll_glow_custom.dart';
import 'package:hisnelmoslem/core/utils/email_manager.dart';
import 'package:hisnelmoslem/core/values/constant.dart';
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
              "settings".tr,
              style: const TextStyle(fontFamily: "Uthmanic"),
            ),
            // backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          ),
          body: ScrollGlowCustom(
            child: ListView(
              physics: const ClampingScrollPhysics(),
              children: [
                Title(title: "general".tr),
                !appData.isCardReadMode
                    ? ListTile(
                        leading: const Icon(MdiIcons.bookOpenPageVariant),
                        title: Text("page mode".tr),
                        onTap: () {
                          appData.toggleReadModeStatus();
                          controller.update();
                        },
                      )
                    : ListTile(
                        leading: const Icon(MdiIcons.card),
                        title: Text("card mode".tr),
                        onTap: () {
                          appData.toggleReadModeStatus();
                          controller.update();
                        },
                      ),
                ListTile(
                  title: Text("theme manager".tr),
                  leading: const Icon(Icons.palette),
                  onTap: () {
                    transitionAnimation.fromBottom2Top(
                      context: context,
                      goToPage: const ThemeManagerPage(),
                    );
                  },
                ),
                ListTile(
                  title: Text("effect manager".tr),
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
                  title: Text("dashboard arrangement".tr),
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
                  title: Text("app language".tr),
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
                  title: Text("font type".tr),
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
                Title(title: "font settings".tr),
                TextSample(
                  controllerToUpdate: controller,
                ),
                FontSettingsToolbox(
                  controllerToUpdate: controller,
                ),
                const Divider(),
                /**/
                Title(title: "reminders".tr),
                ListTile(
                  title: Text("reminders manager".tr),
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
                    contentPadding: const EdgeInsets.all(0),
                    leading: const Icon(
                      Icons.person,
                    ),
                    title: Text("fasting mondays and thursdays reminder".tr),
                  ),
                  activeColor: mainColor,
                  value: appData.isFastAlarmEnabled,
                  onChanged: (value) {
                    appData.changFastAlarmStatus(value);

                    if (appData.isFastAlarmEnabled) {
                      getSnackbar(
                        message:
                            "${"activate".tr} | ${"fasting mondays and thursdays reminder".tr}",
                      );
                    } else {
                      getSnackbar(
                        message:
                            "${"deactivate".tr} | ${"fasting mondays and thursdays reminder".tr}",
                      );
                    }
                    controller.update();
                  },
                ),
                SwitchListTile(
                  title: ListTile(
                    contentPadding: const EdgeInsets.all(0),
                    leading: const Icon(
                      Icons.alarm,
                    ),
                    title: Text("sura Al-Kahf reminder".tr),
                  ),
                  activeColor: mainColor,
                  value: appData.isCaveAlarmEnabled,
                  onChanged: (value) {
                    appData.changCaveAlarmStatus(value);

                    if (appData.isCaveAlarmEnabled) {
                      getSnackbar(
                        message:
                            "${"activate".tr} | ${"sura Al-Kahf reminder".tr}",
                      );
                    } else {
                      getSnackbar(
                        message:
                            "${"deactivate".tr} | ${"sura Al-Kahf reminder".tr}",
                      );
                    }
                    controller.update();
                  },
                ),
                const Divider(),
                /**/
                Title(title: 'contact'.tr),
                ListTile(
                  leading: const Icon(Icons.star),
                  title: Text("report bugs and request new features".tr),
                  onTap: () {
                    EmailManager.sendFeedbackForm();
                  },
                ),
                ListTile(
                  leading: const Icon(MdiIcons.gmail),
                  title: Text("send email".tr),
                  onTap: () {
                    EmailManager.messageUS();
                  },
                ),
                ListTile(
                  leading: const Icon(MdiIcons.github),
                  trailing: const Icon(Icons.keyboard_arrow_left),
                  title: Text("Github".tr),
                  onTap: () async {
                    await openURL(
                      'https://github.com/muslimpack/HisnElmoslem_App',
                    );
                  },
                ),
                ListTile(
                  leading: const Icon(MdiIcons.information),
                  trailing: const Icon(Icons.keyboard_arrow_left),
                  title: Text("about us".tr),
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
