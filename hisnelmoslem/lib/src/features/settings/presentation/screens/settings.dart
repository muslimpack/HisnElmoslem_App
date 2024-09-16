import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/functions/open_url.dart';
import 'package:hisnelmoslem/src/core/shared/transition_animation/transition_animation.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/src/core/utils/email_manager.dart';
import 'package:hisnelmoslem/src/core/values/constant.dart';
import 'package:hisnelmoslem/src/features/about/presentation/screens/about.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/controller/bloc/alarms_bloc.dart';
import 'package:hisnelmoslem/src/features/alarms_manager/presentation/screens/alarms_page.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/screens/effects_manager_screen.dart';
import 'package:hisnelmoslem/src/features/fonts/presentation/screens/font_family_page.dart';
import 'package:hisnelmoslem/src/features/localization/presentation/screens/app_language_page.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/components/rearrange_dashboard/rearrange_dashboard_page.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/screens/themes_manager_page.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class Settings extends StatelessWidget {
  const Settings({super.key});

  @override
  Widget build(BuildContext context) {
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
          const SettingsGeneralSection(),
          const Divider(),
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
                goToPage: const EffectsManagerScreen(),
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
          const _SettingsFontSettingsSection(),
          const Divider(),
          const _SettingsAlarmsSection(),
          const Divider(),
          const _SettingsContactSection(),
        ],
      ),
    );
  }
}

class SettingsGeneralSection extends StatelessWidget {
  const SettingsGeneralSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          children: [
            if (!state.isCardReadMode)
              ListTile(
                leading: Icon(MdiIcons.bookOpenPageVariant),
                title: Text("page mode".tr),
                onTap: () {
                  context.read<SettingsCubit>().toggleIsCardReadMode(
                        activate: true,
                      );
                },
              )
            else
              ListTile(
                leading: Icon(MdiIcons.card),
                title: Text("card mode".tr),
                onTap: () {
                  context.read<SettingsCubit>().toggleIsCardReadMode(
                        activate: false,
                      );
                },
              ),
            SwitchListTile(
              value: state.enableWakeLock,
              title: Text("enableWakeLock".tr),
              onChanged: (value) {
                context.read<SettingsCubit>().toggleWakeLock(
                      use: !state.enableWakeLock,
                    );
              },
            ),
            SwitchListTile(
              tileColor: Colors.amber.withOpacity(.1),
              value: state.useHindiDigits,
              title: Text("useHindiDigits".tr),
              subtitle: Text("Requires app restart".tr),
              onChanged: (value) {
                context.read<SettingsCubit>().toggleUseHiniDigits(
                      use: !state.useHindiDigits,
                    );
              },
            ),
          ],
        );
      },
    );
  }
}

class _SettingsFontSettingsSection extends StatelessWidget {
  const _SettingsFontSettingsSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Title(title: "font settings".tr),
        const TextSample(),
        const FontSettingsToolbox(),
      ],
    );
  }
}

class _SettingsAlarmsSection extends StatelessWidget {
  const _SettingsAlarmsSection();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AlarmsBloc, AlarmsState>(
      builder: (context, state) {
        if (state is! AlarmsLoadedState) {
          return const SizedBox();
        }
        return Column(
          children: [
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
              value: state.isFastAlarmEnabled,
              onChanged: (value) {
                context
                    .read<AlarmsBloc>()
                    .add(AlarmsToggleFastAlarmEvent(value));
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
              value: state.isCaveAlarmEnabled,
              onChanged: (value) {
                context
                    .read<AlarmsBloc>()
                    .add(AlarmsToggleCaveAlarmEvent(value));
              },
            ),
          ],
        );
      },
    );
  }
}

class _SettingsContactSection extends StatelessWidget {
  const _SettingsContactSection();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Title(title: 'contact'.tr),
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
              kOrgGithub,
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
      ],
    );
  }
}

class Title extends StatelessWidget {
  final String title;

  const Title({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return ListTile(
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
