import 'package:flutter/material.dart';
import 'package:boom_mobile/core/constants/app_constants.dart';

import '../../../core/widgets/buttons/switch_button.dart';
import '../../../core/widgets/list/vertical_list_item.dart';

class AccountListItem extends StatelessWidget {
  final String accountName;
  final String accountDetail;
  final VoidCallback onTap;
  final VoidCallback onOptionsTap;

  const AccountListItem({
    super.key,
    required this.accountName,
    required this.accountDetail,
    required this.onTap,
    required this.onOptionsTap,
  });


  @override
  Widget build(BuildContext context) {
    return VerticalListItem(
      leading: CircleAvatar(
        backgroundColor: Colors.white,
        radius: 25,
        child: Image.asset(kAvatar, width: kIconSize, height: kIconSize),
      ),
      title: accountName,
      subtitle: accountDetail,
      subtitle2: "",
      onTap: onTap,
      trailing: SwitchButton(
        onTap: onOptionsTap,
        size: 40,
        flattened: true,
      ),
      boxShadow: const [
        BoxShadow(
          color: Color(0xFFF5F5F5),
          blurRadius: 10,
          offset: Offset(0, 4),
        )
      ],
    );
  }
}
