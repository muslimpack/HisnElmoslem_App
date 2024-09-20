// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/core/shared/widgets/text_divider.dart';
import 'package:hisnelmoslem/src/features/settings/presentation/controller/cubit/settings_cubit.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/data/models/zikr_content.dart';
import 'package:hisnelmoslem/src/features/zikr_viewer/presentation/components/zikr_content_builder.dart';

class ZikrViewerZikrBody extends StatelessWidget {
  final DbContent dbContent;
  const ZikrViewerZikrBody({
    super.key,
    required this.dbContent,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsCubit, SettingsState>(
      builder: (context, state) {
        return Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ZikrContentBuilder(
              dbContent: dbContent,
              enableDiacritics: state.showDiacritics,
              fontSize: state.fontSize * 10,
            ),
            if (dbContent.fadl.isNotEmpty) ...[
              const SizedBox(height: 20),
              const TextDivider(),
              Text(
                dbContent.fadl,
                textAlign: TextAlign.center,
                textDirection: TextDirection.rtl,
                softWrap: true,
                style: TextStyle(
                  fontSize: state.fontSize * 8,
                  height: 2,
                ),
              ),
            ],
          ],
        );
      },
    );
  }
}
