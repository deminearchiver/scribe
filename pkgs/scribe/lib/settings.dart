import 'dart:async';
import 'dart:io';

import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:material/material.dart';
import 'package:meta/meta.dart';
import 'package:scribe/i18n/strings.g.dart';
import 'package:shared_preferences/shared_preferences.dart';

abstract interface class SettingsData with Diagnosticable {
  bool get useDynamicColor;
  bool get useSystemBrightness;
  Brightness get brightness;
  ThemeMode get themeMode;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties);
}

extension BrightnessExtension on Brightness {
  ThemeMode get themeMode => switch (this) {
    Brightness.light => ThemeMode.light,
    Brightness.dark => ThemeMode.dark,
  };
}

extension ThemeModeExtension on ThemeMode {
  Brightness? get brightnessOrNull => switch (this) {
    ThemeMode.light => Brightness.light,
    ThemeMode.dark => Brightness.dark,
    ThemeMode.system => null,
  };
}

abstract interface class SettingsDataMutable implements SettingsData {
  set useDynamicColor(bool value);
  set useSystemBrightness(bool value);
  set brightness(Brightness value);
  set themeMode(ThemeMode value);
}

class _SettingsStoreData with Diagnosticable implements SettingsDataMutable {
  const _SettingsStoreData(this._store);

  final _SettingsStore _store;

  @override
  bool get useDynamicColor => _store.useDynamicColor;

  @override
  set useDynamicColor(bool value) {
    _store.useDynamicColor = value;
  }

  @override
  bool get useSystemBrightness => _store.useSystemBrightness;
  @override
  set useSystemBrightness(bool value) {
    _store.useSystemBrightness = value;
  }

  @override
  Brightness get brightness => _store.brightness;

  @override
  set brightness(Brightness value) {
    _store.brightness = value;
  }

  @override
  ThemeMode get themeMode =>
      _store.useSystemBrightness
          ? ThemeMode.system
          : _store.brightness.themeMode;

  @override
  set themeMode(ThemeMode value) {
    if (themeMode == value) return;
    final brightness = value.brightnessOrNull;
    if (brightness != null) {
      _store.useSystemBrightness = false;
      _store.brightness = brightness;
    } else {
      _store.useSystemBrightness = true;
      _store.brightness = PlatformDispatcher.instance.platformBrightness;
    }
  }
}

class _SettingsStore with ChangeNotifier {
  _SettingsStore({required SettingsAdapter adapter}) : _adapter = adapter {
    _loadAll();
  }

  SettingsDataMutable get data => _SettingsStoreData(this);

  SettingsAdapter _adapter;
  SettingsAdapter get adapter => _adapter;
  set adapter(SettingsAdapter value) {
    if (_adapter == value) return;
    _adapter = value;
    _loadAll();
  }

  static const _useDynamicColorKey = "useDynamicColor";
  bool _useDynamicColor = true;
  bool get useDynamicColor => _useDynamicColor;
  set useDynamicColor(bool value) {
    if (_useDynamicColor == value) return;
    _useDynamicColor = value;
    _saveOnly(useDynamicColor: true);
    notifyListeners();
  }

  static const _useSystemBrightnessKey = "useSystemBrightness";
  bool _useSystemBrightness = true;
  bool get useSystemBrightness => _useSystemBrightness;
  set useSystemBrightness(bool value) {
    if (_useSystemBrightness == value) return;
    _useSystemBrightness = value;
    _saveOnly(useSystemBrightness: true);
    notifyListeners();
  }

  static const _brightnessKey = "brightness";
  Brightness _brightness = PlatformDispatcher.instance.platformBrightness;
  Brightness get brightness => _brightness;
  set brightness(Brightness value) {
    if (_brightness == value) return;
    _brightness = value;
    _saveOnly(brightness: true);
    notifyListeners();
  }

  Future<void> _loadOnly({
    bool useDynamicColor = false,
    bool useSystemBrightness = false,
    bool brightness = false,
  }) async {
    if (!useDynamicColor && !useSystemBrightness && !brightness) return;
    bool useDynamicColorChanged = false;

    if (useDynamicColor) {
      final raw = await adapter.get(_useDynamicColorKey);
      final value = switch (raw) {
        "true" => true,
        "false" => false,
        _ => true,
      };
      if (_useDynamicColor != value) {
        _useDynamicColor = value;
        useDynamicColorChanged = true;
      }
    }
    bool useSystemBrightnessChanged = false;
    if (useSystemBrightness) {
      final raw = await adapter.get(_useSystemBrightnessKey);
      final value = switch (raw) {
        "true" => true,
        "false" => false,
        _ => true,
      };
      if (_useSystemBrightness != value) {
        _useSystemBrightness = value;
        useSystemBrightnessChanged = true;
      }
    }
    bool brightnessChanged = false;
    if (brightness) {
      final raw = await adapter.get(_brightnessKey);
      final value =
          Brightness.values.firstWhereOrNull((value) => value.name == raw) ??
          PlatformDispatcher.instance.platformBrightness;
      if (_brightness != value) {
        _brightness = value;
        brightnessChanged = true;
      }
    }

    if (useDynamicColorChanged ||
        useSystemBrightnessChanged ||
        brightnessChanged) {
      notifyListeners();
    }
  }

  Future<void> _saveOnly({
    bool useDynamicColor = false,
    bool useSystemBrightness = false,
    bool brightness = false,
  }) async {
    if (!useDynamicColor && !useSystemBrightness && !brightness) return;
    if (useDynamicColor) {
      await _adapter.set(
        _useDynamicColorKey,
        _useDynamicColor ? "true" : "false",
      );
    }
    if (useSystemBrightness) {
      await _adapter.set(
        _useSystemBrightnessKey,
        _useSystemBrightness ? "true" : "false",
      );
    }
    if (brightness) {
      await _adapter.set(_brightnessKey, _brightness.name);
    }
  }

  Future<void> _loadAll() => _loadOnly(
    useDynamicColor: true,
    useSystemBrightness: true,
    brightness: true,
  );
  Future<void> _saveAll() => _saveOnly(
    useDynamicColor: true,
    useSystemBrightness: true,
    brightness: true,
  );
}

abstract interface class SettingsAdapter {
  const factory SettingsAdapter.sharedPreferencesAsync(
    SharedPreferencesAsync sharedPreferencesAsync,
  ) = _SharedPreferencesAsync;
  const factory SettingsAdapter.sharedPreferencesWithCache(
    SharedPreferencesWithCache sharedPreferencesWithCache,
  ) = _SharedPreferencesWithCache;

  FutureOr<String?> get(String key);

  /// If value is `null`, it should be removed
  FutureOr<void> set(String key, String? value);
}

class _SharedPreferencesAsync implements SettingsAdapter {
  const _SharedPreferencesAsync(this.sharedPreferencesAsync);

  final SharedPreferencesAsync sharedPreferencesAsync;

  @override
  Future<String?> get(String key) {
    return sharedPreferencesAsync.getString(key);
  }

  @override
  Future<void> set(String key, String? value) async {
    if (value != null) {
      await sharedPreferencesAsync.setString(key, value);
    } else {
      await sharedPreferencesAsync.remove(key);
    }
  }
}

class _SharedPreferencesWithCache implements SettingsAdapter {
  const _SharedPreferencesWithCache(this.sharedPreferencesWithCache);

  final SharedPreferencesWithCache sharedPreferencesWithCache;

  @override
  String? get(String key) {
    return sharedPreferencesWithCache.getString(key);
  }

  @override
  Future<void> set(String key, String? value) async {
    if (value != null) {
      await sharedPreferencesWithCache.setString(key, value);
    } else {
      await sharedPreferencesWithCache.remove(key);
    }
  }
}

enum _SettingsAspect {
  useDynamicColor,
  useSystemBrightness,
  brightness,
  themeMode,
}

class Settings extends StatefulWidget {
  const Settings({super.key, required this.adapter, required this.child});

  final SettingsAdapter adapter;
  final Widget child;

  @override
  State<Settings> createState() => SettingsState();

  static SettingsDataMutable? _maybeOf(
    BuildContext context, [
    _SettingsAspect? aspect,
  ]) {
    return context
        .dependOnInheritedWidgetOfExactType<_SettingsScope>(aspect: aspect)
        ?.data;
  }

  static SettingsDataMutable _of(
    BuildContext context, [
    _SettingsAspect? aspect,
  ]) {
    final result = _maybeOf(context);
    assert(result != null);
    return result!;
  }

  static SettingsDataMutable? maybeOf(BuildContext context) =>
      _maybeOf(context);

  static SettingsDataMutable of(BuildContext context) => _of(context);

  static bool? maybeUseDynamicColorOf(BuildContext context) =>
      _maybeOf(context, _SettingsAspect.useDynamicColor)?.useDynamicColor;

  static bool useDynamicColorOf(BuildContext context) =>
      _of(context, _SettingsAspect.useDynamicColor).useDynamicColor;

  static bool? maybeUseSystemBrightnessOf(BuildContext context) =>
      _maybeOf(
        context,
        _SettingsAspect.useSystemBrightness,
      )?.useSystemBrightness;

  static bool useSystemBrightnessOf(BuildContext context) =>
      _of(context, _SettingsAspect.useSystemBrightness).useSystemBrightness;

  static Brightness? maybeBrightnessOf(BuildContext context) =>
      _maybeOf(context, _SettingsAspect.brightness)?.brightness;

  static Brightness brightnessOf(BuildContext context) =>
      _of(context, _SettingsAspect.brightness).brightness;

  static ThemeMode? maybeThemeModeOf(BuildContext context) =>
      _maybeOf(context, _SettingsAspect.themeMode)?.themeMode;

  static ThemeMode themeModeOf(BuildContext context) =>
      _of(context, _SettingsAspect.themeMode).themeMode;
}

class SettingsState extends State<Settings> {
  late _SettingsStore _store;
  late SettingsDataMutable _data;
  SettingsDataMutable get data => _data;

  @override
  void initState() {
    super.initState();
    _store = _SettingsStore(adapter: widget.adapter);
    _data = _store.data;
    _store.addListener(_listener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant Settings oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.adapter != oldWidget.adapter) {
      _store.adapter = widget.adapter;
    }
  }

  @override
  void dispose() {
    _store._saveAll();
    _store.dispose();
    super.dispose();
  }

  void _listener() {
    setState(() => _data = _store.data);
  }

  @override
  Widget build(BuildContext context) {
    return _SettingsScope(data: data, child: widget.child);
  }
}

class _SettingsScope extends InheritedModel<_SettingsAspect> {
  const _SettingsScope({super.key, required this.data, required super.child});

  final SettingsDataMutable data;

  @override
  bool updateShouldNotify(covariant _SettingsScope oldWidget) {
    return data != oldWidget.data;
  }

  @override
  bool updateShouldNotifyDependent(
    covariant _SettingsScope oldWidget,
    Set<_SettingsAspect> dependencies,
  ) => dependencies.any(
    (dependency) => switch (dependency) {
      _SettingsAspect.useDynamicColor =>
        data.useDynamicColor != oldWidget.data.useDynamicColor,
      _SettingsAspect.useSystemBrightness =>
        data.useSystemBrightness != oldWidget.data.useSystemBrightness,
      _SettingsAspect.brightness =>
        data.brightness != oldWidget.data.brightness,
      _SettingsAspect.themeMode => data.themeMode != oldWidget.data.themeMode,
    },
  );
}
