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
  static LatLng _generateRandomPoint(LatLng center, double radiusMeters,
      Random random) {
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

  // GÉNÉRATION STATIONS RÉALISTES AVEC GÉOMÉTRIES
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

      // ✅ NOUVEAU: Générer des géométries réalistes selon le type de paysage
      final geometries = _generateStationGeometries(point, paysage, random);

      return Station(
        numeroStation: _generateStationNumber(communeName, index),
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

        // ✅ NOUVEAU: Ajout des géométries générées
        points: geometries['points'] as List<LatLng>?,
        lignes: geometries['lignes'] as List<List<LatLng>>?,
        polygones: geometries['polygones'] as List<List<LatLng>>?,

        // Identité (ajout des champs manquants)
        identifiantExterne: "EXT-${communeName.substring(0, 3).toUpperCase()}-${index + 1}",
        archiveNumero: random.nextDouble() < 0.3 ? "ARC${random.nextInt(999).toString().padLeft(3, '0')}" : null,
        adresse: _generateRealisticAddress(communeName, random),
        baseDonneesEssence: essence,
        essenceLibre: random.nextDouble() < 0.1 ? "Essence hybride locale" : null,
        variete: random.nextDouble() < 0.2 ? "Variété ${['Alba', 'Pendula', 'Fastigiata', 'Purpurea'][random.nextInt(4)]}" : null,
        stadeDeveloppement: stadesDeveloppement[random.nextInt(stadesDeveloppement.length)],
        sujetVeteran: random.nextDouble() < 0.05, // 5% sont vétérans
        anneePlantation: random.nextDouble() < 0.4 ? (DateTime.now().year - random.nextInt(50)) : null,
        appartenantGroupe: random.nextDouble() < 0.3,
        arbreReplanter: random.nextDouble() < 0.15,

        // Forme et gabarit
        structureTronc: ['Simple', 'Multiple', 'Cépée'][random.nextInt(3)],
        portForme: ['Érigé', 'Étalé', 'Pleureur', 'Fastigié'][random.nextInt(4)],
        diametreTronc: (10 + random.nextInt(80)).toDouble(),
        circonferenceTronc: (30 + random.nextInt(250)).toDouble(),
        hauteurGenerale: (3 + random.nextInt(25)).toDouble(),
      );
    });
  }


  // ✅ NOUVEAU: Génération intelligente de géométries selon le contexte
  static Map<String, dynamic> _generateStationGeometries(
      LatLng center, String paysage, Random random) {

    // Probabilités de géométries selon le type de paysage
    final geometryConfig = _getGeometryConfigForLandscape(paysage);

    List<LatLng>? points;
    List<List<LatLng>>? lignes;
    List<List<LatLng>>? polygones;

    final geometryType = _selectGeometryType(geometryConfig, random);

    switch (geometryType) {
      case 'point':
      // Point simple (arbre isolé)
        points = [center];

        // Parfois des points additionnels pour groupe d'arbres
        if (random.nextDouble() < 0.3) {
          final additionalPoints = _generateNearbyPoints(center, random.nextInt(4) + 1, 10.0, random);
          points.addAll(additionalPoints);
        }
        break;

      case 'ligne':
      // Ligne (alignement d'arbres)
        lignes = [_generateAlignmentLine(center, paysage, random)];

        // Points aux extrémités et intersections importantes
        if (random.nextDouble() < 0.4) {
          points = [lignes.first.first, lignes.first.last];
        }
        break;

      case 'polygone':
      // Polygone (bosquet, zone boisée)
        polygones = [_generateRealisticPolygon(center, paysage, random)];

        // Points remarquables dans la zone
        if (random.nextDouble() < 0.5) {
          points = _generatePointsInPolygon(polygones.first, random.nextInt(3) + 1, random);
        }
        break;

      case 'mixed':
      // Géométrie mixte (complexe urbaine)
        points = [center];
        lignes = [_generateShortLine(center, random)];

        if (random.nextDouble() < 0.6) {
          polygones = [_generateSmallPolygon(center, random)];
        }
        break;
    }

    return {
      'points': points,
      'lignes': lignes,
      'polygones': polygones,
    };
  }

// ✅ Configuration des géométries par type de paysage
  static Map<String, double> _getGeometryConfigForLandscape(String paysage) {
    switch (paysage) {
      case 'Alignement de rue':
        return {'ligne': 0.70, 'point': 0.25, 'polygone': 0.05, 'mixed': 0.0};

      case 'Parc public':
      case 'Jardin public':
        return {'polygone': 0.45, 'point': 0.30, 'ligne': 0.15, 'mixed': 0.10};

      case 'Place publique':
        return {'point': 0.50, 'ligne': 0.30, 'polygone': 0.15, 'mixed': 0.05};

      case 'Espace vert résidentiel':
        return {'polygone': 0.40, 'point': 0.35, 'ligne': 0.15, 'mixed': 0.10};

      case 'Cimetière':
        return {'ligne': 0.45, 'point': 0.35, 'polygone': 0.20, 'mixed': 0.0};

      case 'Rond-point':
        return {'polygone': 0.60, 'point': 0.25, 'ligne': 0.15, 'mixed': 0.0};

      case 'Bord de rivière':
        return {'ligne': 0.55, 'polygone': 0.30, 'point': 0.15, 'mixed': 0.0};

      default:
        return {'point': 0.40, 'ligne': 0.30, 'polygone': 0.25, 'mixed': 0.05};
    }
  }

  // ✅ Sélection du type de géométrie basée sur les probabilités
  static String _selectGeometryType(Map<String, double> config, Random random) {
    final rand = random.nextDouble();
    double cumulative = 0.0;

    for (final entry in config.entries) {
      cumulative += entry.value;
      if (rand <= cumulative) {
        return entry.key;
      }
    }

    return 'point'; // Fallback
  }

  // ✅ Génération de points multiples à proximité
  static List<LatLng> _generateNearbyPoints(LatLng center, int count,
      double radiusMeters, Random random) {
    return List.generate(count, (index) {
      final angle = (2 * math.pi * index) / count + random.nextDouble() * 0.5;
      final distance = radiusMeters * (0.3 + random.nextDouble() * 0.7);

      final dx = (distance * math.cos(angle)) / 111320;
      final dy = (distance * math.sin(angle)) / 111320;

      return LatLng(center.latitude + dy, center.longitude + dx);
    });
  }


  // ✅ Génération d'alignements d'arbres réalistes
  static List<LatLng> _generateAlignmentLine(LatLng center, String paysage,
      Random random) {
    final length = _getAlignmentLength(paysage, random);
    final angle = random.nextDouble() * 2 * math.pi;
    final pointCount = (length / 15).round().clamp(3, 12); // Espacement ~15m

    return List.generate(pointCount, (index) {
      final distance = (length * index) / (pointCount - 1) - length / 2;

      final dx = (distance * math.cos(angle)) / 111320;
      final dy = (distance * math.sin(angle)) / 111320;

      return LatLng(
        center.latitude + dy,
        center.longitude + dx,
      );
    });
  }

  // ✅ Longueur d'alignement selon le contexte
  static double _getAlignmentLength(String paysage, Random random) {
    switch (paysage) {
      case 'Alignement de rue':
        return 80 + random.nextInt(120).toDouble(); // 80-200m
      case 'Cimetière':
        return 40 + random.nextInt(60).toDouble(); // 40-100m
      case 'Parc public':
        return 60 + random.nextInt(90).toDouble(); // 60-150m
      default:
        return 30 + random.nextInt(70).toDouble(); // 30-100m
    }
  }

  // ✅ Génération de polygones réalistes
  static List<LatLng> _generateRealisticPolygon(LatLng center, String paysage,
      Random random) {
    final radius = _getPolygonRadius(paysage, random);
    final vertexCount = _getPolygonVertexCount(paysage, random);

    return List.generate(vertexCount, (index) {
      final baseAngle = (2 * math.pi * index) / vertexCount;
      final angleVariation = (random.nextDouble() - 0.5) *
          0.8; // Variation naturelle
      final angle = baseAngle + angleVariation;

      final radiusVariation = 0.7 +
          random.nextDouble() * 0.6; // 70-130% du rayon
      final actualRadius = radius * radiusVariation;

      final dx = (actualRadius * math.cos(angle)) / 111320;
      final dy = (actualRadius * math.sin(angle)) / 111320;

      return LatLng(center.latitude + dy, center.longitude + dx);
    });
  }

  // ✅ Rayon de polygone selon le contexte
  static double _getPolygonRadius(String paysage, Random random) {
    switch (paysage) {
      case 'Parc public':
      case 'Espace vert résidentiel':
        return 25 + random.nextInt(40).toDouble(); // 25-65m
      case 'Rond-point':
        return 8 + random.nextInt(12).toDouble(); // 8-20m
      case 'Bord de rivière':
        return 15 + random.nextInt(25).toDouble(); // 15-40m
      default:
        return 12 + random.nextInt(20).toDouble(); // 12-32m
    }
  }

  // ✅ Nombre de sommets selon le type
  static int _getPolygonVertexCount(String paysage, Random random) {
    switch (paysage) {
      case 'Rond-point':
        return 6 + random.nextInt(3); // 6-8 sommets (forme plus régulière)
      case 'Parc public':
        return 5 + random.nextInt(4); // 5-8 sommets (forme naturelle)
      default:
        return 4 + random.nextInt(3); // 4-6 sommets (forme simple)
    }
  }

  // ✅ Génération de lignes courtes pour géométries mixtes
  static List<LatLng> _generateShortLine(LatLng center, Random random) {
    final length = 20 + random.nextInt(30).toDouble(); // 20-50m
    final angle = random.nextDouble() * 2 * math.pi;

    final dx = (length * math.cos(angle)) / 111320;
    final dy = (length * math.sin(angle)) / 111320;

    return [
      LatLng(center.latitude - dy / 2, center.longitude - dx / 2),
      center,
      LatLng(center.latitude + dy / 2, center.longitude + dx / 2),
    ];
  }

  // ✅ Génération de petits polygones pour géométries mixtes
  static List<LatLng> _generateSmallPolygon(LatLng center, Random random) {
    final radius = 8 + random.nextInt(12).toDouble(); // 8-20m
    return _generateRealisticPolygon(center, 'default', random);
  }

  // ✅ Génération de points à l'intérieur d'un polygone
  static List<LatLng> _generatePointsInPolygon(List<LatLng> polygon, int count,
      Random random) {
    final bounds = _getPolygonBounds(polygon);
    final points = <LatLng>[];

    int attempts = 0;
    while (points.length < count && attempts < count * 10) {
      final testPoint = LatLng(
        bounds['minLat']! +
            random.nextDouble() * (bounds['maxLat']! - bounds['minLat']!),
        bounds['minLng']! +
            random.nextDouble() * (bounds['maxLng']! - bounds['minLng']!),
      );

      if (_isPointInPolygon(testPoint, polygon)) {
        points.add(testPoint);
      }
      attempts++;
    }

    return points;
  }

  // ✅ Calcul des limites d'un polygone
  static Map<String, double> _getPolygonBounds(List<LatLng> polygon) {
    double minLat = polygon.first.latitude;
    double maxLat = polygon.first.latitude;
    double minLng = polygon.first.longitude;
    double maxLng = polygon.first.longitude;

    for (final point in polygon) {
      minLat = math.min(minLat, point.latitude);
      maxLat = math.max(maxLat, point.latitude);
      minLng = math.min(minLng, point.longitude);
      maxLng = math.max(maxLng, point.longitude);
    }

    return {
      'minLat': minLat,
      'maxLat': maxLat,
      'minLng': minLng,
      'maxLng': maxLng,
    };
  }

  // ✅ Test si un point est dans un polygone (algorithme ray casting simple)
  static bool _isPointInPolygon(LatLng point, List<LatLng> polygon) {
    bool inside = false;
    int j = polygon.length - 1;

    for (int i = 0; i < polygon.length; i++) {
      final xi = polygon[i].longitude;
      final yi = polygon[i].latitude;
      final xj = polygon[j].longitude;
      final yj = polygon[j].latitude;

      if (((yi > point.latitude) != (yj > point.latitude)) &&
          (point.longitude <
              (xj - xi) * (point.latitude - yi) / (yj - yi) + xi)) {
        inside = !inside;
      }
      j = i;
    }

    return inside;
  }

  // ✅ AJOUT: Génération d'adresses réalistes
  static String _generateRealisticAddress(String communeName, Random random) {
    final rues = [
      'Rue de la Paix', 'Avenue des Tilleuls', 'Place du Marché',
      'Boulevard des Chênes', 'Allée des Jardins', 'Impasse Verte',
      'Rue des Écoles', 'Avenue de la République', 'Place de l\'Église'
    ];

    final numero = 1 + random.nextInt(199);
    final rue = rues[random.nextInt(rues.length)];

    return '$numero $rue, $communeName';
  }


  // POSITION URBAINE RÉALISTE
  static LatLng _generateUrbanTreePosition(LatLng center, Random random,
      String commune) {
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
  static List<Marker> _generateMarkersFromStations(BuildContext context,
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
  static List<Marker> generateStationMarkers(LatLng center,
      BuildContext context, {
        required int count,
        bool showBadges = true,
      }) {
    final stations = _generateRealisticStations(
      center,
      count: count,
      communeName: 'Rennes',
    );
    return _generateMarkersFromStations(
        context, stations, showBadges: showBadges);
  }

  static List<Marker> generateInterventionMarkers(LatLng center, {
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

  static List<Marker> generateRemarkableTreeMarkers(LatLng center, {
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
      User(name: "Alexandra Padounou",
          role: "Responsable technique",
          date: "Active",
          email: "a.padounou@aubepine-scop.fr"),
      User(name: "Jean-Marc Lebon",
          role: "Arboriste-grimpeur",
          date: "Active",
          email: "jm.lebon@aubepine-scop.fr"),
      User(name: "Sophie Moreau",
          role: "Ingénieure environnement",
          date: "Active",
          email: "s.moreau@aubepine-scop.fr"),
      User(name: "Pierre Durand",
          role: "Technicien SIG",
          date: "Active",
          email: "p.durand@aubepine-scop.fr"),
      User(name: "Camille Bernard",
          role: "Gestionnaire données",
          date: "Active",
          email: "c.bernard@aubepine-scop.fr"),
      User(name: "Marc Rousseau",
          role: "Chef d'équipe",
          date: "Congés",
          email: "m.rousseau@aubepine-scop.fr"),
      User(name: "Élise Fontaine",
          role: "Arboriste-conseil",
          date: "Mission",
          email: "e.fontaine@aubepine-scop.fr"),
      User(name: "Thomas Leclerc",
          role: "Conducteur d'engins",
          date: "Active",
          email: "t.leclerc@aubepine-scop.fr"),
      User(name: "Marine Dubois",
          role: "Coordinatrice projets",
          date: "Active",
          email: "m.dubois@aubepine-scop.fr"),
      User(name: "Vincent Garcia",
          role: "Formateur sécurité",
          date: "Formation",
          email: "v.garcia@aubepine-scop.fr"),
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

  // ✅ GÉNÉRATION MARKERS AVEC GÉOMÉTRIES COMPLÈTES
  static List<Widget> generateStationMarkersWithGeometries(
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

    List<Widget> widgets = [];

    for (final station in stations) {
      final stationColor = _getColorFromHealthState(station);

      // 1. Polygones en arrière-plan
      if (station.polygones != null && station.polygones!.isNotEmpty) {
        for (final polygonPoints in station.polygones!) {
          widgets.add(
            PolygonLayer(
              polygons: [
                Polygon(
                  points: polygonPoints,
                  color: stationColor.withValues(alpha: 0.2),
                  borderColor: stationColor,
                  borderStrokeWidth: 2,
                  label: 'Station ${station.numeroStation}',
                ),
              ],
            ),
          );
        }
      }

      // 2. Lignes (alignements)
      if (station.lignes != null && station.lignes!.isNotEmpty) {
        for (final linePoints in station.lignes!) {
          widgets.add(
            PolylineLayer(
              polylines: [
                Polyline(
                  points: linePoints,
                  color: stationColor,
                  strokeWidth: 4,
                  pattern: StrokePattern.solid(),
                ),
              ],
            ),
          );
        }
      }

      // 3. Points (markers individuels)
      if (station.points != null && station.points!.isNotEmpty) {
        for (int i = 0; i < station.points!.length; i++) {
          final point = station.points![i];
          final isMainPoint = i == 0; // Premier point = point principal

          widgets.add(
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: isMainPoint ? 60 : 40,
                  height: isMainPoint ? 60 : 40,
                  alignment: Alignment.center,
                  child: GestureDetector(
                    onTap: () => _handleStationTap(context, station),
                    onLongPress: () => _handleStationLongPress(context, station),
                    child: Container(
                      decoration: BoxDecoration(
                        color: stationColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: isMainPoint ? 3 : 2,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.3),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          Icon(
                            _getStationIcon(station),
                            color: Colors.white,
                            size: isMainPoint ? 24 : 16,
                          ),
                          if (showBadges && station.treesToCut != null && station.treesToCut! > 0)
                            Positioned(
                              right: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(2),
                                decoration: const BoxDecoration(
                                  color: Colors.red,
                                  shape: BoxShape.circle,
                                ),
                                child: Text(
                                  '${station.treesToCut}',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          if (showBadges && station.warning != null)
                            Positioned(
                              left: 0,
                              top: 0,
                              child: Container(
                                padding: const EdgeInsets.all(1),
                                decoration: const BoxDecoration(
                                  color: Colors.orange,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.warning,
                                  color: Colors.white,
                                  size: 12,
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        }
      } else {
        // Fallback: point simple à la position de la station
        widgets.add(
          MarkerLayer(
            markers: [
              Marker(
                point: LatLng(station.latitude, station.longitude),
                width: 60,
                height: 60,
                alignment: Alignment.center,
                child: GestureDetector(
                  onTap: () => _handleStationTap(context, station),
                  onLongPress: () => _handleStationLongPress(context, station),
                  child: Container(
                    decoration: BoxDecoration(
                      color: stationColor,
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white, width: 3),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 4,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Icon(
                      _getStationIcon(station),
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }
    }

    return widgets;
  }

  // ✅ Icône selon le type de géométrie NON NECESSAIRE PUTAIN PAS BESOIN D4ICONE DE STATION JUSTE LA COULEUR QUOI MERDE
  static IconData _getStationIcon(Station station) {
    if (station.polygones != null && station.polygones!.isNotEmpty) {
      return Icons.forest; // Zone boisée
    } else if (station.lignes != null && station.lignes!.isNotEmpty) {
      return Icons.linear_scale; // Alignement
    } else if (station.points != null && station.points!.length > 1) {
      return Icons.scatter_plot; // Groupe de points
    } else {
      return Icons.location_on; // Point simple
    }
  }

  // ✅ Gestion des interactions avec les stations
  static void _handleStationTap(BuildContext context, Station station) {
    // Afficher les détails de la station
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Station ${station.numeroStation}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${station.treeLandscape}',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                    const SizedBox(height: 16),
                    _buildGeometryInfo(station),
                    const SizedBox(height: 16),
                    if (station.baseDonneesEssence != null)
                      Text(
                        'Essence: ${station.baseDonneesEssence}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    if (station.commentaireProtection != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        station.commentaireProtection!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }



  // ✅ Affichage des informations de géométrie
  static Widget _buildGeometryInfo(Station station) {
    List<Widget> geometryWidgets = [];

    if (station.points != null && station.points!.isNotEmpty) {
      geometryWidgets.add(
        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.blue),
            const SizedBox(width: 4),
            Text('${station.points!.length} point(s)'),
          ],
        ),
      );
    }

    if (station.lignes != null && station.lignes!.isNotEmpty) {
      final totalPoints = station.lignes!.fold(0, (sum, ligne) => sum + ligne.length);
      geometryWidgets.add(
        Row(
          children: [
            const Icon(Icons.linear_scale, size: 16, color: Colors.green),
            const SizedBox(width: 4),
            Text('${station.lignes!.length} ligne(s) - $totalPoints points'),
          ],
        ),
      );
    }

    if (station.polygones != null && station.polygones!.isNotEmpty) {
      final totalVertices = station.polygones!.fold(0, (sum, poly) => sum + poly.length);
      geometryWidgets.add(
        Row(
          children: [
            const Icon(Icons.crop_free, size: 16, color: Colors.orange),
            const SizedBox(width: 4),
            Text('${station.polygones!.length} polygone(s) - $totalVertices sommets'),
          ],
        ),
      );
    }

    if (geometryWidgets.isEmpty) {
      geometryWidgets.add(
        Row(
          children: [
            const Icon(Icons.location_on, size: 16, color: Colors.grey),
            const SizedBox(width: 4),
            const Text('Position simple'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Géométries:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        ...geometryWidgets.map((w) => Padding(
          padding: const EdgeInsets.only(bottom: 4),
          child: w,
        )),
      ],
    );
  }

  static void _handleStationLongPress(BuildContext context, Station station) {
    // Menu contextuel pour édition rapide
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info),
                title: const Text('Voir les détails'),
                onTap: () {
                  Navigator.pop(context);
                  _handleStationTap(context, station);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_location),
                title: const Text('Éditer la géométrie'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Ouvrir l'éditeur de géométrie
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_location),
                title: const Text('Ajouter un point'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Mode ajout de point
                },
              ),
              ListTile(
                leading: const Icon(Icons.timeline),
                title: const Text('Créer une ligne'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Mode création de ligne
                },
              ),
              ListTile(
                leading: const Icon(Icons.crop_free),
                title: const Text('Créer un polygone'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Mode création de polygone
                },
              ),
            ],
          ),
        );
      },
    );
  }
}


// ✅ NOUVEAU SYSTÈME D'AFFICHAGE - selon vos spécifications
class StationDisplaySystem {

  // ✅ Génération de l'affichage complet d'une station selon ses géométries
  static List<Widget> generateStationDisplay({
    required Station station,
    required BuildContext context,
    bool showBadges = true,
    double currentZoom = 13.0,
  }) {
    List<Widget> layers = [];
    final stationColor = _getColorFromHealthState(station);

    // 1. POLYGONES (arrière-plan) - Zone grisée selon vos spécifications
    if (station.polygones != null && station.polygones!.isNotEmpty) {
      for (final polygonPoints in station.polygones!) {
        layers.add(
          PolygonLayer(
            polygons: [
              Polygon(
                points: polygonPoints,
                color: stationColor.withValues(alpha: 0.15), // Zone grisée légère
                borderColor: stationColor,
                borderStrokeWidth: 2,
                label: 'Station ${station.numeroStation}',
              ),
            ],
          ),
        );
      }
    }

    // 2. LIGNES (alignements d'arbres)
    if (station.lignes != null && station.lignes!.isNotEmpty) {
      for (final linePoints in station.lignes!) {
        layers.add(
          PolylineLayer(
            polylines: [
              Polyline(
                points: linePoints,
                color: stationColor,
                strokeWidth: 3,
                pattern: StrokePattern.solid(),
              ),
            ],
          ),
        );

        // Ajouter des points aux extrémités de la ligne pour montrer les arbres
        layers.add(
          MarkerLayer(
            markers: [
              // Point de début
              _createStationMarker(
                point: linePoints.first,
                station: station,
                stationColor: stationColor,
                context: context,
                showBadges: showBadges,
                isEndPoint: true,
              ),
              // Point de fin
              _createStationMarker(
                point: linePoints.last,
                station: station,
                stationColor: stationColor,
                context: context,
                showBadges: false, // Badges seulement sur le premier point
                isEndPoint: true,
              ),
            ],
          ),
        );
      }
    }

    // 3. POINTS individuels (arbres isolés ou groupes)
    if (station.points != null && station.points!.isNotEmpty) {
      List<Marker> pointMarkers = [];

      for (int i = 0; i < station.points!.length; i++) {
        final point = station.points![i];
        final isMainPoint = i == 0; // Premier point = point principal avec badges

        pointMarkers.add(
          _createStationMarker(
            point: point,
            station: station,
            stationColor: stationColor,
            context: context,
            showBadges: showBadges && isMainPoint,
            isMainPoint: isMainPoint,
          ),
        );
      }

      layers.add(MarkerLayer(markers: pointMarkers));
    }

    // 4. FALLBACK: Si aucune géométrie, afficher le point de position de base
    if ((station.points?.isEmpty ?? true) &&
        (station.lignes?.isEmpty ?? true) &&
        (station.polygones?.isEmpty ?? true)) {
      layers.add(
        MarkerLayer(
          markers: [
            _createStationMarker(
              point: LatLng(station.latitude, station.longitude),
              station: station,
              stationColor: stationColor,
              context: context,
              showBadges: showBadges,
              isMainPoint: true,
            ),
          ],
        ),
      );
    }

    return layers;
  }

  // ✅ Créer un marqueur de station (cercle coloré avec halo, pas d'icône)
  static Marker _createStationMarker({
    required LatLng point,
    required Station station,
    required Color stationColor,
    required BuildContext context,
    bool showBadges = true,
    bool isMainPoint = false,
    bool isEndPoint = false,
  }) {
    final size = isMainPoint ? 50.0 : (isEndPoint ? 35.0 : 40.0);

    return Marker(
      point: point,
      width: size,
      height: size,
      alignment: Alignment.center,
      child: GestureDetector(
        onTap: () => _handleStationTap(context, station),
        onLongPress: () => _handleStationLongPress(context, station),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Halo externe (effet de glow)
            Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: stationColor.withValues(alpha: 0.2),
                border: Border.all(
                  color: stationColor.withValues(alpha: 0.4),
                  width: 2,
                ),
              ),
            ),

            // Cercle principal (pas d'icône selon vos spécifications)
            Container(
              width: size * 0.6,
              height: size * 0.6,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: stationColor,
                border: Border.all(
                  color: Colors.white,
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.3),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),

            // Badges (nombre d'arbres à couper)
            if (showBadges && station.treesToCut != null && station.treesToCut! > 0)
              Positioned(
                right: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(4),
                  decoration: const BoxDecoration(
                    color: Colors.red,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${station.treesToCut}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),

            // Badge d'avertissement
            if (showBadges && station.warning != null)
              Positioned(
                left: 0,
                top: 0,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: Colors.orange,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.warning,
                    color: Colors.white,
                    size: 8,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // ✅ Couleur selon l'état de santé (votre logique existante)
  static Color _getColorFromHealthState(Station station) {
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

  // ✅ Gestion des interactions (tap simple)
  static void _handleStationTap(BuildContext context, Station station) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.8,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.symmetric(vertical: 12),
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Contenu
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Station ${station.numeroStation}',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                    const SizedBox(height: 8),
                    if (station.treeLandscape != null)
                      Text(
                        '${station.treeLandscape}',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.grey[600],
                        ),
                      ),
                    const SizedBox(height: 16),
                    _buildGeometryInfo(station),
                    const SizedBox(height: 16),
                    if (station.baseDonneesEssence != null)
                      Text(
                        'Essence: ${station.baseDonneesEssence}',
                        style: const TextStyle(fontSize: 16),
                      ),
                    if (station.commentaireProtection != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        station.commentaireProtection!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            // Boutons d'action
            Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(Icons.close),
                      label: const Text('Fermer'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () {
                        Navigator.pop(context);
                        // TODO: Ouvrir l'éditeur
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                      icon: const Icon(Icons.edit),
                      label: const Text('Éditer'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Menu contextuel (long press)
  static void _handleStationLongPress(BuildContext context, Station station) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.info, color: Colors.blue),
                title: const Text('Voir les détails'),
                onTap: () {
                  Navigator.pop(context);
                  _handleStationTap(context, station);
                },
              ),
              ListTile(
                leading: const Icon(Icons.edit_location, color: Colors.green),
                title: const Text('Éditer géométrie'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Mode édition
                },
              ),
              ListTile(
                leading: const Icon(Icons.add_location, color: Colors.orange),
                title: const Text('Ajouter un point'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Mode ajout point
                },
              ),
              ListTile(
                leading: const Icon(Icons.timeline, color: Colors.purple),
                title: const Text('Créer une ligne'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Mode création ligne
                },
              ),
              ListTile(
                leading: const Icon(Icons.crop_free, color: Colors.teal),
                title: const Text('Créer un polygone'),
                onTap: () {
                  Navigator.pop(context);
                  // TODO: Mode création polygone
                },
              ),
            ],
          ),
        );
      },
    );
  }

  // ✅ Affichage des informations de géométrie
  static Widget _buildGeometryInfo(Station station) {
    List<Widget> geometryWidgets = [];

    if (station.points != null && station.points!.isNotEmpty) {
      geometryWidgets.add(
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getColorFromHealthState(station),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text('${station.points!.length} arbre(s) individuel(s)'),
          ],
        ),
      );
    }

    if (station.lignes != null && station.lignes!.isNotEmpty) {
      final totalPoints = station.lignes!.fold(0, (sum, ligne) => sum + ligne.length);
      geometryWidgets.add(
        Row(
          children: [
            Container(
              width: 16,
              height: 4,
              decoration: BoxDecoration(
                color: _getColorFromHealthState(station),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text('${station.lignes!.length} alignement(s) - $totalPoints arbres'),
          ],
        ),
      );
    }

    if (station.polygones != null && station.polygones!.isNotEmpty) {
      final totalVertices = station.polygones!.fold(0, (sum, poly) => sum + poly.length);
      geometryWidgets.add(
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: _getColorFromHealthState(station).withValues(alpha: 0.3),
                border: Border.all(color: _getColorFromHealthState(station), width: 2),
              ),
            ),
            const SizedBox(width: 8),
            Text('${station.polygones!.length} zone(s) boisée(s)'),
          ],
        ),
      );
    }

    if (geometryWidgets.isEmpty) {
      geometryWidgets.add(
        Row(
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.grey,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            const Text('Position simple'),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Type de station:',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Colors.green,
          ),
        ),
        const SizedBox(height: 8),
        ...geometryWidgets.map((w) => Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: w,
        )),
      ],
    );
  }

  // ✅ Méthode pour générer toutes les stations d'un dossier avec leurs géométries
  static List<Widget> generateAllStationsForMap({
    required List<Station> stations,
    required BuildContext context,
    bool showBadges = true,
    double currentZoom = 13.0,
  }) {
    List<Widget> allLayers = [];

    for (final station in stations) {
      allLayers.addAll(
        generateStationDisplay(
          station: station,
          context: context,
          showBadges: showBadges,
          currentZoom: currentZoom,
        ),
      );
    }

    return allLayers;
  }
}