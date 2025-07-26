import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/features/home/presentation/controller/bloc/home_bloc.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/controller/cubit/search_cubit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SearchAppBar extends StatefulWidget {
  const SearchAppBar({super.key});

  @override
  State<SearchAppBar> createState() => _SearchAppBarState();
}

class _SearchAppBarState extends State<SearchAppBar> {
  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      floating: true,
      snap: true,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: () {
          context.read<HomeBloc>().add(
            const HomeToggleSearchEvent(isSearching: false),
          );
        },
      ),
      title: TextFormField(
        controller: context.read<SearchCubit>().searchController,
        autofocus: true,
        style: const TextStyle(fontSize: 18, fontFamily: "Kitab"),
        decoration: const InputDecoration(
          border: InputBorder.none,
          focusedBorder: InputBorder.none,
          enabledBorder: InputBorder.none,
          errorBorder: InputBorder.none,
          disabledBorder: InputBorder.none,
          hintText: "البحث في الأذكار",
          hintStyle: TextStyle(fontSize: 18, fontFamily: "Kitab"),
          contentPadding: EdgeInsets.only(
            left: 15,
            bottom: 5,
            top: 5,
            right: 15,
          ),
        ),
      ),
      actions: [
        IconButton(
          splashRadius: 20,
          padding: EdgeInsets.zero,
          icon: Icon(MdiIcons.eraser),
          onPressed: () {
            context.read<SearchCubit>().clear();
          },
        ),
      ],
    );
  }
}
