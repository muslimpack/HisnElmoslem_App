import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/lang/app_localizations.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/data/models/zikr_filter_enum.dart';
import 'package:hisnelmoslem/src/features/azkar_filters/presentation/controller/cubit/azkar_filters_cubit.dart';

class ZikrHokmFilterScreen extends StatefulWidget {
  const ZikrHokmFilterScreen({super.key});

  @override
  State<ZikrHokmFilterScreen> createState() => _ZikrHokmFilterScreenState();
}

class _ZikrHokmFilterScreenState extends State<ZikrHokmFilterScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AzkarFiltersCubit, AzkarFiltersState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).selectAzkarHokmFilters),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(15),
            children: [
              SwitchListTile(
                value: state.enableHokmFilters,
                title: Text(S.of(context).enableAzkarFilters),
                onChanged: (value) {
                  context
                      .read<AzkarFiltersCubit>()
                      .toggleEnableHokmFilters(value);
                },
              ),
              const Divider(),
              ...state.filters.where((x) => x.filter.isForHokm).map((filter) {
                return SwitchListTile(
                  value: filter.isActivated,
                  title: Text(filter.filter.localeName(context)),
                  onChanged: !state.enableHokmFilters
                      ? null
                      : (value) {
                          context
                              .read<AzkarFiltersCubit>()
                              .toggleFilter(filter);
                        },
                );
              }),
            ],
          ),
        );
      },
    );
  }
}
