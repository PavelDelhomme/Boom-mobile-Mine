import 'package:flutter/material.dart';

class CustomPopupMenu extends StatefulWidget {
  final Widget child;
  final List<PopupMenuItem> items;
  final Function(int)? onSelected;

  const CustomPopupMenu({
    super.key,
    required this.child,
    required this.items,
    this.onSelected,
  });

  @override
  State<CustomPopupMenu> createState() => _CustomPopupMenuState();
}


class _CustomPopupMenuState extends State<CustomPopupMenu> {
  OverlayEntry? _overlayEntry;
  final GlobalKey _buttonKey = GlobalKey();
  bool _isMenuOpen = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      key: _buttonKey,
      onTap: () {
        if (_isMenuOpen) {
          _closeMenu();
        } else {
          _openMenu();
        }
      },
      child: widget.child,
    );
  }

  void _openMenu() {
    final RenderBox buttonBox = _buttonKey.currentContext!.findRenderObject() as RenderBox;
    final Offset buttonPosition = buttonBox.localToGlobal(Offset.zero);
    final Size buttonSize = buttonBox.size;

    _overlayEntry = _createOverlayEntry(buttonPosition, buttonSize);
    Overlay.of(context).insert(_overlayEntry!);
    setState(() => _isMenuOpen = true);
  }

  OverlayEntry _createOverlayEntry(Offset buttonPosition, Size buttonSize) {
    return OverlayEntry(
      builder: (context) => Stack(
        children: [
          GestureDetector(
            onTap: _closeMenu,
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              color: Colors.transparent,
            ),
          ),
          _buildMenuWidget(buttonPosition, buttonSize),
        ],
      ),
    );
  }

  Widget _buildMenuWidget(Offset buttonPosition, Size buttonSize) {
    final screenWidth = MediaQuery.of(context).size.width;
    const menuWidth = 160.0;

    double right = screenWidth - (buttonPosition.dx + buttonSize.width);
    double left = buttonPosition.dx + buttonSize.width - menuWidth;

    if (left < 16) {
      right = 16;
    }

    return Positioned(
      right: right,
      top: buttonPosition.dy + buttonSize.height + 8,
      child: Material(
        elevation: 12,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          width: menuWidth,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.90),
                blurRadius: 12,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: widget.items.map((item) => _buildMenuItem(item)).toList(),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildMenuItem(PopupMenuItem item) {
    return InkWell(
      onTap: () {
        _closeMenu();
        if (widget.onSelected != null && item.value != null) {
          widget.onSelected!(item.value);
        }
      },
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        child: item.child,
      ),
    );
  }

  void _closeMenu() {
    _overlayEntry?.remove();
    _overlayEntry = null;

    if (mounted) {
      setState(() => _isMenuOpen = false);
    }
  }

  @override
  void dispose() {
    if (_overlayEntry != null) {
      _overlayEntry?.remove();
      _overlayEntry = null;
    }
    _isMenuOpen = false;
    super.dispose();
  }
}
