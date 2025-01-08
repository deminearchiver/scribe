import 'package:material/material.dart';

class ButtonStyleTween extends Tween<ButtonStyle?> {
  ButtonStyleTween({super.begin, super.end});

  @override
  ButtonStyle? lerp(double t) => ButtonStyle.lerp(begin, end, t);
}
