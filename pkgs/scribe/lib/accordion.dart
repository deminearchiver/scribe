import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:gap/gap.dart';
import 'package:material/material.dart';

class AccordionItem<T> with Diagnosticable {
  const AccordionItem({
    required this.value,
    this.leading,
    required this.headline,
    this.supportingText,
    required this.child,
  });

  final T value;

  final Widget? leading;
  final Widget headline;
  final Widget? supportingText;
  final Widget child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<T>("value", value));
  }
}

class Accordion<T> extends StatefulWidget {
  const Accordion({
    super.key,
    this.onExpandedChanged,
    required this.expanded,
    required this.items,
  }) : assert(items.length >= 2);

  final ValueChanged<Set<T>>? onExpandedChanged;
  final Set<T> expanded;
  final List<AccordionItem<T>> items;

  @override
  State<Accordion<T>> createState() => _AccordionState<T>();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
      DiagnosticsProperty<ValueChanged<Set<T>>>(
        "onExpandedChanged",
        onExpandedChanged,
        defaultValue: null,
      ),
    );
    properties.add(DiagnosticsProperty<Set<T>>("expanded", expanded));
    properties.add(DiagnosticsProperty<List<AccordionItem<T>>>("items", items));
  }
}

class _AccordionState<T> extends State<Accordion<T>> {
  Widget _buildItem({
    required BuildContext context,
    required int index,
    required List<AccordionItem<T>> items,
    required AccordionItem<T> item,
  }) {
    final theme = Theme.of(context);
    final stateTheme = StateTheme.of(context);

    final isExpanded = widget.expanded.contains(item.value);

    final topBorderRadius =
        isExpanded ||
                index == 0 ||
                widget.expanded.contains(items[index - 1].value)
            ? Radii.extraLarge
            : Radii.small;
    final bottomBorderRadius =
        isExpanded ||
                index == items.length - 1 ||
                widget.expanded.contains(items[index + 1].value)
            ? Radii.extraLarge
            : Radii.small;
    final borderRadius = BorderRadius.vertical(
      bottom: bottomBorderRadius,
      top: topBorderRadius,
    );
    final shape = RoundedRectangleBorder(borderRadius: borderRadius);

    return TweenAnimationBuilder<ShapeBorder?>(
      tween: ShapeBorderTween(end: shape),
      duration: Durations.medium4,
      curve: Easing.standard,
      child: Flex.vertical(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ConstrainedBox(
            constraints: const BoxConstraints(minHeight: 64),
            child: InkWell(
              onTap: () {
                final view = UnmodifiableSetView<T>({
                  ...widget.expanded.whereNot((value) => value == item.value),
                  if (!isExpanded) item.value,
                });
                widget.onExpandedChanged?.call(view);
              },
              overlayColor: WidgetStateLayerColor(
                theme.colorScheme.onSecondaryContainer,
                opacity: stateTheme.stateLayerOpacity,
              ),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Flex.horizontal(
                  children: [
                    if (item.leading != null)
                      IconTheme.merge(
                        data: IconThemeData(
                          size: 24,
                          opticalSize: 24,
                          color: theme.colorScheme.onSecondaryContainer,
                        ),
                        child: item.leading!,
                      ),

                    const Gap(16.0),
                    Expanded(
                      child: Flex.vertical(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          DefaultTextStyle.merge(
                            style: theme.textTheme.bodyLarge!.copyWith(
                              color: theme.colorScheme.onSecondaryContainer,
                            ),
                            child: item.headline,
                          ),
                          if (item.supportingText != null)
                            DefaultTextStyle.merge(
                              style: theme.textTheme.bodyMedium!.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                              child: item.supportingText!,
                            ),
                        ],
                      ),
                    ),
                    const Gap(16.0),
                    AnimatedRotation(
                      turns: isExpanded ? 0.5 : 0.0,
                      duration: Durations.medium4,
                      curve: Easing.standard,
                      child: Icon(
                        Symbols.keyboard_arrow_down,
                        color:
                            isExpanded
                                ? theme.colorScheme.onSurfaceVariant
                                : theme.colorScheme.onSecondaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          AnimatedOpacity(
            duration: Durations.medium4,
            curve: Easing.standard,
            opacity: isExpanded ? 1.0 : 0.0,
            child: AnimatedAlign(
              // alignment: Alignment.topCenter,
              alignment: Alignment(0, -0.75),
              duration: Durations.medium4,
              curve: Easing.standard,
              heightFactor: isExpanded ? 1.0 : 0.0,
              child: item.child,
            ),
          ),
        ],
      ),
      builder:
          (context, value, child) => Material(
            animationDuration: Duration.zero,
            clipBehavior: Clip.antiAlias,
            shape: value,
            color: theme.colorScheme.secondaryContainer,
            child: child!,
          ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Flex.vertical(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      spacing: 4.0,
      children:
          widget.items
              .mapIndexed(
                (index, item) => _buildItem(
                  context: context,
                  index: index,
                  items: widget.items,
                  item: item,
                ),
              )
              .toList(),
    );
  }
}
