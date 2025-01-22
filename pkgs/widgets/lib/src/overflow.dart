import 'dart:collection';

import 'package:flutter/rendering.dart';
import 'package:widgets/widgets.dart';

// class Overflow extends MultiChildRenderObjectWidget {
//   @override
//   RenderObject createRenderObject(BuildContext context) {
//   }

// }

class OverflowParentData extends ContainerBoxParentData<RenderBox> {
  bool shouldPaint = false;

  @override
  String toString() => "${super.toString()}; shouldPaint=$shouldPaint";
}

class Overflow extends RenderObjectWidget {
  const Overflow({
    super.key,
    required this.indicator,
    this.children = const [],
  });

  final Widget indicator;
  final List<Widget> children;

  @override
  RenderObjectElement createElement() => OverflowElement(this);

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderOverflow();
  }
}

enum OverflowItemSlot { indicator }

class OverflowElement extends RenderObjectElement {
  OverflowElement(Overflow super.widget);

  late List<Element> _children;

  final Map<OverflowItemSlot, Element> slotToChild =
      <OverflowItemSlot, Element>{};

  // We keep a set of forgotten children to avoid O(n^2) work walking _children
  // repeatedly to remove children.
  final Set<Element> _forgottenChildren = HashSet<Element>();

  @override
  RenderOverflow get renderObject => super.renderObject as RenderOverflow;

  void _updateRenderObject(RenderBox? child, OverflowItemSlot slot) {
    switch (slot) {
      case OverflowItemSlot.indicator:
        renderObject.indicator = child;
    }
  }

  @override
  void insertRenderObjectChild(RenderObject child, Object? slot) {
    if (slot is OverflowItemSlot) {
      assert(child is RenderBox);
      _updateRenderObject(child as RenderBox, slot);
      assert(renderObject.slottedChildren.containsKey(slot));
      return;
    }
    if (slot is IndexedSlot) {
      assert(renderObject.debugValidateChild(child));
      renderObject.insert(
        child as RenderBox,
        after: slot.value?.renderObject as RenderBox?,
      );
      return;
    }
    assert(false, "slot must be OverflowItemSlot or IndexedSlot");
  }

  // This is not reachable for children that don't have an IndexedSlot.
  @override
  void moveRenderObjectChild(
    RenderObject child,
    IndexedSlot<Element> oldSlot,
    IndexedSlot<Element> newSlot,
  ) {
    assert(child.parent == renderObject);
    renderObject.move(
      child as RenderBox,
      after: newSlot.value.renderObject as RenderBox?,
    );
  }

  static bool _shouldPaint(Element child) {
    return (child.renderObject!.parentData! as OverflowParentData).shouldPaint;
  }

  @override
  void removeRenderObjectChild(RenderObject child, Object? slot) {
    // Check if the child is in a slot.
    if (slot is OverflowItemSlot) {
      assert(child is RenderBox);
      assert(renderObject.slottedChildren.containsKey(slot));
      _updateRenderObject(null, slot);
      assert(!renderObject.slottedChildren.containsKey(slot));
      return;
    }

    // Otherwise look for it in the list of children.
    assert(slot is IndexedSlot);
    assert(child.parent == renderObject);
    renderObject.remove(child as RenderBox);
  }

  @override
  void visitChildren(ElementVisitor visitor) {
    slotToChild.values.forEach(visitor);
    for (final Element child in _children) {
      if (!_forgottenChildren.contains(child)) {
        visitor(child);
      }
    }
  }

  @override
  void forgetChild(Element child) {
    assert(slotToChild.containsValue(child) || _children.contains(child));
    assert(!_forgottenChildren.contains(child));
    // Handle forgetting a child in children or in a slot.
    if (slotToChild.containsKey(child.slot)) {
      final slot = child.slot! as OverflowItemSlot;
      slotToChild.remove(slot);
    } else {
      _forgottenChildren.add(child);
    }
    super.forgetChild(child);
  }

  // Mount or update slotted child.
  void _mountChild(Widget widget, OverflowItemSlot slot) {
    final Element? oldChild = slotToChild[slot];
    final Element? newChild = updateChild(oldChild, widget, slot);
    if (oldChild != null) {
      slotToChild.remove(slot);
    }
    if (newChild != null) {
      slotToChild[slot] = newChild;
    }
  }

  @override
  void mount(Element? parent, Object? newSlot) {
    super.mount(parent, newSlot);
    // Mount slotted children.
    final toolbarItems = widget as Overflow;
    _mountChild(toolbarItems.indicator, OverflowItemSlot.indicator);

    // Mount list children.
    Element? previousChild;
    _children = List<Element>.generate(toolbarItems.children.length, (int i) {
      final Element result = inflateWidget(
        toolbarItems.children[i],
        IndexedSlot<Element?>(i, previousChild),
      );
      previousChild = result;
      return result;
    }, growable: false);
  }

  @override
  void debugVisitOnstageChildren(ElementVisitor visitor) {
    // Visit slot children.
    for (final Element child in slotToChild.values) {
      if (_shouldPaint(child) && !_forgottenChildren.contains(child)) {
        visitor(child);
      }
    }
    // Visit list children.
    _children
        .where(
          (Element child) =>
              !_forgottenChildren.contains(child) && _shouldPaint(child),
        )
        .forEach(visitor);
  }

  @override
  void update(Overflow newWidget) {
    super.update(newWidget);
    assert(widget == newWidget);

    // Update slotted children.
    final toolbarItems = widget as Overflow;
    _mountChild(toolbarItems.indicator, OverflowItemSlot.indicator);

    // Update list children.
    _children = updateChildren(
      _children,
      toolbarItems.children,
      forgottenChildren: _forgottenChildren,
    );
    _forgottenChildren.clear();
  }
}

class RenderOverflow extends RenderBox
    with
        ContainerRenderObjectMixin<RenderBox, OverflowParentData>,
        RenderBoxContainerDefaultsMixin<RenderBox, OverflowParentData> {
  RenderOverflow() : super();

  final Map<OverflowItemSlot, RenderBox> slottedChildren =
      <OverflowItemSlot, RenderBox>{};
  RenderBox? _updateChild(
    RenderBox? oldChild,
    RenderBox? newChild,
    OverflowItemSlot slot,
  ) {
    if (oldChild != null) {
      dropChild(oldChild);
      slottedChildren.remove(slot);
    }
    if (newChild != null) {
      slottedChildren[slot] = newChild;
      adoptChild(newChild);
    }
    return newChild;
  }

  RenderBox? _indicator;
  RenderBox? get indicator => _indicator;
  set indicator(RenderBox? value) {
    _indicator = _updateChild(_indicator, value, OverflowItemSlot.indicator);
  }

  double _getGreatestHeight() {
    double greatestHeight = 0.0;
    visitChildren((renderObjectChild) {
      final child = renderObjectChild as RenderBox;
      final childHeight = child.getMaxIntrinsicHeight(constraints.maxWidth);
      if (childHeight > greatestHeight) {
        greatestHeight = childHeight;
      }
    });
    return greatestHeight;
  }

  @override
  void performLayout() {
    if (firstChild == null) {
      size = constraints.smallest;
      return;
    }

    // First pass: determine the height of the tallest child.
    final greatestHeight = _getGreatestHeight();

    final slottedConstraints = BoxConstraints(
      maxWidth: constraints.maxWidth,
      minHeight: greatestHeight,
      maxHeight: greatestHeight,
    );
    _indicator!.layout(slottedConstraints, parentUsesSize: true);

    double position = 0.0;
    late double width;

    bool hasOverflowed = false;

    int i = -1;
    visitChildren((renderObjectChild) {
      i++;
      final child = renderObjectChild as RenderBox;
      final childParentData = child.parentData! as OverflowParentData;
      childParentData.shouldPaint = false;
      debugPrint("hasOverflow: $hasOverflowed");
      if (child == _indicator || hasOverflowed) return;

      final marginWidth = i == childCount + 1 ? 0.0 : _indicator!.size.width;

      child.layout(
        BoxConstraints(maxWidth: constraints.maxWidth),
        parentUsesSize: true,
      );

      final double currentWidth = position + child.size.width;
      if (position + child.size.width > constraints.maxWidth) {
        hasOverflowed = true;
        position = _indicator!.size.width;
        child.layout(
          BoxConstraints(
            maxWidth: constraints.maxWidth - _indicator!.size.width,
            minHeight: greatestHeight,
            maxHeight: greatestHeight,
          ),
          parentUsesSize: true,
        );
      }
      debugPrint("${position}");
      childParentData.offset = Offset(position, 0.0);
      position += child.size.width;
      childParentData.shouldPaint = !hasOverflowed;

      width = position;

      // i++;
      // final child = renderObjectChild as RenderBox;
      // final childParentData = child.parentData! as OverflowParentData;
      // childParentData.shouldPaint = false;

      // if (child == _indicator || hasOverflowed) {
      //   return;
      // }
      // double indicatorWidth =
      //     !hasOverflowed && i == childCount + 1 ? 0.0 : _indicator!.size.width;

      // // The width of the menu is set by the first page.
      // child.layout(
      //   BoxConstraints(
      //     maxWidth: constraints.maxWidth - indicatorWidth,
      //     minHeight: greatestHeight,
      //     maxHeight: greatestHeight,
      //   ),
      //   parentUsesSize: true,
      // );

      // final double currentWidth =
      //     currentIndicatorPosition + indicatorWidth + child.size.width;
      // if (currentWidth > constraints.maxWidth) {
      //   hasOverflowed = true;
      //   currentIndicatorPosition = _indicator!.size.width;
      //   indicatorWidth = _indicator!.size.width;
      //   child.layout(
      //     BoxConstraints(
      //       maxWidth: constraints.maxWidth - indicatorWidth,
      //       minHeight: greatestHeight,
      //       maxHeight: greatestHeight,
      //     ),
      //     parentUsesSize: true,
      //   );
      // }

      // childParentData.offset = Offset(currentIndicatorPosition, 0.0);
      // currentIndicatorPosition += child.size.width;
      // childParentData.shouldPaint = !hasOverflowed;

      // width = currentIndicatorPosition;
    });
    if (hasOverflowed) {
      final indicatorParentData = _indicator!.parentData! as OverflowParentData;
      // The forward button only shows when there's a page after this one.
      if (hasOverflowed) {
        indicatorParentData.offset = Offset(position, 0.0);
        indicatorParentData.shouldPaint = true;
        width += _indicator!.size.width;
      }
    }

    size = constraints.constrain(Size(width, greatestHeight));
  }

  @override
  void paint(PaintingContext context, Offset offset) {
    visitChildren((RenderObject renderObjectChild) {
      final RenderBox child = renderObjectChild as RenderBox;
      final childParentData = child.parentData! as OverflowParentData;

      if (childParentData.shouldPaint) {
        final Offset childOffset = childParentData.offset + offset;
        context.paintChild(child, childOffset);
      }
    });
  }

  @override
  void setupParentData(RenderBox child) {
    if (child.parentData is! OverflowParentData) {
      child.parentData = OverflowParentData();
    }
  }

  static bool hitTestChild(
    RenderBox? child,
    BoxHitTestResult result, {
    required Offset position,
  }) {
    if (child == null) {
      return false;
    }
    final childParentData = child.parentData! as OverflowParentData;
    if (!childParentData.shouldPaint) {
      return false;
    }
    return result.addWithPaintOffset(
      offset: childParentData.offset,
      position: position,
      hitTest: (BoxHitTestResult result, Offset transformed) {
        assert(transformed == position - childParentData.offset);
        return child.hitTest(result, position: transformed);
      },
    );
  }

  @override
  bool hitTestChildren(BoxHitTestResult result, {required Offset position}) {
    // Hit test list children.
    RenderBox? child = lastChild;
    while (child != null) {
      final childParentData = child.parentData! as OverflowParentData;

      // Don't hit test children that aren't shown.
      if (!childParentData.shouldPaint) {
        child = childParentData.previousSibling;
        continue;
      }

      if (hitTestChild(child, result, position: position)) {
        return true;
      }
      child = childParentData.previousSibling;
    }

    // Hit test slot children.
    if (hitTestChild(indicator, result, position: position)) {
      return true;
    }

    return false;
  }

  @override
  void attach(PipelineOwner owner) {
    // Attach list children.
    super.attach(owner);

    // Attach slot children.
    for (final RenderBox child in slottedChildren.values) {
      child.attach(owner);
    }
  }

  @override
  void detach() {
    // Detach list children.
    super.detach();

    // Detach slot children.
    for (final RenderBox child in slottedChildren.values) {
      child.detach();
    }
  }

  @override
  void redepthChildren() {
    visitChildren((RenderObject renderObjectChild) {
      final RenderBox child = renderObjectChild as RenderBox;
      redepthChild(child);
    });
  }

  void visitChildren(RenderObjectVisitor visitor) {
    // Visit the slotted children.
    if (_indicator != null) {
      visitor(_indicator!);
    }
    // Visit the list children.
    super.visitChildren(visitor);
  }
}
