import 'package:boom_mobile/presentation/screens/accueil/accueil_screen.dart';
import 'package:boom_mobile/presentation/screens/authentication/enhanced_login_screen.dart';
import 'package:boom_mobile/services/modification_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'domain/mock_data.dart';
import 'services/layer_service.dart';
import 'services/station_service.dart';
import 'services/offline_cache_service.dart';
import 'services/draw_service.dart';
import 'core/theme/app_theme.dart';
import 'core/constants/app_data.dart';
import 'domain/entities/account.dart';
import 'domain/entities/dossier.dart';
import 'domain/entities/user.dart';

void main() async {
  // ✅ Initialisation Flutter pour les services async
  WidgetsFlutterBinding.ensureInitialized();

  // ✅ Initialiser les données de l'application
  AppData.initialize();

  // ✅ Initialiser le service de cache offline
  final offlineCacheService = OfflineCacheService();
  await offlineCacheService.initialize();

  runApp(BoomMobileApp(offlineCacheService: offlineCacheService));
}

class BoomMobileApp extends StatelessWidget {
  final OfflineCacheService offlineCacheService;

  const BoomMobileApp({
    super.key,
    required this.offlineCacheService,
  });

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ Service de cache offline (singleton)
        ChangeNotifierProvider<OfflineCacheService>.value(
          value: offlineCacheService,
        ),

        // ✅ Service de gestion des modifications
        ChangeNotifierProvider<ModificationService>(
          create: (context) => ModificationService(),
        ),

        // ✅ Service de gestion des couches avec cache
        ChangeNotifierProvider<LayerService>(
          create: (context) {
            final layerService = LayerService();
            layerService.initialize(
              MockData.fakeLayers(),
              cacheService: offlineCacheService,
            );
            return layerService;
          },
        ),

        // ✅ Service de gestion des stations
        ChangeNotifierProvider<StationService>(
          create: (context) => StationService(),
        ),

        // ✅ Service de dessin
        ChangeNotifierProvider<DrawService>(
          create: (context) => DrawService(),
        ),

        // ✅ Fournir les données statiques à travers l'arbre des widgets
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
class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        // ✅ Providers minimaux pour les tests
        ChangeNotifierProvider<StationService>(
          create: (context) => StationService(),
        ),
        ChangeNotifierProvider<LayerService>(
          create: (context) => LayerService(),
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