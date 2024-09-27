// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:equatable/equatable.dart';

enum EditorActionEnum { add, edit, delete, none }

class EditorResult<T> extends Equatable {
  final EditorActionEnum action;
  final T value;

  const EditorResult({
    required this.action,
    required this.value,
  });

  @override
  List<Object?> get props => [action, value];

  EditorResult<T> copyWith({
    EditorActionEnum? action,
    T? value,
  }) {
    return EditorResult<T>(
      action: action ?? this.action,
      value: value ?? this.value,
    );
  }
}
