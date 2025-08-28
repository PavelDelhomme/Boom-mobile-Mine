import 'package:boom_mobile/data/services/station_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:boom_mobile/core/widgets/form/boom_title_with_divider.dart';

import 'package:boom_mobile/domain/entities/station.dart';

class StationFormesTab extends StatefulWidget {
  final Station station;
  final VoidCallback? onModified;
  final VoidCallback? onEditGeometry;

  const StationFormesTab({
    super.key,
    required this.station,
    this.onModified,
    this.onEditGeometry,
  });

  @override
  State<StationFormesTab> createState() => _StationFormesTabState();
}

class _StationFormesTabState extends State<StationFormesTab> {
  // Contrôleurs pour les champs texte
  final TextEditingController _circonferenceController = TextEditingController();
  final TextEditingController _hauteurController = TextEditingController();

  // Valeurs pour les champs à options
  String? _selectedStructureTronc;
  String? _selectedPortForme;
  String? _selectedDiametreTronc;
  String? _selectedDiametreHouppier;

  // Options pour les champs à sélection
  final List<String> _structuresTronc = [
    'Tronc unique',
    'Cépée',
    '1/2 tige (arbre fruitier)',
  ];

  final List<String> _portsForme = [
    'Libre - naturel',
    'Semi-libre',
    'Semi-libre continu',
    'Mutilé',
    'Architecturé',
    'Emonde - ragosse - trogne',
    'En reconversion vers port libre',
    'En reconversion vers port architecturé',
  ];

  final List<String> _diametresTronc = [
    '0-10', '10-20', '20-30', '30-40', '40-60', '60-80', '>80',
  ];

  final List<String> _diametresHouppier = [
    '<5', '5-10', '10-15', '15-20', '20-25', '>25',
  ];

  @override
  void initState() {
    super.initState();
    _initializeFromStation();
  }

  void _initializeFromStation() {
    final stationService = Provider.of<StationService>(context, listen: false);
    final station = stationService.getStation(widget.station);

    // ✅ CORRECTION: Initialiser les contrôleurs avec conversion de types
    _circonferenceController.text = station.circonferenceTronc?.toString() ?? '';
    _hauteurController.text = station.hauteurGenerale?.toString() ?? '';

    // ✅ CORRECTION: Initialiser les valeurs de sélection avec gestion null
    _selectedStructureTronc = station.structureTronc;
    _selectedPortForme = station.portForme;

    // ✅ CORRECTION: Pour diametreTronc qui est maintenant double?, on le convertit en String pour l'affichage
    _selectedDiametreTronc = station.diametreTronc != null
        ? station.diametreTronc.toString()  // Cette ligne pourrait causer une erreur si diametreTronc est utilisé comme dropdown
        : null;
    _selectedDiametreHouppier = station.diametreHouppier;
  }

  @override
  void dispose() {
    _circonferenceController.dispose();
    _hauteurController.dispose();
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
            const BoomBoutton(title: "STRUCTURE"),
            const SizedBox(height: 16),

            // Structure du tronc
            DropdownButtonFormField<String>(
              value: _selectedStructureTronc,
              decoration: const InputDecoration(
                labelText: "Structure du tronc",
                border: OutlineInputBorder(),
              ),
              items: _structuresTronc.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedStructureTronc = newValue;
                });
                stationService.updateStation(
                  station,
                  structureTronc: newValue,
                );
              },
            ),

            const SizedBox(height: 16),

            // Port / Forme
            DropdownButtonFormField<String>(
              value: _selectedPortForme,
              decoration: const InputDecoration(
                labelText: "Port / Forme",
                border: OutlineInputBorder(),
              ),
              items: _portsForme.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedPortForme = newValue;
                });
                stationService.updateStation(
                  station,
                  portForme: newValue,
                );
              },
            ),

            const SizedBox(height: 24),
            const BoomBoutton(title: "DIMENSIONS"),
            const SizedBox(height: 16),

            // ✅ CORRECTION: Diamètre du tronc - Utiliser un TextField pour saisie numérique
            TextField(
              decoration: const InputDecoration(
                labelText: "Diamètre de tronc (à 1m30 - cm)",
                border: OutlineInputBorder(),
                hintText: "Ex: 25.5",
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              controller: TextEditingController(
                text: station.diametreTronc?.toString() ?? '',
              ),
              onChanged: (value) {
                final diameter = double.tryParse(value);
                stationService.updateStation(
                  station,
                  diametreTronc: diameter,
                );
              },
            ),

            const SizedBox(height: 16),

            // Circonférence du tronc
            TextField(
              controller: _circonferenceController,
              decoration: const InputDecoration(
                labelText: "Circonférence de tronc (cm)",
                border: OutlineInputBorder(),
                hintText: "Ex: 120",
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final circonference = double.tryParse(value);
                stationService.updateStation(
                  station,
                  circonferenceTronc: circonference,
                );
              },
            ),

            const SizedBox(height: 16),

            // Diamètre du houppier
            DropdownButtonFormField<String>(
              value: _selectedDiametreHouppier,
              decoration: const InputDecoration(
                labelText: "Diamètre du houppier (m)",
                border: OutlineInputBorder(),
              ),
              items: _diametresHouppier.map((String option) {
                return DropdownMenuItem<String>(
                  value: option,
                  child: Text(option),
                );
              }).toList(),
              onChanged: (String? newValue) {
                setState(() {
                  _selectedDiametreHouppier = newValue;
                });
                stationService.updateStation(
                  station,
                  diametreHouppier: newValue,
                );
              },
            ),

            const SizedBox(height: 16),

            // Hauteur générale
            TextField(
              controller: _hauteurController,
              decoration: const InputDecoration(
                labelText: "Hauteur générale de l'arbre (m)",
                border: OutlineInputBorder(),
                hintText: "Ex: 15",
              ),
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              onChanged: (value) {
                final hauteur = double.tryParse(value);
                stationService.updateStation(
                  station,
                  hauteurGenerale: hauteur,
                );
              },
            ),

            const SizedBox(height: 24),
            const BoomBoutton(title: "VISUALISATION"),
            const SizedBox(height: 16),

            // Section de visualisation schématique (à implémenter dans une future version)
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.park, size: 64, color: Colors.green.shade300),
                    const SizedBox(height: 16),
                    const Text(
                      "Schéma visuel de l'arbre",
                      style: TextStyle(
                        color: Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      "Visualisation à venir dans une prochaine version",
                      style: TextStyle(
                        color: Colors.grey,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),
          ],
        );
      },
    );
  }
}