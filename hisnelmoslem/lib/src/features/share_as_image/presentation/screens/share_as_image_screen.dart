import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/share_as_image/presentation/components/share_image_action_bar.dart';
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
              bottom: PreferredSize(
                preferredSize: Size.fromHeight(!state.showLoadingIndicator ? 0 : 4),
                child: !state.showLoadingIndicator
                    ? const SizedBox()
                    : const LinearProgressIndicator(minHeight: 4),
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
                    // Room around the picture; only the card inside is captured.
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: FittedBox(
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
                    ),
                  ],
                );
              },
            ),
            bottomNavigationBar: const ShareImageActionBar(),
          );
        },
      ),
    );
  }
}
