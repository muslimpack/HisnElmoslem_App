import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/functions/get_snackbar.dart';
import 'package:hisnelmoslem/src/core/functions/open_url.dart';
import 'package:hisnelmoslem/src/core/repos/app_data.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/src/core/utils/email_manager.dart';
import 'package:hisnelmoslem/src/features/about/presentation/screens/about.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/screens/alarms_page.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/screens/sounds_manager_page.dart';
import 'package:hisnelmoslem/src/features/fonts/presentation/screens/font_family_page.dart';
import 'package:hisnelmoslem/src/features/localization/presentation/screens/app_language_page.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/components/rearrange_dashboard/rearrange_dashboard_page.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/settings_controller.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/screens/themes_manager_page.dart';
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
            ),
          ),
          body: ListView(
            physics: const BouncingScrollPhysics(),
            children: [
              Title(title: "general".tr),
              if (!appData.isCardReadMode)
                ListTile(
                  leading: Icon(MdiIcons.bookOpenPageVariant),
                  title: Text("page mode".tr),
                  onTap: () {
                    appData.toggleReadModeStatus();
                    controller.update();
                  },
                )
              else
                ListTile(
                  leading: Icon(MdiIcons.card),
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
              SwitchListTile(
                tileColor: Colors.amber.withOpacity(.1),
                value: appData.useHindiDigits,
                title: Text("useHindiDigits".tr),
                subtitle: Text("Requires app restart".tr),
                onChanged: (value) {
                  appData.toggleUseHindiDigits();
                  controller.update();
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
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.person,
                  ),
                  title: Text("fasting mondays and thursdays reminder".tr),
                ),
                value: appData.isFastAlarmEnabled,
                onChanged: (value) {
                  appData.changFastAlarmStatus(value: value);

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
                  contentPadding: EdgeInsets.zero,
                  leading: const Icon(
                    Icons.alarm,
                  ),
                  title: Text("sura Al-Kahf reminder".tr),
                ),
                value: appData.isCaveAlarmEnabled,
                onChanged: (value) {
                  appData.changCaveAlarmStatus(value: value);

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
                leading: Icon(MdiIcons.gmail),
                title: Text("send email".tr),
                onTap: () {
                  EmailManager.messageUS();
                },
              ),
              ListTile(
                leading: Icon(MdiIcons.github),
                trailing: const Icon(Icons.keyboard_arrow_left),
                title: Text("Github".tr),
                onTap: () async {
                  await openURL(
                    'https://github.com/muslimpack/HisnElmoslem_App',
                  );
                },
              ),
              ListTile(
                leading: Icon(MdiIcons.information),
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
        style: TextStyle(
          fontSize: 20,
          color: Theme.of(context).colorScheme.primary,
        ),
      ),
    );
  }
}
