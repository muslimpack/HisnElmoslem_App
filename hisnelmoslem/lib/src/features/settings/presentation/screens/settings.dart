import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
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
          S.of(context).settings,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        children: [
          Title(title: S.of(context).general),
          const SettingsGeneralSection(),
          const Divider(),
          ListTile(
            title: Text(S.of(context).themeManager),
            leading: const Icon(Icons.palette),
            onTap: () {
              transitionAnimation.fromBottom2Top(
                context: context,
                goToPage: const ThemeManagerPage(),
              );
            },
          ),
          ListTile(
            title: Text(S.of(context).effectManager),
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
            title: Text(S.of(context).dashboardArrangement),
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
            title: Text(S.of(context).appLanguage),
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
            title: Text(S.of(context).fontType),
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
                title: Text(S.of(context).pageMode),
                onTap: () {
                  context.read<SettingsCubit>().toggleIsCardReadMode(
                        activate: true,
                      );
                },
              )
            else
              ListTile(
                leading: Icon(MdiIcons.card),
                title: Text(S.of(context).cardMode),
                onTap: () {
                  context.read<SettingsCubit>().toggleIsCardReadMode(
                        activate: false,
                      );
                },
              ),
            SwitchListTile(
              secondary: const Icon(Icons.volume_down),
              value: state.praiseWithVolumeKeys,
              title: Text(S.of(context).prefPraiseWithVolumeKeys),
              subtitle: Text(S.of(context).prefPraiseWithVolumeKeysDesc),
              onChanged: (value) {
                context.read<SettingsCubit>().togglePraiseWithVolumeKeys(
                      use: !state.praiseWithVolumeKeys,
                    );
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.screenshot),
              value: state.enableWakeLock,
              title: Text(S.of(context).enableWakeLock),
              onChanged: (value) {
                context.read<SettingsCubit>().toggleWakeLock(
                      use: !state.enableWakeLock,
                    );
              },
            ),
            SwitchListTile(
              secondary: const Icon(Icons.numbers),
              tileColor: Colors.amber.withOpacity(.1),
              value: state.useHindiDigits,
              title: Text(S.of(context).useHindiDigits),
              subtitle: Text(S.of(context).requiresAppRestart),
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
        Title(title: S.of(context).fontSettings),
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
            Title(title: S.of(context).reminders),
            ListTile(
              title: Text(S.of(context).remindersManager),
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
              secondary: const Icon(
                Icons.alarm,
              ),
              title: Text(S.of(context).fastingMondaysThursdaysReminder),
              value: state.isFastAlarmEnabled,
              onChanged: (value) {
                context
                    .read<AlarmsBloc>()
                    .add(AlarmsToggleFastAlarmEvent(value));
              },
            ),
            SwitchListTile(
              secondary: const Icon(
                Icons.alarm,
              ),
              title: Text(S.of(context).suraAlKahfReminder),
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
        Title(title: S.of(context).contact),
        ListTile(
          leading: Icon(MdiIcons.gmail),
          title: Text(S.of(context).sendEmail),
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
              kOrgGithub,
            );
          },
        ),
        ListTile(
          leading: Icon(MdiIcons.information),
          trailing: const Icon(Icons.keyboard_arrow_left),
          title: Text(S.of(context).aboutUs),
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
