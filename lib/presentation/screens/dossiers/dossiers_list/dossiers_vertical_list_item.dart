import 'dart:developer';

import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:flutter/material.dart';

import 'package:boom_mobile/core/widgets/list/vertical_list_item.dart';

import '../../../../core/widgets/buttons/generic_options_button.dart';

class DossiersVerticalListItem extends StatelessWidget {
  final String name;
  final String type;
  final VoidCallback onTap;
  final VoidCallback onOptionsTap;

  const DossiersVerticalListItem({
    super.key,
    required this.name,
    required this.type,
    required this.onTap,
    required this.onOptionsTap,
  });

  //final GlobalKey _menuKey = GlobalKey();

  @override
  Widget build(BuildContext context) {
    /*return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: VerticalListItem(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: Color(0xFFF9F9FB),//const Color.fromARGB(9, 223, 248, 229),
            borderRadius: BorderRadius.circular(17.6),
          ),
          child: const Icon(Icons.folder_open, color: AppColors.primaryGreen, size: kIconSize),
        ),
        title: name,
        subtitle: type,
        subtitle2: "Dossier",
        onTap: onTap,
        //onOptionsTap: () => _showDossierOptions(context),
        trailing: GenericOptionsButton(
          onEdit: onOptionsTap,
          onDelete: onOptionsTap,
        ),
      ),
    );*/
    return VerticalListItem(
      leading: Container(
        width: 50,
        height: 50,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(17.6),
        ),
        child: const Icon(
            //Icons.folder_open,
            Icons.folder,
            color: AppColors.primaryGreen,
            size: kIconSize),
      ),
      title: name,
      subtitle: type,
      subtitle2: "Dossier",
      onTap: onTap,
      trailing: GenericOptionsButton(
        onEdit: () => log('Edit: $name'),
        onDelete: () => log('Delete: $name'),
        menuColor: AppColors.backgroundColorThreePointsListDossier,
        //debugColor: Colors.orange.withAlpha(60), // Pour le debug
      ),
    );
  }
}