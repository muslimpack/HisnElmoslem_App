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
              if (!PlatformExtension.isDesktop) const ToggleBrightnessButton(),
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
                  child: FontSettingsBar(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
