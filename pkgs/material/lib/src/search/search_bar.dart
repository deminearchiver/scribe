import 'package:material/material.dart';
import 'package:flutter/material.dart' as flutter;
import 'package:material_symbols_icons/material_symbols_icons.dart';

enum _SearchBarType { button, input }

class SearchBar extends StatefulWidget {
  const SearchBar.button({
    super.key,
    this.controller,
    this.focusNode,
    this.mouseCursor,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.hintText,
    this.leading,
    this.trailing = const [],
  }) : _type = _SearchBarType.button;
  const SearchBar.input({
    super.key,
    this.controller,
    this.focusNode,
    this.mouseCursor,
    this.onTap,
    this.onLongPress,
    this.padding,
    this.hintText,
    this.leading,
    this.trailing = const [],
  }) : _type = _SearchBarType.input;

  final _SearchBarType _type;

  final TextEditingController? controller;
  final MouseCursor? mouseCursor;
  final FocusNode? focusNode;

  final VoidCallback? onTap;
  final VoidCallback? onLongPress;

  final EdgeInsetsGeometry? padding;

  final String? hintText;

  final Widget? leading;
  final List<Widget> trailing;

  @override
  State<SearchBar> createState() => _SearchBarState();
}

class _SearchBarState extends State<SearchBar> {
  FocusNode? _internalFocusNode;
  FocusNode get _focusNode => widget.focusNode ?? _internalFocusNode!;

  @override
  void initState() {
    super.initState();
    widget.controller?.addListener(_textListener);
    _updateFocusNode();
  }

  @override
  void didUpdateWidget(covariant SearchBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      oldWidget.controller?.removeListener(_textListener);
      widget.controller?.addListener(_textListener);
    }
    if (widget.focusNode != oldWidget.focusNode) _updateFocusNode();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void dispose() {
    _internalFocusNode?.dispose();
    super.dispose();
  }

  void _updateFocusNode() {
    _internalFocusNode?.dispose();
    if (widget.focusNode == null) {
      _internalFocusNode = FocusNode();
    } else {
      _internalFocusNode = null;
    }
  }

  void _textListener() {
    setState(() {});
  }

  String? get _text {
    if (widget.controller?.text.isEmpty ?? true) return null;
    return widget.controller!.text;
  }

  Widget _buildMiddle(BuildContext context) {
    final theme = Theme.of(context);
    return switch (widget._type) {
      _SearchBarType.button => Text(
        _text ?? widget.hintText ?? "",
        style: theme.textTheme.bodyLarge!.copyWith(
          color:
              _text != null
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
        ),
      ),
      _SearchBarType.input => MouseRegion(
        cursor: SystemMouseCursors.text,
        child: Align(
          alignment: Alignment.center,
          child: TextField(
            controller: widget.controller,
            focusNode: _focusNode,
            style: theme.textTheme.bodyLarge!.copyWith(
              color: theme.colorScheme.onSurface,
            ),
            decoration: InputDecoration(
              hintStyle: theme.textTheme.bodyLarge!.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
              hintText: widget.hintText,
              enabledBorder: InputBorder.none,
              border: InputBorder.none,
              focusedBorder: InputBorder.none,
              contentPadding: EdgeInsets.zero,
              isDense: true,
            ),
          ),
        ),
      ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    flutter.SearchBar;

    final effectivePadding =
        widget.padding ?? const EdgeInsets.symmetric(horizontal: 16);

    return ConstrainedBox(
      constraints: const BoxConstraints(
        minWidth: 360,
        maxWidth: 720,
        minHeight: 56,
        maxHeight: 56,
      ),
      child: Material(
        type: MaterialType.canvas,
        color: theme.colorScheme.surfaceContainerHigh,
        elevation: 6.0,
        shape: const StadiumBorder(),
        shadowColor: Colors.transparent,
        child: InkWell(
          focusNode: widget._type == _SearchBarType.button ? _focusNode : null,
          onTap:
              widget._type == _SearchBarType.input
                  ? () {
                    _focusNode.requestFocus();
                    widget.onTap?.call();
                  }
                  : widget.onTap,
          onLongPress: widget.onLongPress,
          // mouseCursor: SystemMouseCursors.text,
          customBorder: const StadiumBorder(),
          overlayColor: WidgetStateLayerColor(theme.colorScheme.onSurface),
          child: Padding(
            padding: effectivePadding,
            child: Row(
              children: [
                Icon(Symbols.menu, color: theme.colorScheme.onSurface),
                Expanded(
                  child: Padding(
                    padding: effectivePadding,
                    child: _buildMiddle(context),
                  ),
                ),
                Icon(Symbols.search, color: theme.colorScheme.onSurfaceVariant),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
