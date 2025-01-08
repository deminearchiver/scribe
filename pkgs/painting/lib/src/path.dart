import 'dart:ui';

import 'package:flutter/cupertino.dart';

Path? lerpPath(Path? a, Path? b, double t) {
  if (identical(a, b)) return a != null ? Path.from(a) : null;
  if (a == null) return b;
  if (b == null) return a;
  // TODO: implement morphing
}
