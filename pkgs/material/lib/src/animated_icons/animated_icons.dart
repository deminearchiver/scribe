import 'package:flutter/material.dart';
import 'package:material/material.dart';

class AnimatedIconHolder<Leader, Follower> {}

abstract class AnimatedIconFactory<Leader, Follower>
    implements AnimatedIconHolder<Leader, Follower> {
  const AnimatedIconFactory();

  Path get path => Path();
}

class AnimatedIconTransition<
  PreviousLeader,
  PreviousFollower,
  CurrentLeader,
  CurrentFollower
> {}

abstract interface class AnimatedIconTransitionsMap<
  PreviousLeader,
  CurrentFollower extends PreviousLeader
> {}

class _AnimatedIconTransitionsMap<
  PreviousLeader,
  CurrentFollower extends PreviousLeader
>
    implements AnimatedIconTransitionsMap<PreviousLeader, CurrentFollower> {
  const _AnimatedIconTransitionsMap();
}

abstract interface class AnimatedIconBuilder<Leader, Follower>
    implements AnimatedIconHolder<Leader, Follower> {
  List<AnimatedIconFactory> get factories;
}

sealed class _AnimatedIconBuilder<CurrentLeader, CurrentFollower>
    implements AnimatedIconBuilder<CurrentLeader, CurrentFollower> {
  const _AnimatedIconBuilder();
}

class _InitialAnimatedIconBuilder<CurrentLeader, CurrentFollower>
    extends _AnimatedIconBuilder<CurrentLeader, CurrentFollower> {
  _InitialAnimatedIconBuilder({required this.factory});

  final AnimatedIconFactory<CurrentLeader, CurrentFollower> factory;

  @override
  List<AnimatedIconFactory> get factories => [factory];
}

class _ChainedAnimatedIconBuilder<
  PreviousLeader,
  PreviousFollower,
  CurrentLeader,
  CurrentFollower
>
    extends _AnimatedIconBuilder<CurrentLeader, CurrentFollower> {
  _ChainedAnimatedIconBuilder({
    required this.parent,
    required this.factory,
    required this.transition,
  });

  final AnimatedIconBuilder<PreviousLeader, PreviousFollower> parent;
  final AnimatedIconFactory<CurrentLeader, CurrentFollower> factory;

  @override
  List<AnimatedIconFactory> get factories => [...parent.factories, factory];

  final AnimatedIconTransition<
    PreviousLeader,
    PreviousFollower,
    CurrentLeader,
    CurrentFollower
  >
  transition;
}

extension AnimatedIconFactoryExtension<Leader, Follower>
    on AnimatedIconFactory<Leader, Follower> {
  AnimatedIconBuilder<NewLeader, NewFollower>
  to<NewLeader, NewFollower extends Leader>(
    AnimatedIconFactory<NewLeader, NewFollower> factory, {
    required AnimatedIconTransition<Leader, Follower, NewLeader, NewFollower>
    Function(AnimatedIconTransitionsMap<Leader, NewFollower> transitions)
    transition,
  }) {
    return _ChainedAnimatedIconBuilder(
      parent: _InitialAnimatedIconBuilder(factory: this),
      factory: factory,
      transition: transition(const _AnimatedIconTransitionsMap()),
    );
  }
}

extension AnimatedIconBuilderExtension<Leader, Follower>
    on AnimatedIconBuilder<Leader, Follower> {
  AnimatedIconBuilder<NewLeader, NewFollower>
  to<NewLeader, NewFollower extends Leader>(
    AnimatedIconFactory<NewLeader, NewFollower> factory, {
    required AnimatedIconTransition<Leader, Follower, NewLeader, NewFollower>
    Function(AnimatedIconTransitionsMap<Leader, NewFollower> transitions)
    transition,
  }) {
    return _ChainedAnimatedIconBuilder(
      parent: this,
      factory: factory,
      transition: transition(const _AnimatedIconTransitionsMap()),
    );
  }
}
