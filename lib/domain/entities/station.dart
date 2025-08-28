import 'package:latlong2/latlong.dart';

class Station {
  final int numeroStation;
  double latitude; // Mutable pour déplacement
  double longitude; // Mutable pour déplacement

  final int? treesToCut;
  final String? warning;
  bool highlight; // Mutable pour les modifications d'affichage

  String? lastModifiedBy;
  String? treeLandscape;
  int? humanFrequency;

  bool? espaceBoiseClasse;
  bool? interetPaysager;
  bool? codeEnvironnement;
  bool? alleeArbres;
  bool? perimetreMonument;
  bool? sitePatrimonial;
  bool? autresProtections;
  bool? meriteProtection;
  String? commentaireProtection;
  String? commentaireMeriteProtection;
  late List<String>? photoUrls;

  // Identité
  String? identifiantExterne;
  String? archiveNumero;
  String? adresse;
  String? baseDonneesEssence;
  String? essenceLibre;
  String? variete;
  String? stadeDeveloppement;
  bool? sujetVeteran;
  int? anneePlantation;
  bool? appartenantGroupe;
  bool? arbreReplanter;

  // Forme et gabarit
  String? structureTronc;
  String? portForme;
  double? diametreTronc; // ✅ CORRECTION : double au lieu de String
  double? circonferenceTronc;
  String? diametreHouppier;
  double? hauteurGenerale;

  // Géométries associées
  List<LatLng>? points;
  List<List<LatLng>>? lignes;
  List<List<LatLng>>? polygones;

  Station({
    required this.numeroStation,
    required this.latitude,
    required this.longitude,
    this.treesToCut,
    this.warning,
    this.highlight = false,
    this.lastModifiedBy,
    this.treeLandscape,
    this.humanFrequency,
    this.espaceBoiseClasse,
    this.interetPaysager,
    this.codeEnvironnement,
    this.alleeArbres,
    this.perimetreMonument,
    this.sitePatrimonial,
    this.autresProtections,
    this.meriteProtection,
    this.commentaireProtection,
    this.commentaireMeriteProtection,
    this.photoUrls,

    // Identité
    this.identifiantExterne,
    this.archiveNumero,
    this.adresse,
    this.baseDonneesEssence,
    this.essenceLibre,
    this.variete,
    this.stadeDeveloppement,
    this.sujetVeteran,
    this.anneePlantation,
    this.appartenantGroupe,
    this.arbreReplanter,

    // Forme et gabarit
    this.structureTronc,
    this.portForme,
    this.diametreTronc,
    this.circonferenceTronc,
    this.diametreHouppier,
    this.hauteurGenerale,

    // Géométries
    this.points,
    this.lignes,
    this.polygones,
  });

  // Méthode pour obtenir les coordonnées comme LatLng
  LatLng get coordinates => LatLng(latitude, longitude);

  // Méthode pour mettre à jour la position
  void updatePosition(double newLatitude, double newLongitude) {
    latitude = newLatitude;
    longitude = newLongitude;
    updateModificationInfo();
  }

  // Méthode pour ajouter un point géographique
  void addPoint(LatLng point) {
    points ??= [];
    points!.add(point);
    updateModificationInfo();
  }

  // Méthode pour ajouter une ligne
  void addLigne(List<LatLng> ligne) {
    lignes ??= [];
    lignes!.add(ligne);
    updateModificationInfo();
  }

  // Méthode pour ajouter un polygone
  void addPolygone(List<LatLng> polygone) {
    polygones ??= [];
    polygones!.add(polygone);
    updateModificationInfo();
  }

  // Méthode pour supprimer tous les points
  void clearPoints() {
    points?.clear();
    updateModificationInfo();
  }

  // Méthode pour supprimer toutes les lignes
  void clearLignes() {
    lignes?.clear();
    updateModificationInfo();
  }

  // Méthode pour supprimer tous les polygones
  void clearPolygones() {
    polygones?.clear();
    updateModificationInfo();
  }

  // Méthode pour supprimer toutes les géométries
  void clearAllGeometries() {
    clearPoints();
    clearLignes();
    clearPolygones();
  }

  // Méthode pour ajouter une photo
  void addPhoto(String photoUrl) {
    photoUrls ??= [];
    photoUrls!.add(photoUrl);
    updateModificationInfo();
  }

  // Méthode pour supprimer une photo
  void removePhoto(String photoUrl) {
    photoUrls?.remove(photoUrl);
    updateModificationInfo();
  }

  // Méthode publique pour mettre à jour les infos de modification
  void updateModificationInfo() {
    lastModifiedBy = "Modifié le ${DateTime.now().toString().substring(0, 19)}";
  }

  // Méthode pour vérifier si la station a des géométries
  bool get hasGeometries {
    return (points?.isNotEmpty ?? false) ||
        (lignes?.isNotEmpty ?? false) ||
        (polygones?.isNotEmpty ?? false);
  }

  // Méthode pour compter le nombre total de géométries
  int get geometriesCount {
    int count = 0;
    count += points?.length ?? 0;
    count += lignes?.length ?? 0;
    count += polygones?.length ?? 0;
    return count;
  }

  // Méthode pour obtenir un résumé des géométries
  String get geometriesSummary {
    List<String> parts = [];

    if (points?.isNotEmpty ?? false) {
      parts.add('${points!.length} point(s)');
    }
    if (lignes?.isNotEmpty ?? false) {
      parts.add('${lignes!.length} ligne(s)');
    }
    if (polygones?.isNotEmpty ?? false) {
      parts.add('${polygones!.length} polygone(s)');
    }

    return parts.isEmpty ? 'Aucune géométrie' : parts.join(', ');
  }

  // ✅ CORRECTION: Méthode copyWith avec types corrects
  Station copyWith({
    int? numeroStation,
    double? latitude,
    double? longitude,
    int? treesToCut,
    String? warning,
    bool? highlight,
    String? lastModifiedBy,
    String? treeLandscape,
    int? humanFrequency,
    bool? espaceBoiseClasse,
    bool? interetPaysager,
    bool? codeEnvironnement,
    bool? alleeArbres,
    bool? perimetreMonument,
    bool? sitePatrimonial,
    bool? autresProtections,
    bool? meriteProtection,
    String? commentaireProtection,
    String? commentaireMeriteProtection,
    List<String>? photoUrls,
    String? identifiantExterne,
    String? archiveNumero,
    String? adresse,
    String? baseDonneesEssence,
    String? essenceLibre,
    String? variete,
    String? stadeDeveloppement,
    bool? sujetVeteran,
    int? anneePlantation,
    bool? appartenantGroupe,
    bool? arbreReplanter,
    String? structureTronc,
    String? portForme,
    double? diametreTronc, // ✅ CORRECTION: double au lieu de String
    double? circonferenceTronc,
    String? diametreHouppier,
    double? hauteurGenerale,
    List<LatLng>? points,
    List<List<LatLng>>? lignes,
    List<List<LatLng>>? polygones,
  }) {
    return Station(
      numeroStation: numeroStation ?? this.numeroStation,
      latitude: latitude ?? this.latitude,
      longitude: longitude ?? this.longitude,
      treesToCut: treesToCut ?? this.treesToCut,
      warning: warning ?? this.warning,
      highlight: highlight ?? this.highlight,
      lastModifiedBy: lastModifiedBy ?? this.lastModifiedBy,
      treeLandscape: treeLandscape ?? this.treeLandscape,
      humanFrequency: humanFrequency ?? this.humanFrequency,
      espaceBoiseClasse: espaceBoiseClasse ?? this.espaceBoiseClasse,
      interetPaysager: interetPaysager ?? this.interetPaysager,
      codeEnvironnement: codeEnvironnement ?? this.codeEnvironnement,
      alleeArbres: alleeArbres ?? this.alleeArbres,
      perimetreMonument: perimetreMonument ?? this.perimetreMonument,
      sitePatrimonial: sitePatrimonial ?? this.sitePatrimonial,
      autresProtections: autresProtections ?? this.autresProtections,
      meriteProtection: meriteProtection ?? this.meriteProtection,
      commentaireProtection: commentaireProtection ?? this.commentaireProtection,
      commentaireMeriteProtection: commentaireMeriteProtection ?? this.commentaireMeriteProtection,
      photoUrls: photoUrls ?? (this.photoUrls != null ? List.from(this.photoUrls!) : null),
      identifiantExterne: identifiantExterne ?? this.identifiantExterne,
      archiveNumero: archiveNumero ?? this.archiveNumero,
      adresse: adresse ?? this.adresse,
      baseDonneesEssence: baseDonneesEssence ?? this.baseDonneesEssence,
      essenceLibre: essenceLibre ?? this.essenceLibre,
      variete: variete ?? this.variete,
      stadeDeveloppement: stadeDeveloppement ?? this.stadeDeveloppement,
      sujetVeteran: sujetVeteran ?? this.sujetVeteran,
      anneePlantation: anneePlantation ?? this.anneePlantation,
      appartenantGroupe: appartenantGroupe ?? this.appartenantGroupe,
      arbreReplanter: arbreReplanter ?? this.arbreReplanter,
      structureTronc: structureTronc ?? this.structureTronc,
      portForme: portForme ?? this.portForme,
      diametreTronc: diametreTronc ?? this.diametreTronc,
      circonferenceTronc: circonferenceTronc ?? this.circonferenceTronc,
      diametreHouppier: diametreHouppier ?? this.diametreHouppier,
      hauteurGenerale: hauteurGenerale ?? this.hauteurGenerale,
      // Types corrects pour les listes
      points: points ?? (this.points != null ? List<LatLng>.from(this.points!) : null),
      lignes: lignes ?? (this.lignes != null ? this.lignes!.map((ligne) => List<LatLng>.from(ligne)).toList() : null),
      polygones: polygones ?? (this.polygones != null ? this.polygones!.map((poly) => List<LatLng>.from(poly)).toList() : null),
    );
  }

  factory Station.fromJson(Map<String, dynamic> json) => Station.fromMap(json);
  Map<String, dynamic> toJson() => toMap();

  Map<String, dynamic> toMap() => {
    'numeroStation': numeroStation,
    'latitude': latitude,
    'longitude': longitude,
    'treesToCut': treesToCut,
    'warning': warning,
    'highlight': highlight,
    'lastModifiedBy': lastModifiedBy,
    'treeLandscape': treeLandscape,
    'humanFrequency': humanFrequency,
    'espaceBoiseClasse': espaceBoiseClasse,
    'interetPaysager': interetPaysager,
    'codeEnvironnement': codeEnvironnement,
    'alleeArbres': alleeArbres,
    'perimetreMonument': perimetreMonument,
    'sitePatrimonial': sitePatrimonial,
    'autresProtections': autresProtections,
    'meriteProtection': meriteProtection,
    'commentaireProtection': commentaireProtection,
    'commentaireMeriteProtection': commentaireMeriteProtection,
    'photoUrls': photoUrls,
    'identifiantExterne': identifiantExterne,
    'archiveNumero': archiveNumero,
    'adresse': adresse,
    'baseDonneesEssence': baseDonneesEssence,
    'essenceLibre': essenceLibre,
    'variete': variete,
    'stadeDeveloppement': stadeDeveloppement,
    'sujetVeteran': sujetVeteran,
    'anneePlantation': anneePlantation,
    'appartenantGroupe': appartenantGroupe,
    'arbreReplanter': arbreReplanter,
    'structureTronc': structureTronc,
    'portForme': portForme,
    'diametreTronc': diametreTronc,
    'circonferenceTronc': circonferenceTronc,
    'diametreHouppier': diametreHouppier,
    'hauteurGenerale': hauteurGenerale,
    'points': points,
    'lignes': lignes,
    'polygones': polygones,
  };

  // ✅ CORRECTION: Méthode fromMap avec conversion de types safe
  static Station fromMap(Map<String, dynamic> map) {
    return Station(
      numeroStation: map['numeroStation'] is String
          ? int.parse(map['numeroStation'])
          : map['numeroStation'],
      latitude: (map['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (map['longitude'] as num?)?.toDouble() ?? 0.0,
      treesToCut: map['treesToCut'],
      warning: map['warning'],
      highlight: map['highlight'] ?? false,
      lastModifiedBy: map['lastModifiedBy'],
      treeLandscape: map['treeLandscape'],
      humanFrequency: map['humanFrequency'] is String
          ? int.tryParse(map['humanFrequency'])
          : map['humanFrequency'],
      espaceBoiseClasse: map['espaceBoiseClasse'],
      interetPaysager: map['interetPaysager'],
      codeEnvironnement: map['codeEnvironnement'],
      alleeArbres: map['alleeArbres'],
      perimetreMonument: map['perimetreMonument'],
      sitePatrimonial: map['sitePatrimonial'],
      autresProtections: map['autresProtections'],
      meriteProtection: map['meriteProtection'],
      commentaireProtection: map['commentaireProtection'],
      commentaireMeriteProtection: map['commentaireMeriteProtection'],
      photoUrls: (map['photoUrls'] as List<dynamic>?)?.cast<String>(),
      identifiantExterne: map['identifiantExterne'],
      archiveNumero: map['archiveNumero'],
      adresse: map['adresse'],
      baseDonneesEssence: map['baseDonneesEssence'],
      essenceLibre: map['essenceLibre'],
      variete: map['variete'],
      stadeDeveloppement: map['stadeDeveloppement'],
      sujetVeteran: map['sujetVeteran'],
      anneePlantation: map['anneePlantation'] is String
          ? int.tryParse(map['anneePlantation'])
          : map['anneePlantation'],
      appartenantGroupe: map['appartenantGroupe'],
      arbreReplanter: map['arbreReplanter'],
      structureTronc: map['structureTronc'],
      portForme: map['portForme'],
      diametreTronc: map['diametreTronc'] is String
          ? double.tryParse(map['diametreTronc'])
          : (map['diametreTronc'] as num?)?.toDouble(),
      circonferenceTronc: map['circonferenceTronc'] is String
          ? double.tryParse(map['circonferenceTronc'])
          : (map['circonferenceTronc'] as num?)?.toDouble(),
      diametreHouppier: map['diametreHouppier'],
      hauteurGenerale: map['hauteurGenerale'] is String
          ? double.tryParse(map['hauteurGenerale'])
          : (map['hauteurGenerale'] as num?)?.toDouble(),
      points: (map['points'] as List<dynamic>?)?.cast<LatLng>(),
      lignes: (map['lignes'] as List<dynamic>?)?.map((e) => (e as List<dynamic>).cast<LatLng>()).toList(),
      polygones: (map['polygones'] as List<dynamic>?)?.map((e) => (e as List<dynamic>).cast<LatLng>()).toList(),
    );
  }
}