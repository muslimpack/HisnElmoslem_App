import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/font_settings.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/loading.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/components/pages/fake_hadith_read_page.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/components/pages/fake_hadith_unread_page.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/components/widgets/fake_hadith_appbar.dart';
import 'package:hisnelmoslem/src/features/fake_hadith/presentation/controller/bloc/fake_hadith_bloc.dart';

class FakeHadithDashboardScreen extends StatelessWidget {
  const FakeHadithDashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => sl<FakeHadithBloc>()..add(FakeHadithStartEvent()),
      child: BlocBuilder<FakeHadithBloc, FakeHadithState>(
        builder: (context, state) {
          if (state is! FakeHadithLoadedState) {
            return const Loading();
          }
          return DefaultTabController(
            length: 2,
            child: Scaffold(
              body: NestedScrollView(
                physics: const BouncingScrollPhysics(),
                floatHeaderSlivers: true,
                headerSliverBuilder:
                    (BuildContext context, bool innerBoxIsScrolled) {
                  return [
                    const FakehadithAppBar(),
                  ];
                },
                body: TabBarView(
                  // controller: tabController,
                  physics: const BouncingScrollPhysics(),
                  children: [
                    FakeHadithUnreadPage(hadithList: state.getUnreadHadith),
                    FakeHadithReadPage(hadithList: state.getReadHadith),
                  ],
                ),
              ),
              bottomNavigationBar: const BottomAppBar(
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      flex: 3,
                      child: FontSettingsToolbox(
                        showDiacriticsControllers: false,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
