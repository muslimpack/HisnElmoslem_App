
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/components/search_type_bar.dart';
import 'package:hisnelmoslem/src/features/home_search/presentation/controller/cubit/search_cubit.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';

class SearchFiltersButton extends StatelessWidget {
  const SearchFiltersButton({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SearchCubit, SearchState>(
      builder: (context, state) {
        return IconButton(
          tooltip: "مرشحات البحث",
          onPressed: () async {
            await showSearchFilterDialog(context);
          },
          icon: Icon(MdiIcons.filter),
        );
      },
    );
  }
}

Future showSearchFilterDialog(BuildContext context) {
  return showDialog(
    context: context,
    builder: (context) {
      return const SearchFiltersDialog();
    },
  );
}

class SearchFiltersDialog extends StatelessWidget {
  const SearchFiltersDialog({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text("مرشحات البحث"),
      content: Container(
        constraints: const BoxConstraints(maxWidth: 500),
        child: const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SearchTypeBar(),
          ],
        ),
      ),
    );
  }
}
