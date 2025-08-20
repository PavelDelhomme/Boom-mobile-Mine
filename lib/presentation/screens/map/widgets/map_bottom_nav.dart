import 'package:flutter/material.dart';

import '../../../../core/widgets/nav/nav_item.dart';

class MapBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<NavItem> navItems;

  const MapBottomNav({super.key, required this.currentIndex, required this.onTap, required this.navItems});

  @override
  Widget build(BuildContext context) {
    final visible = navItems.where((i) => i.isVisible).toList();

    // ≤5 : BottomNavigationBar classique
    if (visible.length <= 5) {
      return _buildFixedBar(context, visible);
    }
    // >5 : barre scrollable
    return _buildScrollableBar(context, visible);
  }

  Widget _buildFixedBar(BuildContext ctx, List<NavItem> items) {
    final w = MediaQuery.of(ctx).size.width / items.length;
    final markW = w - 38;

    return Container(
      decoration: _decor,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          BottomNavigationBar(
            backgroundColor: Colors.transparent,
            elevation: 0,
            currentIndex: _visibleIndex(currentIndex),
            selectedItemColor: Colors.green,
            unselectedItemColor: Colors.grey,
            showSelectedLabels: true,
            showUnselectedLabels: false,
            type: BottomNavigationBarType.fixed,
            onTap: (i) {
              final real = _realIndex(i);
              if (items[i].isEnabled) onTap(real);
            },
            items: items
                .map((i) => BottomNavigationBarItem(
              icon: _NavIcon(
                  icon: i.icon,
                  assetPath: i.assetPath,
                  useAsset: i.useAsset,
                  selected: false,
                  isEnabled: i.isEnabled),
              activeIcon: _NavIcon(
                  icon: i.icon,
                  assetPath: i.assetPath,
                  useAsset: i.useAsset,
                  selected: true,
                  isEnabled: i.isEnabled),
              label: i.label,
            ))
                .toList(),
          ),
          Positioned(
            top: 0,
            left: w * _visibleIndex(currentIndex) + (w - markW) / 2,
            child: Container(
              width: markW,
              height: 4,
              decoration: BoxDecoration(
                  color: Colors.green, borderRadius: BorderRadius.circular(4)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScrollableBar(BuildContext ctx, List<NavItem> items) {
    return Container(
      height: 64,
      decoration: _decor,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: items.length,
        physics: const BouncingScrollPhysics(),
        itemBuilder: (c, i) {
          final real = _realIndex(i, visible: items);
          final selected = real == currentIndex;
          return GestureDetector(
            onTap: () {
              if (items[i].isEnabled) onTap(real);
            },
            child: Container(
              width: 80,
              alignment: Alignment.center,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _NavIcon(
                    icon: items[i].icon,
                    assetPath: items[i].assetPath,
                    useAsset: items[i].useAsset,
                    selected: selected,
                    isEnabled: items[i].isEnabled,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    items[i].label,
                    style: TextStyle(
                        fontSize: 11,
                        color: selected ? Colors.green : Colors.grey),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  int _realIndex(int visibleIdx, {List<NavItem>? visible}) {
    visible ??= navItems.where((i) => i.isVisible).toList();
    return navItems.indexOf(visible[visibleIdx]);
  }

  int _visibleIndex(int realIdx) {
    int v = 0;
    for (int i = 0; i < realIdx; i++) {
      if (navItems[i].isVisible) v++;
    }
    return navItems[realIdx].isVisible ? v : 0;
  }

  final BoxDecoration _decor = const BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.only(topLeft: Radius.circular(30), topRight: Radius.circular(30)),
    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)],
  );
}


class _NavIcon extends StatelessWidget {
  final IconData? icon;
  final String? assetPath;
  final bool selected;
  final bool useAsset;
  final bool isEnabled;

  const _NavIcon({
    this.icon,
    this.assetPath,
    this.useAsset = false,
    required this.selected,
    this.isEnabled = true,
  });

  @override
  Widget build(BuildContext context) {
    //final Color iconColor = selected ? Colors.green : Colors.grey;

    Color iconColor;

    if (!isEnabled) {
      iconColor = Colors.grey.withValues(alpha: 0.4); // Style désactivé
    } else {
      iconColor = selected ? Colors.green : Colors.grey;
    }

    Widget child;
    if (useAsset && assetPath != null) {
      // Colorisation du PNG
      child = ColorFiltered(
        colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
        child: Image.asset(
          assetPath!,
          width: 24,
          height: 24,
        ),
      );
    } else if (icon != null) {
      child = Icon(icon, color: iconColor);
    } else {
      child = const SizedBox.shrink();
    }

    // Ajouter un overlay si désactivé
    if (!isEnabled) {
      child = Opacity(
        opacity: 0.5,
        child: child,
      );
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [child],
    );
  }
}