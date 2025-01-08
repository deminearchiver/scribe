import 'package:material/material.dart';

class PlayPause extends StatelessWidget {
  const PlayPause({super.key, required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final iconTheme = IconTheme.of(context);
    return SizedBox.square(
      dimension: iconTheme.size!,
      child: CustomPaint(
        painter: _PlayPausePainter(progress: progress, color: iconTheme.color!),
      ),
    );
  }
}

class _PlayPausePainter extends CustomPainter {
  const _PlayPausePainter({required this.progress, required this.color});

  final double progress;
  final Color color;

  Path get _path1 {
    final p1 = Offset.lerp(const Offset(8, 5), const Offset(14, 5), progress)!;
    final p2 = Offset.lerp(const Offset(8, 5), const Offset(18, 5), progress)!;
    final p3 =
        Offset.lerp(const Offset(19, 12), const Offset(18, 12), progress)!;
    final p4 =
        Offset.lerp(const Offset(8, 19), const Offset(18, 19), progress)!;
    final p5 =
        Offset.lerp(const Offset(8, 19), const Offset(14, 19), progress)!;
    return Path()..addPolygon([p1, p2, p3, p4, p5], true);
  }

  Path get _path2 {
    final p1 = Offset.lerp(const Offset(8, 5), const Offset(6, 5), progress)!;
    final p2 =
        Offset.lerp(const Offset(12, 7.5455), const Offset(10, 5), progress)!;
    final p3 =
        Offset.lerp(const Offset(12, 16.4545), const Offset(10, 19), progress)!;
    final p4 = Offset.lerp(const Offset(8, 19), const Offset(6, 19), progress)!;
    return Path()..addPolygon([p1, p2, p3, p4], true);
  }

  @override
  void paint(Canvas canvas, Size size) {
    canvas.scale(size.width / 24, size.height / 24);
    final paint =
        Paint()
          ..style = PaintingStyle.fill
          ..color = color;

    canvas.drawPath(_path1, paint);
    canvas.drawPath(_path2, paint);
  }

  @override
  bool shouldRepaint(covariant _PlayPausePainter oldDelegate) {
    return progress != oldDelegate.progress || color != oldDelegate.color;
  }
}
