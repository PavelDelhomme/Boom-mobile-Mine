import 'package:boom_mobile/core/constants/app_data.dart';
import 'package:boom_mobile/presentation/screens/accueil/widgets/accueil_slivers.dart';
import 'package:flutter/material.dart';

import '../account/account_bottom_sheet.dart';
import 'controllers/accueil_controller.dart';

class AccueilScreen extends StatefulWidget {
  const AccueilScreen({super.key});

  @override
  State<AccueilScreen> createState() => _AccueilScreenState();
}

class _AccueilScreenState extends State<AccueilScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();
  late AccueilController _controller;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _controller = AccueilController(
      tabController: _tabController,
      searchController: _searchController,
      dossiers: AppData.dossiers,
      accounts: AppData.accounts,
      users: AppData.users,
      alwaysShowSwitch: true,
    );

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _controller.loadData();
    });

    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _showAccountBottomSheet() {
    _searchController.clear();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return AccountBottomSheet(
          accounts: _controller.accounts,
        );
      },
    );
  }

  dynamic _filteredItems() {
    final query = _searchController.text.toLowerCase();
    final index = _controller.tabController.index;

    if (index == 0) {
      // Dossiers
      return AppData.dossiers.where((dossier) =>
          dossier.nom.toLowerCase().contains(query) ||
          dossier.type.toLowerCase().contains(query)
      ).toList();
    } else if (index == 1) {
      // Utilisateurs
      return AppData.users.where((user) =>
      user.name.toLowerCase().contains(query) ||
          user.email.toLowerCase().contains(query) ||
          user.role.toLowerCase().contains(query)
      ).toList();
    } else if (index == 2) {
      // Couches
      return AppData.layers.where((layer) =>
      layer.nom.toLowerCase().contains(query) ||
          layer.type.toLowerCase().contains(query)
      ).toList();
    }
    return [];
  }

  // Méthode manquante - données non filtrées pour les sections horizontales
  dynamic _getAllItems() {
    final index = _controller.tabController.index;

    if (index == 0) return AppData.dossiers;
    if (index == 1) return AppData.users;
    if (index == 2) return AppData.layers;

    return [];
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: SafeArea(
        child: Scaffold(
          body: AccueilSlivers(
            tabController: _tabController,
            searchController: _searchController,
            scrollController: _controller.scrollController,
            showBadgeNotifier: _controller.showBadgeNotifier,
            isTabBarStickyNotifier: _controller.isTabBarStickyNotifier,
            onLocationTap: _showAccountBottomSheet,
            items: _filteredItems(),
            currentIndex: _tabController.index,
            onSearchChanged: () => setState(() {}),
            allItems: _getAllItems(), // ← Correction ici
          ),
        ),
      ),
    );
  }
}