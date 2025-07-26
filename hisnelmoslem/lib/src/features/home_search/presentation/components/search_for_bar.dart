
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/features/home_search/data/models/search_for.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/controller/cubit/search_cubit.dart';

class SearchForBar extends StatelessWidget {
  const SearchForBar({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        if (state is! SearchLoadedState) return const SizedBox.shrink();
        return Wrap(
          alignment: WrapAlignment.center,
          runSpacing: 10,
          spacing: 10,
          children: SearchFor.values.map((e) {
            final selected = state.searchFor == e;
            return ChoiceChip(
              label: Text(
                "${e.localeName(context)}${selected ? " (${state.searchResultCount})" : ""}",
              ),
              showCheckmark: false,
              selected: selected,
              onSelected: (value) async {
                await context.read<SearchCubit>().changeSearchFor(e);
              },
            );
          }).toList(),
        );
      },
    );
  }
}
