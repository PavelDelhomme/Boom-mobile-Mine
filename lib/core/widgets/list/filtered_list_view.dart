import 'package:flutter/material.dart';
import 'package:boom_mobile/core/widgets/search/search_bar.dart';

typedef ItemBuilder<T> = Widget Function(BuildContext context, T item);
typedef Filter<T> = bool Function(T item, String query);

class FilteredListView<T> extends StatefulWidget {
  final List<T> items;
  final ItemBuilder<T> itemBuilder;
  final Filter<T> filter;
  final String placeholder;
  final bool showTrailing;
  final VoidCallback? onTrailingPressed;

  const FilteredListView({
    super.key,
    required this.items,
    required this.itemBuilder,
    required this.filter,
    this.placeholder = 'Rechercher',
    this.showTrailing = false,
    this.onTrailingPressed,
  });

  @override
  State<FilteredListView<T>> createState() => _FilteredListViewState<T>();
}

class _FilteredListViewState<T> extends State<FilteredListView<T>> {
  final TextEditingController _controller = TextEditingController();
  late List<T> _filtered;

  @override
  void initState() {
    super.initState();
    _filtered = widget.items;
    _controller.addListener(_onSearchChanged);
  }

  void _onSearchChanged() {
    final query = _controller.text.toLowerCase();
    setState(() {
      _filtered = widget.items.where((item) => widget.filter(item, query)).toList();
    });
  }

  @override
  void dispose() {
    _controller.removeListener(_onSearchChanged);
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ReusableSearchBar(
          controller: _controller,
          placeholder: widget.placeholder,
          showTrailing: widget.showTrailing,
          onTrailingPressed: widget.onTrailingPressed,
        ),
        const SizedBox(height: 2),
        Divider(),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: _filtered.length,
            itemBuilder: (context, index) => Padding(
              padding: EdgeInsets.only(bottom: 8),
              child: widget.itemBuilder(context, _filtered[index]),
            ),
          ),
        ),
      ],
    );
  }
}
