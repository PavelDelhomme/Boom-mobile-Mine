import 'package:flutter/material.dart';
import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';
import '../../../widgets/reusable_search.dart';
import '../../../widgets/top_bottom_sheet.dart';
import 'account_list_item.dart';

class AccountBottomSheet extends StatelessWidget {
  final TextEditingController searchController;
  final List<Map<String, String>> accounts;
  final String title;
  final String subtitle;

  const AccountBottomSheet({
    Key? key,
    required this.searchController,
    required this.accounts,
    this.title = "Liste des comptes",
    this.subtitle = "Cliquer pour changer de compte",
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: kElementSpacing),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Column(
              children: [
                TopBottomSheet(
                  title: title,
                  subtitle: subtitle,
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: kVerticalPadding),
                // Utilisation de ReusableSearchBar sans le bouton add-folder
                ReusableSearchBar(
                  controller: searchController,
                  onChanged: (value) {
                    // Filtrer la liste
                  },
                  placeholder: "Rechercher un compte",
                  showTrailing: false,
                ),
                const SizedBox(height: 2),
                Divider(),
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    itemCount: accounts.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 4),
                    itemBuilder: (context, index) {
                      return Align(
                        alignment: Alignment.center,
                        // child: ConstrainedBox(
                        //   constraints: BoxConstraints(
                        //     maxWidth: MediaQuery.of(context).size.width * 0.9,
                        //   ),
                          child: AccountListItem(
                            accountName: accounts[index]['name']!,
                            accountDetail: accounts[index]['detail']!,
                            onTap: () {
                              Navigator.pop(context);
                              // Logique de changement de compte
                            },
                            onOptionsTap: () {
                              // Autres actions
                            },
                          ),
                        // ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
