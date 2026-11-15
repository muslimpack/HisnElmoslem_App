import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hisnelmoslem/src/features/translations/domain/translation_resolver.dart';
import 'package:hisnelmoslem/src/features/translations/presentation/controller/translations_cubit.dart';

/// Font of translated text: never the user's Arabic font.
const String kTranslationFontFamily = "Roboto";

/// The translated title as a small line of text, or nothing when the switch is off or the
/// title has no translation (custom titles never do).
class TitleTranslationText extends StatelessWidget {
  final int titleId;
  final TextAlign? textAlign;
  final TextStyle? style;

  const TitleTranslationText({super.key, required this.titleId, this.textAlign, this.style});

  /// True when [TitleTranslationText] would show something for [titleId]. Use it to decide
  /// whether a list tile gets a subtitle at all.
  static bool hasTitle(BuildContext context, int titleId) {
    return context.select<TranslationsCubit, bool>((c) => c.state.titleFor(titleId) != null);
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<TranslationsCubit, TranslationsState>(
      buildWhen: (a, b) => a.titleFor(titleId) != b.titleFor(titleId),
      builder: (context, state) {
        final ResolvedField? field = state.titleFor(titleId);
        if (field == null) return const SizedBox.shrink();
        return Text(
          field.text,
          textAlign: textAlign,
          textDirection: state.isRtl(field.lang) ? TextDirection.rtl : TextDirection.ltr,
          style: (style ?? Theme.of(context).textTheme.bodySmall)?.copyWith(
            fontFamily: kTranslationFontFamily,
          ),
        );
      },
    );
  }
}

/// A title with its translation under it, for app bars.
class TitleWithTranslation extends StatelessWidget {
  final String name;
  final int titleId;

  const TitleWithTranslation({super.key, required this.name, required this.titleId});

  @override
  Widget build(BuildContext context) {
    if (!TitleTranslationText.hasTitle(context, titleId)) return Text(name);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(name),
        TitleTranslationText(titleId: titleId, textAlign: TextAlign.center),
      ],
    );
  }
}
