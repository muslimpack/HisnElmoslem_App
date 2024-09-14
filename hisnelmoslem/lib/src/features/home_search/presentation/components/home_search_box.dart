import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:get/get.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/controller/cubit/search_cubit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class HomeSearchBox extends StatelessWidget {
  const HomeSearchBox({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return TextFormField(
          textAlign: TextAlign.center,
          controller: context.read<SearchCubit>().searchController,
          autofocus: true,
          decoration: InputDecoration(
            border: InputBorder.none,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            hintText: "search".tr,
            contentPadding: const EdgeInsets.only(
              left: 15,
              bottom: 5,
              top: 5,
              right: 15,
            ),
            suffix: IconButton(
              icon: Icon(MdiIcons.eraser),
              onPressed: () {
                context.read<SearchCubit>().erase();
              },
            ),
          ),
          onChanged: (value) {
            context.read<SearchCubit>().search(value);
          },
        );
      },
    );
  }
}