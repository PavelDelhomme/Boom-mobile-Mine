import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';


class ReusableSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String placeholder;
  final bool showTrailing; // Si true, affiche l'icône d'ajout au lieux du clean (pas ce que je douhaite)
  final VoidCallback? onTrailingPressed;

  const ReusableSearchBar({
    Key? key,
    required this.controller,
    this.onChanged,
    this.placeholder = 'Rechercher un dossier',
    this.showTrailing = false,
    this.onTrailingPressed,
  }): super(key: key);

  @override
  _ReusableSearchBarState createState() => _ReusableSearchBarState();
}

class _ReusableSearchBarState extends State<ReusableSearchBar> {
  bool _showClear = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(() {
      setState(() {
        _showClear = widget.controller.text.isNotEmpty;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    // Calcul de la largeur possible pour respecter les marges
    final availableWidth = MediaQuery.of(context).size.width - 96;
    return Container(
      width: double.infinity,
      height: kSearchBarHeight,
      padding: const EdgeInsets.symmetric(horizontal: kElementSpacing),
      child: Stack(
        children: [
          Container(
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
                hintText: widget.placeholder,
                hintStyle: const TextStyle(
                  color: Color(0xFF9F9F9F),
                  fontSize: 14,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w400,
                ),
                border: InputBorder.none,
                contentPadding: EdgeInsets.zero,
                // Intégration de l'icône de recherche via prefix icon
                prefixIcon: Icon(
                  Icons.search,
                  color: const Color(0xFF9F9F9F),
                  size: kIconSize,
                ),
                // afficher clear si du text est présent et que showTrailing est false
                suffixIcon: !widget.showTrailing && _showClear
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
          // SI show trailling est tru on afficher un button de droite pour action
          if (widget.showTrailing)
            Positioned(
              right: 0,
              top: 0,
              bottom: 0,
              child: GestureDetector(
                onTap: widget.onTrailingPressed,
                child: Container(
                  width: kSearchBarHeight,
                  height: kSearchBarHeight,
                  alignment: Alignment.center,
                  child: Image.asset("assets/images/add-folder_02.png"),
                ),
              ),
            ),
        ],
      ),
    );
  }
}