import 'dart:developer';

import 'package:boom_mobile/domain/mock_data.dart';
import 'package:boom_mobile/domain/entities/account.dart';
import 'package:boom_mobile/domain/entities/dossier.dart';
import 'package:boom_mobile/domain/entities/layer.dart';
import 'package:boom_mobile/domain/entities/user.dart';
import 'package:boom_mobile/domain/entities/station.dart';

class AppData {
  // Données centralisées - génération 1 fois au démarrage
  static final layers = MockData.fakeLayers();
  static final dossiers = MockData.fakeDossiers();
  static final accounts = MockData.fakeAccounts();
  static final users = MockData.fakeUsers();

  // ✅ AJOUT: Propriété stations qui récupère toutes les stations des dossiers
  static List<Station> get stations {
    List<Station> allStations = [];
    for (final dossier in dossiers) {
      allStations.addAll(dossier.stations);
    }
    return allStations;
  }

  // Initialisation toutes les données en une seule fois
  static void initialize() {
    // Force l'initialisation de toutes les données
    layers;
    dossiers;
    accounts;
    users;
    stations; // Initialise aussi les stations
    log("Données mock initialisées - ${stations.length} stations trouvées");
  }
}

// Accesseurs globaux pour une utilisation simplifiée
List<Dossier> get globalDossiers => AppData.dossiers;
List<Layer> get globalLayers => AppData.layers;
List<Account> get globalAccounts => AppData.accounts;
List<User> get globalUsers => AppData.users;
List<Station> get globalStations => AppData.stations; // ✅ AJOUT