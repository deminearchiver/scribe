import 'dart:ui';

import 'package:path_parsing/path_parsing.dart';

class _Proxy implements PathProxy {
  const _Proxy(this.path);
  final Path path;

  @override
  void moveTo(double x, double y) => path.moveTo(x, y);

  @override
  void lineTo(double x, double y) => path.lineTo(x, y);

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) => path.cubicTo(x1, y1, x2, y2, x3, y3);

  @override
  void close() => path.close();
}

void svgPathDataToPath(String svg, Path path) {
  final proxy = _Proxy(path);
  writeSvgPathDataToPath(svg, proxy);
}
