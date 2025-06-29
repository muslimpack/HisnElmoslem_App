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
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  '${state.activeZikrIndex + 1} : ${state.azkarToView.length}'
                      .toArabicNumber(),
                ),
              ),
            ],
            bottom: state.activeZikr == null
                ? null
                : const PreferredSize(
                    preferredSize: Size.fromHeight(5),
                    child: Column(children: [ZikrViewerProgressBar()]),
                  ),
          ),
          floatingActionButtonLocation:
              FloatingActionButtonLocation.centerFloat,
          floatingActionButton: FloatingActionButton(
            onPressed: () {
              if (state.activeZikr != null) {
                context.read<ZikrViewerBloc>().add(
                  ZikrViewerDecreaseZikrEvent(content: state.activeZikr!),
                );
              }
            },
            backgroundColor: Theme.of(context).colorScheme.primaryContainer,
            elevation: .5,
            child: switch (state.activeZikr?.count) {
              null => const SizedBox(),
              final c when c == 0 => const Icon(Icons.done_outline, size: 28),
              int() => Text(
                state.activeZikr!.count.toString(),
                style: const TextStyle(fontSize: 28),
              ),
            },
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
              : ZikrViewerPageModeBottomBar(dbContent: state.activeZikr!),
        );
      },
    );
  }
}
