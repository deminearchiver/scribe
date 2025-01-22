import 'dart:math' as math;

import 'package:material/material.dart';
import 'package:scribe/misc.dart';
import 'package:super_editor/super_editor.dart';

class ListItemComponentBuilder implements ComponentBuilder {
  const ListItemComponentBuilder();

  @override
  SingleColumnLayoutComponentViewModel? createViewModel(
    Document document,
    DocumentNode node,
  ) {
    if (node is! ListItemNode) {
      return null;
    }

    int? ordinalValue;
    if (node.type == ListItemType.ordered) {
      ordinalValue = computeListItemOrdinalValue(node, document);
    }

    return switch (node.type) {
      ListItemType.unordered => UnorderedListItemComponentViewModel(
        nodeId: node.id,
        indent: node.indent,
        text: node.text,
        textStyleBuilder: noStyleBuilder,
        selectionColor: const Color(0x00000000),
      ),
      ListItemType.ordered => OrderedListItemComponentViewModel(
        nodeId: node.id,
        indent: node.indent,
        ordinalValue: ordinalValue,
        text: node.text,
        textStyleBuilder: noStyleBuilder,
        selectionColor: const Color(0x00000000),
      ),
    };
  }

  @override
  Widget? createComponent(
    SingleColumnDocumentComponentContext componentContext,
    SingleColumnLayoutComponentViewModel componentViewModel,
  ) {
    if (componentViewModel is! UnorderedListItemComponentViewModel &&
        componentViewModel is! OrderedListItemComponentViewModel) {
      return null;
    }

    if (componentViewModel is UnorderedListItemComponentViewModel) {
      return UnorderedListItemComponent(
        componentKey: componentContext.componentKey,
        text: componentViewModel.text,
        styleBuilder: componentViewModel.textStyleBuilder,
        indent: componentViewModel.indent,
        dotStyle: componentViewModel.dotStyle,
        textSelection: componentViewModel.selection,
        selectionColor: componentViewModel.selectionColor,
        highlightWhenEmpty: componentViewModel.highlightWhenEmpty,
        underlines: componentViewModel.createUnderlines(),
      );
    } else if (componentViewModel is OrderedListItemComponentViewModel) {
      return OrderedListItemComponent(
        componentKey: componentContext.componentKey,
        indent: componentViewModel.indent,
        listIndex: componentViewModel.ordinalValue!,
        text: componentViewModel.text,
        styleBuilder: componentViewModel.textStyleBuilder,
        numeralStyle: componentViewModel.numeralStyle,
        textSelection: componentViewModel.selection,
        selectionColor: componentViewModel.selectionColor,
        highlightWhenEmpty: componentViewModel.highlightWhenEmpty,
        underlines: componentViewModel.createUnderlines(),
      );
    }

    editorLayoutLog.warning(
      "Tried to build a component for a list item view model without a list item itemType: $componentViewModel",
    );
    return null;
  }
}

Widget _expressiveUnorderedListItemDotBuilder(
  BuildContext context,
  UnorderedListItemComponent component,
) {
  // Usually, the font size is obtained via the stylesheet. But the attributions might
  // also contain a FontSizeAttribution, which overrides the stylesheet. Use the attributions
  // of the first character to determine the text style.
  final attributions = component.text.getAllAttributionsAt(0).toSet();
  final textStyle = component.styleBuilder(attributions);

  final dotSize = component.dotStyle?.size ?? const Size(4, 4);

  return Align(
    alignment: Alignment.centerRight,
    child: Text.rich(
      TextSpan(
        // Place a zero-width joiner before the bullet point to make it properly aligned. Without this,
        // the bullet point is not vertically centered with the text, even when setting the textStyle
        // on the whole rich text or WidgetSpan.
        text: '\u200C',
        style: textStyle,
        children: [
          WidgetSpan(
            alignment: PlaceholderAlignment.middle,
            // child: Container(
            //   width: dotSize.width,
            //   height: dotSize.height,
            //   margin: const EdgeInsets.only(right: 10),
            //   decoration: BoxDecoration(
            //     shape: component.dotStyle?.shape ?? BoxShape.circle,
            //     color: component.dotStyle?.color ?? textStyle.color,
            //   ),
            // ),
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: Transform.rotate(
                // angle: math.pi * 0.2 * index,
                angle: 0,
                child: ExpressiveListBulletIcon(
                  size: dotSize.width,
                  color: component.dotStyle?.color ?? textStyle.color,
                ),
              ),
            ),
          ),
        ],
      ),
      // Don't scale the dot.
      textScaler: const TextScaler.linear(1.0),
    ),
  );
}
