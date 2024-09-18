import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/core/di/dependency_injection.dart';
import 'package:hisnelmoslem/src/core/shared/custom_inputs/custom_field_decoration.dart';
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
          controller: sl<SearchCubit>().searchController,
          autofocus: true,
          decoration: customInputDecoration.copyWith(
            filled: false,
            focusedBorder: InputBorder.none,
            enabledBorder: InputBorder.none,
            suffix: IconButton(
              icon: Icon(MdiIcons.eraser),
              onPressed: () {
                sl<SearchCubit>().erase();
              },
            ),
            hintText: S.of(context).search,
          ),
          onChanged: (value) {
            sl<SearchCubit>().search(value);
          },
        );
      },
    );
  }
}
