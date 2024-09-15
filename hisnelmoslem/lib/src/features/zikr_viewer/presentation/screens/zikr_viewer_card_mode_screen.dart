// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/extensions/extension_object.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/effects_manager/presentation/controller/sounds_manager_controller.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_viewer_mode.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_viewer_card_builder.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/controller/bloc/zikr_viewer_bloc.dart';

class ZikrViewerCardModeScreen extends StatelessWidget {
  final int index;

  const ZikrViewerCardModeScreen({super.key, required this.index});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ZikrViewerBloc(
        soundsManagerController: SoundsManagerController(),
        homeBloc: context.read<HomeBloc>(),
        zikrViewerMode: ZikrViewerMode.card,
        azkarDatabaseHelper: sl(),
      )..add(ZikrViewerStartEvent(titleIndex: index)),
      child: BlocBuilder<ZikrViewerBloc, ZikrViewerState>(
        builder: (context, state) {
          if (state is! ZikrViewerLoadedState) {
            return const Loading();
          }
          return Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(
                state.title.name,
              ),
              actions: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "${state.azkarToView.length}".toArabicNumber(),
                  ),
                ),
              ],
              bottom: PreferredSize(
                preferredSize: const Size(100, 5),
                child: Stack(
                  children: [
                    LinearProgressIndicator(
                      value: 1 - state.manorProgress,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    LinearProgressIndicator(
                      backgroundColor: Colors.transparent,
                      value: state.majorProgress,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Theme.of(context).colorScheme.primary.withOpacity(.5),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            body: ListView.builder(
              physics: const BouncingScrollPhysics(),
              itemCount: state.azkarToView.length,
              itemBuilder: (context, index) {
                return ZikrViewerCardBuilder(
                  dbContent: state.azkarToView[index],
                );
              },
            ),
            bottomNavigationBar: const BottomAppBar(
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Expanded(
                    child: FontSettingsToolbox(),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
