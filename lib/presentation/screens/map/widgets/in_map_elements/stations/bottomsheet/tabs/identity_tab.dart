import 'package:boom_mobile/data/services/station_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boom_mobile/core/widgets/form/boom_text_field.dart';
import 'package:boom_mobile/core/widgets/form/boom_switch_tile.dart';
import 'package:boom_mobile/core/widgets/form/boom_photo_viewer.dart';
import 'package:boom_mobile/core/widgets/form/boom_title_with_divider.dart';

import 'package:boom_mobile/domain/entities/station.dart';

class StationIdentiteTab extends StatefulWidget {
  final Station station;
  final Function(List<String>)? onPhotosUpdated; // Optionnel pour compatibilité
  final VoidCallback onModified;

  const StationIdentiteTab({
    super.key,
    required this.station,
    this.onPhotosUpdated,
    required this.onModified,
  });

  @override
  State<StationIdentiteTab> createState() => _StationIdentiteTabState();
}

class _StationIdentiteTabState extends State<StationIdentiteTab> {
  // Contrôleurs pour les champs texte
  final TextEditingController _identifiantExterneController = TextEditingController();
  final TextEditingController _archiveNumeroController = TextEditingController();
  final TextEditingController _adresseController = TextEditingController();
  final TextEditingController _essenceLibreController = TextEditingController();
  final TextEditingController _varieteController = TextEditingController();
  final TextEditingController _anneePlantationController = TextEditingController();

  // Valeurs pour les champs à options
  String? _selectedBaseDonneesEssence;
  String? _selectedStadeDeveloppement;
  bool _sujetVeteran = false;
  bool _appartenantGroupe = false;
  bool _arbreReplanter = false;

  // Bases de données d'essences (liste pour autocomplétion)
  final List<String> _basesDonneesEssences = [
    'Acer campestre - Érable champêtre',
    'Acer platanoides - Érable plane',
    'Acer pseudoplatanus - Érable sycomore',
    'Aesculus hippocastanum - Marronnier d\'Inde',
    'Alnus glutinosa - Aulne glutineux',
    'Betula pendula - Bouleau verruqueux',
    'Carpinus betulus - Charme commun',
    'Castanea sativa - Châtaignier',
    'Fagus sylvatica - Hêtre commun',
    'Fraxinus excelsior - Frêne commun',
    'Platanus x hispanica - Platane commun',
    'Populus alba - Peuplier blanc',
    'Quercus petraea - Chêne sessile',
    'Quercus robur - Chêne pédonculé',
    'Salix alba - Saule blanc',
    'Tilia cordata - Tilleul à petites feuilles',
    'Tilia platyphyllos - Tilleul à grandes feuilles',
    'Ulmus minor - Orme champêtre',
  ];

  // Stades de développement
  final List<String> _stadesDeveloppement = [
    'Juvénile / jeune',
    'Jeune adulte',
    'Adulte',
    'Adulte mature',
    'Sénescent',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFromStation();
  }

  void _initializeFromStation() {
    final stationService = Provider.of<StationService>(context, listen: false);
    final station = stationService.getStation(widget.station);

    // Initialiser les contrôleurs avec les valeurs existantes
    _identifiantExterneController.text = station.identifiantExterne ?? '';
    _archiveNumeroController.text = station.archiveNumero ?? '';
    _adresseController.text = station.adresse ?? '';
    _essenceLibreController.text = station.essenceLibre ?? '';
    _varieteController.text = station.variete ?? '';

    // ✅ CORRECTION: Conversion sécurisée int? vers String
    _anneePlantationController.text = station.anneePlantation?.toString() ?? '';

    // Initialiser les valeurs de sélection
    _selectedBaseDonneesEssence = station.baseDonneesEssence;
    _selectedStadeDeveloppement = station.stadeDeveloppement;
    _sujetVeteran = station.sujetVeteran ?? false;
    _appartenantGroupe = station.appartenantGroupe ?? false;
    _arbreReplanter = station.arbreReplanter ?? false;
  }

  @override
  void dispose() {
    _identifiantExterneController.dispose();
    _archiveNumeroController.dispose();
    _adresseController.dispose();
    _essenceLibreController.dispose();
    _varieteController.dispose();
    _anneePlantationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<StationService>(
      builder: (context, stationService, child) {
        final station = stationService.getStation(widget.station);

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const BoomBoutton(title: "IDENTIFIANTS"),
            const SizedBox(height: 16),

            // Identifiant station (lecture seule)
            BoomTextField(
              label: "Identifiant",
              value: station.numeroStation.toString(),
              readOnly: true,
            ),

            const SizedBox(height: 12),

            // Identifiant externe
            TextField(
              controller: _identifiantExterneController,
              decoration: const InputDecoration(
                labelText: "Identifiant externe",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                stationService.updateStation(
                  station,
                  identifiantExterne: value,
                );
              },
            ),

            const SizedBox(height: 12),

            // Numéro d'archive
            TextField(
              controller: _archiveNumeroController,
              decoration: const InputDecoration(
                labelText: "Archive numéro",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                stationService.updateStation(
                  station,
                  archiveNumero: value,
                );
              },
            ),

            const SizedBox(height: 12),

            // Adresse
            TextField(
              controller: _adresseController,
              decoration: const InputDecoration(
                labelText: "Adresse",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                stationService.updateStation(
                  station,
                  adresse: value,
                );
              },
            ),

            const SizedBox(height: 24),
            const BoomBoutton(title: "ESSENCE"),
            const SizedBox(height: 16),

            // Base de données d'essence (avec autocomplétion)
            Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) {
                if (textEditingValue.text.isEmpty) {
                  return const Iterable<String>.empty();
                }
                return _basesDonneesEssences.where((option) {
                  return option.toLowerCase().contains(textEditingValue.text.toLowerCase());
                });
              },
              fieldViewBuilder: (
                  BuildContext context,
                  TextEditingController controller,
                  FocusNode focusNode,
                  VoidCallback onFieldSubmitted,
                  ) {
                if (_selectedBaseDonneesEssence != null && controller.text.isEmpty) {
                  controller.text = _selectedBaseDonneesEssence!;
                }

                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: const InputDecoration(
                    labelText: "Base de données d'essence",
                    border: OutlineInputBorder(),
                    hintText: "Commencez à taper pour rechercher",
                  ),
                  onChanged: (value) {
                    _selectedBaseDonneesEssence = value;
                  },
                );
              },
              onSelected: (String selection) {
                _selectedBaseDonneesEssence = selection;
                stationService.updateStation(
                  station,
                  baseDonneesEssence: selection,
                );
              },
            ),

            const SizedBox(height: 12),

            // Essence libre
            TextField(
              controller: _essenceLibreController,
              decoration: const InputDecoration(
                labelText: "Essence libre",
                border: OutlineInputBorder(),
                hintText: "Saisie libre d'essence",
              ),
              onChanged: (value) {
                stationService.updateStation(
                  station,
                  essenceLibre: value,
                );
              },
            ),

            const SizedBox(height: 12),

            // Variété
            TextField(
              controller: _varieteController,
              decoration: const InputDecoration(
                labelText: "Variété",
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                stationService.updateStation(
                  station,
                  variete: value,
                );
              },
            ),

            const SizedBox(height: 24),
            const BoomBoutton(title: "DÉVELOPPEMENT"),
            const SizedBox(height: 16),

            // Stade de développement
            DropdownButtonFormField<String>(
              value: _selectedStadeDeveloppement,
              decoration: const InputDecoration(
                labelText: "Stade de développement",
                border: OutlineInputBorder(),
              ),
              items: _stadesDeveloppement.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStadeDeveloppement = newValue;
                });
                stationService.updateStation(
                  station,
                  stadeDeveloppement: newValue,
                );
              },
            ),

            const SizedBox(height: 12),

            // Sujet vétéran
            BoomSwitchTile(
              title: "Sujet vétéran (vieux)",
              value: station.sujetVeteran ?? _sujetVeteran,
              onChanged: (value) {
                setState(() {
                  _sujetVeteran = value;
                });
                stationService.updateStation(
                  station,
                  sujetVeteran: value,
                );
              },
            ),

            const SizedBox(height: 12),

            // ✅ CORRECTION: Année de plantation - Conversion String vers int?
            TextField(
              controller: _anneePlantationController,
              decoration: const InputDecoration(
                labelText: "Année de plantation",
                border: OutlineInputBorder(),
                hintText: "Ex: 2015",
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                // ✅ CORRECTION: Parser la String en int?
                final annee = int.tryParse(value);
                stationService.updateStation(
                  station,
                  anneePlantation: annee,
                );
              },
            ),

            const SizedBox(height: 16),

            // Groupe d'arbres
            BoomSwitchTile(
              title: "Ce point appartient à un groupe d'arbres",
              value: station.appartenantGroupe ?? _appartenantGroupe,
              onChanged: (value) {
                setState(() {
                  _appartenantGroupe = value;
                });
                stationService.updateStation(
                  station,
                  appartenantGroupe: value,
                );
              },
            ),

            const SizedBox(height: 12),

            // Arbre à replanter
            BoomSwitchTile(
              title: "Arbre à replanter",
              value: station.arbreReplanter ?? _arbreReplanter,
              onChanged: (value) {
                setState(() {
                  _arbreReplanter = value;
                });
                stationService.updateStation(
                  station,
                  arbreReplanter: value,
                );
              },
            ),

            const SizedBox(height: 24),
            const BoomBoutton(title: "PHOTOS"),
            const SizedBox(height: 16),

            // Photos
            BoomPhotoViewer(
              photoPaths: station.photoUrls ?? [],
              onPhotosUpdated: (newPhotos) {
                stationService.updateStation(
                  station,
                  photoUrls: newPhotos,
                );

                // Support pour l'ancien callback si présent
                if (widget.onPhotosUpdated != null) {
                  widget.onPhotosUpdated!(newPhotos);
                }
              },
            ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}