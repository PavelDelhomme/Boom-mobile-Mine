import 'package:boom_mobile/data/services/station_service.dart';
import 'package:boom_mobile/domain/entities/station.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boom_mobile/core/widgets/form/boom_text_field.dart';
import 'package:boom_mobile/core/widgets/form/boom_switch_tile.dart';
import 'package:boom_mobile/core/widgets/form/boom_slider.dart';
import 'package:boom_mobile/core/widgets/form/boom_title_with_divider.dart';
import 'package:boom_mobile/core/widgets/form/boom_text_area_field.dart';

class StationContextTab extends StatefulWidget {
  final Station station;
  final VoidCallback onModified;

  const StationContextTab({super.key, required this.station, required this.onModified});

  @override
  State<StationContextTab> createState() => _StationContextTabState();
}

class _StationContextTabState extends State<StationContextTab> {
  late String? selectedTreeLandscape;
  late int humanFrequency;
  late bool espaceBoiseClasse;
  late bool interetPaysager;
  late bool codeEnvironnement;
  late bool alleeArbres;
  late bool perimetreMonument;
  late bool sitePatrimonial;
  late bool autresProtections;
  late bool meriteProtection;
  late String commentaireProtection;
  late String commentaireMeriteProtection;
  TextEditingController commentaireController = TextEditingController();
  TextEditingController commentaireMeriteController = TextEditingController();

  // Liste complète synchronisée avec mock_data.dart
  final List<String> treeLandscapeOptions = [
    'Parc public',
    'Jardin public',
    'Alignement de rue',
    'Place publique',
    'Cour d\'école',
    'Cimetière',
    'Espace vert résidentiel',
    'Zone industrielle',
    'Rond-point',
    'Parking',
    'Terrain de sport',
    'Bord de rivière',
    'Forêt',
    'Privé',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFromStation();
  }

  void _initializeFromStation() {
    final stationService = Provider.of<StationService>(context, listen: false);
    final station = stationService.getStation(widget.station);

    // Validation et initialisation des valeurs
    selectedTreeLandscape = treeLandscapeOptions.contains(station.treeLandscape)
        ? station.treeLandscape
        : null;

    humanFrequency = station.humanFrequency ?? 3;
    espaceBoiseClasse = station.espaceBoiseClasse ?? false;
    interetPaysager = station.interetPaysager ?? false;
    codeEnvironnement = station.codeEnvironnement ?? false;
    alleeArbres = station.alleeArbres ?? false;
    perimetreMonument = station.perimetreMonument ?? false;
    sitePatrimonial = station.sitePatrimonial ?? false;
    autresProtections = station.autresProtections ?? false;
    meriteProtection = station.meriteProtection ?? false;
    commentaireProtection = station.commentaireProtection ?? '';
    commentaireMeriteProtection = station.commentaireMeriteProtection ?? '';

    commentaireController.text = commentaireProtection;
    commentaireMeriteController.text = commentaireMeriteProtection;
  }

  @override
  void dispose() {
    commentaireController.dispose();
    commentaireMeriteController.dispose();
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
            BoomTextField(
              label: "Dernière modification effectuée",
              value: station.lastModifiedBy ?? "N/A",
              readOnly: true,
            ),
            const SizedBox(height: 12),

            DropdownButtonFormField<String>(
              value: selectedTreeLandscape,
              decoration: const InputDecoration(labelText: "Paysage de l'arbre"),
              items: treeLandscapeOptions.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  selectedTreeLandscape = newValue;
                });
                stationService.updateStation(
                  station,
                  treeLandscape: newValue,
                );
              },
            ),

            const SizedBox(height: 16),
            BoomSlider(
              label: "Indice de fréquentation humaine",
              min: 1,
              max: 5,
              value: (station.humanFrequency ?? humanFrequency).toDouble(),
              onChanged: (v) {
                setState(() {
                  humanFrequency = v.toInt();
                });
                stationService.updateStation(
                  station,
                  humanFrequency: v.toInt(),
                );
              },
            ),
            const SizedBox(height: 16),
            BoomTextField(
              label: "Dernière modification effectuée",
              value: station.lastModifiedBy ?? "N/A",
              readOnly: true,
            ),
            const SizedBox(height: 24),
            const BoomBoutton(
                title: "PROTECTION RÉGLEMENTAIRE?"
            ),
            const SizedBox(height: 12),
            BoomSwitchTile(
              title: "Espace Boisé Classé",
              value: station.espaceBoiseClasse ?? espaceBoiseClasse,
              onChanged: (value) {
                setState(() {
                  espaceBoiseClasse = value;
                });
                stationService.updateStation(
                  station,
                  espaceBoiseClasse: value,
                );
              },
            ),
            BoomSwitchTile(
              title: "Espace d'Intérêt Paysager",
              value: station.interetPaysager ?? interetPaysager,
              onChanged: (value) {
                setState(() {
                  interetPaysager = value;
                });
                stationService.updateStation(
                  station,
                  interetPaysager: value,
                );
              },
            ),
            BoomSwitchTile(
              title: "Code de l'environnement",
              value: station.codeEnvironnement ?? codeEnvironnement,
              onChanged: (value) {
                setState(() {
                  codeEnvironnement = value;
                });
                stationService.updateStation(
                  station,
                  codeEnvironnement: value,
                );
              },
            ),
            BoomSwitchTile(
              title: "Allée d'arbres (Art. L350-3 code de l'environnement)",
              value: station.alleeArbres ?? alleeArbres,
              onChanged: (value) {
                setState(() {
                  alleeArbres = value;
                });
                stationService.updateStation(
                  station,
                  alleeArbres: value,
                );
              },
            ),
            BoomSwitchTile(
              title: "Périmètre monument historique/site classé",
              value: station.perimetreMonument ?? perimetreMonument,
              onChanged: (value) {
                setState(() {
                  perimetreMonument = value;
                });
                stationService.updateStation(
                  station,
                  perimetreMonument: value,
                );
              },
            ),
            BoomSwitchTile(
              title: "Site Patrimonial Remarquable (ex-AVAP et ex-ZPPAUP)",
              value: station.sitePatrimonial ?? sitePatrimonial,
              onChanged: (value) {
                setState(() {
                  sitePatrimonial = value;
                });
                stationService.updateStation(
                  station,
                  sitePatrimonial: value,
                );
              },
            ),
            BoomSwitchTile(
              title: "Autres",
              value: station.autresProtections ?? autresProtections,
              onChanged: (value) {
                setState(() {
                  autresProtections = value;
                });
                stationService.updateStation(
                  station,
                  autresProtections: value,
                );
              },
            ),
            const SizedBox(height: 12),

            BoomTextAreaField(
              label: "Commentaire Protection réglementaire",
              value: station.commentaireProtection ?? commentaireProtection,
              onChanged: (value) {
                setState(() {
                  commentaireProtection = value;
                });
                stationService.updateStation(
                  station,
                  commentaireProtection: value,
                );
              },
            ),

            const SizedBox(height: 16),

            BoomSwitchTile(
              title: "L'entité mériterait-elle une protection?",
              value: station.meriteProtection ?? meriteProtection,
              onChanged: (value) {
                setState(() {
                  meriteProtection = value;
                });
                stationService.updateStation(
                  station,
                  meriteProtection: value,
                );
              },
            ),

            const SizedBox(height: 12),

            if (station.meriteProtection ?? meriteProtection)
              BoomTextAreaField(
                label: "Commentaire sur le mérite de protection",
                value: station.commentaireMeriteProtection ?? commentaireMeriteProtection,
                onChanged: (value) {
                  setState(() {
                    commentaireMeriteProtection = value;
                  });
                  stationService.updateStation(
                    station,
                    commentaireMeriteProtection: value,
                  );
                },
              ),
          ],
        );
      },
    );
  }
}