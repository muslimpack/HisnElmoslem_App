import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/pages/titles_list_view.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';

class AzkarBookmarks extends StatelessWidget {
  const AzkarBookmarks({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoadedState) {
          return const SizedBox();
        }
        return state.bookmarkedTitles.isEmpty
            ? Empty(
                isImage: false,
                icon: Icons.bookmark_outline_rounded,
                title: "nothing found in favorites".tr,
                description:
                    "no title from the index is marked as a favourite. Click on the Favorites icon at any index title"
                        .tr,
              )
            : HomeTitlesListView(
                titles: state.bookmarkedTitles,
                alarms: state.alarms,
              );
      },
    );
  }
}
