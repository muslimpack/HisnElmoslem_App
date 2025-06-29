import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/src/features/themes/data/models/theme_brightness_mode_enum.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/commentary_dialog.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';

class ZikrViewerPageModeBottomBar extends StatelessWidget {
  final DbContent dbContent;
  const ZikrViewerPageModeBottomBar({super.key, required this.dbContent});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      height: 85,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: <Widget>[
          IconButton(
            tooltip: S.of(context).resetZikr,
            padding: EdgeInsets.zero,
            icon: const Icon(Icons.repeat),
            onPressed: () {
              context.read<ZikrViewerBloc>().add(
                ZikrViewerResetZikrEvent(content: dbContent),
              );
            },
          ),
          IconButton(
            tooltip: S.of(context).commentary,
            icon: const Icon(Icons.description_outlined),
            onPressed: () {
              showCommentaryDialog(context: context, contentId: dbContent.id);
            },
          ),
          if (!dbContent.favourite)
            IconButton(
              icon: const Icon(Icons.favorite_border),
              onPressed: () {
                context.read<ZikrViewerBloc>().add(
                  ZikrViewerToggleZikrBookmarkEvent(
                    content: dbContent,
                    bookmark: true,
                  ),
                );
              },
            )
          else
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: Theme.of(context).colorScheme.primary,
              ),
              onPressed: () {
                context.read<ZikrViewerBloc>().add(
                  ZikrViewerToggleZikrBookmarkEvent(
                    content: dbContent,
                    bookmark: false,
                  ),
                );
              },
            ),
          PopupMenuButton(
            itemBuilder: (context) {
              return [
                PopupMenuItem(
                  child: ListTile(
                    mouseCursor: SystemMouseCursors.click,
                    leading: const Icon(
                      Icons.report_outlined,
                      color: Colors.orange,
                    ),
                    title: Text(S.of(context).report),
                  ),
                  onTap: () {
                    context.read<ZikrViewerBloc>().add(
                      ZikrViewerReportZikrEvent(content: dbContent),
                    );
                  },
                ),
                PopupMenuItem(
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return Dialog(
                          alignment: Alignment.center,
                          child: Container(
                            height: 277,
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: BlocBuilder<ThemeCubit, ThemeState>(
                              builder: (context, state) {
                                return Column(
                                  children: [
                                    Text(S.of(context).chooseBrightnessMode),
                                    const SizedBox(height: 25),
                                    RadioListTile(
                                      dense: false,
                                      title: Text(S.of(context).brightnessDark),
                                      secondary: const Icon(Icons.dark_mode),
                                      value: ThemeBrightnessModeEnum.dark,
                                      groupValue: state.themeBrightnessMode,
                                      onChanged: sl
                                          .get<ThemeCubit>()
                                          .changeBrightnessMode,
                                    ),
                                    RadioListTile(
                                      dense: false,
                                      title: Text(
                                        S.of(context).brightnessLight,
                                      ),
                                      secondary: const Icon(Icons.light_mode),
                                      value: ThemeBrightnessModeEnum.light,
                                      groupValue: state.themeBrightnessMode,
                                      onChanged: sl
                                          .get<ThemeCubit>()
                                          .changeBrightnessMode,
                                    ),
                                    RadioListTile(
                                      dense: false,
                                      title: Text(
                                        S.of(context).brightnessSystem,
                                      ),
                                      secondary: const Icon(
                                        Icons.brightness_medium_outlined,
                                      ),
                                      value: ThemeBrightnessModeEnum.system,
                                      groupValue: state.themeBrightnessMode,
                                      onChanged: sl
                                          .get<ThemeCubit>()
                                          .changeBrightnessMode,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                  child: ListTile(
                    title: Text(S.of(context).brightness),
                    leading: const Icon(Icons.brightness_6),
                  ),
                ),
                PopupMenuItem(
                  child: ListTile(
                    title: Text(S.of(context).fontSettings),
                    leading: const Icon(Icons.text_format_outlined),
                    mouseCursor: SystemMouseCursors.click,
                  ),
                  onTap: () {
                    showDialog(
                      context: context,
                      builder: (context) {
                        return const AlertDialog(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.all(Radius.circular(15)),
                          ),
                          contentPadding: EdgeInsets.zero,
                          content: FontSettingsToolbox(),
                        );
                      },
                    );
                  },
                ),
                PopupMenuItem(
                  onTap: () {
                    context.read<ZikrViewerBloc>().add(
                      ZikrViewerShareZikrEvent(content: dbContent),
                    );
                  },
                  child: ListTile(
                    mouseCursor: SystemMouseCursors.click,
                    title: Text(S.of(context).share),
                    leading: const Icon(Icons.share),
                  ),
                ),
              ];
            },
          ),
        ],
      ),
    );
  }
}
