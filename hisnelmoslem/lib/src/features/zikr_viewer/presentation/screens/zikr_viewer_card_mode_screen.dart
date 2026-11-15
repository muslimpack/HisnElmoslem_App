part of 'zikr_viewer_screen.dart';

class _ZikrViewerCardModeScreen extends StatelessWidget {
  const _ZikrViewerCardModeScreen();

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZikrViewerBloc, ZikrViewerState>(
      builder: (context, state) {
        if (state is! ZikrViewerLoadedState) {
          return const Loading();
        }
        return Scaffold(
          appBar: ZikrViewerAppBar(
            title: state.title.name,
            titleId: state.title.id,
            actions: [
              if (!PlatformExtension.isDesktop) const ToggleBrightnessButton(),
            ],
          ),
          body: ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(8),
            itemCount: state.azkarToView.length,
            itemBuilder: (context, index) {
              return ZikrViewerCardBuilder(dbContent: state.azkarToView[index]);
            },
          ),
          bottomNavigationBar: const Card(
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[Expanded(child: FontSettingsBar())],
            ),
          ),
        );
      },
    );
  }
}
