// import 'package:boom_mobile/presentation/widgets/app_tab_bar.dart';
// import 'package:boom_mobile/presentation/widgets/app_top_bar.dart';
// import 'package:flutter/material.dart';
// import '../../../core/theme/app_colors.dart';
// import '../../../core/theme/app_text_styles.dart';
// import '../../widgets/app_button.dart';
// import 'widgets/dossier_card.dart';
// import 'widgets/dossier_list_item.dart';
// import 'widgets/welcome_banner.dart';
// import 'package:boom_mobile/presentation/widgets/search_bar.dart' as custom;
// import 'package:flutter_sticky_header/flutter_sticky_header.dart';

// class AccueilScreen extends StatefulWidget {
//   const AccueilScreen({Key? key}) : super(key: key);

//   @override
//   State<AccueilScreen> createState() => _AccueilScreenState();
// }

// class _AccueilScreenState extends State<AccueilScreen> with SingleTickerProviderStateMixin {
//   late TabController _tabController;
//   final TextEditingController _searchController = TextEditingController();
//   final ScrollController _scrollController = ScrollController();
//   //bool _showStickyHeader = false;
  
//   // Données statiques pour la démo de l'interface
//   final List<Map<String, String>> _dossiers = [
//     {'nom': 'Vertou - Stade Raymond Durand', 'type': 'En attente de Sauvegarde', 'date': '14/03/2025'},
//     {'nom': 'Thorigné Fouillard', 'type': 'En attente de Sauvegarde', 'date': '14/03/2025'},
//     {'nom': 'Thorigné Fouillard', 'type': 'En attente de Sauvegarde', 'date': '14/03/2025'},
//     {'nom': 'Cesson', 'type': 'En attente de Sauvegarde', 'date': '10/03/2025'},
//     {'nom': 'Cesson', 'type': 'En attente de Sauvegarde', 'date': '10/03/2025'},
//     {'nom': 'Cesson', 'type': 'En attente de Sauvegarde', 'date': '10/03/2025'},
//     {'nom': 'Cesson', 'type': 'En attente de Sauvegarde', 'date': '10/03/2025'},
//     {'nom': 'Cesson', 'type': 'En attente de Sauvegarde', 'date': '10/03/2025'},
//     {'nom': 'Cesson', 'type': 'En attente de Sauvegarde', 'date': '10/03/2025'},
//     {'nom': 'Cesson', 'type': 'En attente de Sauvegarde', 'date': '10/03/2025'},
//     {'nom': 'Cesson', 'type': 'En attente de Sauvegarde', 'date': '10/03/2025'},

//   ];

//   @override
//   void initState() {
//     super.initState();
//     _tabController = TabController(length: 6, vsync: this);
//     _scrollController.addListener(() {
//       setState(() {});
//     });
//     //_scrollController.addListener(_handleScroll);
//   }


//   @override
//   void dispose() {
//     _tabController.dispose();
//     _searchController.dispose();
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _showOptions(int index) {
//     showModalBottomSheet(
//       context: context,
//       builder: (context) {
//         return Container(
//             decoration: BoxDecoration(
//               color: AppColors.ligthGreenSearchBar.withOpacity(0.2),
//               borderRadius: BorderRadius.only(
//                 topLeft: Radius.circular(15),
//                 topRight: Radius.circular(15),
//               ),
//             ),
//             child: Column(
//               mainAxisSize: MainAxisSize.min,
//               children: [
//                 ListTile(
//                   title: Text(
//                     'Modifier',
//                     style: TextStyle(color: Colors.black),
//                   ),
//                   onTap: () => Navigator.pop(context),
//                 ),
//                 ListTile(
//                   title: Text(
//                     'Supprimer',
//                     style: TextStyle(color: Colors.black),
//                   ),
//                   onTap: () => Navigator.pop(context),
//                 ),
//               ],
//             ),
//         );
//       },
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: CustomScrollView(
//         controller: _scrollController,
//         slivers: [
//           // Entête fixe logo + user
//           SliverAppBar(
//             pinned: true,
//             expandedHeight: 200,
//             flexibleSpace: FlexibleSpaceBar(
//               collapseMode: CollapseMode.pin,
//               background: Column(
//                 children: [
//                   AppTopBar(
//                     showLocationBadge: false,
//                     onLocationTap: () {},
//                     ),
//                     const WelcomeBanner(
//                       userName: "Emmanuel",
//                       userRole: "Administrateur",
//                     ),
//                 ],
//               ),
//             ),
//           ),
//           // SliverStickyHeader(
//           //   sticky: true,
//           //   header: AppTopBar(
//           //     showLocationBadge: false,
//           //     onLocationTap: () {},
//           //   ),
//           // ),

//           // Sticky Tab Bar (Onglets)
//           SilverPersistentHeader(
//             pinned: true,
//             delegate: _StickyTabBarDelegate(
//               child: AppTabBar(
//                 currentIndex: _tabController.index,
//                 onTap: (index) => _tabController.animateTo(index),
//               ),
//             ),
//           ),

//           // Contenu principal
//           SilverList(
//             delegate: SilverChildBuilderDelegate(
//               (context, index) => _buildContent(),
//               childCount: 1,
//             ),
//           ),
//         ],
//       ),
//     );
//   }


//   Widget _buildCustomTabBar() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.start,
//       children: [
//         _buildTabItem('Dossier', 0),
//         SizedBox(width: 24),
//         _buildTabItem('Utilisateurs', 1),
//         SizedBox(width: 28),
//         _buildTabItem('Couches', 2),
//         SizedBox(width: 28),
//         _buildTabItem('Couches', 3),
//         SizedBox(width: 28),
//         _buildTabItem('Couches', 4),
//         SizedBox(width: 28),
//         _buildTabItem('Couches', 5),
//       ],
//     );
//   }

//   Widget _buildTabItem(String title, int index) {
//     final isSelected = _tabController.index == index;

//     return GestureDetector(
//       onTap: () => _tabController.animateTo(index),
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
//         decoration: BoxDecoration(
//           color: isSelected
//               ? AppColors.ligthGreenSearchBar
//               : null,
//           borderRadius: BorderRadius.circular(33),
//         ),
//         child: Text(
//           title,
//           style: TextStyle(
//             color:
//                 isSelected ? Colors.white : Color(0xFFB7B7B7), // Texte blanc pour actif
//             fontSize: 14,
//             fontFamily: 'Inter',
//             fontWeight:
//                 isSelected ? FontWeight.w700 : FontWeight.w400, // Gras si actif
//           ),
//         ),
//       ),
//     );
//   }


//   // Onglet Dossiers
//   Widget _buildDossiersTab() {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.only(top: 12.0, left: 16.0, right: 16.0), // Uniformisation des marges
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             // Barre de recherche
//             Padding(
//               padding: const EdgeInsets.only(right: 12.0), // Alignement avec le titre
//               child: custom.SearchBar(
//                 controller: _searchController,
//                 onAddPressed: () {},
//                 onChanged: (value) {},
//               ),
//             ),

//             // Liste verticale des dossiers
//             ListView.separated(
//               physics: NeverScrollableScrollPhysics(),
//               shrinkWrap: true,
//               itemCount: _dossiers.length,
//               separatorBuilder: (context, index) => SizedBox(height: 12),
//               itemBuilder: (context, index) {
//                 return DossierListItem(
//                   key: ValueKey(_dossiers[index]['nom']),
//                   name: _dossiers[index]['nom']!,
//                   type: _dossiers[index]['type']!,
//                   onTap: () {},
//                   onOptionsTap: () => _showOptions(index),
//                 );
//               },
//             ),
//           ],
//         ),
//       ),
//     );
//   }

//   // Onglet Utilisateurs (structure similaire)
//   Widget _buildUtilisateursTab() {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.only(top: 12.0, left: 16.0, right: 16.0), // Uniformisation des marges
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Contenu Utilisateurs', style: AppTextStyles.sectionTitle),
//             SizedBox(height: 200),
//             Text('Cette section est en cours de développement', 
//                 style: TextStyle(color: AppColors.textGrey)),
//           ],
//         ),
//       ),
//     );
//   }

//   // Onglet Couches (structure similaire)
//   Widget _buildCouchesTab() {
//     return SingleChildScrollView(
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text('Contenu Couches', style: AppTextStyles.sectionTitle),
//             SizedBox(height: 200),
//             Text('Cette section est en cours de développement', 
//                 style: TextStyle(color: AppColors.textGrey)),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildLocationBadge() {
//     return GestureDetector(
//       onTap: () {/* Gérer le changement de ville */},
//       child: Container(
//         padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
//         decoration: BoxDecoration(
//         color: AppColors.primaryGreen,
//         borderRadius: BorderRadius.circular(15),
//         boxShadow: const [
//             BoxShadow(
//               color: Color(0xFFC5FFE6),
//               blurRadius: 4,
//               offset: Offset(0, 2),
//             )
//           ],
//         ),
//         child: Row(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             const Text(
//               'Rennes Métropole',
//               style: TextStyle(
//                 color: Colors.white,
//                 fontSize: 10,
//                 fontFamily: 'Inter',
//                 //fontWeight: FontWeight.w400,
//               ),
//             ),
//             const SizedBox(width: 8),
//             Image.asset('assets/images/switch_02.png', width: 16, height: 16),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildContent() {
//     return Padding(
//       padding: const EdgeInsets.only(top: 16), // Marge entre Dossiers et les onglet
//       child: Padding(
//         padding: const EdgeInsets.symmetric(horizontal: 16), // Marge
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//                     Text(
//                           'Derniers dossiers',
//                           style: AppTextStyles.sectionTitle,
//                     ),
//                     const SizedBox(height: 8), // Espacement entre le titre et la liste horizontale

//                     // Liste Horizontal des cartes
//                     SizedBox(
//                       height: 170,
//                       child: ListView.separated(
//                         scrollDirection: Axis.horizontal,
//                         //padding: EdgeInsets.zero, // Pas de marge supplémentaire
//                         itemCount: _dossiers.length,
//                         separatorBuilder: (context, index) => const SizedBox(width: 16),
//                         itemBuilder: (context, index) {
//                           return DossierCard(
//                             title: _dossiers[index]['nom']!,
//                             status: _dossiers[index]['type']!,
//                             date: _dossiers[index]['date']!,
//                             onTap: () {},
//                           );
//                         },
//                       ),
//                     ),

//                     const SizedBox(height: 12), // Reduction espace entre liste horizontale et barre recherche

//                     // Barre de recherche
//                     custom.SearchBar(
//                       controller: _searchController,
//                       onAddPressed: () {},
//                       onChanged: (value) {},
//                     ),
//                     const SizedBox(height: 12), // Réduction espace entre recherche et liste verticale
//                     // Liste verticale des dossiers
//                     ListView.separated(
//                       physics: const NeverScrollableScrollPhysics(),
//                       shrinkWrap: true,
//                       itemCount: _dossiers.length,
//                       separatorBuilder: (context, index) => const SizedBox(height: 12),
//                       itemBuilder: (context, index) {
//                         return DossierListItem(
//                           key: ValueKey(_dossiers[index]['nom']),
//                           name: _dossiers[index]['nom']!,
//                           type: _dossiers[index]['type']!,
//                           onTap: () {},
//                           onOptionsTap: () => _showOptions(index),
//               );
//             },
//           ),
//         ],
//       ),
//     )
//   ); 
//   }
// }

// Sticky Tab Bar Delegate pour les onglets
// class _StickyTabBarDelegate extends SliverPersistentHeaderDelegate {
//   final Widget child;

//   const _StickyTabBarDelegate({required this.child});

//   @override
//   Widget build(BuildContext context, double shrinkOffset, bool overlapContent) {
//     return Material(
//       color: Colors.white,
//       child: child);
//   }
// }