// 🗝️ Configuration des clés API pour les services cartographiques

// ✅ INSTRUCTIONS pour obtenir une clé IGN gratuite :
// 1. Aller sur https://geoservices.ign.fr/
// 2. Créer un compte
// 3. Créer une nouvelle application
// 4. Sélectionner les services WMTS (Plan, Ortho, etc.)
// 5. Copier la clé générée ci-dessous

// 🔑 CLÉ IGN - À remplacer par votre vraie clé
const String ignApiKey = 'VOTRE_CLE_IGN_ICI';

// ✅ ALTERNATIVE : Utiliser une clé de démonstration IGN (limitée)
// const String ignApiKey = 'choisirgeoportail';

// 🔑 Autres clés API (optionnelles)
const String mapboxApiKey = 'VOTRE_CLE_MAPBOX_ICI';
const String googleMapsApiKey = 'VOTRE_CLE_GOOGLE_ICI';

// 🛠️ Configuration des services
class GeoServicesConfig {
  static const int maxZoom = 19;
  static const int minZoom = 1;
  static const String userAgent = 'com.boom.boom_mobile';

  // URLs de base pour différents services
  static const String ignBaseUrl = 'https://wxs.ign.fr';
  static const String osmBaseUrl = 'https://tile.openstreetmap.org';
  static const String mapboxBaseUrl = 'https://api.mapbox.com/styles/v1';

  // Validation des clés
  static bool get hasValidIgnKey =>
      ignApiKey.isNotEmpty &&
          ignApiKey != 'VOTRE_CLE_IGN_ICI' &&
          ignApiKey != 'CLEF_IGN_Ici';

  static bool get hasValidMapboxKey =>
      mapboxApiKey.isNotEmpty &&
          mapboxApiKey != 'VOTRE_CLE_MAPBOX_ICI';
}

// 🎨 Styles de carte disponibles
enum MapStyle {
  openStreetMap,
  ignPlan,
  ignOrtho,
  openTopo,
  stamenTerrain,
  cartoPositron,
  esriImagery,
  mapboxSatellite,
}

extension MapStyleExtension on MapStyle {
  String get displayName {
    switch (this) {
      case MapStyle.openStreetMap:
        return 'OpenStreetMap';
      case MapStyle.ignPlan:
        return 'Plan IGN';
      case MapStyle.ignOrtho:
        return 'Photographies aériennes';
      case MapStyle.openTopo:
        return 'OpenTopoMap';
      case MapStyle.stamenTerrain:
        return 'Terrain';
      case MapStyle.cartoPositron:
        return 'CartoDB Clair';
      case MapStyle.esriImagery:
        return 'Imagerie Esri';
      case MapStyle.mapboxSatellite:
        return 'Satellite Mapbox';
    }
  }

  bool get requiresApiKey {
    switch (this) {
      case MapStyle.ignPlan:
      case MapStyle.ignOrtho:
        return true;
      case MapStyle.mapboxSatellite:
        return true;
      default:
        return false;
    }
  }

  bool get isAvailable {
    switch (this) {
      case MapStyle.ignPlan:
      case MapStyle.ignOrtho:
        return GeoServicesConfig.hasValidIgnKey;
      case MapStyle.mapboxSatellite:
        return GeoServicesConfig.hasValidMapboxKey;
      default:
        return true;
    }
  }
}