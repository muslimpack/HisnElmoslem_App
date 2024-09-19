import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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
            title: const Text("اختيار مصدر الأذكار"),
            centerTitle: true,
          ),
          body: ListView(
            padding: const EdgeInsets.all(15),
            children: [
              SwitchListTile(
                value: state.enableFilters,
                title: const Text("تفعيل تصفية الأذكار"),
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
                  title: Text(filter.filter.arabicName),
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
