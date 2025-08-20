import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/core/widgets/buttons/copy_button.dart';
import 'package:boom_mobile/domain/entities/station.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/in_map_elements/stations/bottomsheet/tabs/context_tab.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/in_map_elements/stations/bottomsheet/tabs/formes_tab.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/in_map_elements/stations/bottomsheet/tabs/identity_tab.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/in_map_elements/stations/bottomsheet/station_tab_bar_headers.dart';
import 'package:boom_mobile/services/station_service.dart';
import 'package:boom_mobile/services/modification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class StationBottomSheet extends StatefulWidget {
  final Station station;
  final String? dossierName; // ✅ Nom du dossier pour les modifications
  final VoidCallback? onDrawingRequested;

  const StationBottomSheet({
    super.key,
    required this.station,
    this.dossierName,
    this.onDrawingRequested,
  });

  @override
  State<StationBottomSheet> createState() => _StationBottomSheetState();
}

class _StationBottomSheetState extends State<StationBottomSheet> {
  int currentTabIndex = 0;
  Station? _originalStation; // ✅ Station originale pour le rollback
  bool _hasUnsavedChanges = false; // ✅ Indicateur de modifications non sauvées

  @override
  void initState() {
    super.initState();
    // ✅ Sauvegarder l'état original de la station
    final stationService = context.read<StationService>();
    _originalStation = stationService.getStation(widget.station);
  }

  // ✅ Vérifier s'il y a des modifications locales
  void _checkForChanges() {
    if (_originalStation != null) {
      final stationService = context.read<StationService>();
      final currentStation = stationService.getStation(widget.station);

      // Comparaison simple - dans un vrai projet, vous pourriez avoir une méthode equals
      final hasChanges = _originalStation!.identifiantExterne != currentStation.identifiantExterne ||
          _originalStation!.adresse != currentStation.adresse ||
          _originalStation!.essenceLibre != currentStation.essenceLibre ||
          _originalStation!.baseDonneesEssence != currentStation.baseDonneesEssence;

      if (hasChanges != _hasUnsavedChanges) {
        setState(() {
          _hasUnsavedChanges = hasChanges;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer2<StationService, ModificationService>(
      builder: (context, stationService, modificationService, child) {
        final station = stationService.getStation(widget.station);

        return FractionallySizedBox(
          heightFactor: 0.95,
          child: Container(
            padding: const EdgeInsets.only(top: 16, left: 16, right: 16),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ✅ En-tête avec indicateur de modifications
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Text(
                          'Station ${station.numeroStation}',
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primaryGreen,
                          ),
                        ),
                        // ✅ Indicateur de modifications
                        if (_hasUnsavedChanges ||
                            (widget.dossierName != null &&
                                modificationService.hasPendingModifications(widget.dossierName!)))
                          Container(
                            margin: const EdgeInsets.only(left: 8),
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.orange,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text(
                              'Modifié',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                      ],
                    ),
                    Row(
                      children: [
                        // Bouton pour passer en mode dessin
                        if (widget.onDrawingRequested != null)
                          IconButton(
                            icon: const Icon(Icons.edit_location_alt, color: Colors.green),
                            tooltip: 'Dessiner sur la carte',
                            onPressed: () {
                              // ✅ Retourner les données nécessaires pour le mode dessin
                              Navigator.pop(context, {
                                'drawingMode': true,
                                'station': station,
                                'dossierName': widget.dossierName,
                              });
                            },
                          ),

                        // Bouton pour copier les coordonnées
                        BoomCopyButton(onTap: () {
                          // Copier les coordonnées de la station dans le presse-papiers
                          final text = "Station ${station.numeroStation}: ${station.latitude}, ${station.longitude}";
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Coordonnées copiées dans le presse-papiers')),
                          );
                        }),

                        // ✅ Bouton de rollback local si modifications
                        if (_hasUnsavedChanges)
                          IconButton(
                            icon: const Icon(Icons.undo, color: Colors.orange),
                            tooltip: 'Annuler les modifications',
                            onPressed: _rollbackLocalChanges,
                          ),

                        IconButton(
                          icon: const Icon(Icons.close),
                          onPressed: () => Navigator.pop(context),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),

                // ✅ Barre d'information des modifications si applicable
                if (widget.dossierName != null &&
                    modificationService.hasPendingModifications(widget.dossierName!))
                  Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.orange.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: Colors.orange.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.info_outline, color: Colors.orange, size: 16),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Cette station a des modifications non sauvegardées',
                            style: TextStyle(
                              color: Colors.orange.shade800,
                              fontSize: 12,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Barre d'onglets
                StationTabBarHeaders(
                  currentIndex: currentTabIndex,
                  onTap: (i) => setState(() => currentTabIndex = i),
                ),

                const SizedBox(height: 8),

                // Contenu
                Expanded(
                  child: IndexedStack(
                    index: currentTabIndex,
                    children: [
                      // ✅ Onglet Contexte avec callback de modification
                      StationContextTab(
                        station: station,
                        onModified: () {
                          _checkForChanges();
                          _registerModification(station);
                        },
                      ),

                      // ✅ Onglet Identité avec callback de modification
                      StationIdentiteTab(
                        station: station,
                        onPhotosUpdated: (newPhotos) {
                          stationService.updateStation(
                            station,
                            photoUrls: newPhotos,
                          );
                          _checkForChanges();
                          _registerModification(station);
                        },
                        onModified: () {
                          _checkForChanges();
                          _registerModification(station);
                        },
                      ),

                      // ✅ Onglet Formes avec callback de modification
                      StationFormesTab(
                        station: station,
                        onModified: () {
                          _checkForChanges();
                          _registerModification(station);
                        },
                      ),
                    ],
                  ),
                ),

                // ✅ Boutons d'action en bas
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  child: Row(
                    children: [
                      // Bouton Annuler (si modifications)
                      if (_hasUnsavedChanges) ...[
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: _rollbackLocalChanges,
                            icon: const Icon(Icons.undo),
                            label: const Text('Annuler'),
                            style: OutlinedButton.styleFrom(
                              foregroundColor: Colors.orange,
                              side: const BorderSide(color: Colors.orange),
                              padding: const EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                      ],

                      // Bouton Enregistrer
                      Expanded(
                        flex: _hasUnsavedChanges ? 1 : 1,
                        child: ElevatedButton.icon(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                          onPressed: _saveChanges,
                          icon: const Icon(Icons.save),
                          label: Text(
                            _hasUnsavedChanges ? 'Enregistrer' : 'Fermer',
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ✅ Enregistrer la modification dans le service
  void _registerModification(Station station) {
    if (widget.dossierName != null && _originalStation != null) {
      final modificationService = context.read<ModificationService>();
      modificationService.addStationModification(
        dossierName: widget.dossierName!,
        station: station,
        previousStation: _originalStation,
        type: ModificationType.stationUpdate,
      );
    }
  }

  // ✅ Rollback des modifications locales
  void _rollbackLocalChanges() {
    if (_originalStation != null) {
      final stationService = context.read<StationService>();

      // Restaurer tous les champs de la station originale
      stationService.updateStation(
        widget.station,
        identifiantExterne: _originalStation!.identifiantExterne,
        archiveNumero: _originalStation!.archiveNumero,
        adresse: _originalStation!.adresse,
        baseDonneesEssence: _originalStation!.baseDonneesEssence,
        essenceLibre: _originalStation!.essenceLibre,
        variete: _originalStation!.variete,
        stadeDeveloppement: _originalStation!.stadeDeveloppement,
        sujetVeteran: _originalStation!.sujetVeteran,
        anneePlantation: _originalStation!.anneePlantation,
        appartenantGroupe: _originalStation!.appartenantGroupe,
        arbreReplanter: _originalStation!.arbreReplanter,
        structureTronc: _originalStation!.structureTronc,
        portForme: _originalStation!.portForme,
        diametreTronc: _originalStation!.diametreTronc,
        circonferenceTronc: _originalStation!.circonferenceTronc,
        diametreHouppier: _originalStation!.diametreHouppier,
        hauteurGenerale: _originalStation!.hauteurGenerale,
        treeLandscape: _originalStation!.treeLandscape,
        humanFrequency: _originalStation!.humanFrequency,
        photoUrls: _originalStation!.photoUrls,
      );

      setState(() {
        _hasUnsavedChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Modifications annulées'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  // ✅ Sauvegarder les modifications
  void _saveChanges() {
    if (_hasUnsavedChanges) {
      final stationService = context.read<StationService>();
      stationService.saveChanges();

      // Mettre à jour la station originale
      _originalStation = stationService.getStation(widget.station);

      setState(() {
        _hasUnsavedChanges = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Station sauvegardée avec succès'),
          backgroundColor: Colors.green,
        ),
      );
    }

    // Fermer le bottom sheet
    Navigator.pop(context);
  }
}