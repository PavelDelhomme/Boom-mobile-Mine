import 'dart:math';
import 'dart:math' as math;

import 'package:boom_mobile/domain/entities/user.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../presentation/screens/map/widgets/in_map_elements/station_marker.dart';
import 'entities/account.dart';
import 'entities/dossier.dart';
import 'entities/layer.dart';
import 'entities/station.dart';

// ✅ Constantes pour les couleurs de stations
const List<Color> allowedStationColors = [
  Colors.green,
  Colors.blue,
  Colors.orange,
  Colors.red,
  Colors.purple,
  Colors.brown,
  Colors.pink,
  Colors.cyan,
];

// CLASSE PRINCIPALE - Données de base simplifiées
class MockData {
  // Comptes utilisateurs réalistes
  static List<Account> fakeAccounts() => [
    Account(name: 'Alexandre Dupont', detail: 'Compte administrateur'),
    Account(name: 'Sophie Martin', detail: 'Compte gestionnaire'),
    Account(name: 'Pierre Dubois', detail: 'Compte technicien'),
    Account(name: 'Marie Lefevre', detail: 'Compte consultante'),
    Account(name: 'Jean Moreau', detail: 'Compte arboriste'),
    Account(name: 'Camille Bernard', detail: 'Compte supervisor'),
    Account(name: 'Thomas Garcia', detail: 'Compte opérateur terrain'),
    Account(name: 'Emma Rousseau', detail: 'Compte coordinatrice'),
    Account(name: 'Lucas David', detail: 'Compte formateur'),
    Account(name: 'Léa Fontaine', detail: 'Compte responsable SIG'),
  ];

  // Couches réalistes pour un SIG arboricole
  static List<Layer> fakeLayers() => [
    // FONDS DE CARTE
    Layer(
      nom: 'OpenStreetMap',
      type: 'Fond de carte',
      date: 'Temps réel',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = false}) => [],
    ),
    Layer(
      nom: 'Plan IGN',
      type: 'Fond de carte',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = false}) => [],
    ),
    Layer(
      nom: 'Photographies aériennes',
      type: 'Imagerie',
      date: '2023',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = false}) => [],
    ),

    // DONNÉES RÉFÉRENTIEL
    Layer(
      nom: 'Cadastre',
      type: 'Référentiel',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = false}) => [],
    ),
    Layer(
      nom: 'Limites communales',
      type: 'Administratif',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = false}) => [],
    ),

    // DONNÉES MÉTIER ARBORICOLES
    Layer(
      nom: 'Stations arboricoles',
      type: 'Données métier',
      date: '18/02/2025',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = false}) =>
          BoomRealisticData.generateStationMarkers(
            LatLng(48.1173, -1.6778),
            context,
            count: 50,
            showBadges: showBadges,
          ),
    ),
    Layer(
      nom: 'Zones d\'intervention',
      type: 'Données métier',
      date: '15/02/2025',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = false}) =>
          BoomRealisticData.generateInterventionMarkers(
            LatLng(48.1173, -1.6778),
            count: 12,
            showBadges: showBadges,
          ),
    ),
    Layer(
      nom: 'Arbres remarquables',
      type: 'Données métier',
      date: '12/02/2025',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = false}) =>
          BoomRealisticData.generateRemarkableTreeMarkers(
            LatLng(48.1173, -1.6778),
            count: 8,
            showBadges: showBadges,
          ),
    ),

    // RÉGLEMENTAIRE
    Layer(
      nom: 'Espaces boisés classés',
      type: 'Réglementaire',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = false}) => [],
      // ✅ Exemple avec polygones
      polygonBuilder: (context) => [
        Polygon(
          points: [
            LatLng(48.1173, -1.6778),
            LatLng(48.1200, -1.6750),
            LatLng(48.1150, -1.6700),
            LatLng(48.1173, -1.6778),
          ],
          color: Colors.green.withValues(alpha: 0.3),
          borderColor: Colors.green,
          borderStrokeWidth: 2,
          label: 'EBC Zone 1',
        ),
      ],
    ),
    Layer(
      nom: 'ZNIEFF',
      type: 'Environnement',
      date: '2023',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = false}) => [],
    ),
    Layer(
      nom: 'PLU - Zonage',
      type: 'Urbanisme',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = false}) => [],
    ),
  ];

  // Utilisateurs réalistes
  static List<User> fakeUsers() => BoomRealisticData.generateRealisticUsers();

  // Dossiers réalistes
  static List<Dossier> fakeDossiers() => BoomRealisticData.generateRealisticDossiers();
}

// CLASSE DONNÉES RÉALISTES - Spécialisée pour l'arboriculture
class BoomRealisticData {
  // Essences d'arbres françaises réalistes
  static const List<String> essencesArbres = [
    'Chêne pédonculé',
    'Chêne sessile',
    'Hêtre commun',
    'Châtaignier',
    'Frêne commun',
    'Érable sycomore',
    'Tilleul à grandes feuilles',
    'Platane commun',
    'Marronnier d\'Inde',
    'Pin maritime',
    'Pin sylvestre',
    'Bouleau verruqueux',
    'Charme commun',
    'Aulne glutineux',
    'Saule blanc',
  ];

  // États sanitaires professionnels
  static const List<String> etatsSanitaires = [
    'Excellent',
    'Bon',
    'Moyen',
    'Dégradé',
    'Mauvais',
    'Dépérissant',
    'Mort',
  ];

  // Stades de développement arboricoles
  static const List<String> stadesDeveloppement = [
    'Jeune plantation',
    'Jeune arbre',
    'Arbre adulte',
    'Arbre mature',
    'Arbre sénescent',
    'Vétéran',
  ];

  // Types de paysages urbains réalistes
  static const List<String> typesPaysage = [
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
  ];

  // Interventions arboricoles professionnelles
  static const List<String> interventionsNecessaires = [
    'Élagage de formation',
    'Élagage sanitaire',
    'Réduction de couronne',
    'Démontage complet',
    'Abattage simple',
    'Dessouchage',
    'Traitement phytosanitaire',
    'Haubanage',
    'Surveillance renforcée',
    'Plantation de remplacement',
  ];

  // Communes réelles de Rennes Métropole
  static List<Map<String, dynamic>> getCommunesReelles() {
    return [
      {
        'nom': 'Rennes',
        'center': LatLng(48.1173, -1.6778),
        'population': 220488,
        'superficie': 50.39,
        'stations_count': 850,
        'code': 35238, // Code INSEE réel
      },
      {
        'nom': 'Cesson-Sévigné',
        'center': LatLng(48.1210, -1.6245),
        'population': 17234,
        'superficie': 32.22,
        'stations_count': 340,
        'code': 35051,
      },
      {
        'nom': 'Bruz',
        'center': LatLng(48.0214, -1.7464),
        'population': 18567,
        'superficie': 29.87,
        'stations_count': 280,
        'code': 35047,
      },
      {
        'nom': 'Thorigné-Fouillard',
        'center': LatLng(48.1342, -1.5790),
        'population': 8234,
        'superficie': 15.43,
        'stations_count': 150,
        'code': 35342,
      },
      {
        'nom': 'Pacé',
        'center': LatLng(48.1471, -1.7914),
        'population': 10956,
        'superficie': 32.11,
        'stations_count': 180,
        'code': 35206,
      },
    ];
  }

  // ✅ Méthode helper pour générer un point aléatoire autour d'un centre
  static LatLng _generateRandomPoint(LatLng center, double radiusMeters, Random random) {
    // Convertir le rayon en degrés approximativement
    final radiusDegrees = radiusMeters / 111320; // 1 degré ≈ 111.32 km

    final u = random.nextDouble();
    final v = random.nextDouble();

    final w = radiusDegrees * math.sqrt(u);
    final t = 2 * math.pi * v;

    final deltaLat = w * math.cos(t);
    final deltaLng = w * math.sin(t);

    return LatLng(
      center.latitude + deltaLat,
      center.longitude + deltaLng,
    );
  }

  // ✅ CORRECTION: Génération de numéro de station basé sur code commune + index
  static int _generateStationNumber(String communeName, int index) {
    // Obtenir le code INSEE de la commune
    final communes = getCommunesReelles();
    final commune = communes.firstWhere(
          (c) => c['nom'] == communeName,
      orElse: () => {'code': 35000}, // Code par défaut
    );

    final codeCommune = commune['code'] as int;
    // Format: code commune (5 chiffres) + numéro station (3 chiffres)
    return codeCommune * 1000 + (index + 1);
  }

  // ✅ Mise à jour de la méthode pour les dossiers réalistes
  static List<Dossier> generateRealisticDossiers() {
    final communes = getCommunesReelles();
    final Random random = Random();

    return communes.map((communeData) {
      final stations = _generateRealisticStations(
        communeData['center'] as LatLng,
        count: communeData['stations_count'] as int,
        communeName: communeData['nom'] as String,
      );

      final statuts = [
        'Inventaire en cours',
        'En attente de validation',
        'Validé - À programmer',
        'Interventions planifiées',
        'Travaux en cours',
        'Terminé',
      ];

      return Dossier(
        nom: 'Inventaire ${communeData['nom']}',
        type: statuts[random.nextInt(statuts.length)],
        date: _generateRealisticDate(),
        center: communeData['center'] as LatLng,
        stations: stations,
        markerBuilder: (BuildContext context, {bool showBadges = true}) =>
            _generateMarkersFromStations(
              context,
              stations,
              showBadges: showBadges,
            ),
      );
    }).toList();
  }

  // GÉNÉRATION STATIONS RÉALISTES
  static List<Station> _generateRealisticStations(
      LatLng center, {
        required int count,
        required String communeName,
      }) {
    final Random random = Random();

    return List.generate(count, (index) {
      final point = _generateUrbanTreePosition(center, random, communeName);

      final essence = essencesArbres[random.nextInt(essencesArbres.length)];
      final etatSanitaire = etatsSanitaires[random.nextInt(etatsSanitaires.length)];
      final paysage = typesPaysage[random.nextInt(typesPaysage.length)];

      final needsIntervention = random.nextDouble() < 0.3; // 30% nécessitent intervention
      final intervention = needsIntervention
          ? interventionsNecessaires[random.nextInt(interventionsNecessaires.length)]
          : null;

      final urgence = _calculateUrgence(etatSanitaire, needsIntervention);

      return Station(
        numeroStation: _generateStationNumber(communeName, index), // ✅ CORRIGÉ: retourne int
        latitude: point.latitude,
        longitude: point.longitude,
        treesToCut: needsIntervention ? random.nextInt(3) + 1 : null,
        warning: urgence > 2 ? "!" : null,
        highlight: urgence > 1,

        lastModifiedBy: _generateRealisticModifier(),
        treeLandscape: paysage,
        humanFrequency: _calculateFrequency(paysage),

        espaceBoiseClasse: random.nextDouble() < 0.15, // 15% en EBC
        interetPaysager: random.nextDouble() < 0.25,   // 25% d'intérêt paysager
        codeEnvironnement: random.nextDouble() < 0.08, // 8% protégés
        meriteProtection: random.nextDouble() < 0.12,  // 12% mériteraient protection

        commentaireProtection: _generateRealisticComment(essence, etatSanitaire),
        commentaireMeriteProtection: needsIntervention
            ? "Intervention recommandée: $intervention"
            : null,

        photoUrls: _generateRealisticPhotos(random),
      );
    });
  }

  // POSITION URBAINE RÉALISTE
  static LatLng _generateUrbanTreePosition(LatLng center, Random random, String commune) {
    final densityFactors = {
      'Rennes': 0.8,
      'Cesson-Sévigné': 0.6,
      'Bruz': 0.5,
      'Thorigné-Fouillard': 0.4,
      'Pacé': 0.4,
    };

    final density = densityFactors[commune] ?? 0.5;
    final maxRadius = 3000 * (1 - density) + 1000; // Entre 1-4km selon densité

    double distance;
    if (random.nextDouble() < 0.4) {
      // 40% dans le centre (0-30% du rayon)
      distance = maxRadius * 0.3 * random.nextDouble();
    } else if (random.nextDouble() < 0.7) {
      // 30% en zone intermédiaire (30-70% du rayon)
      distance = maxRadius * (0.3 + 0.4 * random.nextDouble());
    } else {
      // 30% en périphérie (70-100% du rayon)
      distance = maxRadius * (0.7 + 0.3 * random.nextDouble());
    }

    final angle = 2 * math.pi * random.nextDouble();
    final dx = (distance * math.cos(angle)) / 111320;
    final dy = (distance * math.sin(angle)) / 111320;

    return LatLng(center.latitude + dy, center.longitude + dx);
  }

  // ✅ GÉNÉRATION MARKERS RÉALISTES À PARTIR DES STATIONS
  static List<Marker> _generateMarkersFromStations(
      BuildContext context,
      List<Station> stations, {
        bool showBadges = true,
      }) {
    return stations.map((station) {
      Color stationColor = _getColorFromHealthState(station);

      return Marker(
        point: LatLng(station.latitude, station.longitude),
        width: 60,
        height: 60,
        child: GestureDetector(
          onTap: () {
            // Interaction avec les stations
            debugPrint('Station ${station.numeroStation} tapée');
          },
          child: StationMarker(
            color: stationColor,
            treesToCut: showBadges ? station.treesToCut : null,
            warning: showBadges ? station.warning : null,
            highlight: station.highlight,
            stationNumber: station.numeroStation, // ✅ Convertir int vers String
          ),
        ),
      );
    }).toList();
  }

  // ✅ GÉNÉRATION MARKERS POUR COUCHES (signature corrigée)
  static List<Marker> generateStationMarkers(
      LatLng center,
      BuildContext context, {
        required int count,
        bool showBadges = true,
      }) {
    final stations = _generateRealisticStations(
      center,
      count: count,
      communeName: 'Rennes',
    );
    return _generateMarkersFromStations(context, stations, showBadges: showBadges);
  }

  static List<Marker> generateInterventionMarkers(
      LatLng center, {
        required int count,
        bool showBadges = true,
      }) {
    final Random random = Random();
    return List.generate(count, (index) {
      final point = _generateUrbanTreePosition(center, random, 'Rennes');

      return Marker(
        point: point,
        width: 40,
        height: 40,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.orange,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
          ),
          child: const Icon(
            Icons.build,
            color: Colors.white,
            size: 20,
          ),
        ),
      );
    });
  }

  static List<Marker> generateRemarkableTreeMarkers(
      LatLng center, {
        required int count,
        bool showBadges = true,
      }) {
    final Random random = Random();
    return List.generate(count, (index) {
      final point = _generateUrbanTreePosition(center, random, 'Rennes');

      return Marker(
        point: point,
        width: 50,
        height: 50,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.purple,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
          ),
          child: const Icon(
            Icons.park,
            color: Colors.white,
            size: 24,
          ),
        ),
      );
    });
  }

  // UTILISATEURS RÉALISTES
  static List<User> generateRealisticUsers() {
    return [
      User(name: "Alexandra Padounou", role: "Responsable technique", date: "Active", email: "a.padounou@aubepine-scop.fr"),
      User(name: "Jean-Marc Lebon", role: "Arboriste-grimpeur", date: "Active", email: "jm.lebon@aubepine-scop.fr"),
      User(name: "Sophie Moreau", role: "Ingénieure environnement", date: "Active", email: "s.moreau@aubepine-scop.fr"),
      User(name: "Pierre Durand", role: "Technicien SIG", date: "Active", email: "p.durand@aubepine-scop.fr"),
      User(name: "Camille Bernard", role: "Gestionnaire données", date: "Active", email: "c.bernard@aubepine-scop.fr"),
      User(name: "Marc Rousseau", role: "Chef d'équipe", date: "Congés", email: "m.rousseau@aubepine-scop.fr"),
      User(name: "Élise Fontaine", role: "Arboriste-conseil", date: "Mission", email: "e.fontaine@aubepine-scop.fr"),
      User(name: "Thomas Leclerc", role: "Conducteur d'engins", date: "Active", email: "t.leclerc@aubepine-scop.fr"),
      User(name: "Marine Dubois", role: "Coordinatrice projets", date: "Active", email: "m.dubois@aubepine-scop.fr"),
      User(name: "Vincent Garcia", role: "Formateur sécurité", date: "Formation", email: "v.garcia@aubepine-scop.fr"),
    ];
  }

  static int _calculateUrgence(String etatSanitaire, bool needsIntervention) {
    if (etatSanitaire == 'Mort' || etatSanitaire == 'Dépérissant') return 3;
    if (etatSanitaire == 'Mauvais' && needsIntervention) return 2;
    if (needsIntervention) return 1;
    return 0;
  }

  static int _calculateFrequency(String paysage) {
    final frequencies = {
      'Place publique': 5,
      'Parc public': 4,
      'Jardin public': 4,
      'Cour d\'école': 4,
      'Alignement de rue': 3,
      'Rond-point': 2,
      'Parking': 2,
      'Cimetière': 2,
      'Zone industrielle': 1,
      'Bord de rivière': 2,
    };
    return frequencies[paysage] ?? 3;
  }

  static String _generateRealisticModifier() {
    final operateurs = [
      'A.Dupont',
      'M.Martin',
      'C.Bernard',
      'S.Rousseau',
      'L.Moreau',
      'P.Lefevre',
      'J.Garcia',
      'N.David',
    ];

    final dates = [
      '15/01/2025 14:23:45',
      '22/01/2025 09:15:12',
      '28/01/2025 16:42:33',
      '03/02/2025 11:07:21',
      '10/02/2025 13:55:18',
    ];

    final random = Random();
    final operateur = operateurs[random.nextInt(operateurs.length)];
    final date = dates[random.nextInt(dates.length)];

    return '$date par $operateur';
  }

  static String _generateRealisticComment(String essence, String etat) {
    final comments = {
      'Excellent': [
        'Sujet remarquable, port équilibré',
        'Croissance vigoureuse, aucun défaut visible',
        'Exemplaire de belle venue',
      ],
      'Bon': [
        'État général satisfaisant',
        'Quelques branches mortes en périphérie',
        'Léger déséquilibre de couronne',
      ],
      'Moyen': [
        'Présence de bois mort dans le houppier',
        'Cavités de petite taille observées',
        'Contraintes d\'espace perceptibles',
      ],
      'Dégradé': [
        'Dépérissement partiel du houppier',
        'Chancres multiples sur le tronc',
        'Décollement d\'écorce important',
      ],
      'Mauvais': [
        'Dépérissement généralisé',
        'Cavités importantes, stabilité compromise',
        'Attaque de pathogènes avérée',
      ],
    };

    final stateComments = comments[etat] ?? ['État à évaluer'];
    final comment = stateComments[Random().nextInt(stateComments.length)];

    return '$essence - $comment';
  }

  static List<String> _generateRealisticPhotos(Random random) {
    final availablePhotos = [
      'assets/images/photo1.png',
      'assets/images/photo2.png',
      'assets/images/effiel.png',
      'assets/images/logo_boom.png',
    ];

    if (random.nextDouble() < 0.6) {
      final count = random.nextInt(3) + 1; // 1 à 3 photos
      return List.generate(
          count,
              (index) => availablePhotos[random.nextInt(availablePhotos.length)]
      );
    }

    return [];
  }

  static String _generateRealisticDate() {
    final dates = [
      '15/01/2025',
      '22/01/2025',
      '28/01/2025',
      '03/02/2025',
      '08/02/2025',
      '12/02/2025',
      '18/02/2025',
    ];
    return dates[Random().nextInt(dates.length)];
  }

  // ✅ Méthode utilitaire pour obtenir la couleur selon l'état de santé
  static Color _getColorFromHealthState(Station station) {
    // Logique pour déterminer la couleur selon l'état de la station
    if (station.warning != null) {
      return Colors.red; // Urgent
    } else if (station.treesToCut != null && station.treesToCut! > 0) {
      return Colors.orange; // Intervention nécessaire
    } else if (station.highlight) {
      return Colors.yellow; // Attention
    } else {
      return Colors.green; // Bon état
    }
  }
}