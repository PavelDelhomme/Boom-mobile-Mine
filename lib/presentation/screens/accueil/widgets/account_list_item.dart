import 'package:flutter/material.dart';
import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:boom_mobile/core/theme/app_text_styles.dart';

import '../../../widgets/switch_button.dart';

class AccountListItem extends StatelessWidget {
  final String accountName;
  final String accountDetail;
  final VoidCallback onTap;
  final VoidCallback onOptionsTap;

  const AccountListItem({
    Key? key,
    required this.accountName,
    required this.accountDetail,
    required this.onTap,
    required this.onOptionsTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: Colors.white,
          //borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: Color(0xFFF5F5F5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [            // Icône à gauche et infos du compte
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Colors.white,
                  radius: 25,
                  child: Image.asset('assets/images/person_02.png', width: kIconSize, height: kIconSize),
                ), // En faire un composant réutilisable
                const SizedBox(width: 15),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(accountName, style: AppTextStyles.cardTitle),
                    Text(accountDetail, style: AppTextStyles.cardSubtitle),
                  ],
                ),
              ],
            ),
            // Switch
            SwitchButton(onTap: onOptionsTap, size: 40, flattened: true),
          ],
        ),
      ),
    );
  }
}
