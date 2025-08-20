import 'package:flutter/material.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/core/widgets/bottom_sheet/top_bottom_sheet.dart';

class MapExportPdfPanel extends StatefulWidget {
  const MapExportPdfPanel({super.key});

  @override
  State<MapExportPdfPanel> createState() => _MapExportPdfPanelState();
}

class _MapExportPdfPanelState extends State<MapExportPdfPanel> {
  String _formatPage = 'A4';
  String _orientation = 'Portrait';
  String _echelle = 'Auto';
  bool _inclureLegende = true;
  bool _inclureNordFleche = true;
  bool _inclureEchelle = true;
  bool _inclureCoordonnees = false;
  bool _inclureDate = true;
  //bool _inclureTitre = true;
  bool _inclureStations = true;
  bool _inclureNumeros = true;
  bool _inclureCouches = false;

  String _titre = '';
  double _qualite = 300; // DPI

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              TopBottomSheet(
                title: "Exporter la carte en PDF",
                subtitle: "Configurez votre export cartographique",
                onClose: () => Navigator.pop(context),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Format de page
                    _buildSectionTitle("Format de page"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: _buildFormatChip('A4', Icons.picture_as_pdf),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFormatChip('A3', Icons.picture_as_pdf),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildFormatChip('A5', Icons.picture_as_pdf),
                        ),
                      ],
                    ),

                    const SizedBox(height: 16),

                    // Orientation
                    Row(
                      children: [
                        Expanded(
                          child: _buildOrientationChip('Portrait', Icons.portrait),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _buildOrientationChip('Paysage', Icons.landscape),
                        ),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Titre personnalisé
                    _buildSectionTitle("Titre du document"),
                    const SizedBox(height: 8),
                    TextField(
                      decoration: InputDecoration(
                        hintText: "Carte des stations - ${DateTime.now().year}",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        prefixIcon: Icon(Icons.title, color: AppColors.primaryGreen),
                      ),
                      onChanged: (value) => setState(() => _titre = value),
                    ),

                    const SizedBox(height: 24),

                    // Échelle
                    _buildSectionTitle("Échelle"),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _echelle,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'Auto', child: Text('Automatique')),
                            DropdownMenuItem(value: '1:500', child: Text('1:500')),
                            DropdownMenuItem(value: '1:1000', child: Text('1:1000')),
                            DropdownMenuItem(value: '1:2000', child: Text('1:2000')),
                            DropdownMenuItem(value: '1:5000', child: Text('1:5000')),
                            DropdownMenuItem(value: '1:10000', child: Text('1:10000')),
                          ],
                          onChanged: (value) => setState(() => _echelle = value!),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Qualité
                    _buildSectionTitle("Qualité d'export"),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        const Icon(Icons.photo, size: 16, color: Colors.grey),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Slider(
                            value: _qualite,
                            min: 150,
                            max: 600,
                            divisions: 3,
                            label: '${_qualite.round()} DPI',
                            activeColor: AppColors.primaryGreen,
                            inactiveColor: AppColors.primaryGreen.withAlpha(77),
                            onChanged: (value) => setState(() => _qualite = value),
                          ),
                        ),
                        Text(
                          '${_qualite.round()} DPI',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text('Rapide', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                        Text('Standard', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                        Text('Haute', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                        Text('Maximum', style: TextStyle(fontSize: 10, color: Colors.grey[600])),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Éléments cartographiques
                    _buildSectionTitle("Éléments cartographiques"),
                    const SizedBox(height: 12),

                    _buildToggleTile(
                      "Légende",
                      "Afficher la légende des symboles",
                      _inclureLegende,
                          (value) => setState(() => _inclureLegende = value),
                      Icons.list_alt,
                    ),

                    _buildToggleTile(
                      "Flèche du Nord",
                      "Indiquer l'orientation",
                      _inclureNordFleche,
                          (value) => setState(() => _inclureNordFleche = value),
                      Icons.explore,
                    ),

                    _buildToggleTile(
                      "Échelle graphique",
                      "Barre d'échelle",
                      _inclureEchelle,
                          (value) => setState(() => _inclureEchelle = value),
                      Icons.straighten,
                    ),

                    _buildToggleTile(
                      "Coordonnées",
                      "Afficher les coordonnées GPS",
                      _inclureCoordonnees,
                          (value) => setState(() => _inclureCoordonnees = value),
                      Icons.gps_fixed,
                    ),

                    _buildToggleTile(
                      "Date de création",
                      "Horodatage du document",
                      _inclureDate,
                          (value) => setState(() => _inclureDate = value),
                      Icons.calendar_today,
                    ),

                    const SizedBox(height: 16),
                    _buildSectionTitle("Contenu"),
                    const SizedBox(height: 12),

                    _buildToggleTile(
                      "Stations",
                      "Marquer les stations",
                      _inclureStations,
                          (value) => setState(() => _inclureStations = value),
                      Icons.location_on,
                      isRequired: true,
                    ),

                    _buildToggleTile(
                      "Numéros de stations",
                      "Afficher les identifiants",
                      _inclureNumeros,
                          (value) => setState(() => _inclureNumeros = value),
                      Icons.format_list_numbered,
                    ),

                    _buildToggleTile(
                      "Couches additionnelles",
                      "Inclure toutes les couches visibles",
                      _inclureCouches,
                          (value) => setState(() => _inclureCouches = value),
                      Icons.layers,
                    ),

                    const SizedBox(height: 16),

                    // Aperçu
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.ligthGreenSearchBar.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.preview, color: AppColors.primaryGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Format: $_formatPage $_orientation • Qualité: ${_qualite.round()} DPI • ${_getEstimatedFileSize()}",
                              style: TextStyle(
                                fontSize: 12,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Boutons d'action
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton(
                        onPressed: () => Navigator.pop(context),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppColors.orange),
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Text(
                          "Annuler",
                          style: TextStyle(color: AppColors.orange, fontSize: 16),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () => _generatePdf(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.picture_as_pdf, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              "Générer PDF",
                              style: TextStyle(color: Colors.white, fontSize: 16),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: AppColors.textDark,
      ),
    );
  }

  Widget _buildFormatChip(String format, IconData icon) {
    final isSelected = _formatPage == format;
    return GestureDetector(
      onTap: () => setState(() => _formatPage = format),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              format,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrientationChip(String orientation, IconData icon) {
    final isSelected = _orientation == orientation;
    return GestureDetector(
      onTap: () => setState(() => _orientation = orientation),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryGreen : Colors.white,
          border: Border.all(
            color: isSelected ? AppColors.primaryGreen : Colors.grey[300]!,
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected ? Colors.white : Colors.grey[600],
              size: 20,
            ),
            const SizedBox(width: 8),
            Text(
              orientation,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.grey[600],
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToggleTile(
      String title,
      String subtitle,
      bool value,
      ValueChanged<bool> onChanged,
      IconData icon, {
        bool isRequired = false,
      }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
        border: isRequired ? Border.all(color: AppColors.primaryGreen.withAlpha(50)) : null,
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    if (isRequired) ...[
                      const SizedBox(width: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.primaryGreen,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Text(
                          "Requis",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: isRequired ? null : onChanged,
            thumbColor: WidgetStateProperty.resolveWith<Color?>((states) {
              return Colors.white;
            }),
            trackColor: WidgetStateProperty.resolveWith<Color?>((states) {
              if (states.contains(WidgetState.selected)) {
                return AppColors.primaryGreen.withAlpha(50);
              }
              return Colors.grey.shade400;
            }),
          ),
        ],
      ),
    );
  }

  String _getEstimatedFileSize() {
    double size = 0.5; // MB de base
    if (_qualite > 300) size += 1.0;
    if (_qualite > 450) size += 1.5;
    if (_formatPage == 'A3') size *= 2;
    if (_inclureLegende) size += 0.2;
    if (_inclureCouches) size += 0.5;
    return "${size.toStringAsFixed(1)} MB";
  }

  void _generatePdf() {
    Navigator.pop(context);
    // TODO: Logique de génération PDF
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Génération PDF en cours... Format: $_formatPage $_orientation'),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }
}