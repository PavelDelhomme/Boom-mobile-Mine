import 'package:flutter/material.dart';
import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/core/widgets/bottom_sheet/top_bottom_sheet.dart';

class MapExportDatabasePanel extends StatefulWidget {
  final int totalStations;
  final List<String> availableEssences;
  final List<String> availableEtatsSanitaires;

  const MapExportDatabasePanel({
    super.key,
    this.totalStations = 0,
    this.availableEssences = const [],
    this.availableEtatsSanitaires = const [],
  });

  @override
  State<MapExportDatabasePanel> createState() => _MapExportDatabasePanelState();
}

class _MapExportDatabasePanelState extends State<MapExportDatabasePanel> {
  // Format d'export
  String _formatExport = 'CSV';
  String _filtreDate = 'Toutes';

  // Données de base (obligatoires)
  final bool _exportNumeroStation = true;
  final bool _exportCoordonnees = true;

  // Données optionnelles des stations
  bool _exportEssenceArbre = true;
  bool _exportEtatSanitaire = true;
  bool _exportStadeDeveloppement = true;
  bool _exportPaysageArbre = false;
  bool _exportFrequentationHumaine = false;
  bool _exportProtectionReglementaire = false;
  bool _exportInterventionsNecessaires = true;
  bool _exportCommentaires = false;
  bool _exportPhotos = false;
  bool _exportDernierModificateur = false;
  bool _exportDateModification = true;

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
                title: "Exporter les données des stations",
                subtitle: "Sélectionnez les informations à inclure",
                onClose: () => Navigator.pop(context),
              ),

              Expanded(
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Résumé
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.ligthGreenSearchBar.withAlpha(50),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: AppColors.primaryGreen),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "${widget.totalStations} stations • ${_getSelectedFieldsCount()} champs sélectionnés",
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: AppColors.primaryGreen,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Format d'export
                    _buildSectionTitle("Format d'export"),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(child: _buildFormatChip('CSV', Icons.table_chart)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildFormatChip('Excel', Icons.description)),
                        const SizedBox(width: 8),
                        Expanded(child: _buildFormatChip('JSON', Icons.code)),
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Période
                    _buildSectionTitle("Période de données"),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        border: Border.all(color: Colors.grey[300]!),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<String>(
                          value: _filtreDate,
                          isExpanded: true,
                          items: const [
                            DropdownMenuItem(value: 'Toutes', child: Text('Toutes les données')),
                            DropdownMenuItem(value: '2025', child: Text('Données 2025')),
                            DropdownMenuItem(value: '2024', child: Text('Données 2024')),
                            DropdownMenuItem(value: 'Trimestre', child: Text('Ce trimestre')),
                            DropdownMenuItem(value: 'Mois', child: Text('Ce mois')),
                          ],
                          onChanged: (value) => setState(() => _filtreDate = value!),
                        ),
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Données obligatoires
                    _buildSectionTitle("Données de base (incluses automatiquement)"),
                    const SizedBox(height: 12),

                    _buildRequiredDataTile(
                      "Numéro de station",
                      "Identifiant unique de chaque station",
                      Icons.pin_drop,
                    ),

                    _buildRequiredDataTile(
                      "Coordonnées GPS",
                      "Latitude et longitude précises",
                      Icons.gps_fixed,
                    ),

                    const SizedBox(height: 24),

                    // Données optionnelles
                    _buildSectionTitle("Informations des arbres"),
                    const SizedBox(height: 12),

                    _buildDataTile(
                      "Essence d'arbre",
                      "Type et espèce de l'arbre",
                      _exportEssenceArbre,
                          (value) => setState(() => _exportEssenceArbre = value),
                      Icons.nature,
                    ),

                    _buildDataTile(
                      "État sanitaire",
                      "Condition de santé de l'arbre",
                      _exportEtatSanitaire,
                          (value) => setState(() => _exportEtatSanitaire = value),
                      Icons.health_and_safety,
                    ),

                    _buildDataTile(
                      "Stade de développement",
                      "Maturité et âge de l'arbre",
                      _exportStadeDeveloppement,
                          (value) => setState(() => _exportStadeDeveloppement = value),
                      Icons.timeline,
                    ),

                    const SizedBox(height: 16),
                    _buildSectionTitle("Contexte environnemental"),
                    const SizedBox(height: 12),

                    _buildDataTile(
                      "Paysage de l'arbre",
                      "Type d'environnement (parc, rue, etc.)",
                      _exportPaysageArbre,
                          (value) => setState(() => _exportPaysageArbre = value),
                      Icons.landscape,
                    ),

                    _buildDataTile(
                      "Fréquentation humaine",
                      "Niveau de passage et d'activité",
                      _exportFrequentationHumaine,
                          (value) => setState(() => _exportFrequentationHumaine = value),
                      Icons.people,
                    ),

                    _buildDataTile(
                      "Protection réglementaire",
                      "Statuts de protection légale",
                      _exportProtectionReglementaire,
                          (value) => setState(() => _exportProtectionReglementaire = value),
                      Icons.shield,
                    ),

                    const SizedBox(height: 16),
                    _buildSectionTitle("Gestion et interventions"),
                    const SizedBox(height: 12),

                    _buildDataTile(
                      "Interventions nécessaires",
                      "Actions à programmer",
                      _exportInterventionsNecessaires,
                          (value) => setState(() => _exportInterventionsNecessaires = value),
                      Icons.build,
                    ),

                    _buildDataTile(
                      "Commentaires techniques",
                      "Observations et notes",
                      _exportCommentaires,
                          (value) => setState(() => _exportCommentaires = value),
                      Icons.comment,
                    ),

                    const SizedBox(height: 16),
                    _buildSectionTitle("Métadonnées"),
                    const SizedBox(height: 12),

                    _buildDataTile(
                      "Date de modification",
                      "Dernière mise à jour des données",
                      _exportDateModification,
                          (value) => setState(() => _exportDateModification = value),
                      Icons.update,
                    ),

                    _buildDataTile(
                      "Dernier modificateur",
                      "Opérateur ayant effectué la dernière modification",
                      _exportDernierModificateur,
                          (value) => setState(() => _exportDernierModificateur = value),
                      Icons.person_outline,
                    ),

                    _buildDataTile(
                      "Photos associées",
                      "Images et documentation visuelle",
                      _exportPhotos,
                          (value) => setState(() => _exportPhotos = value),
                      Icons.photo_camera,
                    ),

                    const SizedBox(height: 16),

                    // Aperçu final
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppColors.cardBackground,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppColors.primaryGreen.withAlpha(50)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(Icons.preview, color: AppColors.primaryGreen, size: 20),
                              const SizedBox(width: 8),
                              Text(
                                "Aperçu de l'export",
                                style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.primaryGreen,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          Text(
                            "Format: $_formatExport • Période: $_filtreDate\n"
                                "${_getSelectedFieldsCount()} champs • ${_getEstimatedSize()}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
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
                        onPressed: () => _exportData(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.primaryGreen,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.download, color: Colors.white, size: 20),
                            const SizedBox(width: 8),
                            const Text(
                              "Exporter",
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
    final isSelected = _formatExport == format;
    return GestureDetector(
      onTap: () => setState(() => _formatExport = format),
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

  Widget _buildRequiredDataTile(String title, String subtitle, IconData icon) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.primaryGreen.withAlpha(25),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.primaryGreen.withAlpha(50)),
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
                        fontWeight: FontWeight.w600,
                        fontSize: 13,
                      ),
                    ),
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
          Icon(Icons.check, color: AppColors.primaryGreen, size: 20),
        ],
      ),
    );
  }

  Widget _buildDataTile(
      String title,
      String subtitle,
      bool value,
      ValueChanged<bool> onChanged,
      IconData icon,
      ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(icon, color: AppColors.primaryGreen, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 13,
                  ),
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
            onChanged: onChanged,
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

  int _getSelectedFieldsCount() {
    int count = 2; // Numéro station + coordonnées (obligatoires)
    if (_exportEssenceArbre) count++;
    if (_exportEtatSanitaire) count++;
    if (_exportStadeDeveloppement) count++;
    if (_exportPaysageArbre) count++;
    if (_exportFrequentationHumaine) count++;
    if (_exportProtectionReglementaire) count++;
    if (_exportInterventionsNecessaires) count++;
    if (_exportCommentaires) count++;
    if (_exportPhotos) count++;
    if (_exportDernierModificateur) count++;
    if (_exportDateModification) count++;
    return count;
  }

  String _getEstimatedSize() {
    double baseSize = 0.05; // MB par station
    int stations = widget.totalStations > 0 ? widget.totalStations : 500;

    if (_exportPhotos) baseSize += 0.2;
    if (_exportCommentaires) baseSize += 0.02;
    if (_exportProtectionReglementaire) baseSize += 0.01;

    double totalSize = baseSize * stations;

    if (totalSize < 1) {
      return "${(totalSize * 1000).toStringAsFixed(0)} KB";
    }
    return "${totalSize.toStringAsFixed(1)} MB";
  }

  void _exportData() {
    Navigator.pop(context);

    // Collect selected fields
    List<String> selectedFields = ['numeroStation', 'coordonnees'];
    if (_exportEssenceArbre) selectedFields.add('essenceArbre');
    if (_exportEtatSanitaire) selectedFields.add('etatSanitaire');
    if (_exportStadeDeveloppement) selectedFields.add('stadeDeveloppement');
    if (_exportPaysageArbre) selectedFields.add('paysageArbre');
    if (_exportFrequentationHumaine) selectedFields.add('frequentationHumaine');
    if (_exportProtectionReglementaire) selectedFields.add('protectionReglementaire');
    if (_exportInterventionsNecessaires) selectedFields.add('interventionsNecessaires');
    if (_exportCommentaires) selectedFields.add('commentaires');
    if (_exportPhotos) selectedFields.add('photos');
    if (_exportDernierModificateur) selectedFields.add('dernierModificateur');
    if (_exportDateModification) selectedFields.add('dateModification');

    // TODO: Implement actual export logic
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            'Export $_formatExport en cours... ${selectedFields.length} champs sélectionnés'
        ),
        backgroundColor: AppColors.primaryGreen,
      ),
    );
  }
}