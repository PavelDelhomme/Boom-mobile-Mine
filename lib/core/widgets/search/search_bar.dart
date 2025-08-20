import 'package:flutter/material.dart';
import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';

class ReusableSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String placeholder;
  final bool showTrailing; // true = bouton add dossier ; false = bouton clear
  final VoidCallback? onTrailingPressed;

  const ReusableSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.placeholder = 'Rechercher un dossier',
    this.showTrailing = false,
    this.onTrailingPressed,
  });

  @override
  State<ReusableSearchBar> createState() => _ReusableSearchBarState();
}

class _ReusableSearchBarState extends State<ReusableSearchBar> {
  bool _showClear = false;

  @override
  void dispose() {
    widget.controller.removeListener(_handleTextChange);
    super.dispose();
  }

  void _handleTextChange() {
    if (!mounted) return;
    setState(() {
      _showClear = widget.controller.text.isNotEmpty;
    });
  }

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_handleTextChange);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kSearchBarHeight + 8, // Augmentation de la hauteur
      padding: const EdgeInsets.symmetric(horizontal: kElementSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Barre de recherche (partie gauche)
          Expanded(
            child: Container(
              height: kSearchBarHeight,
              padding: const EdgeInsets.symmetric(horizontal: kElementSpacing),
              decoration: ShapeDecoration(
                color: AppColors.ligthGreenSearchBar,
                shape: RoundedRectangleBorder(
                  side: const BorderSide(width: 1, color: Color(0x33A8F0C3)),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Center( // Utilisation de Center pour centrer verticalement
                child: TextField(
                  controller: widget.controller,
                  onChanged: widget.onChanged,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                  decoration: InputDecoration(
                    hintText: widget.placeholder,
                    hintStyle: const TextStyle(
                      color: Color(0xFF9F9F9F),
                      fontSize: 16,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(vertical: 12),
                    isDense: true,
                    prefixIcon: const Padding(
                      padding: EdgeInsets.only(left: 8.0),
                      child: Icon(Icons.search, color: Color(0xFF9F9F9F), size: 22),
                    ),
                    suffixIcon: _showClear
                        ? IconButton(
                      padding: EdgeInsets.zero,
                      icon: const Icon(Icons.clear, color: Color(0xFF9F9F9F), size: 20),
                      onPressed: () {
                        widget.controller.clear();
                        widget.onChanged?.call('');
                      },
                    )
                        : null,
                  ),
                ),
              ),
            ),
          ),

          // Bouton trailing (partie droite, à côté de la barre de recherche)
          if (widget.showTrailing)
            Container(
              margin: const EdgeInsets.only(left: 12.0),
              width: 44,
              height: 44,
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: widget.onTrailingPressed,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Image.asset(kAddFolderImage),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}