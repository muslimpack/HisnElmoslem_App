import 'package:capture_widget/capture_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/share_image_bottom_bar.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/share_image_card.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/share_image_settings_editor.dart';
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
            body: GestureDetector(
              onDoubleTap: () {
                context.read<ShareImageCubit>().fitImageToScreen(context);
              },
              child: Stack(
                children: [
                  InteractiveViewer(
                    constrained: false,
                    // clipBehavior: Clip.none,
                    transformationController: context
                        .read<ShareImageCubit>()
                        .transformationController,
                    minScale: 0.25,
                    maxScale: 3,
                    boundaryMargin: const EdgeInsets.all(5000),
                    child: CaptureWidget(
                      controller: context
                          .read<ShareImageCubit>()
                          .captureWidgetController,
                      child: const ShareImageCard(),
                    ),
                  ),
                ],
              ),
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
