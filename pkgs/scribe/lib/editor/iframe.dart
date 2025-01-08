import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/scheduler.dart';
import 'package:flutter/services.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:material/material.dart';
import 'package:services/services.dart';
import 'package:super_editor/super_editor.dart';
import 'package:url_launcher/url_launcher.dart';

import 'dart:math' as math;

const iFrameAttribution = NamedAttribution("iFrame");

class IFrameNode extends BlockNode with ChangeNotifier {
  IFrameNode({required this.id, required Uri uri, super.metadata})
    : _uri = uri {
    putMetadataValue("blockType", iFrameAttribution);
  }

  @override
  final String id;

  Uri _uri;
  Uri get uri => _uri;
  set uri(Uri newValue) {
    if (newValue == _uri) return;
    _uri = newValue;
    notifyListeners();
  }

  @override
  String? copyContent(NodeSelection selection) {
    if (selection is! UpstreamDownstreamNodeSelection) {
      throw Exception(
        "IFrameNode can only copy content from a UpstreamDownstreamNodeSelection.",
      );
    }

    return !selection.isCollapsed ? uri.toString() : null;
  }

  @override
  bool hasEquivalentContent(DocumentNode other) {
    return other is IFrameNode && uri == other.uri;
  }

  @override
  IFrameNode copy() =>
      IFrameNode(id: id, uri: uri, metadata: Map.from(metadata));

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is IFrameNode &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          _uri == other._uri;

  @override
  int get hashCode => Object.hashAll([id, uri]);
}

class IFrameComponentBuilder implements ComponentBuilder {
  @override
  SingleColumnLayoutComponentViewModel? createViewModel(
    Document document,
    DocumentNode node,
  ) {
    if (node is! IFrameNode) return null;
    return IFrameComponentViewModel(nodeId: node.id, uri: node.uri);
  }

  @override
  Widget? createComponent(
    SingleColumnDocumentComponentContext componentContext,
    SingleColumnLayoutComponentViewModel componentViewModel,
  ) {
    if (componentViewModel is! IFrameComponentViewModel) {
      return null;
    }
    return IFrameComponent(
      componentKey: componentContext.componentKey,
      uri: componentViewModel.uri,
      selection:
          componentViewModel.selection?.nodeSelection
              as UpstreamDownstreamNodeSelection?,
      selectionColor: componentViewModel.selectionColor,
    );
  }
}

class IFrameComponentViewModel extends SingleColumnLayoutComponentViewModel
    with SelectionAwareViewModelMixin {
  IFrameComponentViewModel({
    required super.nodeId,
    required this.uri,
    super.maxWidth,
    super.padding = EdgeInsets.zero,
    DocumentNodeSelection? selection,
    Color selectionColor = Colors.transparent,
  }) {
    this.selection = selection;
    this.selectionColor = selectionColor;
  }

  final Uri uri;

  @override
  IFrameComponentViewModel copy() => IFrameComponentViewModel(
    nodeId: nodeId,
    uri: uri,
    maxWidth: maxWidth,
    padding: padding,
    selection: selection,
    selectionColor: selectionColor,
  );

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is IFrameComponentViewModel &&
          runtimeType == other.runtimeType &&
          nodeId == other.nodeId &&
          uri == other.uri &&
          selection == other.selection &&
          selectionColor == other.selectionColor;
  @override
  int get hashCode => Object.hashAll([
    nodeId,
    uri,
    maxWidth,
    padding,
    selection,
    selectionColor,
  ]);
}

class IFrameComponent extends StatefulWidget {
  const IFrameComponent({
    super.key,
    required this.componentKey,
    required this.uri,
    this.selection,
    this.selectionColor = Colors.transparent,
  });

  final GlobalKey componentKey;
  final Uri uri;
  final UpstreamDownstreamNodeSelection? selection;
  final Color selectionColor;

  @override
  State<IFrameComponent> createState() => _IFrameComponentState();
}

class _IFrameComponentState extends State<IFrameComponent> {
  final _webViewContainerKey = GlobalKey();
  final _actionsContainerKey = GlobalKey();

  bool _viewOpen = false;

  // Webview stuff
  final _webViewKey = GlobalKey();
  InAppWebViewController? _webViewController;
  InAppWebViewSettings settings = InAppWebViewSettings(
    // isInspectable: kDebugMode,
    mediaPlaybackRequiresUserGesture: false,
    allowsInlineMediaPlayback: true,
    // iframeAllow: "camera; microphone",
    iframeAllowFullscreen: true,
  );
  String _uri = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  void didUpdateWidget(covariant IFrameComponent oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.uri != oldWidget.uri) {
      _webViewController?.loadUrl(
        urlRequest: URLRequest(url: WebUri.uri(widget.uri)),
      );
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  void _openView() {
    final navigator = Navigator.of(context);
    setState(() => _viewOpen = true);
    navigator.push(
      _IFrameViewRoute(
        webViewContainerKey: _webViewContainerKey,
        actionsContainerKey: _actionsContainerKey,
        webViewKey: _webViewKey,
        webViewBuilder: _buildWebView,
        actionsBuilder: _buildActions,
        onVisibilityChanged: (value) {
          if (mounted) setState(() => _viewOpen = value);
        },
      ),
    );
  }

  void _closeView() {}

  Widget _buildWebView(BuildContext context) {
    return InAppWebView(
      key: _webViewKey,
      initialUrlRequest: URLRequest(url: WebUri.uri(widget.uri)),
      onWebViewCreated: (controller) => _webViewController = controller,
      onLoadStart: (controller, url) {
        setState(() => _uri = url.toString());
      },
      shouldOverrideUrlLoading: (controller, navigationAction) async {
        final uri = navigationAction.request.url!;

        if (!_builtInSchemes.contains(uri.scheme)) {
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri);
            return NavigationActionPolicy.CANCEL;
          }
        }

        return NavigationActionPolicy.ALLOW;
      },
    );
  }

  Widget _buildActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
      child: Column(
        children: [
          IconButton(
            onPressed: () async {
              await showBasicDialog(
                context: context,
                builder:
                    (context) => BasicDialog(
                      title: Text("Edit embed"),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          TextField(
                            keyboardType: TextInputType.url,
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "URL",
                            ),
                          ),
                          const SizedBox(height: 16),
                          TextField(
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              TextInputFormatter.withFunction((
                                oldValue,
                                newValue,
                              ) {
                                if (oldValue.text.isEmpty) {
                                  if (newValue.text.isNotEmpty) {
                                    return newValue.copyWith(
                                      text: "${newValue.text}/",
                                    );
                                  }
                                } else {
                                  final slash = newValue.text.indexOf("/");
                                  if (slash > 0) {
                                    final before = newValue.text[slash - 1];
                                    if (before == " ") {
                                      return newValue.copyWith(
                                        text:
                                            newValue.text.substring(
                                              0,
                                              slash - 1,
                                            ) +
                                            newValue.text.substring(slash),
                                        selection: newValue.selection.copyWith(
                                          baseOffset:
                                              newValue.selection.baseOffset + 1,
                                        ),
                                      );
                                    }
                                  }
                                }
                                return newValue;
                              }),
                            ],
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              labelText: "Aspect ratio",
                            ),
                          ),
                        ],
                      ),

                      actions: [
                        TextButton(onPressed: () {}, label: Text("Cancel")),
                        TextButton(onPressed: () {}, label: Text("OK")),
                      ],
                    ),
              );
            },
            icon: const Icon(Symbols.edit),
          ),
          const Spacer(),
          IconButton(
            onPressed: _openView,
            icon: const Icon(Symbols.open_in_full),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isSelected =
        widget.selection != null && !widget.selection!.isCollapsed;
    return BoxComponent(
      key: widget.componentKey,
      child: DecoratedBox(
        position: DecorationPosition.foreground,
        decoration: BoxDecoration(
          color:
              isSelected
                  ? widget.selectionColor.withValues(alpha: 0.5)
                  : Colors.transparent,
        ),
        child: IntrinsicHeight(
          child: Row(
            children: [
              Expanded(
                child: Material(
                  key: _webViewContainerKey,
                  animationDuration: Duration.zero,
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.all(Radii.extraLarge),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radii.medium),
                      child: AspectRatio(
                        aspectRatio: 16 / 9,
                        child: _buildWebView(context),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Visibility.maintain(
                visible: !_viewOpen,
                child: Material(
                  key: _actionsContainerKey,
                  animationDuration: Duration.zero,
                  borderRadius: BorderRadius.all(Radii.extraLarge),
                  color: theme.colorScheme.surfaceContainerHighest,
                  child: _buildActions(context),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

const Set<String> _builtInSchemes = <String>{
  "http",
  "https",
  "file",
  "chrome",
  "data",
  "javascript",
  "about",
};

class _IFrameViewRoute extends PageRoute {
  _IFrameViewRoute({
    required this.webViewContainerKey,
    required this.actionsContainerKey,
    required this.webViewKey,
    required this.webViewBuilder,
    required this.actionsBuilder,
    this.onVisibilityChanged,
    super.barrierDismissible = true,
    super.fullscreenDialog = true,
    super.requestFocus = true,
    super.settings,
  }) : super(allowSnapshotting: false);
  final GlobalKey webViewContainerKey;
  final GlobalKey actionsContainerKey;
  final GlobalKey webViewKey;
  final WidgetBuilder webViewBuilder;
  final WidgetBuilder actionsBuilder;

  final ValueChanged<bool>? onVisibilityChanged;

  @override
  Color? get barrierColor => Colors.black.withValues(alpha: 0.32);

  @override
  String? get barrierLabel => null;

  @override
  bool get maintainState => true;

  @override
  Duration get transitionDuration => Durations.long4;

  @override
  Duration get reverseTransitionDuration => Durations.medium4;

  void _animationListener() {
    onVisibilityChanged?.call(
      !offstage && animation!.status != AnimationStatus.dismissed,
    );
  }

  @override
  void install() {
    super.install();
    animation?.addListener(_animationListener);
  }

  @override
  TickerFuture didPush() {
    SchedulerBinding.instance.addPostFrameCallback((_) {
      onVisibilityChanged?.call(false);
    });
    return super.didPush();
  }

  @override
  Widget buildTransitions(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    debugPrint("OFF STAGE: ${offstage}");
    if (offstage) return const SizedBox.shrink();
    return child;
  }

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> linearAnimation,
    Animation<double> linearSecondaryAnimation,
  ) {
    // if (_firstRender) {
    //   _firstRender = false;
    //   SchedulerBinding.instance.addPostFrameCallback((_) {
    //     onVisibilityChanged?.call(true);
    //   });
    // }

    final curvedAnimation = CurvedAnimation(
      parent: linearAnimation,
      curve: Easing.emphasized,
      reverseCurve: Easing.emphasized.flipped,
    );

    final navigatorRenderObject =
        navigator!.context.findRenderObject()! as RenderBox;
    final navigatorRect =
        navigatorRenderObject.localToGlobal(Offset.zero) &
        navigatorRenderObject.size;

    final webViewContainerRenderObject =
        webViewContainerKey.currentContext!.findRenderObject()! as RenderBox;
    final webViewContainerRect =
        webViewContainerRenderObject.localToGlobal(
          Offset.zero,
          ancestor: navigatorRenderObject,
        ) &
        webViewContainerRenderObject.size;

    final actionsContainerRenderObject =
        actionsContainerKey.currentContext!.findRenderObject()! as RenderBox;
    final actionsContainerRect =
        actionsContainerRenderObject.localToGlobal(
          Offset.zero,
          ancestor: navigatorRenderObject,
        ) &
        actionsContainerRenderObject.size;

    final webViewContainerRectTween = RectTween(
      begin: webViewContainerRect,
      end: navigatorRect,
    );
    final borderRadiusTween = SwitchTween.fromMap(
      parent: BorderRadiusTween(
        begin: const BorderRadius.all(Radii.extraLarge),
        end: const Services().windowCorners,
      ),
      map: {1.0: BorderRadius.zero},
    );
    final theme = Theme.of(context);
    final colorTween = ColorTween(
      begin: theme.colorScheme.surfaceContainerHighest,
      end: theme.colorScheme.surface,
    );
    final scale =
        math.max(navigatorRect.height, webViewContainerRect.height) /
        math.min(navigatorRect.height, webViewContainerRect.height);

    final offsetTween = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1, 0),
    );

    final paddingTween = EdgeInsetsTween(
      begin: const EdgeInsets.all(16),
      end: EdgeInsets.zero,
    );

    return AnimatedBuilder(
      animation: curvedAnimation,
      builder: (context, child) {
        final rect = webViewContainerRectTween.evaluate(curvedAnimation)!;
        debugPrint("$scale");
        return Stack(
          alignment: Alignment.topLeft,
          children: [
            Positioned.fromRect(
              rect: actionsContainerRect,
              child: FractionalTranslation(
                translation: offsetTween.evaluate(curvedAnimation),
                child: Material(
                  color: theme.colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.all(Radii.extraLarge),
                  child: IgnorePointer(child: actionsBuilder(context)),
                ),
              ),
            ),
            Positioned.fromRect(
              rect: rect,
              child: Row(
                children: [
                  SizedBox(
                    width: rect.width,
                    height: rect.height,
                    child: Material(
                      animationDuration: Duration.zero,
                      clipBehavior: Clip.antiAlias,
                      borderRadius:
                          borderRadiusTween.evaluate(curvedAnimation)!,
                      color: colorTween.evaluate(curvedAnimation)!,
                      child: Padding(
                        padding: paddingTween.evaluate(curvedAnimation),
                        child: Material(
                          animationDuration: Duration.zero,
                          clipBehavior: Clip.antiAlias,
                          color:
                              Color.lerp(
                                theme.colorScheme.surfaceContainer,
                                theme.colorScheme.surface,
                                curvedAnimation.value,
                              )!,
                          borderRadius:
                              BorderRadiusTween(
                                begin: const BorderRadius.all(Radii.medium),
                                end: BorderRadius.zero,
                              ).evaluate(curvedAnimation)!,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              Align(
                                alignment: Alignment.bottomCenter,
                                heightFactor:
                                    lerpDouble(
                                      0.0,
                                      1.0,
                                      curvedAnimation.value,
                                    )!,
                                child: TopAppBar.small(
                                  backgroundColor:
                                      Color.lerp(
                                        theme.colorScheme.surfaceContainer,
                                        theme.colorScheme.surface,
                                        curvedAnimation.value,
                                      )!,
                                  title: Text("Scribe"),
                                  actions: [
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(
                                        Symbols.open_in_browser_rounded,
                                      ),
                                    ),
                                    IconButton(
                                      onPressed: () {},
                                      icon: const Icon(Symbols.more_vert),
                                    ),
                                    const SizedBox(width: 4),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }
}

class _IFrameViewTransition extends StatefulWidget {
  const _IFrameViewTransition({super.key});

  @override
  State<_IFrameViewTransition> createState() => __IFrameViewTransitionState();
}

class __IFrameViewTransitionState extends State<_IFrameViewTransition> {
  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

sealed class SwitchTween<T> extends Animatable<T> {
  const SwitchTween._({required this.parent});

  const factory SwitchTween.fromCallback({
    required Animatable<T> parent,
    required T? Function(double t) callback,
  }) = _CallbackSwitchTween;

  const factory SwitchTween.fromMap({
    required Animatable<T> parent,
    Map<double, T> map,
  }) = _MapSwitchTween;

  final Animatable<T> parent;

  @override
  T transform(double t) {
    return parent.transform(t);
  }
}

class _CallbackSwitchTween<T> extends SwitchTween<T> {
  const _CallbackSwitchTween({required super.parent, required this.callback})
    : super._();

  final T? Function(double t) callback;

  @override
  T transform(double t) {
    final value = callback(t);
    if (value != null) return value;
    return parent.transform(t);
  }
}

class _MapSwitchTween<T> extends SwitchTween<T> {
  const _MapSwitchTween({required super.parent, this.map = const {}})
    : super._();

  final Map<double, T> map;

  @override
  T transform(double t) {
    final value = map[t];
    if (value != null) return value;
    return parent.transform(t);
  }
}
