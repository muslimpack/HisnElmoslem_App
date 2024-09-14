import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/empty.dart';
import 'package:hisnelmoslem/src/features/home/data/models/zikr_title.dart';
import 'package:hisnelmoslem/src/features/home/presentation/components/widgets/home_bookmarked_content_card.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';

class FavouriteZikr extends StatelessWidget {
  const FavouriteZikr({super.key});

  @override
  Widget build(BuildContext context) {
    //
    return BlocBuilder<HomeBloc, HomeState>(
      builder: (context, state) {
        if (state is! HomeLoadedState) {
          return const SizedBox();
        }

        return state.bookmarkedContents.isEmpty
            ? Empty(
                isImage: false,
                icon: Icons.favorite_outline_rounded,
                title: "nothing found in favorites".tr,
                description:
                    "no zikr has been selected as a favorite Click on the heart icon on any internal zikr"
                        .tr,
              )
            : ListView.builder(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 50),
                itemCount: state.bookmarkedContents.length,
                itemBuilder: (BuildContext context, int index) {
                  final DbContent dbContent = state.bookmarkedContents[index];
                  final DbTitle dbTitle = state.titles
                      .where((element) => element.id == dbContent.titleId)
                      .first;

                  return HomeBookmarkedContentCard(
                    dbContent: dbContent,
                    dbTitle: dbTitle,
                  );
                },
              );
      },
    );
  }
}
