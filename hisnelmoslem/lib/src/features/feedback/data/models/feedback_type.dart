import 'package:hisnelmoslem/generated/lang/app_localizations.dart';

/// What the user wants to tell us. [tag] is a fixed English word used in the email subject so
/// the inbox can be filtered whatever the app language is.
enum FeedbackType {
  bug('Bug'),
  featureRequest('Feature'),
  suggestion('Suggestion'),
  question('Question'),
  misspelling('Misspelling'),
  other('Other');

  const FeedbackType(this.tag);

  final String tag;

  String label(S s) => switch (this) {
    FeedbackType.bug => s.feedbackTypeBug,
    FeedbackType.featureRequest => s.feedbackTypeFeature,
    FeedbackType.suggestion => s.feedbackTypeSuggestion,
    FeedbackType.question => s.feedbackTypeQuestion,
    FeedbackType.misspelling => s.feedbackTypeMisspelling,
    FeedbackType.other => s.feedbackTypeOther,
  };

  /// Types the user can pick from the dropdown (misspelling has its own entry points).
  static const List<FeedbackType> selectable = [
    bug,
    featureRequest,
    suggestion,
    question,
    other,
  ];
}
