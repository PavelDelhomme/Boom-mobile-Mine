import 'package:flutter/material.dart';
import 'package:boom_mobile/core/constants/app_constants.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';

class ReusableSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final String placeholder;
  final bool showTrailing;
  final VoidCallback? onTrailingPressed;
  final String? trailingTooltip;
  final IconData? trailingIcon;
  final bool enabled;
  final bool autoFocus;
  final FocusNode? focusNode;
  final ValueChanged<String>? onSubmitted;
  final VoidCallback? onTap;
  final TextInputAction textInputAction;
  final List<String> suggestions;
  final Function(String)? onSuggestionTap;
  final bool showSuggestions;

  const ReusableSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.placeholder = 'Rechercher...',
    this.showTrailing = false,
    this.onTrailingPressed,
    this.trailingTooltip,
    this.trailingIcon,
    this.enabled = true,
    this.autoFocus = false,
    this.focusNode,
    this.onSubmitted,
    this.onTap,
    this.textInputAction = TextInputAction.search,
    this.suggestions = const [],
    this.onSuggestionTap,
    this.showSuggestions = false,
  });

  @override
  State<ReusableSearchBar> createState() => _ReusableSearchBarState();
}

class _ReusableSearchBarState extends State<ReusableSearchBar> {
  late FocusNode _focusNode;
  bool _hasFocus = false;
  bool _showClearButton = false;
  List<String> _filteredSuggestions = [];
  OverlayEntry? _suggestionOverlay;

  @override
  void initState() {
    super.initState();
    _focusNode = widget.focusNode ?? FocusNode();
    _focusNode.addListener(_onFocusChange);
    _showClearButton = widget.controller.text.isNotEmpty;

    widget.controller.addListener(() {
      final hasText = widget.controller.text.isNotEmpty;
      if (_showClearButton != hasText) {
        setState(() {
          _showClearButton = hasText;
        });
      }

      if (widget.showSuggestions && hasText) {
        _filterSuggestions(widget.controller.text);
      } else {
        _hideSuggestions();
      }
    });
  }

  @override
  void dispose() {
    if (widget.focusNode == null) {
      _focusNode.dispose();
    }
    _hideSuggestions();
    super.dispose();
  }

  void _onFocusChange() {
    setState(() {
      _hasFocus = _focusNode.hasFocus;
    });

    if (!_hasFocus) {
      _hideSuggestions();
    } else if (widget.showSuggestions && widget.controller.text.isNotEmpty) {
      _filterSuggestions(widget.controller.text);
    }
  }

  void _filterSuggestions(String query) {
    if (query.isEmpty) {
      _filteredSuggestions.clear();
      _hideSuggestions();
      return;
    }

    _filteredSuggestions = widget.suggestions
        .where((suggestion) => suggestion.toLowerCase().contains(query.toLowerCase()))
        .take(5)
        .toList();

    if (_filteredSuggestions.isNotEmpty) {
      _showSuggestions();
    } else {
      _hideSuggestions();
    }
  }

  void _showSuggestions() {
    _hideSuggestions();

    final renderBox = context.findRenderObject() as RenderBox?;
    if (renderBox == null) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;

    _suggestionOverlay = OverlayEntry(
      builder: (context) => Positioned(
        left: position.dx,
        top: position.dy + size.height + 4,
        width: size.width,
        child: Material(
          elevation: 8,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            constraints: const BoxConstraints(maxHeight: 200),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.transparent),
              //border: Border.all(color: Colors.grey[300]!),
            ),
            child: ListView.builder(
              padding: EdgeInsets.zero,
              shrinkWrap: true,
              itemCount: _filteredSuggestions.length,
              itemBuilder: (context, index) {
                final suggestion = _filteredSuggestions[index];
                return ListTile(
                  dense: true,
                  title: Text(suggestion),
                  leading: const Icon(Icons.search, size: 16),
                  onTap: () {
                    widget.controller.text = suggestion;
                    if (widget.onSuggestionTap != null) {
                      widget.onSuggestionTap!(suggestion);
                    }
                    if (widget.onChanged != null) {
                      widget.onChanged!(suggestion);
                    }
                    _hideSuggestions();
                    _focusNode.unfocus();
                  },
                );
              },
            ),
          ),
        ),
      ),
    );

    Overlay.of(context).insert(_suggestionOverlay!);
  }

  void _hideSuggestions() {
    _suggestionOverlay?.remove();
    _suggestionOverlay = null;
  }

  // ✅ CORRECTION: Clear text et déclencher onChanged pour réinitialiser les filtres
  void _clearText() {
    widget.controller.clear();
    if (widget.onChanged != null) {
      widget.onChanged!(''); // ✅ AJOUT: Déclencher onChanged avec string vide
    }
    _hideSuggestions();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: kSearchBarHeight + 8,
      padding: const EdgeInsets.symmetric(horizontal: kElementSpacing),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              height: kSearchBarHeight,
              decoration: ShapeDecoration(
                color: AppColors.ligthGreenSearchBar, // ✅ GARDE: Votre couleur originale
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    width: _hasFocus ? 2.0 : 1.0,
                    color: _hasFocus ? AppColors.primaryGreen : const Color(0x33A8F0C3),
                  ),
                  borderRadius: BorderRadius.circular(24),
                ),
              ),
              child: Row(
                children: [
                  Padding(
                    padding: const EdgeInsets.only(left: 16, right: 4),
                    child: Icon(
                      Icons.search,
                      color: _hasFocus ? AppColors.primaryGreen : const Color(0xFF9F9F9F),
                      size: 24,
                    ),
                  ),
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: Colors.transparent,
                        borderRadius: BorderRadius.circular(24),
                      ),
                      child: TextField(
                        controller: widget.controller,
                        focusNode: _focusNode,
                        enabled: widget.enabled,
                        autofocus: widget.autoFocus,
                        textInputAction: widget.textInputAction,
                        onChanged: widget.onChanged,
                        onSubmitted: widget.onSubmitted,
                        onTap: widget.onTap,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.placeholder,
                          hintStyle: TextStyle(
                            // texte du palceholder en ver
                            color: _hasFocus ? AppColors.primaryGreen.withOpacity(0.6) : const Color(0xFF9F9F9F),
                            fontSize: 16,
                          ),
                          disabledBorder: InputBorder.none,
                          //border: InputBorder.none,
                          isDense: true,
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 7,
                            horizontal: 4,
                          ),
                        ),
                      )
                    ),
                  ),
                  if (_showClearButton)
                    Padding(
                      padding: const EdgeInsets.only(right: 16, left: 8),
                      child: GestureDetector(
                        onTap: _clearText, // ✅ CORRECTION: Utilise la nouvelle méthode
                        child: const Icon(
                          Icons.clear,
                          color: Color(0xFF9F9F9F),
                          size: 20,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),
          if (widget.showTrailing)
            Container(
              margin: const EdgeInsets.only(left: 12.0),
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: Colors.transparent,
                borderRadius: BorderRadius.circular(22),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(22),
                  onTap: widget.onTrailingPressed,
                  child: Padding(
                    padding: const EdgeInsets.all(1.0),
                    child: Image.asset(
                      kAddFolderImage, // ✅ GARDE: Votre image originale
                      width: 24,
                      height: 24,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// Widget spécialisé pour la recherche de stations
class StationSearchBar extends StatefulWidget {
  final TextEditingController controller;
  final ValueChanged<String>? onChanged;
  final List<String> stationSuggestions;
  final Function(String)? onStationSelected;

  const StationSearchBar({
    super.key,
    required this.controller,
    this.onChanged,
    this.stationSuggestions = const [],
    this.onStationSelected,
  });

  @override
  State<StationSearchBar> createState() => _StationSearchBarState();
}

class _StationSearchBarState extends State<StationSearchBar> {
  @override
  Widget build(BuildContext context) {
    return ReusableSearchBar(
      controller: widget.controller,
      placeholder: 'Rechercher une station...',
      onChanged: widget.onChanged,
      showSuggestions: true,
      suggestions: widget.stationSuggestions,
      onSuggestionTap: widget.onStationSelected,
      textInputAction: TextInputAction.search,
    );
  }
}