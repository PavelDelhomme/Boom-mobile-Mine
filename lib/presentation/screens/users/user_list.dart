import 'package:flutter/material.dart';
import 'package:boom_mobile/domain/entities/user.dart';
import 'package:boom_mobile/presentation/screens/users/users_list/users_vertical_list_item.dart';
import 'package:boom_mobile/core/constants/app_constants.dart';

class UserList extends StatelessWidget {
  final List<User> users;
  final double spacing;

  const UserList({
    super.key,
    required this.users,
    this.spacing = kElementListSpacing,
  });

  @override
  Widget build(BuildContext context) {
    return SliverPadding(
      padding: EdgeInsets.symmetric(horizontal: kHorizontalPadding),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) {
            final user = users[index];
            return Padding(
              padding: EdgeInsets.only(bottom: spacing),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white, // ou la couleur souhaitée
                ),
                child: UsersVerticalListItem(
                  key: ValueKey(user.email),
                  name: user.name,
                  email: user.email,
                  role: user.role,
                  onTap: () {
                    // TODO: navigation vers fiche utilisateur
                  },
                  onOptionsTap: () {
                    // TODO: menu options utilisateur
                  },
                ),
              ),
            );
          },
          childCount: users.length,
        ),
      ),
    );
  }
}
