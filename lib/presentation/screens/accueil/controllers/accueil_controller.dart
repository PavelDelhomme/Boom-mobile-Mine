import 'package:boom_mobile/domain/entities/user.dart';
import 'package:flutter/material.dart';

import 'package:boom_mobile/domain/entities/account.dart';
import 'package:boom_mobile/domain/entities/dossier.dart';


class AccueilController {
  final TabController tabController;
  final TextEditingController searchController;
  final ScrollController scrollController = ScrollController();
  final ValueNotifier<bool> showBadgeNotifier = ValueNotifier(false);
  final ValueNotifier<bool> isTabBarStickyNotifier = ValueNotifier(false);
  final bool alwaysShowSwitch;
  final List<Dossier> dossiers;
  final List<Account> accounts;
  final List<User> users;
  final bool showWorkingBanner;
  GlobalKey? workingKey;


  AccueilController({
    required this.tabController,
    required this.searchController,
    required this.dossiers,
    required this.accounts,
    required this.users,
    this.showWorkingBanner = false,
    this.alwaysShowSwitch = false,
  }) {
    scrollController.addListener(_onScroll);

    WidgetsBinding.instance.addPostFrameCallback((_) => _onScroll());
  }

  Future<void> loadData() async {
    await Future.delayed(const Duration(milliseconds: 500));
    // todo : rafraîchir les données, puis appeler notifyListeners() si tu fais de ce controller un ChangeNotifier ou setState(side widget)
  }

  void _onScroll() {
    if (showWorkingBanner && !alwaysShowSwitch && workingKey != null) {
      final box = workingKey!.currentContext?.findRenderObject() as RenderBox?;
      final dy = box?.localToGlobal(Offset.zero).dy ?? 1000;
      showBadgeNotifier.value = dy <= kToolbarHeight;
    } else {
      showBadgeNotifier.value = false;
    }
    isTabBarStickyNotifier.value = scrollController.offset >= 170;
  }

  void dispose() {
    scrollController.dispose();
    searchController.dispose();
    tabController.dispose();
  }
}