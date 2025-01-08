import 'package:material/material.dart';
import 'package:material_symbols_icons/material_symbols_icons.dart';

abstract class SplitButton extends StatefulWidget {
  const SplitButton._({super.key, this.icon, this.label})
    : assert(icon != null || label != null);
  const factory SplitButton.filled({
    Key? key,
    Widget? icon,
    required Widget label,
  }) = _FilledSplitButton;

  final Widget? icon;
  final Widget? label;

  @override
  State<SplitButton> createState() => _SplitButtonState();

  @protected
  Widget _buildButton({
    required BuildContext context,
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool autofocus = false,
    Clip clipBehavior = Clip.none,
    WidgetStatesController? statesController,
    IconAlignment iconAlignment = IconAlignment.start,
    Widget? icon,
    Widget? label,
  });
}

class _SplitButtonState extends State<SplitButton> {
  @override
  Widget build(BuildContext context) {
    return ButtonGroup.connected(
      children: [
        widget._buildButton(
          context: context,
          onPressed: () {},
          icon: widget.icon,
          label: widget.label,
        ),
        widget._buildButton(
          context: context,
          onPressed: () {},
          icon: const Icon(Symbols.expand_more_rounded),
        ),
      ],
    );
  }
}

class _FilledSplitButton extends SplitButton {
  const _FilledSplitButton({super.key, super.icon, super.label}) : super._();

  @override
  Widget _buildButton({
    required BuildContext context,
    Key? key,
    required VoidCallback? onPressed,
    VoidCallback? onLongPress,
    ValueChanged<bool>? onHover,
    ValueChanged<bool>? onFocusChange,
    ButtonStyle? style,
    FocusNode? focusNode,
    bool autofocus = false,
    Clip clipBehavior = Clip.none,
    WidgetStatesController? statesController,
    IconAlignment iconAlignment = IconAlignment.start,
    Widget? icon,
    Widget? label,
  }) => FilledButton(
    key: key,
    onPressed: onPressed,
    onLongPress: onLongPress,
    onHover: onHover,
    onFocusChange: onFocusChange,
    style: style,
    focusNode: focusNode,
    autofocus: autofocus,
    clipBehavior: clipBehavior,
    statesController: statesController,
    iconAlignment: iconAlignment,
    icon: icon,
    label: label,
  );
}
