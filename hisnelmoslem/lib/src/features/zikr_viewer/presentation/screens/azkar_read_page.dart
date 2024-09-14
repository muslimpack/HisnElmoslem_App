import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/controller/sounds_manager_controller.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_viewer_page_mode_appbar.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_viewer_page_mode_bottom_bar.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_viewer_page_mode_page_builder.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_page_viewer_bloc.dart';

class AzkarReadPage extends StatelessWidget {
  final int index;

  const AzkarReadPage({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ZikrPageViewerBloc(SoundsManagerController())
        ..add(ZikrPageViewerStartEvent(titleIndex: index)),
      child: BlocBuilder<ZikrPageViewerBloc, ZikrPageViewerState>(
        builder: (context, state) {
          if (state is! ZikrPageViewerLoadedState) {
            return const Loading();
          }
          return Scaffold(
            // key: controller.hReadScaffoldKey, // TODO
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                state.title.name,
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${state.activeZikrIndex + 1} :: ${state.azkarToView.length}"
                        .toArabicNumber(),
                  ),
                ),
              ],
              bottom: const PreferredSize(
                preferredSize: Size.fromHeight(50),
                child: ZikrViewerPageModeAppBar(),
              ),
            ),
            body: PageView.builder(
              physics: const BouncingScrollPhysics(),
              controller: context.read<ZikrPageViewerBloc>().pageController,
              itemCount: state.azkarToView.length,
              itemBuilder: (context, index) {
                return ZikrViewerPageBuilder(
                  dbContent: state.azkarToView[index],
                );
              },
            ),
            bottomNavigationBar: const ZikrViewerPageModeBottomBar(),
          );
        },
      ),
    );
  }
}
