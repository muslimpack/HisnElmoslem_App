import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/src/features/bookmark/presentation/controller/bloc/bookmark_bloc.dart';
import 'package:hisnelmoslem/src/features/custom_azkar/presentation/bloc/custom_titles/custom_titles_bloc.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/data/reciter_audio_repo.dart';
import 'package:hisnelmoslem/src/features/reciter_audio/presentation/components/reciter_download_actions.dart';
import 'package:hisnelmoslem/src/features/themes/data/models/theme_brightness_mode_enum.dart';
import 'package:hisnelmoslem/src/features/themes/presentation/controller/cubit/theme_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_audio_player/presentation/components/zikr_audio_settings_dialog.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/custom_title_source.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/commentary_dialog.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_action_tile.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

/// Every action available for the current zikr, as labelled tiles.
class ZikrActionsSheet extends StatelessWidget {
  final DbContent dbContent;
  const ZikrActionsSheet({super.key, required this.dbContent});

  static Future<void> show(BuildContext context, {required DbContent dbContent}) {
    final viewerBloc = context.read<ZikrViewerBloc>();

    return showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: viewerBloc,
        child: ZikrActionsSheet(dbContent: dbContent),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final s = S.of(context);
    final viewerBloc = context.read<ZikrViewerBloc>();
    final isCustom = dbContent.isFromCustomTitle;

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: GridView.count(
          crossAxisCount: 3,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          childAspectRatio: 1.05,
          children: [
            ZikrActionTile(
              icon: Icons.share_rounded,
              label: s.share,
              onTap: () {
                Navigator.pop(context);
                viewerBloc.add(ZikrViewerShareZikrEvent(content: dbContent));
              },
            ),
            ZikrActionTile(
              icon: Icons.repeat_rounded,
              label: s.resetZikr,
              onTap: () {
                Navigator.pop(context);
                viewerBloc.add(ZikrViewerResetZikrEvent(content: dbContent));
              },
            ),
            if (!isCustom)
              ZikrActionTile(
                icon: MdiIcons.comment,
                label: s.commentary,
                onTap: () {
                  final parent = Navigator.of(context);
                  parent.pop();
                  showCommentaryDialog(context: parent.context, contentId: dbContent.id);
                },
              ),
            if (!isCustom)
              OriginalZikrFavouriteTile(dbContent: dbContent)
            else if (dbContent.customZikrId != null)
              CustomZikrFavouriteTile(zikrId: dbContent.customZikrId!),
            if (dbContent.hasPlayableAudio)
              ZikrActionTile(
                icon: Icons.graphic_eq_rounded,
                label: s.audioPlayerSettings,
                onTap: () {
                  final parent = Navigator.of(context);
                  final audioCubit = viewerBloc.zikrAudioPlayerCubit;
                  parent.pop();
                  ZikrAudioSettingsDialog.show(parent.context, cubit: audioCubit);
                },
              ),
            if (!isCustom)
              ZikrActionTile(
                icon: Icons.download_rounded,
                label: s.audioDownloadTitleAction,
                onTap: () {
                  final parent = Navigator.of(context);
                  parent.pop();
                  ReciterDownloadActions.download(
                    parent.context,
                    sl<ReciterAudioRepo>().getReciter(),
                    titleId: dbContent.titleId,
                  );
                },
              ),
            const BrightnessActionTile(),
            ZikrActionTile(
              icon: MdiIcons.formatQuoteOpen,
              label: s.fontSettings,
              onTap: () {
                final parent = Navigator.of(context);
                parent.pop();
                FontSettingsDialog.show(parent.context);
              },
            ),
            if (!isCustom)
              ZikrActionTile(
                icon: Icons.report_outlined,
                label: s.report,
                color: Colors.orange,
                onTap: () {
                  Navigator.pop(context);
                  viewerBloc.add(ZikrViewerReportZikrEvent(content: dbContent));
                },
              ),
          ],
        ),
      ),
    );
  }
}

/// Favourite toggle of an original zikr (state from [BookmarkBloc]).
class OriginalZikrFavouriteTile extends StatelessWidget {
  final DbContent dbContent;
  const OriginalZikrFavouriteTile({super.key, required this.dbContent});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BookmarkBloc, BookmarkState>(
      builder: (context, state) {
        final isBookmarked =
            state is BookmarkLoadedState &&
            state.bookmarkedContents.any((c) => c.id == dbContent.id);

        return ZikrActionTile(
          icon: isBookmarked ? Icons.favorite : Icons.favorite_border,
          label: S.of(context).bookmark,
          onTap: () => context.read<BookmarkBloc>().add(
            BookmarkToggleContentBookmarkEvent(content: dbContent, bookmark: !isBookmarked),
          ),
        );
      },
    );
  }
}

/// Favourite toggle of a zikr written by the user (state from [CustomTitlesBloc]).
class CustomZikrFavouriteTile extends StatelessWidget {
  final int zikrId;
  const CustomZikrFavouriteTile({super.key, required this.zikrId});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<CustomTitlesBloc, CustomTitlesState>(
      builder: (context, state) {
        final isFavourite =
            state is CustomTitlesLoadedState && state.favouriteZikrs.any((z) => z.id == zikrId);

        return ZikrActionTile(
          icon: isFavourite ? Icons.favorite : Icons.favorite_border,
          label: S.of(context).bookmark,
          onTap: () => context.read<CustomTitlesBloc>().add(
            CustomZikrToggleFavouriteEvent(zikrId: zikrId, favourite: !isFavourite),
          ),
        );
      },
    );
  }
}

/// Cycles light / dark / system and shows the current mode.
class BrightnessActionTile extends StatelessWidget {
  const BrightnessActionTile({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeState>(
      builder: (context, state) {
        return ZikrActionTile(
          icon: switch (state.themeBrightnessMode) {
            ThemeBrightnessModeEnum.dark => Icons.dark_mode,
            ThemeBrightnessModeEnum.light => Icons.light_mode,
            ThemeBrightnessModeEnum.system => Icons.brightness_medium_outlined,
          },
          label: state.themeBrightnessMode.localeName(context),
          onTap: () => sl<ThemeCubit>().toggleBrightnessMode(),
        );
      },
    );
  }
}
