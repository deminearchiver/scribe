import 'package:collection/collection.dart';
import 'package:flutter/foundation.dart';
import 'package:gap/gap.dart';
import 'package:material/material.dart';

enum AccordionItemVariant { primary, secondary, filled, outlined }

class AccordionItem with Diagnosticable {
  const AccordionItem({
    this.onPressed,
    required this.expanded,
    required this.variant,
    this.borderRadius,
    this.leading,
    required this.headline,
    this.supportingText,
    this.trailing,
    required this.child,
  });
  const AccordionItem.primary({
    this.onPressed,
    required this.expanded,
    this.borderRadius,
    this.leading,
    required this.headline,
    this.supportingText,
    this.trailing,
    required this.child,
  }) : variant = AccordionItemVariant.primary;
  const AccordionItem.secondary({
    this.onPressed,
    required this.expanded,
    this.borderRadius,
    this.leading,
    required this.headline,
    this.supportingText,
    this.trailing,
    required this.child,
  }) : variant = AccordionItemVariant.secondary;
  const AccordionItem.filled({
    this.onPressed,
    required this.expanded,
    this.borderRadius,
    this.leading,
    required this.headline,
    this.supportingText,
    this.trailing,
    required this.child,
  }) : variant = AccordionItemVariant.filled;
  const AccordionItem.outlined({
    this.onPressed,
    required this.expanded,
    this.borderRadius,
    this.leading,
    required this.headline,
    this.supportingText,
    this.trailing,
    required this.child,
  }) : variant = AccordionItemVariant.outlined;

  final VoidCallback? onPressed;
  final bool expanded;
  final AccordionItemVariant variant;

  /// Replaces the item's borderRadius at all times
  final BorderRadius? borderRadius;

  final Widget? leading;
  final Widget headline;
  final Widget? supportingText;
  final Widget? trailing;

  /// If this is null, then this item won't be able to become expanded
  final Widget? child;

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DiagnosticsProperty<bool>("expanded", expanded));
    properties.add(EnumProperty<AccordionItemVariant>("variant", variant));
  }
}

class Accordion extends StatefulWidget {
  const Accordion({super.key, required this.items}) : assert(items.length >= 1);

  final List<AccordionItem> items;

  @override
  State<Accordion> createState() => _AccordionState();

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    // properties.add(
    //   DiagnosticsProperty<ValueChanged<Set<T>>>(
    //     "onExpandedChanged",
    //     onExpandedChanged,
    //     defaultValue: null,
    //   ),
    // );
    // properties.add(DiagnosticsProperty<Set<T>>("expanded", expanded));
    properties.add(DiagnosticsProperty<List<AccordionItem>>("items", items));
  }
}

class _AccordionState extends State<Accordion> {
  Widget _buildItem({
    required BuildContext context,
    required int index,
    required List<AccordionItem> items,
    required AccordionItem item,
  }) {
    final theme = Theme.of(context);
    final stateTheme = StateTheme.of(context);

    final previousItem = index > 0 ? items[index - 1] : null;
    final nextItem = index < items.length - 1 ? items[index + 1] : null;
    final isPreviousExpanded = previousItem?.expanded ?? false;
    final isNextExpanded = nextItem?.expanded ?? false;
    final isExpanded = item.expanded && item.child != null;
    final backgroundColor = switch (item.variant) {
      AccordionItemVariant.primary => theme.colorScheme.primaryContainer,
      AccordionItemVariant.secondary => theme.colorScheme.secondaryContainer,
      AccordionItemVariant.filled => theme.colorScheme.surfaceContainerHighest,
      AccordionItemVariant.outlined => Colors.transparent,
    };
    final foregroundColor = switch (item.variant) {
      AccordionItemVariant.primary => theme.colorScheme.onPrimaryContainer,
      AccordionItemVariant.secondary => theme.colorScheme.onSecondaryContainer,
      AccordionItemVariant.filled => theme.colorScheme.onSurface,
      AccordionItemVariant.outlined => theme.colorScheme.onSurface,
    };
    final side = switch (item.variant) {
      AccordionItemVariant.outlined => BorderSide(
        color: theme.colorScheme.outlineVariant,
      ),
      _ => BorderSide.none,
    };

    OutlinedBorder shape;
    if (item.borderRadius != null) {
      shape = RoundedRectangleBorder(
        borderRadius: item.borderRadius!,
        side: side,
      );
    } else {
      final topBorderRadius =
          isExpanded || index == 0 || isPreviousExpanded
              ? Radii.extraLarge
              : Radii.small;
      final bottomBorderRadius =
          isExpanded || index == items.length - 1 || isNextExpanded
              ? Radii.extraLarge
              : Radii.small;
      final borderRadius = BorderRadius.vertical(
        bottom: bottomBorderRadius,
        top: topBorderRadius,
      );
      shape = RoundedRectangleBorder(borderRadius: borderRadius, side: side);
    }

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
              onTap: item.onPressed,
              overlayColor: WidgetStateLayerColor(
                foregroundColor,
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
                          color: foregroundColor,
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
                              color: foregroundColor,
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
                    if (item.child != null && item.trailing == null)
                      AnimatedRotation(
                        turns: isExpanded ? 0.5 : 0.0,
                        duration: Durations.medium4,
                        curve: Easing.standard,
                        child: Icon(
                          Symbols.keyboard_arrow_down,
                          color:
                              isExpanded
                                  ? theme.colorScheme.onSurfaceVariant
                                  : foregroundColor,
                        ),
                      ),
                    if (item.trailing != null)
                      IconTheme.merge(
                        data: IconThemeData(color: foregroundColor),
                        child: item.trailing!,
                      ),
                  ],
                ),
              ),
            ),
          ),
          if (item.child != null)
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
                child: SizedBox(width: double.infinity, child: item.child),
              ),
            ),
        ],
      ),
      builder:
          (context, value, child) => Material(
            animationDuration: Duration.zero,
            clipBehavior: Clip.antiAlias,
            shape: value,
            color: backgroundColor,
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
