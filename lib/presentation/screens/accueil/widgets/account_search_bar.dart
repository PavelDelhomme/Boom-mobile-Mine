import 'package:flutter/material.dart';
import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';

class AccountSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;

  const AccountSearchBar({
    Key? key,
    required this.controller,
    this.onChanged,
  }) : super(key: key);

  @override
  _AccountSearchBarState createState() => _AccountSearchBarState();
}

class _AccountSearchBarState extends State<AccountSearchBar> {
  bool _showClearButton = false;

  @override
  void initState() {
    super.initState();
    // Ecoute les changements du controller pour mettre à jour le bouton clear
    widget.controller.addListener(() {
      setState(() {
        _showClearButton = widget.controller.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final availableWidth = MediaQuery.of(context).size.width - 96;
    return Container(
      width: double.infinity,
      height: kSearchBarHeight,
      padding: const EdgeInsets.only(left: kElementSpacing, right: kElementSpacing),
      child: Container(
        width: availableWidth > 0 ? availableWidth : 0,
        height: kSearchBarHeight,
        padding: const EdgeInsets.symmetric(horizontal: kElementSpacing),
        decoration: ShapeDecoration(
          color: AppColors.ligthGreenSearchBar.withOpacity(0.2),
          shape: RoundedRectangleBorder(
            side: const BorderSide(
              width: 1,
              color: Color(0x33A8F0C3),
            ),
            borderRadius: BorderRadius.circular(24),
          ),
        ),
        child: TextField(
          controller: widget.controller,
          onChanged: widget.onChanged,
          textAlign: TextAlign.center,
          textAlignVertical: TextAlignVertical.center,
          decoration: InputDecoration(
            hintText: "Rechercher un compte",
            hintStyle: const TextStyle(
              color: Color(0xFF9F9F9F),
              fontSize: 14,
              fontFamily: 'Inter',
              fontWeight: FontWeight.w400,
            ),
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            // Icon de recherche
            prefixIcon: Icon(
              Icons.search,
              color: const Color(0xFF9F9F9F),
              size: kIconSize,
            ),
            // Bouton clear afficher seuelemnt si du texte est présent
            suffix: _showClearButton
              ? IconButton(
                icon: const Icon(
                  Icons.clear,
                  color: Color(0xFF9F9F9F),
                  size: 20,
                ),
                onPressed: () {
                  widget.controller.clear();
                  if (widget.onChanged != null) widget.onChanged!('');
                },
              )
            : null,
          ),
        ),
      ),
    );
  }
}
