
/*
class MockData {
  static List<Account> fakeAccounts() => [
    Account(name: 'Compte 1', detail: 'Détails du compte A'),
    Account(name: 'Compte 2', detail: 'Détails du compte B'),
    Account(name: 'Compte 3', detail: 'Détails du compte C'),
    Account(name: 'Compte 4', detail: 'Détails du compte D'),
    Account(name: 'Compte 5', detail: 'Détails du compte E'),
    Account(name: 'Compte 6', detail: 'Détails du compte F'),
    Account(name: 'Compte 7', detail: 'Détails du compte G'),
    Account(name: 'Compte 8', detail: 'Détails du compte H'),
    Account(name: 'Compte 9', detail: 'Détails du compte I'),
    Account(name: 'Compte 10', detail: 'Détails du compte J'),
    Account(name: 'Compte 11', detail: 'Détails du compte K'),
    Account(name: 'Compte 12', detail: 'Détails du compte L'),
    Account(name: 'Compte 13', detail: 'Détails du compte M'),
    Account(name: 'Compte 14', detail: 'Détails du compte N'),
    Account(name: 'Compte 15', detail: 'Détails du compte O'),
    Account(name: 'Compte 16', detail: 'Détails du compte P'),
    Account(name: 'Compte 17', detail: 'Détails du compte Q'),
    Account(name: 'Compte 19', detail: 'Détails du compte R'),
    Account(name: 'Compte 19', detail: 'Détails du compte S'),
    Account(name: 'Compte 20', detail: 'Détails du compte T'),
    Account(name: 'Compte 21', detail: 'Détails du compte U'),
    Account(name: 'Compte 22', detail: 'Détails du compte V'),
    Account(name: 'Compte 23', detail: 'Détails du compte W'),
    Account(name: 'Compte 24', detail: 'Détails du compte X'),
    Account(name: 'Compte 25', detail: 'Détails du compte Y'),
    Account(name: 'Compte 26', detail: 'Détails du compte Z'),
  ];

  // Couches cartographiques réalistes pour un SIG
  static List<Layer> fakeLayers() => [
    // === FONDS DE CARTE ===
    Layer(
      nom: 'OpenStreetMap',
      type: 'Fond de carte',
      date: 'Temps réel',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => [],
    ),
    Layer(
      nom: 'Plan IGN',
      type: 'Fond de carte',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => [],
    ),
    Layer(
      nom: 'Photographies aériennes',
      type: 'Imagerie',
      date: '2023',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => [],
    ),
    Layer(
      nom: 'Vue satellite',
      type: 'Imagerie',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => [],
    ),


    // === DONNÉES CADASTRALES ===
    Layer(
      nom: 'Cadastre',
      type: 'Référentiel',
      date: '2024',
      center: centers['Rennes']!,
      markerBuilder: (context, {showBadges = true}) => [],
    ),

    // === DONNÉES ADMINISTRATIVES ===
    Layer(
      nom: 'Limites communales',
      type: 'Administratif',
      date: '2024',
      center: centers['Rennes']!,
      markerBuilder: (context, {showBadges = true}) => [],
    ),
    Layer(
      nom: 'Parcellaire DGFiP',
      type: 'Référentiel',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => [],
    ),

    Layer(
      nom: 'Limites communales',
      type: 'Administratif',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => [],
    ),
    Layer(
      nom: 'Limites départementales',
      type: 'Administratif',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => [],
    ),

    // === TRANSPORT ===
    Layer(
      nom: 'Réseau routier BD TOPO',
      type: 'Transport',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => [],
    ),
    Layer(
      nom: 'Réseau ferroviaire',
      type: 'Transport',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => [],
    ),

    // === HYDROGRAPHIE ===
    Layer(
      nom: 'Cours d\'eau',
      type: 'Hydrographie',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => [],
    ),
    Layer(
      nom: 'Plans d\'eau',
      type: 'Hydrographie',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => [],
    ),

    // === DONNÉES MÉTIER (PRINCIPALES) ===
    Layer(
      nom: 'Stations arboricoles',
      type: 'Données métier',
      date: '18/02/2025',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => _generateStationMarkers(
        LatLng(48.1173, -1.6778),
        count: 50,
        showBadges: showBadges,
      ),
    ),
    Layer(
      nom: 'Zones d\'intervention',
      type: 'Données métier',
      date: '15/02/2025',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => _generateInterventionMarkers(
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
      markerBuilder: (context, {showBadges = true}) => _generateRemarkableTreeMarkers(
        LatLng(48.1173, -1.6778),
        count: 8,
        showBadges: showBadges,
      ),
    ),


    // === RÉGLEMENTAIRE ===
    Layer(
      nom: 'Espaces boisés classés',
      type: 'Réglementaire',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => [],
    ),

    // === ENVIRONNEMENT ===
    Layer(
      nom: 'ZNIEFF',
      type: 'Environnement',
      date: '2023',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => [],
    ),
    Layer(
      nom: 'Natura 2000',
      type: 'Environnement',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => [],
    ),


    // === URBANISME ===
    Layer(
      nom: 'PLU - Zonage',
      type: 'Urbanisme',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => [],
    ),

    // === BÂTI ===
    Layer(
      nom: 'Bâtiments BD TOPO',
      type: 'Bâti',
      date: '2024',
      center: LatLng(48.1173, -1.6778),
      markerBuilder: (context, {showBadges = true}) => [],
    ),
  ];

  static String randomRole() {
    final List<String> roles = [
      "Administrateur",
      "Administratrice",
      "Gestionnaire",
      "Superviseur",
      "Délégué",
      "Coordinateur",
      "Chef de projet",
      "Directeur",
      "Responsable",
      "Conseiller",
    ];
    final Random random = Random();
    return roles[random.nextInt(roles.length)];
  }
  static List<User> fakeUsers() => BoomRealisticData.generateRealisticUsers();

  static const List<Color> allowedStationColors = [
    Colors.green,
    Colors.orange,
    Colors.red,
    Colors.yellow,
  ];

  final countTest = 80;
  final radiusInMetersTest = 50.0;

  final centerNantes = LatLng(47.2184, -1.5536);
  final centerVertou = LatLng(47.1681, -1.4725);
  final centerThorigneFouillard = LatLng(48.1342, -1.5790);
  final centerRennes = LatLng(48.1173, -1.6778);
  final centerCessonSevigne = LatLng(48.1210, -1.6245);
  final centerAngers = LatLng(47.4784, -0.5632);
  final centerBruz = LatLng(48.0214, -1.7464);
  final centerPace = LatLng(48.1471, -1.7914);
  final centerBeton = LatLng(48.1862, -1.6397);
  final centerVitre = LatLng(48.1232, -1.2055);
  final centerChateaugiron = LatLng(48.0496, -1.5003);
  final centerChateaubriant = LatLng(47.7177, -1.3736);
  final centerAncenis = LatLng(47.3689, -1.1766);
  final centerBlain = LatLng(47.5114, -1.7553);

  List<Dossier> fakeDossiers() {
    return BoomRealisticData.generateRealisticDossiers();
  }


  // Générateurs de marqueurs pour les différents types de données métier
  static List<Marker> _generateStationMarkers(LatLng center, {required int count, bool showBadges = true}) {
    final Random random = Random();
    return List.generate(count, (index) {
      final point = _generateRandomPoint(center, 2000, random);

      // Générer des données de station fictives pour ce marker
      final stationColor = allowedStationColors[random.nextInt(allowedStationColors.length)];
      final treesToCut = showBadges && random.nextBool() ? random.nextInt(3) + 1 : null;
      final warning = showBadges && random.nextDouble() < 0.2 ? "!" : null;
      final highlight = random.nextDouble() < 0.3;

      return Marker(
        point: point,
        width: 60,
        height: 60,
        child: StationMarker(
          color: stationColor, // ✅ Paramètre obligatoire fourni
          treesToCut: treesToCut,
          warning: warning,
          highlight: highlight,
        ),
      );
    });
  }




  static List<Marker> _generateInterventionMarkers(LatLng center, {required int count, bool showBadges = true}) {
    final Random random = Random();
    return List.generate(count, (index) {
      final point = _generateRandomPoint(center, 3000, random);

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
  static List<Layer> generateFakeLayers() => fakeLayers();
  static List<Dossier> generateFakeDossiers() => MockData().fakeDossiers();

  List<Station> generateStations(
      LatLng center, {
        int count = 80,
        double radiusInMeters = 3000,
      }) {
    return _generateStations(center, count: count, radiusInMeters: radiusInMeters);
  }
  List<Marker> generateMarkersFromStations(
      List<Station> stations, {
        bool showBadges = true,
      }) {
    return _generateMarkersFromStations(context, stations, showBadges: showBadges);
  }
  // Génère des fake layers
  static List<Layer> _generateFakeLayers() {
    return [
      Layer(
        nom: "OpenStreetMap",
        type: "Fond de carte",
        date: "14/07/2025",
        center: LatLng(48.1, -1.6),
        markerBuilder: (context, {showBadges = false}) => [],
      ),
      Layer(
        nom: "Plan IGN",
        type: "Fond de carte",
        date: "14/07/2025",
        center: LatLng(48.1, -1.6),
        markerBuilder: (context, {showBadges = false}) => [],
      ),
      Layer(
        nom: "Photographies aériennes",
        type: "Fond de carte",
        date: "14/07/2025",
        center: LatLng(48.1, -1.6),
        markerBuilder: (context, {showBadges = false}) => [],
      ),Layer(
        nom: "Stations d’arbres",
        type: "Données métier",
        date: "14/07/2025",
        center: LatLng(48.1, -1.6),
        markerBuilder: (context, {showBadges = false}) =>
            MockData.generateMarkersFromStations(
              MockData.generateStations(LatLng(48.1, -1.6)),
              showBadges: showBadges,
            ),
      ),
      Layer(
        nom: "Points d’intérêt",
        type: "Données métier",
        date: "14/07/2025",
        center: LatLng(48.1, -1.6),
        markerBuilder: (context, {showBadges = false}) => [],
      ),
      Layer(
        nom: "Zones à risque",
        type: "Données métier",
        date: "14/07/2025",
        center: LatLng(48.1, -1.6),
        markerBuilder: (context, {showBadges = false}) => [],
      ),
      Layer(
        nom: "Limitations communales",
        type: "Données métier",
        date: "14/07/2025",
        center: LatLng(48.1, -1.6),
        markerBuilder: (context, {showBadges = false}) => [],
      ),
      Layer(
        nom: "Voirie",
        type: "Données métier",
        date: "14/07/2025",
        center: LatLng(48.1, -1.6),
        markerBuilder: (context, {showBadges = false}) => [],
      ),

    ];
  }

  static List<Marker> _generateRemarkableTreeMarkers(LatLng center, {required int count, bool showBadges = true}) {
    final Random random = Random();
    return List.generate(count, (index) {
      final point = _generateRandomPoint(center, 5000, random);

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

  static LatLng _generateRandomPoint(LatLng center, double radiusInMeters, Random random) {
    // Distribution de Rayleigh pour un clustering réaliste
    // Formule : R = σ * sqrt(-2 * ln(1 - u)) où u = random(0,1)
    final u = random.nextDouble();
    final rayleighDistance = 0.3 * math.sqrt(-2 * math.log(1 - u));

    // Limiter la distance au rayon maximum
    final normalizedDistance = math.min(rayleighDistance, 1.0);
    final distance = radiusInMeters * normalizedDistance;

    // Angle aléatoire pour la direction
    final angle = 2 * math.pi * random.nextDouble();

    // Conversion en coordonnées géographiques
    final dx = (distance * math.cos(angle)) / 111320;
    final dy = (distance * math.sin(angle)) / 111320;

    return LatLng(center.latitude + dy, center.longitude + dx);
  }

  // Méthode pour détecter les groupes d'arbres
  static List<List<Station>> _detectTreeGroups(List<Station> stations) {
    const double groupingThreshold = 0.0005; // ~50m en degrés
    List<List<Station>> groups = [];
    List<Station> processed = [];

    for (Station station in stations) {
      if (processed.contains(station)) continue;

      List<Station> currentGroup = [station];
      processed.add(station);

      // Rechercher les stations proches
      for (Station other in stations) {
        if (processed.contains(other)) continue;

        final distance = math.sqrt(
            math.pow(station.latitude - other.latitude, 2) +
                math.pow(station.longitude - other.longitude, 2)
        );

        if (distance < groupingThreshold) {
          currentGroup.add(other);
          processed.add(other);
        }
      }

      groups.add(currentGroup);
    }

    return groups;
  }

  LatLng _calculateRandomPoint(LatLng center, double radiusInMeters, Random random) {
    double distanceFactor;
    final rand = random.nextDouble();
    if (rand < 0.3) {
      distanceFactor = random.nextDouble() * 0.2;
    } else if (rand < 0.8) {
      distanceFactor = 0.2 + random.nextDouble() * 0.5;
    } else {
      distanceFactor = 0.7 + random.nextDouble() * 0.3;
    }

    final angle = 2 * pi * random.nextDouble();
    final distance = radiusInMeters * distanceFactor;
    final dx = (distance * cos(angle)) / 111320;
    final dy = (distance * sin(angle)) / 111320;

    return LatLng(center.latitude + dy, center.longitude + dx);
  }

  static List<Station> _generateStations(
      LatLng center, {
        int count = 80,
        double radiusInMeters = 3000,
      }) {
    final random = Random();
    List<Station> stations = [];

    // Génération des stations avec distribution de Rayleigh
    for (int i = 0; i < count; i++) {
      final point = _generateRandomPoint(center, radiusInMeters, random);
      stations.add(Station(
        numeroStation: i + 1,
        latitude: point.latitude,
        longitude: point.longitude,
        treesToCut: random.nextDouble() < 0.3 ? random.nextInt(8) + 1 : null,
        warning: random.nextDouble() < 0.15 ? _getRandomWarning(random) : null,
        highlight: random.nextDouble() < 0.25,
        treeLandscape: _getRandomLandscape(random),
        humanFrequency: random.nextInt(5) + 1,
        espaceBoiseClasse: random.nextDouble() < 0.2,
        interetPaysager: random.nextDouble() < 0.3,
        codeEnvironnement: random.nextDouble() < 0.1,
        meriteProtection: random.nextDouble() < 0.4,
        commentaireProtection: random.nextDouble() < 0.3 ? _getRandomComment(random) : null,
      ));
    }

    // Détection des groupes et marquage
    final groups = _detectTreeGroups(stations);
    for (var group in groups) {
      if (group.length >= 3) { // Groupe de 3+ arbres
        for (var station in group) {
          // Marquer comme groupe (vous pouvez ajouter une propriété `isInGroup`)
          station.highlight = true;
        }
      }
    }

    return stations;
  }


  static String _getRandomWarning(Random random) {
    const warnings = ['Maladie détectée', 'Élagage nécessaire', 'Racines exposées', 'Branches cassées'];
    return warnings[random.nextInt(warnings.length)];
  }


  static String _getRandomLandscape(Random random) {
    const landscapes = ['Parc public', 'Alignement de rue', 'Jardin public', 'Place publique', 'Zone industrielle'];
    return landscapes[random.nextInt(landscapes.length)];
  }



  static String _getRandomComment(Random random) {
    const comments = [
      'Arbre remarquable à préserver',
      'Espèce rare nécessitant protection',
      'Élément structurant du paysage',
      'Valeur écologique importante'
    ];
    return comments[random.nextInt(comments.length)];
  }

  List<Marker> _generateMarkersFromStations(
      BuildContext context,
      List<Station> stations, {
        bool showBadges = true,
      }) {
    final random = Random();
    return stations.map((station) {
      final stationColor = allowedStationColors[random.nextInt(allowedStationColors.length)];
      return Marker(
        point: LatLng(station.latitude, station.longitude),
        width: 60,
        height: 60,
        child: StationMarker(
          color: stationColor,
          treesToCut: showBadges ? station.treesToCut : null,
          warning: showBadges ? station.warning : null,
          highlight: station.highlight,
        ),
      );
    }).toList();
  }
}


class BoomRealisticData {
  static const List<String> essencesArbres = [
    'Chêne pédonculé',
    'Chêne sessile',
    'Hêtre commun',
    'Châtaignier',
    'Frêne commun',
    'Erable sycomore',
    'Tilleul à grandes feuilles',
    'Platane commun',
    'Marronnier',
    'Pin maritime',
    'Pin sylvestre',
    'Bouleau verruqueux',
    'Charme commun',
    'Aulne glutineux',
    'Saule blanc',
  ];

  static const List<String> etatsSanitaires = [
    'Excellent',
    'Bon',
    'Moyen',
    'Dégradé',
    'Mauvais',
    'Dépérissant',
    'Mort',
  ];

  static const List<String> stadesDeveloppement = [
    'Jeune plantation',
    'Jeune arbre',
    'Arbre adulte',
    'Arbre mature',
    'Arbre sénescent',
    'Vétéran',
  ];

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

  static List<Map<String, dynamic>> getCommunesReelles() {
    return [
      {
        'nom': 'Rennes',
        'center': LatLng(48.1173, -1.6778),
        'population': 220488,
        'superficie': 50.39,
        'stations_count': 850,
      },
      {
        'nom': 'Cesson-Sévigné',
        'center': LatLng(48.1210, -1.6245),
        'population': 17234,
        'superficie': 32.22,
        'stations_count': 340,
      },
      {
        'nom': 'Bruz',
        'center': LatLng(48.0214, -1.7464),
        'population': 18567,
        'superficie': 29.87,
        'stations_count': 280,
      },
      {
        'nom': 'Thorigné-Fouillard',
        'center': LatLng(48.1342, -1.5790),
        'population': 8234,
        'superficie': 15.43,
        'stations_count': 150,
      },
      {
        'nom': 'Pacé',
        'center': LatLng(48.1471, -1.7914),
        'population': 10956,
        'superficie': 32.11,
        'stations_count': 180,
      },
      {
        'nom': 'Betton',
        'center': LatLng(48.1862, -1.6397),
        'population': 12450,
        'superficie': 24.56,
        'stations_count': 220,
      },
      {
        'nom': 'Châteaugiron',
        'center': LatLng(48.0496, -1.5003),
        'population': 7834,
        'superficie': 27.89,
        'stations_count': 140,
      },
      {
        'nom': 'Vitré',
        'center': LatLng(48.1232, -1.2055),
        'population': 18567,
        'superficie': 37.54,
        'stations_count': 290,
      },
      {
        'nom': 'Saint-Grégoire',
        'center': LatLng(48.1561, -1.6981),
        'population': 9876,
        'superficie': 18.23,
        'stations_count': 160,
      },
      {
        'nom': 'Le Rheu',
        'center': LatLng(48.0975, -1.7789),
        'population': 8234,
        'superficie': 22.67,
        'stations_count': 130,
      },
    ];
  }

  static LatLng calculateRandomPoint(LatLng center, double radiusInMeters, Random random) {
    double distanceFactor;
    final rand = random.nextDouble();
    if (rand < 0.3) {
      distanceFactor = random.nextDouble() * 0.2;
    } else if (rand < 0.8) {
      distanceFactor = 0.2 + random.nextDouble() * 0.5;
    } else {
      distanceFactor = 0.7 + random.nextDouble() * 0.3;
    }

    final angle = 2 * pi * random.nextDouble();
    final distance = radiusInMeters * distanceFactor;
    final dx = (distance * cos(angle)) / 111320;
    final dy = (distance * sin(angle)) / 111320;

    return LatLng(center.latitude + dy, center.longitude + dx);
  }
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
        markerBuilder: (BuildContext context, {bool showBadges = true}) => _generateMarkersFromStations(
          context, // ✅ Passage du contexte
          stations,
          showBadges: showBadges,
        ),
      );
    }).toList();
  }

  static List<Station> _generateRealisticStations(
      LatLng center,
      {required int count, required String communeName}
      ) {
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
      );
    });
  }

  static LatLng _generateUrbanTreePosition(LatLng center, Random random, String commune) {
    final densityFactors = {
      'Rennes': 0.8,
      'Cesson-Sévigné': 0.6,
      'Bruz': 0.5,
      'Thorigné-Fouillard': 0.4,
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

    final angle = 2 * pi * random.nextDouble();
    final dx = (distance * cos(angle)) / 111320;
    final dy = (distance * sin(angle)) / 111320;

    return LatLng(center.latitude + dy, center.longitude + dx);
  }

  static int _generateStationNumber(String commune, int index) {
    // Numérotation par commune avec préfixe
    final prefixes = {
      'Rennes': 35000,
      'Cesson-Sévigné': 35001,
      'Bruz': 35002,
      'Thorigné-Fouillard': 35003,
      'Pacé': 35004,
      'Betton': 35005,
      'Châteaugiron': 35006,
      'Vitré': 35007,
      'Saint-Grégoire': 35008,
      'Le Rheu': 35009,
    };

    final prefix = prefixes[commune] ?? 35999;
    return prefix * 1000 + index + 1;
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

  static List<Marker> _generateRealisticMarkers(
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
        child: StationMarker(
          color: stationColor,
          treesToCut: showBadges ? station.treesToCut : null,
          warning: showBadges ? station.warning : null,
          highlight: station.highlight,
        ),
      );
    }).toList();
  }

  static Color _getColorFromHealthState(Station station) {
    // Logique métier réaliste Aubépine SCOP
    if (station.warning != null) return Colors.red;      // Urgent
    if (station.treesToCut != null) return Colors.orange; // À intervenir
    if (station.highlight) return Colors.yellow;          // Surveillance
    return Colors.green;                                   // Bon état
  }

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


  static List<Station> _generateStationsFromTemplate(
      LatLng center, {
        required int count,
        required double radiusInMeters,
        required Map<String, dynamic> templates,
      }) {
    final random = Random();
    final templateKeys = templates.keys.toList();

    return List.generate(count, (i) {
      final point = _generateRandomPoint(center, radiusInMeters, random);

      // Sélectionner un template aléatoire
      final templateKey = templateKeys[random.nextInt(templateKeys.length)];
      final template = templates[templateKey];

      return Station(
        numeroStation: i + 1,
        latitude: point.latitude,
        longitude: point.longitude,
        treesToCut: template['treesToCut'],
        warning: template['warning'],
        highlight: template['highlight'] ?? false,
        treeLandscape: _getRandomLandscape(random),
        humanFrequency: template['humanFrequency'] ?? 3,
        espaceBoiseClasse: template['espaceBoiseClasse'] ?? false,
        interetPaysager: template['interetPaysager'] ?? false,
        codeEnvironnement: template['codeEnvironnement'] ?? false,
        meriteProtection: template['meriteProtection'] ?? false,
        commentaireProtection: template['commentaireProtection'],
      );
    });
  }

  static String _getRandomLandscape(Random random) {
    const landscapes = [
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
      'Privé'
    ];
    return landscapes[random.nextInt(landscapes.length)];
  }

  // Méthode pour charger depuis JSON
  static Future<List<Dossier>> loadDossiersFromJson() async {
    try {
      final String jsonString = await rootBundle.loadString('assets/mock_stations.json');
      final Map<String, dynamic> data = json.decode(jsonString);

      return (data['cities'] as List).map((cityData) {
        final stations = _generateStationsFromTemplate(
          LatLng(cityData['center'][0], cityData['center'][1]),
          count: cityData['expectedCount'],
          radiusInMeters: cityData['radius'].toDouble(),
          templates: data['stationTemplates'],
        );

        return Dossier(
          nom: cityData['name'],
          type: 'En attente de sauvegarde',
          date: DateTime.now().toString().substring(0, 10),
          center: LatLng(cityData['center'][0], cityData['center'][1]),
          stations: stations,
          markerBuilder: (BuildContext context, {bool showBadges = true}) =>
              _generateMarkersFromStations(stations, showBadges: showBadges),
        );
      }).toList();
    } catch (e) {
      // Fallback vers génération procédurale
      return BoomRealisticData.generateRealisticDossiers();
    }
  }

  static LatLng _generateRandomPoint(LatLng center, double radiusInMeters, Random random) {
    double distanceFactor;
    final rand = random.nextDouble();
    if (rand < 0.3) {
      distanceFactor = random.nextDouble() * 0.2;
    } else if (rand < 0.8) {
      distanceFactor = 0.2 + random.nextDouble() * 0.5;
    } else {
      distanceFactor = 0.7 + random.nextDouble() * 0.3;
    }

    final angle = 2 * pi * random.nextDouble();
    final distance = radiusInMeters * distanceFactor;
    final dx = (distance * cos(angle)) / 111320;
    final dy = (distance * sin(angle)) / 111320;

    return LatLng(center.latitude + dy, center.longitude + dx);
  }

  static List<Marker> _generateMarkersFromStations(
      BuildContext context, // ← Ajout du contexte
      List<Station> stations, {
        bool showBadges = true,
      }) {
    return stations.map((station) {
      Color stationColor = _getColorFromHealthState(station);

      return Marker(
        point: LatLng(station.latitude, station.longitude),
        width: 60,
        height: 60,
        child: StationMarker(
          color: stationColor,
          treesToCut: showBadges ? station.treesToCut : null,
          warning: showBadges ? station.warning : null,
          highlight: station.highlight,
        ),
      );
    }).toList();
  }

}



Station buildStation(int i, LatLng point) {
  final random = Random();
  return Station(
    numeroStation: i + 1,
    latitude: point.latitude,
    longitude: point.longitude,
    treesToCut: i % 3 == 0 ? i + 1 : null,
    warning: i % 4 == 0 ? "!" : null,
    highlight: i % 2 == 0,
    lastModifiedBy: "23/12/2024 11:40:13 par A.padounou",
    treeLandscape: "Parc Public",
    humanFrequency: 2 + random.nextInt(3),
    espaceBoiseClasse: i % 2 == 0,
    interetPaysager: i % 3 == 0,
    codeEnvironnement: i % 4 == 0,
    meriteProtection: i % 5 == 0,
    commentaireProtection: "Commentaire ${i + 1}",
    commentaireMeriteProtection: "Mérite réflexion ${i + 1}",
    photoUrls: kStationImageUrlList.take(random.nextInt(kStationImageUrlList.length) + 1).toList(),
  );
}

LatLng randomPointAround(LatLng center,double radiusInMeters, Random random) {
  final angle = 2 * pi * random.nextDouble();
  final distance = radiusInMeters * random.nextDouble();
  final dx = (distance * cos(angle)) / 111320;
  final dy = (distance * sin(angle)) / 111320;
  return LatLng(center.latitude + dy, center.longitude + dx);
}

List<Station> generateStations({required LatLng center, int count = 50, double radius = 2500}) {
  final random = Random();
  return List.generate(count, (i) {
    final point = randomPointAround(center, radius, random);
    return buildStation(i, point);
  });
}

List<Marker> stationsToMarkers(BuildContext context, List<Station> stations, {bool showBadges = false}) {
  final random = Random();
  return stations.map((station) {
    final stationColor = allowedStationColors[random.nextInt(allowedStationColors.length)];
    return Marker(
      point: LatLng(station.latitude, station.longitude),
      width: 60,
      height: 60,
      child: StationMarker(
        color: stationColor,
        treesToCut: showBadges ? station.treesToCut : null,
        warning: showBadges ? station.warning : null,
        highlight: station.highlight,
      ),
    );
  }).toList();
}
 */