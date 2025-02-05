import 'package:flutter/scheduler.dart';
import 'package:gap/gap.dart';
import 'package:material/material.dart';

class NoteCard extends StatefulWidget {
  const NoteCard({
    super.key,
    this.selected = false,
    this.checked = false,
    this.headline,
    this.supportingText,
  });

  final bool selected;
  final bool checked;

  final Widget? headline;
  final Widget? supportingText;

  @override
  State<NoteCard> createState() => _NoteCardState();
}

class _NoteCardState extends State<NoteCard> {
  late WidgetStatesController _statesController;

  late WidgetStateProperty<Color> _backgroundColor;
  late WidgetStateProperty<Color> _overlayColor;
  late WidgetStateProperty<BorderSide> _side;
  late WidgetStateProperty<TextStyle> _headlineStyle;
  late WidgetStateProperty<TextStyle> _supportingTextStyle;

  @override
  void initState() {
    super.initState();
    _statesController = WidgetStatesController({
      if (widget.selected) WidgetState.selected,
    })..addListener(_statesListener);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final theme = Theme.of(context);
    final stateTheme = StateTheme.of(context);
    _backgroundColor = WidgetStateProperty.resolveWith((states) {
      if (widget.checked) {
        return theme.colorScheme.primaryContainer;
      }
      if (widget.selected) {
        return theme.colorScheme.secondaryContainer;
      }
      return theme.colorScheme.surface;
    });
    _overlayColor = WidgetStateProperty.resolveWith((states) {
      final color =
          widget.checked
              ? theme.colorScheme.onPrimaryContainer
              : widget.selected
              ? theme.colorScheme.onSecondaryContainer
              : theme.colorScheme.onSurface;
      final opacity = stateTheme.stateLayerOpacity.resolve(states);
      if (opacity == 0.0) return color.withAlpha(0);
      return color.withValues(alpha: opacity);
    });

    _side = WidgetStateProperty.resolveWith((states) {
      if (widget.checked) {
        return BorderSide(
          width: 3.0,
          strokeAlign: BorderSide.strokeAlignInside,
          color: theme.colorScheme.secondary,
        );
      }
      if (widget.selected) return BorderSide.none;
      return BorderSide(
        width: 1.0,
        strokeAlign: BorderSide.strokeAlignInside,
        color: theme.colorScheme.outlineVariant,
      );
    });

    _headlineStyle = WidgetStateProperty.resolveWith((states) {
      final color =
          widget.checked
              ? theme.colorScheme.onPrimaryContainer
              : widget.selected
              ? theme.colorScheme.onSecondaryContainer
              : theme.colorScheme.onSurface;
      return theme.textTheme.titleMedium!.copyWith(color: color);
    });
    _supportingTextStyle = WidgetStateProperty.resolveWith((states) {
      final color =
          widget.checked
              ? theme.colorScheme.onPrimaryContainer
              : widget.selected
              ? theme.colorScheme.onSecondaryContainer
              : theme.colorScheme.onSurfaceVariant;
      return theme.textTheme.bodyMedium!.copyWith(color: color);
    });
  }

  @override
  void didUpdateWidget(covariant NoteCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.selected != oldWidget.selected) {
      _statesController.update(WidgetState.selected, widget.selected);
    }
  }

  @override
  void dispose() {
    _statesController.dispose();
    super.dispose();
  }

  void _statesListener() {
    if (SchedulerBinding.instance.schedulerPhase ==
        SchedulerPhase.persistentCallbacks) {
      SchedulerBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() {});
      });
    } else if (mounted) {
      setState(() {});
    }
  }

  Widget _buildAnimatedButtonChild({
    required BuildContext context,
    Widget? icon,
    Widget? label,
  }) {
    icon ??= const SizedBox.shrink();
    label ??= const SizedBox.shrink();
    Widget layoutBuilder(Widget? currentChild, List<Widget> previousChildren) {
      return Stack(
        alignment: Alignment.centerLeft,
        children: [
          ...previousChildren.map(
            (child) => Align(
              alignment: Alignment.centerLeft,
              widthFactor: 0.0,
              heightFactor: 0.0,
              child: child,
            ),
          ),
          if (currentChild != null) currentChild,
        ],
      );
    }

    return AnimatedSize(
      duration: Durations.medium4,
      curve: Easing.standard,
      alignment: Alignment.centerLeft,
      child: CommonButtonChild(
        icon: AnimatedSwitcher(
          duration: Durations.medium4,
          layoutBuilder: layoutBuilder,
          child: icon,
        ),
        label: AnimatedSwitcher(
          duration: Durations.medium4,
          layoutBuilder: layoutBuilder,
          child: label,
        ),
      ),
    );
  }

  Widget _buildReminder(BuildContext context) {
    final windowWidthSizeClass = WindowWidthSizeClass.of(context);
    return Center(
      child: FilledButton.custom(
        onPressed: () {},
        clipBehavior: Clip.antiAlias,
        child: _buildAnimatedButtonChild(
          context: context,
          icon: Icon(Symbols.done),
          label: Text(key: UniqueKey(), "Lorem aaaaaaaaa"),
        ),
      ),
    );
    if (windowWidthSizeClass <= WindowWidthSizeClass.compact) {
      return Flex.horizontal(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          OutlinedButton(
            // onPressed: null,
            onPressed: () {},
            // icon: const Icon(Symbols.alarm),
            icon: const Icon(Symbols.done),
            label: Text("Jan 16, 8:00 AM"),
          ),
          const Gap(4),
          // IconButton.filled(onPressed: null, icon: const Icon(Symbols.done)),
        ],
      );
    }
    if (windowWidthSizeClass <= WindowWidthSizeClass.medium) {
      return ButtonGroup.connected(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () {},
              icon: const Icon(Symbols.alarm),
              label: Text("Jan 16, 8:00 AM"),
            ),
          ),
          Expanded(
            child: FilledButton(
              onPressed: () {},
              icon: const Icon(Symbols.done),
              label: Text("Mark as completed"),
            ),
          ),
        ],
      );
    }
    if (windowWidthSizeClass <= WindowWidthSizeClass.expanded) {
      return Flex.vertical(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Expanded(
          //   child: OutlinedButton(
          //     onPressed: () {},
          //     icon: const Icon(Symbols.alarm),
          //     label: Text("Jan 16, 8:00 AM"),
          //   ),
          // ),
          FilledButton(onPressed: () {}, label: Text("Mark as completed")),
        ],
      );
    }
    return ButtonGroup.connected(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () {},
            icon: const Icon(Symbols.alarm),
            label: Text("Jan 16, 8:00 AM"),
          ),
        ),
        Expanded(
          child: FilledButton(
            onPressed: () {},
            icon: const Icon(Symbols.done),
            label: Text("Mark as completed"),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final textDirection = Directionality.of(context);
    final states = _statesController.value;

    final clipShape = Shapes.medium;
    final outlineShape = clipShape.copyWith(side: _side.resolve(states));
    return Material(
      animationDuration: Duration.zero,
      type: MaterialType.card,
      clipBehavior: Clip.none,
      borderOnForeground: true,
      color: _backgroundColor.resolve(states),
      shape: outlineShape,
      child: InkWell(
        statesController: _statesController,
        overlayColor: _overlayColor,
        onTap: () {},
        customBorder: clipShape,
        child: ClipPath.shape(
          shape: clipShape,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
            child: Flex.vertical(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (widget.headline != null)
                  DefaultTextStyle(
                    style: _headlineStyle.resolve(states),
                    child: widget.headline!,
                  ),
                if (widget.supportingText != null)
                  DefaultTextStyle(
                    style: _supportingTextStyle.resolve(states),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                    child: widget.supportingText!,
                  ),
                // const Gap(16),
                // Wrap(
                //   children: [
                //     ActionChip(
                //       onPressed: () {},
                //       avatar: const Icon(Symbols.alarm),
                //       labelPadding: EdgeInsets.zero,
                //       materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                //       padding: const EdgeInsets.only(left: 8, right: 16),
                //       label: Text("Jan 16, 8:00 AM"),
                //     ),
                //   ],
                // ),
                // _buildReminder(context),
                // ButtonGroup.connected(
                //   children: [
                //     Expanded(
                //       child: OutlinedButton(
                //         onPressed: () {},
                //         icon: const Icon(Symbols.alarm),
                //         label: Text("Jan 16, 8:00 AM"),
                //       ),
                //     ),
                //     Expanded(
                //       child: FilledButton(
                //         onPressed: () {},
                //         icon: const Icon(Symbols.done),
                //         label: Text("Mark as completed"),
                //       ),
                //     ),
                //   ],
                // ),
                // Flex.horizontal(
                //   mainAxisAlignment: MainAxisAlignment.end,
                //   children: [
                //     OutlinedButton(
                //       onPressed: () {},
                //       icon: const Icon(Symbols.alarm),
                //       label: Text("Jan 16, 8:00 AM"),
                //     ),

                //     const Gap(4),
                //     IconButton.outlined(
                //       onPressed: () {},
                //       icon: const Icon(Symbols.done),
                //       tooltip: "Mark as completed",
                //     ),
                //   ],
                // ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class Reminder extends StatefulWidget {
  const Reminder({super.key});

  @override
  State<Reminder> createState() => _ReminderState();
}

class _ReminderState extends State<Reminder> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}
