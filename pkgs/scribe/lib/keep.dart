import 'package:freezed_annotation/freezed_annotation.dart';

part 'keep.g.dart';
part 'keep.freezed.dart';

@freezed
class KeepNote with _$KeepNote {
  const factory KeepNote({
    @Default("DEFAULT") String color,
    @Default(false) bool isTrashed,
    @Default(false) bool isPinned,
    @Default(false) bool isArchived,
    @Default("") String textContent,
    @Default("") String title,
    @DateTimeTimestampConverter.microseconds()
    DateTime? userEditedTimestampUsec,
    @DateTimeTimestampConverter.microseconds() DateTime? createdTimestampUsec,
    @Default("") String textContentHtml,
    @Default([]) List<KeepNoteLabel> labels,
  }) = _KeepNote;
  factory KeepNote.fromJson(Map<String, dynamic> json) =>
      _$KeepNoteFromJson(json);
}

@freezed
class KeepNoteLabel with _$KeepNoteLabel {
  const factory KeepNoteLabel({required String name}) = _KeepNoteLabel;
  factory KeepNoteLabel.fromJson(Map<String, dynamic> json) =>
      _$KeepNoteLabelFromJson(json);
}

@freezed
class KeepNoteAnnotation with _$KeepNoteAnnotation {
  const factory KeepNoteAnnotation({
    required String source,
    String? title,
    String? description,
    Uri? url,
  }) = _KeepNoteAnnotation;
  factory KeepNoteAnnotation.fromJson(Map<String, dynamic> json) =>
      _$KeepNoteAnnotationFromJson(json);
}

enum _DurationUnit { microseconds, milliseconds }

class DurationConverter implements JsonConverter<Duration, int> {
  const DurationConverter.microseconds() : _unit = _DurationUnit.microseconds;
  const DurationConverter.milliseconds() : _unit = _DurationUnit.milliseconds;

  final _DurationUnit _unit;

  @override
  Duration fromJson(int json) => switch (_unit) {
    _DurationUnit.microseconds => Duration(microseconds: json),
    _DurationUnit.milliseconds => Duration(milliseconds: json),
  };

  @override
  int toJson(Duration object) => switch (_unit) {
    _DurationUnit.microseconds => object.inMicroseconds,
    _DurationUnit.milliseconds => object.inMilliseconds,
  };
}

class DateTimeTimestampConverter implements JsonConverter<DateTime, int> {
  const DateTimeTimestampConverter.microseconds()
    : _unit = _DurationUnit.microseconds;
  const DateTimeTimestampConverter.milliseconds()
    : _unit = _DurationUnit.milliseconds;

  final _DurationUnit _unit;

  @override
  DateTime fromJson(int json) => switch (_unit) {
    _DurationUnit.microseconds => DateTime.fromMicrosecondsSinceEpoch(
      json,
      isUtc: true,
    ),
    _DurationUnit.milliseconds => DateTime.fromMillisecondsSinceEpoch(
      json,
      isUtc: true,
    ),
  };

  @override
  int toJson(DateTime object) {
    final utc = object.toUtc();
    return switch (_unit) {
      _DurationUnit.microseconds => utc.microsecondsSinceEpoch,
      _DurationUnit.milliseconds => utc.millisecondsSinceEpoch,
    };
  }
}
