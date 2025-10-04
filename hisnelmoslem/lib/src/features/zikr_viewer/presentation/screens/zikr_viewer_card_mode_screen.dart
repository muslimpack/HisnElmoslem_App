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
          appBar: AppBar(
            centerTitle: true,
            title: Text(state.title.name),
            actions: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text("${state.azkarToView.length}".toArabicNumber()),
              ),
              if (!PlatformExtension.isDesktop) const ToggleBrightnessButton(),
            ],
            bottom: const PreferredSize(
              preferredSize: Size(100, 5),
              child: ZikrViewerProgressBar(),
            ),
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
