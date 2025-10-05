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
            title: Text(state.title.name),
            actions: [
              AnimatedZikrProgressCounter(
                currentIndex: state.activeZikrIndex,
                totalCount: state.azkarToView.length,
              ),
              BookmarkTitleButton(titleId: state.title.id),
            ],
            bottom: state.activeZikr == null
                ? null
                : const PreferredSize(
                    preferredSize: Size.fromHeight(10),
                    child: Column(children: [ZikrViewerProgressBar()]),
                  ),
          ),
          body: PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: context.read<ZikrViewerBloc>().pageController,
            itemCount: state.azkarToView.length,
            itemBuilder: (context, index) {
              return ZikrViewerPageBuilder(dbContent: state.azkarToView[index]);
            },
          ),

          floatingActionButton: state.activeZikr == null
              ? null
              : ZikrViewerExpandingFab(dbContent: state.activeZikr!),
          floatingActionButtonLocation: ExpandableFab.location,
        );
      },
    );
  }
}
