import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/share_image_bottom_bar.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/share_image_settings_editor.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/widgets/shareable_image_card.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/controller/cubit/share_image_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

class ShareAsImageScreen extends StatelessWidget {
  final DbContent dbContent;

  const ShareAsImageScreen({super.key, required this.dbContent});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<ShareImageCubit>()..start(dbContent),
      child: BlocBuilder<ShareImageCubit, ShareImageState>(
        builder: (context, state) {
          if (state is! ShareImageLoadedState) {
            return const Loading();
          }
          return Scaffold(
            resizeToAvoidBottomInset: false,
            appBar: AppBar(
              elevation: 0,
              title: Text(S.of(context).shareAsImage),
              centerTitle: true,
              actions: const [ShareImageBaractionButtons()],
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(
                  !state.showLoadingIndicator ? 0 : 20,
                ),
                child: !state.showLoadingIndicator
                    ? const SizedBox()
                    : LinearProgressIndicator(
                        backgroundColor: Theme.of(
                          context,
                        ).scaffoldBackgroundColor,
                        minHeight: 15,
                      ),
              ),
            ),
            body: PageView.builder(
              controller: context.read<ShareImageCubit>().pageController,
              itemCount: state.splittedMatn.length,
              onPageChanged: context.read<ShareImageCubit>().onPageChanged,
              itemBuilder: (context, index) {
                return Stack(
                  fit: StackFit.expand,
                  alignment: Alignment.center,
                  children: [
                    FittedBox(
                      child: RepaintBoundary(
                        key: context.read<ShareImageCubit>().imageKeys[index],
                        child: ShareableImageCard(
                          zikr: state.content,
                          zikrTitle: state.title,
                          settings: state.settings,
                          matnRange: state.splittedMatn[index],
                          splittedLength: state.splittedMatn.length,
                          splittedindex: index,
                          shareImageSettings: state.shareImageSettings,
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            bottomSheet: const ShareImageBottomBar(),
          );
        },
      ),
    );
  }
}

class ShareImageBaractionButtons extends StatelessWidget {
  const ShareImageBaractionButtons({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          tooltip: S.of(context).settings,
          onPressed: () async {
            await showDialog(
              context: context,
              builder: (_) {
                return ShareImageSettingsEditor(context: context);
              },
            );
          },
          icon: const Icon(Icons.style),
        ),
        IconButton(
          tooltip: S.of(context).share,
          onPressed: () async {
            await context.read<ShareImageCubit>().shareImage();
          },
          icon: const Icon(Icons.share),
        ),
      ],
    );
  }
}
