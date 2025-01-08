import 'package:material/material.dart';
import 'package:super_editor/super_editor.dart';

class CustomImageComponentBuilder implements ComponentBuilder {
  const CustomImageComponentBuilder();

  @override
  SingleColumnLayoutComponentViewModel? createViewModel(
    Document document,
    DocumentNode node,
  ) {
    if (node is! ImageNode) {
      return null;
    }

    return CustomImageComponentViewModel(
      nodeId: node.id,
      imageUrl: node.imageUrl,
      expectedSize: node.expectedBitmapSize,
      selectionColor: const Color(0x00000000),
    );
  }

  @override
  Widget? createComponent(
    SingleColumnDocumentComponentContext componentContext,
    SingleColumnLayoutComponentViewModel componentViewModel,
  ) {
    if (componentViewModel is! CustomImageComponentViewModel) {
      return null;
    }

    return CustomImageComponent(
      componentKey: componentContext.componentKey,
      imageUrl: componentViewModel.imageUrl,
      expectedSize: componentViewModel.expectedSize,
      selection:
          componentViewModel.selection?.nodeSelection
              as UpstreamDownstreamNodeSelection?,
      selectionColor: componentViewModel.selectionColor,
      borderRadius: componentViewModel.borderRadius,
    );
  }
}

class CustomImageComponentViewModel extends SingleColumnLayoutComponentViewModel
    with SelectionAwareViewModelMixin {
  CustomImageComponentViewModel({
    required super.nodeId,
    super.maxWidth,
    super.padding = EdgeInsets.zero,
    this.borderRadius = BorderRadius.zero,
    required this.imageUrl,
    this.expectedSize,
    DocumentNodeSelection? selection,
    Color selectionColor = Colors.transparent,
  }) {
    this.selection = selection;
    this.selectionColor = selectionColor;
  }

  String imageUrl;
  ExpectedSize? expectedSize;

  BorderRadiusGeometry borderRadius;

  @override
  void applyStyles(Map<String, dynamic> styles) {
    super.applyStyles(styles);
    borderRadius =
        (styles[Styles.borderRadius] as BorderRadiusGeometry?) ??
        BorderRadius.zero;
  }

  @override
  CustomImageComponentViewModel copy() {
    return CustomImageComponentViewModel(
      nodeId: nodeId,
      maxWidth: maxWidth,
      padding: padding,
      imageUrl: imageUrl,
      expectedSize: expectedSize,
      selection: selection,
      selectionColor: selectionColor,
      borderRadius: borderRadius,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is CustomImageComponentViewModel &&
          runtimeType == other.runtimeType &&
          nodeId == other.nodeId &&
          imageUrl == other.imageUrl &&
          selection == other.selection &&
          selectionColor == other.selectionColor &&
          borderRadius == other.borderRadius;
  @override
  int get hashCode =>
      super.hashCode ^
      nodeId.hashCode ^
      imageUrl.hashCode ^
      selection.hashCode ^
      selectionColor.hashCode ^
      borderRadius.hashCode;
}

/// Displays an image in a document.
class CustomImageComponent extends StatelessWidget {
  const CustomImageComponent({
    Key? key,
    required this.componentKey,
    required this.imageUrl,
    this.expectedSize,
    this.selectionColor = Colors.blue,
    this.selection,
    this.imageBuilder,
    this.borderRadius = BorderRadius.zero,
  }) : super(key: key);

  final GlobalKey componentKey;
  final String imageUrl;
  final ExpectedSize? expectedSize;
  final Color selectionColor;
  final UpstreamDownstreamNodeSelection? selection;
  final BorderRadiusGeometry borderRadius;

  /// Called to obtain the inner image for the given [imageUrl].
  ///
  /// This builder is used in tests to 'mock' an [Image], avoiding accessing the network.
  ///
  /// If [imageBuilder] is `null` an [Image] is used.
  final Widget Function(BuildContext context, String imageUrl)? imageBuilder;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      cursor: SystemMouseCursors.basic,
      hitTestBehavior: HitTestBehavior.translucent,
      child: IgnorePointer(
        child: Center(
          child: SelectableBox(
            selection: selection,
            selectionColor: selectionColor,
            child: BoxComponent(
              key: componentKey,
              child: ClipRRect(
                borderRadius: borderRadius,
                child:
                    imageBuilder != null
                        ? imageBuilder!(context, imageUrl)
                        : Image.network(
                          imageUrl,
                          fit: BoxFit.contain,
                          frameBuilder: (
                            context,
                            child,
                            frame,
                            wasSynchronouslyLoaded,
                          ) {
                            if (frame != null) {
                              // The image is already loaded. Use the image as is.
                              return child;
                            }

                            if (expectedSize != null &&
                                expectedSize!.width != null &&
                                expectedSize!.height != null) {
                              // Both width and height were provide.
                              // Preserve the aspect ratio of the original image.
                              return AspectRatio(
                                aspectRatio: expectedSize!.aspectRatio,
                                child: SizedBox(
                                  width: expectedSize!.width!.toDouble(),
                                  height: expectedSize!.height!.toDouble(),
                                ),
                              );
                            }

                            // The image is still loading and only one dimension was provided.
                            // Use the given dimension.
                            return SizedBox(
                              width: expectedSize?.width?.toDouble(),
                              height: expectedSize?.height?.toDouble(),
                            );
                          },
                        ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
