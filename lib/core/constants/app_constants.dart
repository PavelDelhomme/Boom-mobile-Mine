import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';

// 📏 Marges et hauteurs
const double kHorizontalPadding = 16.0;
const double kVerticalPadding = 16.0;
const double kAppTopBarHeight = 60.0;
const double kTabBarHeight = 44.0;
const double kSearchBarHeight = 44.0;
const double kSilverPersistentSearchBarHeight = kSearchBarHeight + 8.0;
const double kStickyExtraSpace = 8.0;
const double kElementSpacing = 8.0;
const double kCardSpacing = 8.0;
const double kElementListSpacing = 4.0;
const double kBoutonSize = 20;
const double kTabContentPaddingVertical = 12.0;
const double kIconSize = 32;


// 📦 Images UI
const kDossierImage = "assets/images/exemple_image_dossier.png"; // Image de dossier mock
const kBienvenueImage = "assets/images/bienvenue_image.png"; // Image de bienvenue
const kBoomLogo = "assets/images/logo_boom.png"; // Logo Boom
const kStationImage = "assets/images/photo2.png"; // Image de la station (perroquet)
const kStationImage1 = "assets/images/effiel.png";
const kStationImage2 = "assets/images/logo_boom.png";
const kStationImage3 = "assets/images/photo1.png";
const kCopier = "assets/icons/copier.png"; // Button copier station

// 🗂️ Dossiers / Add Folder
const kAddFolderImage = "assets/icons/add-folder.png"; // Ensemble du bouton vec le vert autour
const kAddFolderImageTest = "assets/icons/add-folder.png"; // Plus besoin du _test, on est clean

// 🔄 Switchs
const kSwitch = "assets/icons/switch.png"; // Bouton de switch de dossier, utilisateur,...

// 🗺️ Boutons Map génériques
const double kMapIconSize = 48.0; // Taille des icônes de boutons de map

const kBtnExportPdf = "assets/icons/export_pdf.png"; // Bouton export PDF
const kBtnExportData = "assets/icons/export_data.png"; // Bouton export Data
const kBtnExportDatabase = "assets/icons/export_database.png"; // Bouton export Database

const kBtnFilter = "assets/icons/filter.png"; // Bouton de filtres

const kBtnEdit = "assets/icons/edit.png"; // Bouton d'édition

const kBtnLayers = "assets/icons/layer.png"; // Bouton de couche
const kBtnLocation = "assets/icons/location.png"; // Bouton de localisation

const kBtnPosition = "assets/icons/position.png"; // Bouton de position

// 👤 Avatar / Perso
const kAvatar = "assets/icons/person_icon.png";

// 📊 Onglets navigation
const kNavHome = "assets/icons/li_home_01.png";
const kNavMap = "assets/icons/li_pie-chart_01.png";
const kNavIntervention = "assets/icons/li_clock_512w.png";
const kNavUser = "assets/icons/li_user.png";

// 🪓 Icônes spécifiques
const kAbattage = "assets/icons/abattage.png";
const kAddPhoto = "assets/icons/add_photo.png";
// 📦 Icônes systèmes (Flutter Material icons)
var btnSave = Icons.save;
var btnEditMaterial = Icons.edit;
var btnFilterMaterial = Icons.filter_alt;
var btnLockReset = Icons.lock_reset;
var btnDatabaseExport = Icons.cloud_upload;
var btnLayersMaterial = Icons.layers_outlined;
var btnExportPdfMaterial = Icons.picture_as_pdf;

// Constantes des images & des données de mock
const kStationImageUrlList = [
  'https://picsum.photos/400/300?random=1',
  'https://picsum.photos/400/300?random=2',
  'https://picsum.photos/400/300?random=3',
  'https://picsum.photos/400/300?random=4',
  'https://picsum.photos/400/300?random=5',
];

const centers = {
  'Nantes': LatLng(47.2184, -1.5536),
  'Vertou': LatLng(47.1684, -1.4693),
  'Thorigné-Fouillard': LatLng(48.1342, -1.5790),
  'Rennes': LatLng(48.1176, -1.6774),
  'Cesson-Sévigné': LatLng(48.1210, -1.6245),
  'Angers': LatLng(47.4804, -0.5601),
  'Bruz': LatLng(48.0214, -1.7464),
  'Pacé': LatLng(48.1471, -1.7914),
  'Betton': LatLng(48.1862, -1.6397),
  'Vitré': LatLng(48.1232, -1.2055),
  'Chateaugiron': LatLng(48.0496, -1.5003),
  'Chateaubriant': LatLng(47.7177, -1.3736),
  'Ancenis': LatLng(47.3689, -1.1766),
  'Blain': LatLng(47.5114, -1.7553)
};

final allowedStationColors = [
  Colors.green,
  Colors.orange,
  Colors.red,
  Colors.yellow,
];

const kGeoServicesImagesTuileesWMTS = "https://data.geopf.fr/wmts?SERVICE=WMTS&VERSION=1.0.0&REQUEST=GetCapabilities";

const kGeoServicesPlanIGN = "https://data.geopf.fr/tms/1.0.0/PLAN.IGN/metadata.json/";

const kGeoServicesAdminEXPRESS = "https://data.geopf.fr/tms/1.0.0/ADMIN_EXPRESS/metadata.json/";

const kGeoServicesImageWMSRaster = "https://data.geopf.fr/wms-r/wms?SERVICE=WMS&VERSION=1.3.0&REQUEST=GetCapabilities";

const kGeoServicesImageWMSRasterFilres = "https://data.geopf.fr/annexes/ressources/wms-r/essentiels.xml";

const kGeoServicesImageWMSVecteur = "https://data.geopf.fr/wms-v/ows?service=wms&version=1.3.0&request=GetCapabilities";

const kGeoServicesImageWMSVecteurFiltres = "https://data.geopf.fr/annexes/ressources/wms-v/essentiels.xml";

const kGeoServicesServicesWFS = "https://data.geopf.fr/wfs/ows?SERVICE=WFS&VERSION=2.0.0&REQUEST=GetCapabilities";

const kGeoServicesServicesWFSFiltres = "https://data.geopf.fr/annexes/ressources/wfs/essentiels.xml";


//const kGoogleIcon = "https://www.google.com/url?sa=i&url=https%3A%2F%2Ffr.m.wikipedia.org%2Fwiki%2FFichier%3AGoogle_%2522G%2522_logo.svg&psig=AOvVaw0iX_Ce-JomGJodLGH0pCLc&ust=1753455804186000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCMjUn4bi1Y4DFQAAAAAdAAAAABAE";
//const kMicrosoftIcon = "https://www.google.com/url?sa=i&url=https%3A%2F%2Fwww.logo.wine%2Flogo%2FMicrosoft_Store&psig=AOvVaw3JGiy6LrSKIUgnme3Nej2C&ust=1753455827362000&source=images&cd=vfe&opi=89978449&ved=0CBUQjRxqFwoTCOCrhpLi1Y4DFQAAAAAdAAAAABA7";
