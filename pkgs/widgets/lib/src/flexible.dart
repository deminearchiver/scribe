import 'package:flutter/widgets.dart' as flutter;
import 'package:widgets/widgets.dart';

class Flexible extends flutter.Flexible {
  const Flexible({super.key, super.flex, super.fit, required super.child});
  const Flexible.expand({super.key, super.flex, Widget? child})
    : super(fit: FlexFit.tight, child: child ?? const SizedBox.shrink());
}
