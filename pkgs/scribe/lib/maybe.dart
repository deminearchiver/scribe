import 'package:flutter/widgets.dart';

sealed class Maybe<T extends Object?> {
  const factory Maybe.child(T child) = _MaybeWidget<T>;
  const factory Maybe.builder(T Function(BuildContext context) builder) =
      _MaybeBuilder;

  T resolve(BuildContext context);
}

class _MaybeWidget<T extends Object?> implements Maybe<T> {
  const _MaybeWidget(this.child);

  final T child;

  @override
  T resolve(BuildContext context) => child;
}

class _MaybeBuilder<T extends Object?> implements Maybe<T> {
  const _MaybeBuilder(this.builder);

  final T Function(BuildContext context) builder;

  @override
  T resolve(BuildContext context) => builder(context);
}
