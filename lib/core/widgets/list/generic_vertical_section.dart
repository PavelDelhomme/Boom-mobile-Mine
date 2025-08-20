import 'package:flutter/material.dart';

class GenericVerticalSection<T> extends StatelessWidget {
  final List<T> items;
  final Widget Function(BuildContext context, T item) itemBuilder;
  final double spacing;

  const GenericVerticalSection({
    super.key,
    required this.items,
    required this.itemBuilder,
    this.spacing = 8.0,
  });

  @override
  Widget build(BuildContext context) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: spacing),
              child: itemBuilder(context, items[index]),
            );
          },
        childCount: items.length,
        addAutomaticKeepAlives: true,
        addRepaintBoundaries: true,
      ),
    );
  }
}