import 'package:flutter/services.dart';
import 'package:material/material.dart';

typedef PredictiveBackGestureDetectorWidgetBuilder =
    Widget Function(
      BuildContext context,
      PredictiveBackPhase phase,
      PredictiveBackEvent? startBackEvent,
      PredictiveBackEvent? currentBackEvent,
    );

enum PredictiveBackPhase { idle, start, update, commit, cancel }

class PredictiveBackGestureDetector extends StatefulWidget {
  const PredictiveBackGestureDetector({
    super.key,
    required this.route,
    required this.builder,
  });

  final PageRoute<dynamic> route;
  final PredictiveBackGestureDetectorWidgetBuilder builder;

  @override
  State<PredictiveBackGestureDetector> createState() =>
      _PredictiveBackGestureDetectorState();
}

class _PredictiveBackGestureDetectorState
    extends State<PredictiveBackGestureDetector>
    with WidgetsBindingObserver {
  /// True when the predictive back gesture is enabled.
  bool get _isEnabled {
    return widget.route.isCurrent && widget.route.popGestureEnabled;
  }

  PredictiveBackPhase get phase => _phase;
  PredictiveBackPhase _phase = PredictiveBackPhase.idle;
  set phase(PredictiveBackPhase phase) {
    if (_phase != phase && mounted) {
      setState(() => _phase = phase);
    }
  }

  /// The back event when the gesture first started.
  PredictiveBackEvent? get startBackEvent => _startBackEvent;
  PredictiveBackEvent? _startBackEvent;
  set startBackEvent(PredictiveBackEvent? startBackEvent) {
    if (_startBackEvent != startBackEvent && mounted) {
      setState(() => _startBackEvent = startBackEvent);
    }
  }

  /// The most recent back event during the gesture.
  PredictiveBackEvent? get currentBackEvent => _currentBackEvent;
  PredictiveBackEvent? _currentBackEvent;
  set currentBackEvent(PredictiveBackEvent? currentBackEvent) {
    if (_currentBackEvent != currentBackEvent && mounted) {
      setState(() => _currentBackEvent = currentBackEvent);
    }
  }

  // Begin WidgetsBindingObserver.

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    phase = PredictiveBackPhase.start;

    final bool gestureInProgress = !backEvent.isButtonEvent && _isEnabled;
    if (!gestureInProgress) {
      return false;
    }

    widget.route.handleStartBackGesture(progress: 1 - backEvent.progress);
    startBackEvent = currentBackEvent = backEvent;
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    phase = PredictiveBackPhase.update;

    widget.route.handleUpdateBackGestureProgress(
      progress: 1 - backEvent.progress,
    );
    currentBackEvent = backEvent;
  }

  @override
  void handleCancelBackGesture() {
    phase = PredictiveBackPhase.cancel;

    widget.route.handleCancelBackGesture();
    startBackEvent = currentBackEvent = null;
  }

  @override
  void handleCommitBackGesture() {
    phase = PredictiveBackPhase.commit;

    widget.route.handleCommitBackGesture();
    startBackEvent = currentBackEvent = null;
  }

  // End WidgetsBindingObserver.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PredictiveBackPhase effectivePhase =
        widget.route.popGestureInProgress ? phase : PredictiveBackPhase.idle;
    return widget.builder(
      context,
      effectivePhase,
      startBackEvent,
      currentBackEvent,
    );
  }
}

class PredictiveBackGestureListener extends StatefulWidget {
  const PredictiveBackGestureListener({
    super.key,
    required this.route,
    required this.builder,
  });

  final PredictiveBackGestureDetectorWidgetBuilder builder;
  final PageRoute<dynamic> route;

  @override
  State<PredictiveBackGestureListener> createState() =>
      _PredictiveBackGestureListenerState();
}

class _PredictiveBackGestureListenerState
    extends State<PredictiveBackGestureListener>
    with WidgetsBindingObserver {
  PredictiveBackPhase get phase => _phase;
  PredictiveBackPhase _phase = PredictiveBackPhase.idle;
  set phase(PredictiveBackPhase phase) {
    if (_phase != phase && mounted) {
      setState(() => _phase = phase);
    }
  }

  /// The back event when the gesture first started.
  PredictiveBackEvent? get startBackEvent => _startBackEvent;
  PredictiveBackEvent? _startBackEvent;
  set startBackEvent(PredictiveBackEvent? startBackEvent) {
    if (_startBackEvent != startBackEvent && mounted) {
      setState(() => _startBackEvent = startBackEvent);
    }
  }

  /// The most recent back event during the gesture.
  PredictiveBackEvent? get currentBackEvent => _currentBackEvent;
  PredictiveBackEvent? _currentBackEvent;
  set currentBackEvent(PredictiveBackEvent? currentBackEvent) {
    if (_currentBackEvent != currentBackEvent && mounted) {
      setState(() => _currentBackEvent = currentBackEvent);
    }
  }

  // Begin WidgetsBindingObserver.

  @override
  bool handleStartBackGesture(PredictiveBackEvent backEvent) {
    phase = PredictiveBackPhase.start;

    final bool gestureInProgress =
        !backEvent.isButtonEvent && widget.route.popGestureEnabled;
    if (!gestureInProgress) {
      return false;
    }

    startBackEvent = currentBackEvent = backEvent;
    return true;
  }

  @override
  void handleUpdateBackGestureProgress(PredictiveBackEvent backEvent) {
    phase = PredictiveBackPhase.update;
    currentBackEvent = backEvent;
  }

  @override
  void handleCancelBackGesture() {
    phase = PredictiveBackPhase.cancel;
    startBackEvent = currentBackEvent = null;
  }

  @override
  void handleCommitBackGesture() {
    phase = PredictiveBackPhase.commit;
    startBackEvent = currentBackEvent = null;
  }

  // End WidgetsBindingObserver.

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final PredictiveBackPhase effectivePhase =
        widget.route.popGestureInProgress ? phase : PredictiveBackPhase.idle;
    return widget.builder(
      context,
      effectivePhase,
      startBackEvent,
      currentBackEvent,
    );
  }
}
