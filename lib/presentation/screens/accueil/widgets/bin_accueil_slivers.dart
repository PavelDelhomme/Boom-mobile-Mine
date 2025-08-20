/*
import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/core/widgets/list/generic_horizontal_section.dart';
import 'package:boom_mobile/core/widgets/search/search_bar.dart';
import 'package:boom_mobile/presentation/screens/accueil/widgets/slivers/sticky_header_delegate.dart';
import 'package:boom_mobile/presentation/screens/accueil/widgets/sticky/sticky_top_bar.dart';
import 'package:boom_mobile/presentation/screens/accueil/widgets/welcome_banner.dart';
import 'package:boom_mobile/presentation/screens/layers/layers_vertical_list_item.dart';
import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/widgets/bars/boom_tab_bar_header.dart';
import '../../../../core/widgets/buttons/dossier_switch_banner.dart';
import '../../../../core/widgets/cards/generic_horizontal_card_item.dart';
import '../../../../core/widgets/list/generic_filtered_sliver.dart';
import '../../../../domain/entities/dossier.dart';
import '../../../../domain/entities/layer.dart';
import '../../../../domain/entities/user.dart';
import '../../dossiers/dossiers_list/dossiers_vertical_list_item.dart';
import '../../map/map_screen.dart';
import '../../users/users_list/users_vertical_list_item.dart';


enum AccueilSliverSection {
  topBar,
  welcomeBanner,
  switchBanner,
  tabBar,
  horizontalList,
  searchBar,
  spacer,
  verticalList,
}

class AccueilSlivers extends StatefulWidget {
  final TabController tabController;
  final TextEditingController searchController;
  final ValueNotifier<bool> showBadgeNotifier;
  final VoidCallback onLocationTap;
  final ScrollController scrollController;
  final VoidCallback onSearchChanged;
  final List<dynamic> items; // Filtrés
  final List<dynamic> allItems; // Originaux
  final int currentIndex;
  final ValueNotifier<bool> isTabBarStickyNotifier;

  const AccueilSlivers({
    super.key,
    required this.tabController,
    required this.searchController,
    required this.scrollController,
    required this.showBadgeNotifier,
    required this.onLocationTap,
    required this.onSearchChanged,
    required this.items,
    required this.allItems,
    required this.currentIndex,
    required this.isTabBarStickyNotifier
  });

  @override
  State<AccueilSlivers> createState() => _AccueilSliversState();
}

class _AccueilSliversState extends State<AccueilSlivers> {
  final List<AccueilSliverSection> _order = [
    AccueilSliverSection.topBar,
    AccueilSliverSection.welcomeBanner,
    AccueilSliverSection.switchBanner,
    AccueilSliverSection.tabBar,
    AccueilSliverSection.horizontalList,
    AccueilSliverSection.searchBar,
    AccueilSliverSection.spacer,
    AccueilSliverSection.verticalList,
  ];


  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: _order.map(_buildSliver).toList(),
    );
  }


  Widget _buildSliver(AccueilSliverSection s) {
    switch (s) {
      case AccueilSliverSection.topBar:
        return _sliverPersistent(child: StickyTopBar(
          onLocationTap: widget.onLocationTap,
          showBadgeNotifier: widget.showBadgeNotifier,
          isTabBarStickyNotifier: widget.isTabBarStickyNotifier,
        ), height: kAppTopBarHeight);
      case AccueilSliverSection.welcomeBanner:
        return SliverToBoxAdapter(child: WelcomeBanner(
          userName: "Emmanuel",
          userRole: "Administrateur",
          imageUrl: kBienvenueImage,
        ));
      case AccueilSliverSection.switchBanner:
        return SliverToBoxAdapter(child: ValueListenableBuilder<bool>(
          valueListenable: widget.isTabBarStickyNotifier,
          builder: (_, isSticky, __) {
            if (isSticky) return const SizedBox.shrink();
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text(
                    "Vous travaillez actuellement sur ",
                    style: TextStyle(color: AppColors.primaryGreen, fontWeight: FontWeight.w500),
                  ),
                  const SizedBox(height: 8),
                  DossierSwitchBanner(
                    label: "Rennes Métropole",
                    onSwitchTap: widget.onLocationTap,
                  ),
                ],
              ),
            );
          },
        ));
      case AccueilSliverSection.tabBar:
        return _sliverPersistent(child: BoomTabHeader(
          currentIndex: widget.tabController.index,
          labels: const ["Dossiers", "Utilisateurs", "Couches"],
          onTap: (i) => setState(() => widget.tabController.index = i),
          onChanged: (i) => setState(() => widget.tabController.index = i),
        ), height: kTabBarHeight);
      case AccueilSliverSection.horizontalList:
        return SliverToBoxAdapter(child: _buildList(isHorizontal: true));
      case AccueilSliverSection.searchBar:
        return _sliverPersistent(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: ReusableSearchBar(
              controller: widget.searchController,
              placeholder: _getPlaceholder(),
              showTrailing: true,
              onTrailingPressed: _handleAddItem,
              onChanged: (_) => widget.onSearchChanged(),
            ),
          ),
          height: kSearchBarHeight,
        );
      case AccueilSliverSection.spacer:
        return const SliverToBoxAdapter(child: SizedBox(height: 12));
      case AccueilSliverSection.verticalList:
        return _buildList(isHorizontal: false);
    }
  }

  SliverPersistentHeader _sliverPersistent({required Widget child, required double height}) {
    return SliverPersistentHeader(
      pinned: true,
      delegate: StickyHeaderDelegate(child: child, height: height),
    );
  }

  String _getPlaceholder() {
    final i = widget.tabController.index;
    return i == 0
        ? "Rechercher un dossier"
        : i == 1
          ? "Rechercher un utilisateur"
          : "Rechercher une couche";
  }


  Widget _buildList({required bool isHorizontal}) {
    final i = widget.currentIndex;
    if (i == 0) return isHorizontal ? _horizontalDossiers() : _verticalDossiers();
    if (i == 1) return isHorizontal ? _horizontalUsers() : _verticalUsers();
    return isHorizontal ? _horizontalLayers() : _verticalLayers();
  }


  Widget _horizontalDossiers() => GenericHorizontalSection<Dossier>(
    title: "Derniers dossiers",
    items: widget.allItems.cast<Dossier>(),
    itemBuilder: (d) => GenericHorizontalCardItem(
      title: d.nom, subtitle: d.type, date: d.date, imageUrl: kDossierImage,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MapScreen(dossier: d))),
      badge: _badge("${d.stations.length}"),
    ),
  );

  Widget _verticalDossiers() => GenericFilteredSliver<Dossier>(
    controller: widget.searchController,
    items: widget.items.cast<Dossier>(),
    filter: (d, q) => d.nom.toLowerCase().contains(q) || d.type.toLowerCase().contains(q),
    itemBuilder: (c, d) => DossiersVerticalListItem(
      name: d.nom, type: d.type,
      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => MapScreen(dossier: d))),
      onOptionsTap: () {},
    ),
  );

  Widget _horizontalUsers() => GenericHorizontalSection<User>(
    title: "Équipe active",
    items: widget.allItems.cast<User>().take(6).toList(),
    itemBuilder: (u) => GenericHorizontalCardItem(
      borderRadius: BorderRadius.circular(16),
      title: u.name, subtitle: u.role, date: u.date, imageUrl: kAvatar,
      onTap: () => _showUserDetails(u), imageBorderRadius: 8,
    ),
  );

  Widget _verticalUsers() => GenericFilteredSliver<User>(
    controller: widget.searchController,
    items: widget.items.cast<User>(),
    filter: (u, q) => u.name.toLowerCase().contains(q) || u.email.toLowerCase().contains(q) || u.role.toLowerCase().contains(q),
    itemBuilder: (c, u) => UsersVerticalListItem(
      name: u.name, email: u.email, role: u.role,
      onTap: () => _showUserDetails(u), onOptionsTap: () => _showUserOptions(u),
    ),
  );

  Widget _horizontalLayers() => GenericHorizontalSection<Layer>(
    title: "Couches disponibles",
    items: widget.allItems.cast<Layer>().take(6).toList(),
    itemBuilder: (l) => GenericHorizontalCardItem(
      title: l.nom, subtitle: l.type, date: l.date,
      onTap: () => _showLayerDetails(l),
      badge: _layerBadge(l),
    ),
  );

  Widget _verticalLayers() => GenericFilteredSliver<Layer>(
    controller: widget.searchController,
    items: widget.items.cast<Layer>(),
    filter: (l, q) => l.nom.toLowerCase().contains(q) || l.type.toLowerCase().contains(q),
    itemBuilder: (c, l) => LayersVerticalListItem(
      name: l.nom, type: l.type, date: l.date,
      onTap: () => _showLayerDetails(l),
      onOptionsTap: () => _showLayerOptions(l),
    ),
  );

  Widget _badge(String text) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.orange, borderRadius: BorderRadius.circular(9),
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
  );

  Widget _layerBadge(Layer l) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
    decoration: BoxDecoration(
      color: AppColors.primaryGreen, borderRadius: BorderRadius.circular(9),
      border: Border.all(color: Colors.white, width: 2),
    ),
    child: const Icon(Icons.layers, color: Colors.white, size: 12),
  );

  /*
  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: widget.scrollController,
      physics: const BouncingScrollPhysics(),
      slivers: [
        // Top bar
        /*SliverPersistentHeader(
          pinned: true,
          delegate: StickyHeaderDelegate(
            child: StickyTopBar(
              onLocationTap: widget.onLocationTap,
              showBadgeNotifier: widget.showBadgeNotifier,
              isTabBarStickyNotifier: widget.isTabBarStickyNotifier,
            ),
            height: kAppTopBarHeight,
          ),
        ),*/

        /*
        // Banner de bienvenue
        SliverToBoxAdapter(
          child: WelcomeBanner(
            userName: "Emmanuel",
            userRole: "Administrateur",
            imageUrl: kBienvenueImage,
          ),
        ),
         */

        /*
        // Banner de switch
        SliverToBoxAdapter(
          child: ValueListenableBuilder<bool>(
            valueListenable: widget.isTabBarStickyNotifier,
            builder: (context, isSticky, _) {
              if (isSticky) return const SizedBox.shrink();
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    const Text(
                      "Vous travaillez actuellement sur ",
                      style: TextStyle(
                        color: AppColors.primaryGreen,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 8),
                    DossierSwitchBanner(
                      label: "Rennes Métropole",
                      onSwitchTap: widget.onLocationTap,
                    ),
                  ],
                ),
              );
            },
          ),
        ),
        */

        // Tab bar - SANS DELAY


        // Section horizontale - SANS DELAY
        SliverToBoxAdapter(
          child: _buildSectionWidget(isHorizontal: true),
        ),

        // Bar de recherche - SANS DELAY
        SliverPersistentHeader(
          pinned: true,
          delegate: StickyHeaderDelegate(
            child: StickySearchBar(
              controller: widget.searchController,
              placeholder: _getSearchPlaceholder(),
              onAddPressed: () => _handleAddItem(),
              onChanged: (_) => widget.onSearchChanged(),
            ),
            height: kSearchBarHeight + kStickyExtraSpace,
          ),
        ),

        // Espace
        const SliverToBoxAdapter(child: SizedBox(height: 12)),

        // Liste verticale - SANS DELAY
        _buildSectionWidget(isHorizontal: false),
      ],
    );
  }*/


  void _handleAddItem() {
    final i = widget.tabController.index;
    if (i == 0) {
      // TODO: Ajouter un dossier
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajouter un dossier - À implémenter')),
      );
    } else if (i == 1) {
      // TODO: Ajouter un utilisateur
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajouter un utilisateur - À implémenter')),
      );
    } else if (i == 2) {
      // TODO: Ajouter une couche
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ajouter une couche - À implémenter')),
      );
    }
  }

  Widget _buildOrangeBadge(String content) {
    return Container(
        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
        decoration: BoxDecoration(
          color: AppColors.orange,
          borderRadius: BorderRadius.circular(9),
          border: Border.all(color: Colors.white, width: 2),
        ),
        child: Text(
          content,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
        )
    );
  }

  Widget _buildSectionWidget({required bool isHorizontal}) {
    if (widget.currentIndex == 0) {
      // DOSSIERS
      return isHorizontal
          ? GenericHorizontalSection(
        title: "Derniers dossiers",
        itemBuilder: (dossier) => GenericHorizontalCardItem(
          title: dossier.nom,
          subtitle: dossier.type,
          date: dossier.date,
          imageUrl: kDossierImage,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MapScreen(dossier: dossier)),
            );
          },
          badge: _buildOrangeBadge("${dossier.stations.length}"),
        ),
        items: widget.allItems.cast<Dossier>(),
      ) : GenericFilteredSliver<Dossier>(
        controller: widget.searchController,
        items: widget.items.cast<Dossier>(),
        filter: (d, q) => d.nom.toLowerCase().contains(q) || d.type.toLowerCase().contains(q),
        itemBuilder: (context, dossier) => DossiersVerticalListItem(
          name: dossier.nom,
          type: dossier.type,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => MapScreen(dossier: dossier)),
            );
          },
          onOptionsTap: () {
            // TODO: menu options
          },
        ),
      );
    }

    if (widget.currentIndex == 1) {
      // UTILISATEURS
      return isHorizontal
          ? GenericHorizontalSection<User>(
        title: "Équipe active",
        items: widget.allItems.cast<User>().take(6).toList(),
        itemBuilder: (user) => GenericHorizontalCardItem(
          borderRadius: BorderRadius.circular(16),
          title: user.name,
          subtitle: user.role,
          date: user.date,
          imageUrl: kAvatar,
          onTap: () => _showUserDetails(user),
          imageBorderRadius: 8,
        ),
      ) : GenericFilteredSliver<User>(
        controller: widget.searchController,
        items: widget.items.cast<User>(),
        filter: (user, q) => user.name.toLowerCase().contains(q) ||
            user.email.toLowerCase().contains(q) ||
            user.role.toLowerCase().contains(q),
        itemBuilder: (context, user) => UsersVerticalListItem(
          name: user.name,
          email: user.email,
          role: user.role,
          onTap: () => _showUserDetails(user),
          onOptionsTap: () => _showUserOptions(user),
        ),
      );
    }

    if (widget.currentIndex == 2) {
      // COUCHES
      return isHorizontal
          ? GenericHorizontalSection<Layer>(
        title: "Couches disponibles",
        items: widget.allItems.cast<Layer>().take(6).toList(),
        itemBuilder: (layer) => GenericHorizontalCardItem(
          title: layer.nom,
          subtitle: layer.type,
          date: layer.date,
          imageUrl: null,
          onTap: () => _showLayerDetails(layer),
          badge: _buildLayerStatusBadge(layer),
        ),
      ) : GenericFilteredSliver<Layer>(
        controller: widget.searchController,
        items: widget.items.cast<Layer>(),
        filter: (layer, q) => layer.nom.toLowerCase().contains(q) ||
            layer.type.toLowerCase().contains(q),
        itemBuilder: (context, layer) => LayersVerticalListItem(
          name: layer.nom,
          type: layer.type,
          date: layer.date,
          onTap: () => _showLayerDetails(layer),
          onOptionsTap: () => _showLayerOptions(layer),
        ),
      );
    }

    return const SliverToBoxAdapter(child: SizedBox());
  }

  Widget _buildLayerStatusBadge(Layer layer) {
    // Badge selon le statut de la couche
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen,
        borderRadius: BorderRadius.circular(9),
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: const Icon(
        Icons.layers,
        color: Colors.white,
        size: 12,
      ),
    );
  }

  void _showUserDetails(User user) {
    // TODO: Navigation vers détail utilisateur
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(user.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Rôle: ${user.role}'),
            Text('Email: ${user.email}'),
            Text('Statut: ${user.date}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showUserOptions(User user) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.edit),
              title: const Text('Modifier'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Éditer utilisateur
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_off),
              title: const Text('Désactiver'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Désactiver utilisateur
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showLayerDetails(Layer layer) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(layer.nom),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Type: ${layer.type}'),
            Text('Dernière mise à jour: ${layer.date}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Fermer'),
          ),
        ],
      ),
    );
  }

  void _showLayerOptions(Layer layer) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.visibility),
              title: const Text('Activer/Désactiver'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Toggle visibilité couche
              },
            ),
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Configurer'),
              onTap: () {
                Navigator.pop(context);
                // TODO: Configurer couche
              },
            ),
          ],
        ),
      ),
    );
  }
}

*/

