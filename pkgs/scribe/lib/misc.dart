import 'package:material/material.dart';
import 'package:path_parsing/path_parsing.dart';

/// Rotation by 36 deg for each list item results in a random-looking pattern
class ExpressiveListBulletIcon extends StatelessWidget {
  const ExpressiveListBulletIcon({super.key, this.size, this.color});

  final double? size;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    final resolvedSize = size ?? 8.0;
    final resolvedColor = color ?? iconTheme.color!;
    return OverflowBox(
      alignment: Alignment.center,
      minWidth: resolvedSize,
      maxWidth: resolvedSize,
      minHeight: resolvedSize,
      maxHeight: resolvedSize,
      child: CustomPaint(
        size: Size.square(resolvedSize),
        painter: _ExpressiveListBulletIconPainter(color: resolvedColor),
      ),
    );
  }
}

const Rect _kViewBoxRect = Rect.fromLTRB(0, 0, 8, 8);
final Path _kPath =
    Path()
      ..moveTo(4.958, 0.28)
      ..cubicTo(
        5.538,
        -0.3540000000000001,
        6.585000000000001,
        0.17300000000000001,
        6.42,
        1.016,
      )
      ..lineTo(6.055, 2.8840000000000003)
      ..cubicTo(
        5.998121924280534,
        3.1746463725786427,
        6.096624943379911,
        3.473944007534444,
        6.315000440613319,
        3.6740002563441543,
      )
      ..lineTo(7.72, 4.958)
      ..cubicTo(8.354, 5.538, 7.827, 6.585000000000001, 6.984, 6.42)
      ..lineTo(5.116, 6.055)
      ..cubicTo(
        4.825354185601334,
        5.998121924280534,
        4.526056550645532,
        6.096624943379911,
        4.326000301835822,
        6.315000440613319,
      )
      ..lineTo(3.042, 7.72)
      ..cubicTo(
        2.4619999999999997,
        8.354,
        1.4149999999999996,
        7.827,
        1.5799999999999998,
        6.984,
      )
      ..lineTo(1.9449999999999998, 5.116)
      ..cubicTo(
        2.001878633899443,
        4.825354185601334,
        1.9033756148000656,
        4.526056550645533,
        1.6850001175666576,
        4.326000301835822,
      )
      ..lineTo(0.28, 3.042)
      ..cubicTo(
        -0.3540000000000001,
        2.4619999999999997,
        0.17300000000000001,
        1.4149999999999996,
        1.016,
        1.5799999999999998,
      )
      ..lineTo(2.8840000000000003, 1.9449999999999998)
      ..cubicTo(
        3.1746463725786427,
        2.001878633899443,
        3.4739440075344445,
        1.9033756148000656,
        3.674000256344155,
        1.6850001175666576,
      )
      ..lineTo(4.958, 0.28)
      ..close();

class _ExpressiveListBulletIconPainter extends CustomPainter {
  const _ExpressiveListBulletIconPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(
      size.width / _kViewBoxRect.width,
      size.height / _kViewBoxRect.height,
    );
    final paint =
        Paint()
          ..color = color
          ..style = PaintingStyle.fill;
    // final path =
    //     Path()
    //       ..moveTo(4.958, 0.28)
    //       ..cubicTo(
    //         5.538,
    //         -0.3540000000000001,
    //         6.585000000000001,
    //         0.17300000000000001,
    //         6.42,
    //         1.016,
    //       )
    //       ..lineTo(6.055, 2.8840000000000003)
    //       ..cubicTo(
    //         5.998121924280534,
    //         3.1746463725786427,
    //         6.096624943379911,
    //         3.473944007534444,
    //         6.315000440613319,
    //         3.6740002563441543,
    //       )
    //       ..lineTo(7.72, 4.958)
    //       ..cubicTo(8.354, 5.538, 7.827, 6.585000000000001, 6.984, 6.42)
    //       ..lineTo(5.116, 6.055)
    //       ..cubicTo(
    //         4.825354185601334,
    //         5.998121924280534,
    //         4.526056550645532,
    //         6.096624943379911,
    //         4.326000301835822,
    //         6.315000440613319,
    //       )
    //       ..lineTo(3.042, 7.72)
    //       ..cubicTo(
    //         2.4619999999999997,
    //         8.354,
    //         1.4149999999999996,
    //         7.827,
    //         1.5799999999999998,
    //         6.984,
    //       )
    //       ..lineTo(1.9449999999999998, 5.116)
    //       ..cubicTo(
    //         2.001878633899443,
    //         4.825354185601334,
    //         1.9033756148000656,
    //         4.526056550645533,
    //         1.6850001175666576,
    //         4.326000301835822,
    //       )
    //       ..lineTo(0.28, 3.042)
    //       ..cubicTo(
    //         -0.3540000000000001,
    //         2.4619999999999997,
    //         0.17300000000000001,
    //         1.4149999999999996,
    //         1.016,
    //         1.5799999999999998,
    //       )
    //       ..lineTo(2.8840000000000003, 1.9449999999999998)
    //       ..cubicTo(
    //         3.1746463725786427,
    //         2.001878633899443,
    //         3.4739440075344445,
    //         1.9033756148000656,
    //         3.674000256344155,
    //         1.6850001175666576,
    //       )
    //       ..lineTo(4.958, 0.28)
    //       ..close();

    canvas.drawPath(_kPath, paint);
  }

  @override
  bool shouldRepaint(covariant _ExpressiveListBulletIconPainter oldDelegate) {
    return color != oldDelegate.color;
  }
}
