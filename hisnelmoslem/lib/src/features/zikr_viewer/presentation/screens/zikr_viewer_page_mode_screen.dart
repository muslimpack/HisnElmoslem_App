part of 'zikr_viewer_screen.dart';

class _ZikrViewerPageModeScreen extends StatelessWidget {
  const _ZikrViewerPageModeScreen();

  void _movePage(PageController controller, int pageCount, int step) {
    if (!controller.hasClients || controller.position.isScrollingNotifier.value) return;
    final page = controller.page;
    if (page == null) return;
    final target = page.round() + step;
    if (target < 0 || target >= pageCount) return;

    controller.animateToPage(
      target,
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZikrViewerBloc, ZikrViewerState>(
      builder: (context, state) {
        if (state is! ZikrViewerLoadedState) {
          return const Loading();
        }
        final pageController = context.read<ZikrViewerBloc>().pageController;
        final pageCount = state.azkarToView.length;
        final screen = Scaffold(
          appBar: ZikrViewerAppBar(
            title: state.title.name,
            titleId: state.title.id,
            showProgress: state.activeZikr != null,
            actions: [
              if (state.title.isCustom)
                ViewerCustomTitleFavouriteButton(customTitleId: state.title.customTitleId)
              else
                BookmarkTitleButton(titleId: state.title.id),
            ],
          ),
          body: _ZikrViewerDesktopBody(
            child: PageView.builder(
              physics: const BouncingScrollPhysics(),
              controller: pageController,
              itemCount: pageCount,
              itemBuilder: (context, index) {
                return ZikrViewerPageBuilder(dbContent: state.azkarToView[index]);
              },
            ),
          ),
          bottomNavigationBar: state.activeZikr == null
              ? null
              : ZikrViewerBottomDock(dbContent: state.activeZikr!),
        );

        if (!PlatformExtension.isDesktop) return screen;
        final rightStep = Directionality.of(context) == TextDirection.rtl ? -1 : 1;
        return CallbackShortcuts(
          bindings: {
            const SingleActivator(LogicalKeyboardKey.arrowLeft): () {
              _movePage(pageController, pageCount, -rightStep);
            },
            const SingleActivator(LogicalKeyboardKey.arrowRight): () {
              _movePage(pageController, pageCount, rightStep);
            },
          },
          child: Focus(autofocus: true, skipTraversal: true, child: screen),
        );
      },
    );
  }
}
