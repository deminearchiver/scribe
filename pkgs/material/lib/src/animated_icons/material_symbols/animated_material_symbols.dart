import 'package:flutter/material.dart';
import 'package:material/src/animated_icons/animated_icons.dart';

///
///```dart
///AnimatedSymbols.play_arrow
/// .to(AnimatedSymbols.pause, transition: (transitions) => transitions.variant1)
/// .animate()
/// .icon(
///   size: 24,
///   color: Colors.red,
/// );
///```
class AnimatedSymbols {
  static const AnimatedIconFactory<PauseLeader, PauseFollower> pause = _Pause();
  static const AnimatedIconFactory<PlayArrowLeader, PlayArrowFollower>
  playArrow = _PlayArrow();
}

abstract interface class PauseFollower implements PlayArrowLeader {}

abstract interface class PauseLeader {}

class _Pause extends AnimatedIconFactory<PauseLeader, PauseFollower> {
  const _Pause();
}

abstract interface class PlayArrowFollower implements PauseLeader {}

abstract interface class PlayArrowLeader {}

class _PlayArrow
    extends AnimatedIconFactory<PlayArrowLeader, PlayArrowFollower> {
  const _PlayArrow();
}

extension PauseToPlayArrowTransitions
    on AnimatedIconTransitionsMap<PauseLeader, PlayArrowFollower> {
  AnimatedIconTransition<
    PauseLeader,
    PauseFollower,
    PlayArrowLeader,
    PlayArrowFollower
  >
  get transition1 => AnimatedIconTransition();
}

extension PlayArrowToPauseTransitions
    on AnimatedIconTransitionsMap<PlayArrowLeader, PauseFollower> {
  AnimatedIconTransition<
    PlayArrowLeader,
    PlayArrowFollower,
    PauseLeader,
    PauseFollower
  >
  get transition1 => AnimatedIconTransition();
}
