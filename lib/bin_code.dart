// accueil_screen.dart
  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     body: SafeArea(
  //       child: NestedScrollView(
  //         headerSliverBuilder: (context, innerBoxIsScrolled) {
  //           return [
  //             SliverToBoxAdapter(
  //               child: Padding(
  //                 padding: const EdgeInsets.all(16.0),
  //                 child: Column(
  //                   crossAxisAlignment: CrossAxisAlignment.start,
  //                   children: [
  //                     // En-tête avec logo et métropole
  //                     Row(
  //                       mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //                       children: [
  //                         // Logo 
  //                         Container(
  //                           width: 28,
  //                           height: 37,
  //                           //child: Icon(Icons.map, size: 28, color: AppColors.primaryGreen),
  //                           child: Image.asset("assets/images/logo_boom.png"),
  //                         ),
                          
  //                         // Badge métropole
  //                         Container(
  //                           padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
  //                           decoration: ShapeDecoration(
  //                             color: AppColors.primaryGreen,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(15),
  //                             ),
  //                             shadows: [
  //                               BoxShadow(
  //                                 color: Color(0xFFC5FFE6),
  //                                 blurRadius: 4,
  //                                 offset: Offset(0, 4),
  //                               )
  //                             ],
  //                           ),
  //                           child: Row(
  //                             children: [
  //                               Text(
  //                                 'Rennes Métropole',
  //                                 style: TextStyle(
  //                                   color: Colors.white,
  //                                   fontSize: 10,
  //                                   fontFamily: 'Inter',
  //                                   fontWeight: FontWeight.w400,
  //                                 ),
  //                               ),
  //                               SizedBox(width: 10),
  //                               Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
  //                             ],
  //                           ),
  //                         ),
  //                       ],
  //                     ),
                      
  //                     SizedBox(height: 20),
                      
  //                     // Bannière de bienvenue
  //                     WelcomeBanner(
  //                       userName: 'Emmanuel',
  //                       userRole: 'Administrateur',
  //                     ),
                      
  //                     SizedBox(height: 20),
                      
  //                     // Info métropole
  //                     Text(
  //                       'Vous travaillez actuellement sur',
  //                       style: TextStyle(
  //                         color: AppColors.textDark,
  //                         fontSize: 14,
  //                         fontFamily: 'Montserrat',
  //                         fontWeight: FontWeight.w400,
  //                       ),
  //                     ),

  //                     // Badge métropole
  //                         Container(
  //                           padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
  //                           decoration: ShapeDecoration(
  //                             color: AppColors.primaryGreen,
  //                             shape: RoundedRectangleBorder(
  //                               borderRadius: BorderRadius.circular(15),
  //                             ),
  //                             shadows: [
  //                               BoxShadow(
  //                                 color: Color(0xFFC5FFE6),
  //                                 blurRadius: 4,
  //                                 offset: Offset(0, 4),
  //                               )
  //                             ],
  //                           ),
  //                           child: Row(
  //                             children: [
  //                               Text(
  //                                 'Rennes Métropole',
  //                                 style: TextStyle(
  //                                   color: Colors.white,
  //                                   fontSize: 10,
  //                                   fontFamily: 'Inter',
  //                                   fontWeight: FontWeight.w400,
  //                                 ),
  //                               ),
  //                               SizedBox(width: 10),
  //                               Icon(Icons.arrow_forward_ios, color: Colors.white, size: 14),
  //                             ],
  //                           ),
  //                         ),
                      
  //                     SizedBox(height: 20),
  //                   ],
  //                 ),
  //               ),
  //             ),
              
  //             // TabBar personnalisée
  //             SliverToBoxAdapter(
  //               child: Padding(
  //                 padding: const EdgeInsets.symmetric(horizontal: 16.0),
  //                 child: _buildCustomTabBar(),
  //               ),
  //             ),
  //           ];
  //         },
  //         body: TabBarView(
  //           controller: _tabController,
  //           children: [
  //             _buildDossiersTab(),
  //             _buildUtilisateursTab(),
  //             _buildCouchesTab(),
  //             _buildCouchesTab(),
  //             _buildCouchesTab(),
  //             _buildCouchesTab(),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }

  // Widget _buildTabItem(String title, int index) {
  //   final isSelected = _tabController.index == index;
    
  //   return GestureDetector(
  //     onTap: () => _tabController.animateTo(index),
  //     child: isSelected
  //         ? Container(
  //             padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
  //             decoration: ShapeDecoration(
  //               color: AppColors.ligthGreenSearchBar.withAlpha(80),
  //               shape: RoundedRectangleBorder(
  //                 borderRadius: BorderRadius.circular(33),
  //               ),
  //             ),
  //             child: Text(
  //               title,
  //               style: AppTextStyles.tabActive,
  //             ),
  //           )
  //         : Text(
  //             title,
  //             style: AppTextStyles.tabInactive,
  //           ),
  //   );
  // }
  
  // Onglet Dossiers
  // Widget _buildDossiersTab() {
  //   return SingleChildScrollView(
  //     child: Padding(
  //       padding: const EdgeInsets.only(left: 16.0, right: 16.0), // Uniformisation des marges
  //       child: Column(
  //         crossAxisAlignment: CrossAxisAlignment.start,
  //         children: [
  //           // Padding(
  //           //   padding: const EdgeInsets.only(right: 1.0), // Alignement avec les cartes
  //           //   child: Text(
  //           //     'Derniers dossiers_list',
  //           //     style: AppTextStyles.sectionTitle,
  //           //   ),
  //           // ),
            
  //           SizedBox(height: 32.0),
            
  //           // Liste horizontale des cartes dossiers_list
  //           // Container(
  //           //   height: 170,
  //           //   child: ListView(
  //           //     scrollDirection: Axis.horizontal,
  //           //     children: [
  //           //       DossierCard(
  //           //         title: 'Cesson',
  //           //         status: 'En attente de Sauvegarde',
  //           //         date: '10 Mars 25',
  //           //         onTap: () {},
  //           //       ),
  //           //       SizedBox(width: 16),
  //           //       DossierCard(
  //           //         title: 'Cesson',
  //           //         status: 'En attente de Sauvegarde',
  //           //         date: '10 Fev 25',
  //           //         onTap: () {},
  //           //       ),
  //           //       DossierCard(
  //           //         title: 'Cesson',
  //           //         status: 'En attente de Sauvegarde',
  //           //         date: '10 Fev 25',
  //           //         onTap: () {},
  //           //       ),
  //           //       DossierCard(
  //           //         title: 'Cesson',
  //           //         status: 'En attente de Sauvegarde',
  //           //         date: '10 Fev 25',
  //           //         onTap: () {},
  //           //       ),
  //           //       DossierCard(
  //           //         title: 'Cesson',
  //           //         status: 'En attente de Sauvegarde',
  //           //         date: '10 Fev 25',
  //           //         onTap: () {},
  //           //       ),
  //           //       DossierCard(
  //           //         title: 'Cesson',
  //           //         status: 'En attente de Sauvegarde',
  //           //         date: '10 Fev 25',
  //           //         onTap: () {},
  //           //       ),
  //           //       DossierCard(
  //           //         title: 'Cesson',
  //           //         status: 'En attente de Sauvegarde',
  //           //         date: '10 Fev 25',
  //           //         onTap: () {},
  //           //       ),
  //           //     ],
  //           //   ),
  //           // ),
            
  //           SizedBox(height: 12),
            
  //           // Barre de recherche
  //           Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 16), // Alignement avec le titre
  //             child: custom.SearchBar(
  //               controller: _searchController,
  //               onAddPressed: () {},
  //               onChanged: (value) {},
  //             ),
  //           ),

  //           // Liste verticale des dossiers_list
  //           ListView.separated(
  //             physics: NeverScrollableScrollPhysics(),
  //             shrinkWrap: true,
  //             itemCount: _dossiers.length,
  //             separatorBuilder: (context, index) => SizedBox(height: 12),
  //             itemBuilder: (context, index) {
  //               return DossierListItem(
  //                 key: ValueKey(_dossiers[index]['nom']),
  //                 name: _dossiers[index]['nom']!,
  //                 type: _dossiers[index]['type']!,
  //                 onTap: () {},
  //                 onOptionsTap: () => _showOptions(index),
  //               );
  //             },
  //           ),
  //         ],
  //       ),
  //     ),
  //   );
  // }



//


// accueil_screen.dart : 

  // Widget _buildContent() {
  //   return Column(
  //     children: [
  //       // Liste des dossiers_list
  //       ListView.separated(
  //         physics: const NeverScrollableScrollPhysics(),
  //         shrinkWrap: true,
  //         itemCount: _dossiers.length,
  //         separatorBuilder: (context, index) => const SizedBox(height: 12),
  //         itemBuilder: (context, index) {
  //           return DossierListItem(
  //             name: _dossiers[index]['nom']!,
  //             type: _dossiers[index]['type']!,
  //             onTap: () {},
  //             onOptionsTap: () => _showOptions(index),
  //           );
  //         },
  //       ),
  //     ],
  //   );
  // }

// accueil_screen.dart buildContent
// return Column(
    //   children: [
    //     // Titre "Derniers dossiers_list"
    //     Padding(
    //       padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 24),
    //       child: Text(
    //         'Derniers dossiers_list',
    //         style: AppTextStyles.sectionTitle,
    //       ),
    //     ),

    //     // Liste horizontale des cartes
    //     SizedBox(
    //       height: 170,
    //       child: ListView.separated(
    //         scrollDirection: Axis.horizontal,
    //         padding: const EdgeInsets.symmetric(horizontal: 16),
    //         itemCount: _dossiers.length,
    //         separatorBuilder: (context, index) => const SizedBox(width: 16),
    //         itemBuilder: (context, index) {
    //           return DossierCard(
    //             title: _dossiers[index]['nom']!,
    //             status: _dossiers[index]['type']!,
    //             date: _dossiers[index]['date']!,
    //             onTap: () {},
    //           );
    //         },
    //       ),
    //     ),

    //     // Barre de recherche
    //     Padding(
    //       padding: const EdgeInsets.only(top: 16.0),
    //       child: custom.SearchBar(
    //         controller: _searchController,
    //         onAddPressed: () {},
    //         onChanged: (value) {},
    //       ),
    //     ),

    //     // Liste verticale
    //     ListView.separated(
    //       physics: const NeverScrollableScrollPhysics(),
    //       padding: const EdgeInsets.only(top: 5),
    //       shrinkWrap: true,
    //       itemCount: _dossiers.length,
    //       separatorBuilder: (context, index) => const SizedBox(height: 12),
    //       itemBuilder: (context, index) {
    //         return DossierListItem(
    //           key: ValueKey(_dossiers[index]['nom']),
    //           name: _dossiers[index]['nom']!,
    //           type: _dossiers[index]['type']!,
    //           onTap: () {},
    //           onOptionsTap: () => _showOptions(index),
    //         );
    //       },
    //     ),
    //   ],
    // );


// accueil_screen.dart - buildLocation 
        /*decoration: ShapeDecoration(
          color: AppColors.primaryGreen,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          shadows: const [
            BoxShadow(
              color: Color(0xFFC5FFE6),
              blurRadius: 4,
              offset: Offset(0, 4),
            )
          ],
        ),*/