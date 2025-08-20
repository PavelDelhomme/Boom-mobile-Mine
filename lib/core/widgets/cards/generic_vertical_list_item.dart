import 'package:flutter/material.dart';

class GenericVerticalListItem extends StatelessWidget {
  final Widget leading;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final VoidCallback onOptionsTap;
  final List<PopupMenuEntry> Function()? buildOptions;

  const GenericVerticalListItem({
    super.key,
    required this.leading,
    required this.title,
    required this.subtitle,
    required this.onTap,
    required this.onOptionsTap,
    this.buildOptions,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: leading,
      title: Text(title, style: Theme.of(context).textTheme.titleMedium),
      subtitle: Text(subtitle),
      onTap: onTap,
      trailing: IconButton(
        icon: const Icon(Icons.more_vert),
        onPressed: () => _showPopupMenu(context),
      ),
    );
  }

  void _showPopupMenu(BuildContext context) {
    final renderBox = context.findRenderObject() as RenderBox;
    final overlay = Overlay.of(context).context.findRenderObject() as RenderBox;
    final size = renderBox.size;
    final offset = renderBox.localToGlobal(Offset.zero, ancestor: overlay);
    final position = RelativeRect.fromLTRB(
        offset.dx + size.width - 100, offset.dy, offset.dx + size.width, 0);

    showMenu(
      context: context,
      position: position,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      items: buildOptions?.call() ??
          [
            PopupMenuItem(onTap: onOptionsTap, child: const Text('Modifier')),
            PopupMenuItem(onTap: onOptionsTap, child: const Text('Supprimer')),
          ],
    );
  }
}