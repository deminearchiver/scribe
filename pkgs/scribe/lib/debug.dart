import 'dart:typed_data';

import 'dart:ui';

import 'package:flutter/painting.dart';

enum CommandType { M }

sealed class Command {
  const Command._();

  const factory Command.M(double x, double y) = MCommand;

  String get tag;
  String? get parameters;

  @override
  String toString() => [tag, if (parameters != null) parameters].join(" ");
}

class MCommand extends Command {
  const MCommand(this.x, this.y) : super._();

  final double x;
  final double y;

  @override
  String get tag => "M";

  @override
  String? get parameters => "$x $y";
}

class CCommand extends Command {
  const CCommand(this.x1, this.y1, this.x2, this.y2, this.x3, this.y3)
    : super._();
  final double x1;
  final double y1;
  final double x2;
  final double y2;
  final double x3;
  final double y3;

  @override
  String get tag => "C";

  @override
  String? get parameters => "$x1 $x2, $y1 $y2, $x3 $y3";
}

class ZCommand extends Command {
  const ZCommand() : super._();

  @override
  String get tag => "Z";

  @override
  String? get parameters => null;
}

extension CommandsExtension on Iterable<Command> {
  String toPathData() => join(" ");
}

class DebugPath extends ProxyPath {
  DebugPath(super.path);

  final List<Command> commands = [];

  @override
  String toString() => "DebugPath(${commands.toPathData()})";

  @override
  void moveTo(double x, double y) {
    commands.add(MCommand(x, y));
    super.moveTo(x, y);
  }

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    commands.add(CCommand(x1, y1, x2, y2, x3, y3));
    super.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  @override
  void close() {
    commands.add(const ZCommand());
    super.close();
  }
}

class ProxyPath implements Path {
  const ProxyPath(this.path);
  final Path path;

  @override
  PathFillType get fillType => path.fillType;
  @override
  set fillType(PathFillType value) {
    path.fillType = value;
  }

  @override
  void addArc(Rect oval, double startAngle, double sweepAngle) {
    path.addArc(oval, startAngle, sweepAngle);
  }

  @override
  void addOval(Rect oval) {
    path.addOval(oval);
  }

  @override
  void addPath(Path path, Offset offset, {Float64List? matrix4}) {
    path.addPath(path, offset, matrix4: matrix4);
  }

  @override
  void addPolygon(List<Offset> points, bool close) {
    path.addPolygon(points, close);
  }

  @override
  void addRRect(RRect rrect) {
    path.addRRect(rrect);
  }

  @override
  void addRect(Rect rect) {
    path.addRect(rect);
  }

  @override
  void arcTo(
    Rect rect,
    double startAngle,
    double sweepAngle,
    bool forceMoveTo,
  ) {
    path.arcTo(rect, startAngle, sweepAngle, forceMoveTo);
  }

  @override
  void arcToPoint(
    Offset arcEnd, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    path.arcToPoint(
      arcEnd,
      radius: radius,
      rotation: rotation,
      largeArc: largeArc,
      clockwise: clockwise,
    );
  }

  @override
  void close() {
    path.close();
  }

  @override
  PathMetrics computeMetrics({bool forceClosed = false}) {
    return path.computeMetrics(forceClosed: forceClosed);
  }

  @override
  void conicTo(double x1, double y1, double x2, double y2, double w) {
    path.conicTo(x1, y1, x2, y2, w);
  }

  @override
  bool contains(Offset point) {
    return path.contains(point);
  }

  @override
  void cubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    path.cubicTo(x1, y1, x2, y2, x3, y3);
  }

  @override
  void extendWithPath(Path path, Offset offset, {Float64List? matrix4}) {
    path.extendWithPath(path, offset, matrix4: matrix4);
  }

  @override
  Rect getBounds() {
    return path.getBounds();
  }

  @override
  void lineTo(double x, double y) {
    path.lineTo(x, y);
  }

  @override
  void moveTo(double x, double y) {
    path.moveTo(x, y);
  }

  @override
  void quadraticBezierTo(double x1, double y1, double x2, double y2) {
    path.quadraticBezierTo(x1, y1, x2, y2);
  }

  @override
  void relativeArcToPoint(
    Offset arcEndDelta, {
    Radius radius = Radius.zero,
    double rotation = 0.0,
    bool largeArc = false,
    bool clockwise = true,
  }) {
    path.relativeArcToPoint(
      arcEndDelta,
      radius: radius,
      rotation: rotation,
      largeArc: largeArc,
      clockwise: clockwise,
    );
  }

  @override
  void relativeConicTo(double x1, double y1, double x2, double y2, double w) {
    path.relativeConicTo(x1, y1, x2, y2, w);
  }

  @override
  void relativeCubicTo(
    double x1,
    double y1,
    double x2,
    double y2,
    double x3,
    double y3,
  ) {
    path.relativeCubicTo(x1, y1, x2, y2, x3, y3);
  }

  @override
  void relativeLineTo(double dx, double dy) {
    path.relativeLineTo(dx, dy);
  }

  @override
  void relativeMoveTo(double dx, double dy) {
    path.relativeMoveTo(dx, dy);
  }

  @override
  void relativeQuadraticBezierTo(double x1, double y1, double x2, double y2) {
    path.relativeQuadraticBezierTo(x1, y1, x2, y2);
  }

  @override
  void reset() {
    path.reset();
  }

  @override
  Path shift(Offset offset) {
    return path.shift(offset);
  }

  @override
  Path transform(Float64List matrix4) {
    return path.transform(matrix4);
  }
}
