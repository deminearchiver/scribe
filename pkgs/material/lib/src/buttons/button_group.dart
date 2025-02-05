import 'package:collection/collection.dart';
import 'package:material/material.dart';
import 'package:painting/painting.dart';

extension ItersperseIterableExtension<T> on Iterable<T> {
  Iterable<T> intersperse(T Function(int index) separator) sync* {
    var index = 0;
    final iterator = this.iterator;
    if (iterator.moveNext()) {
      yield iterator.current;
      while (iterator.moveNext()) {
        yield separator(1 + 2 * index++);
        yield iterator.current;
      }
    }
  }
}

extension IntersperseListExtension<E> on List<E> {
  Iterable<E> intersperse(E Function(int index) separator) sync* {
    final lastIndex = length - 1;
    for (var index = 0; index < length; index++) {
      yield this[index];
      if (index < lastIndex) yield separator(index * 2 + 1);
    }
  }
}

enum _ButtonGroupVariant { connected }

class ButtonGroup extends StatelessWidget {
  const ButtonGroup.connected({super.key, this.children = const []})
    : _variant = _ButtonGroupVariant.connected;

  final _ButtonGroupVariant _variant;

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final lastIndex = children.length - 1;
    return Flex.horizontal(
      spacing: 4.0,
      children: [
        ...children.mapIndexed<Widget>((index, child) {
          final isFirst = index == 0;
          final isLast = index == lastIndex;
          return CommonButtonTheme(
            data: CommonButtonThemeData(
              style: ButtonStyle(
                shape: WidgetStatePropertyAll(
                  RoundBorder(
                    topLeft: isFirst ? null : Corners.small,
                    topRight: isLast ? null : Corners.small,
                    bottomRight: isLast ? null : Corners.small,
                    bottomLeft: isFirst ? null : Corners.small,
                  ),
                ),
                // padding:
                //     isFirst || isLast
                //         ? WidgetStatePropertyAll(
                //           EdgeInsets.only(
                //             left: isFirst ? 16 : 12,
                //             right: isLast ? 16 : 16,
                //           ),
                //         )
                //         : null,
              ),
            ),
            child: child,
          );
        }),
      ],
    );
  }
}

class _ButtonThemeOverride extends StatelessWidget {
  const _ButtonThemeOverride({super.key, this.style, required this.child});

  final ButtonStyle? style;
  final Widget child;

  Widget _buildElevatedButtonTheme(BuildContext context, Widget child) {
    final elevatedButtonStyle = ElevatedButtonTheme.of(context).style;
    return ElevatedButtonTheme(
      data: ElevatedButtonThemeData(
        style: elevatedButtonStyle?.merge(style) ?? style,
      ),
      child: child,
    );
  }

  Widget _buildFilledButtonTheme(BuildContext context, Widget child) {
    final filledButtonStyle = FilledButtonTheme.of(context).style;
    return FilledButtonTheme(
      data: FilledButtonThemeData(
        style: filledButtonStyle?.merge(style) ?? style,
      ),
      child: child,
    );
  }

  Widget _buildOutlinedButtonTheme(BuildContext context, Widget child) {
    final outlinedButtonStyle = OutlinedButtonTheme.of(context).style;
    return OutlinedButtonTheme(
      data: OutlinedButtonThemeData(
        style: outlinedButtonStyle?.merge(style) ?? style,
      ),
      child: child,
    );
  }

  Widget _buildTextButtonTheme(BuildContext context, Widget child) {
    final textButtonStyle = TextButtonTheme.of(context).style;
    return TextButtonTheme(
      data: TextButtonThemeData(style: textButtonStyle?.merge(style) ?? style),
      child: child,
    );
  }

  Widget _buildTree(BuildContext context, Widget child) {
    return _buildElevatedButtonTheme(
      context,
      _buildFilledButtonTheme(
        context,
        _buildOutlinedButtonTheme(
          context,
          _buildTextButtonTheme(context, child),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => _buildTree(context, child);
}
