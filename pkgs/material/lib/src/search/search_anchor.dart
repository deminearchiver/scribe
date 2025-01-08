import 'package:flutter/material.dart';

class SearchAnchor extends StatefulWidget {
  const SearchAnchor({super.key});

  @override
  State<SearchAnchor> createState() => SearchAnchorState();
}

class SearchAnchorState extends State<SearchAnchor> {
  Future<T?> openView<T extends Object?>() async {
    final navigator = Navigator.of(context);
    navigator.push(_SearchViewRoute());
  }

  void closeView() {}

  @override
  Widget build(BuildContext context) {
    return const Placeholder();
  }
}

class _SearchViewRoute<T> extends PopupRoute<T> {
  _SearchViewRoute({
    super.settings,
    super.requestFocus,
    super.filter,
    super.traversalEdgeBehavior,
  });

  @override
  Color? get barrierColor => null;

  @override
  bool get barrierDismissible => true;

  @override
  String? get barrierLabel => null;

  @override
  Duration get transitionDuration => Durations.long2;

  @override
  Widget buildPage(
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
  ) {
    return const Placeholder();
  }
}
