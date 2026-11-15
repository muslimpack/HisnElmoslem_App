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
          body: PageView.builder(
            physics: const BouncingScrollPhysics(),
            controller: context.read<ZikrViewerBloc>().pageController,
            itemCount: state.azkarToView.length,
            itemBuilder: (context, index) {
              return ZikrViewerPageBuilder(dbContent: state.azkarToView[index]);
            },
          ),
          bottomNavigationBar: state.activeZikr == null
              ? null
              : ZikrViewerBottomDock(dbContent: state.activeZikr!),
        );
      },
    );
  }
}
