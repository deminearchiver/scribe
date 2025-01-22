import 'package:flutter/cupertino.dart';
import 'package:material/material.dart';
import 'package:scribe/gen/assets.gen.dart';

class GoogleKeepIcon extends StatelessWidget {
  const GoogleKeepIcon({super.key, this.size});

  final double? size;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final resolvedSize = size ?? iconTheme.size!;
    return Assets.images.keep.svg(
      width: resolvedSize,
      height: resolvedSize,
      fit: BoxFit.contain,
    );
  }
}

class GoogleKeepAvatar extends StatelessWidget {
  const GoogleKeepAvatar({super.key, this.shape, this.size});

  final ShapeBorder? shape;
  final double? size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final size = this.size ?? 40.0;
    final shape = this.shape ?? const CircleBorder();

    return SizedBox.square(
      dimension: size,
      child: Material(
        animationDuration: Duration.zero,
        clipBehavior: Clip.antiAlias,
        // color: Colors.white,
        color: theme.colorScheme.primaryContainer,
        shape: shape,
        child: Stack(
          alignment: Alignment.center,
          children: [
            Positioned.fill(
              child: Assets.images.keepBackground.image(fit: BoxFit.cover),
            ),
            Positioned.fill(
              child: Assets.images.keepForeground.image(fit: BoxFit.cover),
            ),
          ],
        ),
      ),
    );
  }
}
