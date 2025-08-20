import '../../../../domain/entities/account.dart';
import 'package:flutter/material.dart';
import '../../../core/widgets/bottom_sheet/top_bottom_sheet.dart';
import '../../../core/widgets/list/filtered_list_view.dart';
import 'account_list_item.dart';

class AccountBottomSheet extends StatelessWidget {
  final List<Account> accounts;

  const AccountBottomSheet({super.key, required this.accounts});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.75,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
            ),
            child: Column(
              children: [
                TopBottomSheet(
                  title: "Liste des comptes",
                  subtitle: "Cliquer pour changer de compte",
                  onClose: () => Navigator.pop(context),
                ),
                const SizedBox(height: 8),
                Expanded(
                  child: FilteredListView<Account>(
                    items: accounts,
                    placeholder: "Rechercher un compte",
                    filter: (a, q) =>
                    a.name.toLowerCase().contains(q) || a.detail.toLowerCase().contains(q),
                    itemBuilder: (context, account) => AccountListItem(
                      accountName: account.name,
                      accountDetail: account.detail,
                      onTap: () {
                        Navigator.pop(context);
                      },
                      onOptionsTap: () {},
                    ),
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
