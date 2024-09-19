import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/generated/l10n.dart';
import 'package:hisnelmoslem/src/features/zikr_source_filter/data/models/zikr_filter_enum.dart';
import 'package:hisnelmoslem/src/features/zikr_source_filter/presentation/controller/cubit/zikr_source_filter_cubit.dart';

class ZikrSourceFilterScreen extends StatefulWidget {
  const ZikrSourceFilterScreen({super.key});

  @override
  State<ZikrSourceFilterScreen> createState() => _ZikrSourceFilterScreenState();
}

class _ZikrSourceFilterScreenState extends State<ZikrSourceFilterScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ZikrSourceFilterCubit, ZikrSourceFilterState>(
      builder: (context, state) {
        return Scaffold(
          appBar: AppBar(
            title: Text(S.of(context).selectAzkarSource),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(15),
            children: [
              SwitchListTile(
                value: state.enableFilters,
                title: Text(S.of(context).enableAzkarFilters),
                onChanged: (value) {
                  context
                      .read<ZikrSourceFilterCubit>()
                      .toggleEnableFilters(value);
                },
              ),
              const Divider(),
              ...state.filters.where((x) => !x.filter.isForHokm).map((filter) {
                return SwitchListTile(
                  value: filter.isActivated,
                  title: Text(filter.filter.localeName(context)),
                  onChanged: !state.enableFilters
                      ? null
                      : (value) {
                          context
                              .read<ZikrSourceFilterCubit>()
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
