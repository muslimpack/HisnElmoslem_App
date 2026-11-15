import 'package:equatable/equatable.dart';
import 'package:hisnelmoslem/src/features/feedback/data/models/feedback_type.dart';

/// Where a misspelling report comes from: a zikr of a title, or a fake hadith card.
class MisspellingContext extends Equatable {
  /// Title name (or the "Fake Hadith" subject).
  final String title;

  /// 1-based index of the zikr / card.
  final int index;

  /// The text as it is shown in the app now.
  final String currentText;

  /// True for fake hadith cards (the labels in the email differ).
  final bool isFakeHadith;

  const MisspellingContext({
    required this.title,
    required this.index,
    required this.currentText,
    this.isFakeHadith = false,
  });

  @override
  List<Object> get props => [title, index, currentText, isFakeHadith];
}

/// Everything the user decided in the feedback sheet.
class FeedbackDraft extends Equatable {
  final FeedbackType type;
  final String message;
  final bool includeDeviceInfo;
  final MisspellingContext? misspelling;

  const FeedbackDraft({
    required this.type,
    required this.message,
    required this.includeDeviceInfo,
    this.misspelling,
  });

  @override
  List<Object?> get props => [type, message, includeDeviceInfo, misspelling];
}

/// A composed email, ready for the sender.
class FeedbackEmail extends Equatable {
  final String recipient;
  final String subject;
  final String body;

  /// Path of the error log file to attach, when the user agreed to share data.
  final String? attachmentPath;

  const FeedbackEmail({
    required this.recipient,
    required this.subject,
    required this.body,
    this.attachmentPath,
  });

  @override
  List<Object?> get props => [recipient, subject, body, attachmentPath];
}
