import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/core/widgets/list/vertical_list_item.dart';

import '../../../../core/widgets/buttons/generic_options_button.dart';

class UsersVerticalListItem extends StatelessWidget {
  final String name;
  final String email;
  final String role;
  final VoidCallback onTap;
  final VoidCallback onOptionsTap;

  const UsersVerticalListItem({
    super.key,
    required this.name,
    required this.email,
    required this.role,
    required this.onTap,
    required this.onOptionsTap,
  });

  @override
  Widget build(BuildContext context) {
    return VerticalListItem(
      leading: const CircleAvatar(
        backgroundColor: AppColors.primaryGreen,
        child: Icon(Icons.person, color: AppColors.primaryGreenWithAlpha),
      ),
      title: name,
      subtitle: email,
      subtitle2: role,
      onTap: onTap,
      trailing: GenericOptionsButton(
        onEdit: () {
          log("Edit user: $name");
          onOptionsTap();
          // TODO: navigation vers fiche utilisateur editable
        },
        onDelete: () {
          log("Delete user: $name");
          onOptionsTap();
          // TODO: confirmation de suppression
        },
        menuColor: AppColors.backgroundColorThreePointsListDossier,
        //debugColor: Colors.blue.withAlpha(60),
      ),
    );
  }
}
