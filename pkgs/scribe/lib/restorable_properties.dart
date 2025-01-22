import 'package:flutter/services.dart';
import 'package:material/material.dart';

class RestorableDuration extends RestorableValue<Duration> {
  RestorableDuration(Duration defaultValue) : _defaultValue = defaultValue;

  final Duration _defaultValue;

  @override
  Duration createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(Duration? oldValue) {
    assert(debugIsSerializableForRestoration(value.inMicroseconds));
    if (oldValue == null || oldValue.inMicroseconds != value.inMicroseconds) {
      notifyListeners();
    }
  }

  @override
  Duration fromPrimitives(Object? data) => Duration(microseconds: data! as int);

  @override
  Object? toPrimitives() => value.inMicroseconds;
}

class RestorableDurationN extends RestorableValue<Duration?> {
  RestorableDurationN(Duration? defaultValue) : _defaultValue = defaultValue;

  final Duration? _defaultValue;

  @override
  Duration? createDefaultValue() => _defaultValue;

  @override
  void didUpdateValue(Duration? oldValue) {
    assert(debugIsSerializableForRestoration(value?.inMicroseconds));
    if (oldValue?.inMicroseconds != value?.inMicroseconds) {
      notifyListeners();
    }
  }

  @override
  Duration? fromPrimitives(Object? data) =>
      data != null ? Duration(microseconds: data as int) : null;

  @override
  Object? toPrimitives() => value?.inMicroseconds;
}
