import 'package:flutter/material.dart';

import 'generic_vertical_section.dart';

class GenericFilteredSliver<T> extends StatefulWidget {
  final List<T> items;
  final TextEditingController controller;
  final bool Function(T, String) filter;
  final Widget Function(BuildContext, T) itemBuilder;

  const GenericFilteredSliver({
    super.key,
    required this.items,
    required this.controller,
    required this.filter,
    required this.itemBuilder
  });

  @override
  State<GenericFilteredSliver<T>> createState() => _GenericFilteredSliverState<T>();
}

class _GenericFilteredSliverState<T> extends State<GenericFilteredSliver<T>> {
  late List<T> filtered;

  @override
  void initState() {
    super.initState();
    filtered = widget.items;
    widget.controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final q = widget.controller.text.toLowerCase();
    setState(() {
      filtered = widget.items.where((item) => widget.filter(item, q)).toList();
    });
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onSearchChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GenericVerticalSection<T>(
      items: filtered,
      itemBuilder: widget.itemBuilder,
    );
  }
}