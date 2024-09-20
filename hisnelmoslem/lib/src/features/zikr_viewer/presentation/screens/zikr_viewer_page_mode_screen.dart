part of 'zikr_viewer_screen.dart';

class _ZikrViewerPageModeScreen extends StatelessWidget {
  const _ZikrViewerPageModeScreen();

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
                  "${state.activeZikrIndex + 1} : ${state.azkarToView.length}"
                      .toArabicNumber(),
                ),
              ),
            ],
            bottom: state.activeZikr == null
                ? null
                : PreferredSize(
                    preferredSize: const Size.fromHeight(50),
                    child: Column(
                      children: [
                        ZikrViewerTopBar(dbContent: state.activeZikr!),
                        const ZikrViewerProgressBar(),
                      ],
                    ),
                  ),
          ),
          body: PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: context.read<ZikrViewerBloc>().pageController,
            itemCount: state.azkarToView.length,
            itemBuilder: (context, index) {
              return ZikrViewerPageBuilder(
                dbContent: state.azkarToView[index],
              );
            },
          ),
          bottomNavigationBar: state.activeZikr == null
              ? null
              : ZikrViewerPageModeBottomBar(dbContent: state.activeZikr!),
        );
      },
    );
  }
}
