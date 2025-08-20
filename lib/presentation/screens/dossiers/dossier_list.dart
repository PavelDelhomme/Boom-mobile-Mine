import 'package:flutter/material.dart';


import '../../../domain/entities/dossier.dart';

import 'package:boom_mobile/core/constants/app_constants.dart';

import 'package:boom_mobile/presentation/screens/map/map_screen.dart';

import 'dossiers_list/dossiers_vertical_list_item.dart';

class DossierList extends StatelessWidget {
  final List<Dossier> dossiers;
  final double spacing;


  const DossierList({
    super.key,
    required this.dossiers,
    this.spacing = kElementListSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: kHorizontalPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
            (context, index) {
            final dossier = dossiers[index];
            return Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.red,
                ),
                child: DossiersVerticalListItem(
                  key: ValueKey(dossier.nom),
                  name: dossier.nom,
                  type: dossier.type,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapScreen(dossier: dossier),
                    ),
                  ),
                  onOptionsTap: () {},
                ),
              ),
            );
          },
          childCount: dossiers.length,
          //addAutomaticKeepAlives: true,
          //addRepaintBoundaries: true,
        ),
      ),
    );
  }
}
