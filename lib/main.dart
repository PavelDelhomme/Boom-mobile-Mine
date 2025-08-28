import 'package:boom_mobile/data/repositories/geometry_repository.dart';
import 'package:boom_mobile/data/services/geometry_service.dart';
import 'package:boom_mobile/data/services/layer_service.dart';
import 'package:boom_mobile/data/services/modification_service.dart';
import 'package:boom_mobile/data/services/offline_cache_service.dart';
import 'package:boom_mobile/data/services/station_service.dart';
import 'package:boom_mobile/presentation/screens/accueil/accueil_screen.dart';
import 'package:boom_mobile/presentation/screens/authentication/enhanced_login_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:provider/provider.dart';
import 'data/services/draw_bloc.dart';
import 'data/services/station_version_manager.dart';
import 'data/services/tile_cache_service.dart';
import 'data/services/draw_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_data.dart';
import 'domain/entities/account.dart';
import 'domain/entities/dossier.dart';
import 'domain/entities/user.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialiser Hive
  await Hive.initFlutter();

  // Initialiser les données de l'application
  AppData.initialize();

  // Initialiser les services
  final offlineCacheService = OfflineCacheService();
  await offlineCacheService.initialize();

  final tileCacheService = TileCacheService();
  await tileCacheService.initialize();

  final stationVersionManager = StationVersionManager();
  await stationVersionManager.initialize();

  final geometryRepository = GeometryRepository();

  runApp(BoomMobileApp(
    offlineCacheService: offlineCacheService,
    tileCacheService: tileCacheService,
    stationVersionManager: stationVersionManager,
    geometryRepository: geometryRepository,
  ));
}

class BoomMobileApp extends StatelessWidget {
  final OfflineCacheService offlineCacheService;
  final TileCacheService tileCacheService;
  final StationVersionManager stationVersionManager;
  final GeometryRepository geometryRepository;

  const BoomMobileApp({
    super.key,
    required this.offlineCacheService,
    required this.tileCacheService,
    required this.stationVersionManager,
    required this.geometryRepository,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ CORRECTION: OfflineCacheService hérite de ChangeNotifier
        ChangeNotifierProvider<OfflineCacheService>.value(value: offlineCacheService),
        Provider<TileCacheService>.value(value: tileCacheService),
        Provider<StationVersionManager>.value(value: stationVersionManager),
        Provider<GeometryRepository>.value(value: geometryRepository),

        // ✅ CORRECTION: Service de géométrie avec ChangeNotifierProvider
        ChangeNotifierProvider<GeometryService>(
          create: (context) => GeometryService(
            context.read<GeometryRepository>(),
          ),
        ),

        // Service de modification
        ChangeNotifierProvider<ModificationService>(
          create: (context) => ModificationService(),
        ),

        // Service de gestion des couches
        ChangeNotifierProvider<LayerService>(
          create: (context) {
            return LayerService();
          },
        ),

        // Service de gestion des stations
        ChangeNotifierProvider<StationService>(
          create: (context) => StationService(),
        ),

        // Service de dessin (DrawService)
        ChangeNotifierProvider<DrawService>(
          create: (context) => DrawService(),
        ),

        // Bloc de dessin (pour la compatibilité)
        BlocProvider<DrawBloc>(
          create: (context) => DrawBloc(context.read<StationService>()),
        ),

        // Données statiques
        Provider<List<Dossier>>.value(value: AppData.dossiers),
        Provider<List<Account>>.value(value: AppData.accounts),
        Provider<List<User>>.value(value: AppData.users),
      ],
      child: MaterialApp(
        title: 'Boom Mobile',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        // TODO: Commencer par l'écran de login
        //home: const LoginScreen(),
        // Commencer directement par l'accueil
        home: const AccueilScreen(),
      ),
    );
  }
}

// Pour les tests seulement - cette classe permet de tester l'application
// sans avoir à instancier OfflineCacheService
class BoomMobileAppTest extends StatelessWidget {
  const BoomMobileAppTest({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // Providers minimaux pour les tests
        ChangeNotifierProvider<StationService>(
          create: (context) => StationService(),
        ),
        ChangeNotifierProvider<LayerService>(
          create: (context) => LayerService(),
        ),
        // DrawService pour les tests
        ChangeNotifierProvider<DrawService>(
          create: (context) => DrawService(),
        ),
      ],
      child: MaterialApp(
        title: 'Boom Mobile',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}