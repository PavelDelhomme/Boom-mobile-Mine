import 'package:flutter_map_location_marker/flutter_map_location_marker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

class LocationMapView extends StatefulWidget {
  @override
  LocationMapViewState createState() => LocationMapViewState();
}

class LocationMapViewState extends State<LocationMapView> {
  final MapController _mapController = MapController();
  bool _hasLocationPermission = false;
  String _locationStatus = 'Vérification...';
  LatLng? _currentPosition;
  bool _isFollowingLocation = false;

  @override
  void initState() {
    super.initState();
    _checkLocationPermissions();
  }

  Future<void> _checkLocationPermissions() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() => _locationStatus = 'Services de localisation désactivés');
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      setState(() {
        _locationStatus = permission == LocationPermission.deniedForever
            ? 'Permission refusée définitivement'
            : 'Permission de localisation refusée';
      });
      return;
    }

    // ✅ Obtenir la position initiale
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _hasLocationPermission = true;
        _locationStatus = 'Localisation active';
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      setState(() => _locationStatus = 'Erreur de géolocalisation: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ma Position'),
        backgroundColor: Colors.blue,
        actions: [
          if (_hasLocationPermission)
            IconButton(
              icon: Icon(
                _isFollowingLocation ? Icons.gps_fixed : Icons.gps_not_fixed,
                color: _isFollowingLocation ? Colors.white : Colors.white70,
              ),
              onPressed: _toggleLocationFollowing,
              tooltip: _isFollowingLocation ? 'Arrêter le suivi' : 'Suivre ma position',
            ),
        ],
      ),
      body: Column(
        children: [
          // ✅ Indicateur de statut avec plus de détails
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: _getStatusColor(),
            child: Row(
              children: [
                Icon(
                  _getStatusIcon(),
                  color: Colors.white,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    _locationStatus,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                if (_currentPosition != null)
                  Text(
                    '${_currentPosition!.latitude.toStringAsFixed(4)}, ${_currentPosition!.longitude.toStringAsFixed(4)}',
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ),

          // ✅ Carte ou vue désactivée
          Expanded(
            child: _hasLocationPermission
                ? _buildMap()
                : _buildLocationDisabledView(),
          ),
        ],
      ),

      // ✅ Boutons d'action
      floatingActionButton: _hasLocationPermission
          ? Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          // Bouton centrer sur position
          FloatingActionButton(
            heroTag: "center_location",
            onPressed: _centerOnCurrentLocation,
            backgroundColor: Colors.blue,
            tooltip: 'Centrer sur ma position',
            child: const Icon(Icons.my_location),
          ),
          const SizedBox(height: 12),

          // Bouton rafraîchir position
          FloatingActionButton(
            heroTag: "refresh_location",
            onPressed: _refreshLocation,
            backgroundColor: Colors.green,
            tooltip: 'Actualiser ma position',
            child: const Icon(Icons.refresh),
          ),
        ],
      )
          : FloatingActionButton(
        onPressed: _requestLocationPermission,
        backgroundColor: Colors.orange,
        tooltip: 'Activer la localisation',
        child: const Icon(Icons.location_disabled),
      ),
    );
  }

  // ✅ Construction de la carte avec localisation
  Widget _buildMap() {
    return FlutterMap(
      mapController: _mapController,
      options: MapOptions(
        initialCenter: _currentPosition ?? const LatLng(48.8566, 2.3522),
        initialZoom: 15.0,
        minZoom: 3,
        maxZoom: 19,

        // ✅ Configuration d'interaction optimisée
        interactionOptions: InteractionOptions(
          flags: InteractiveFlag.drag |
          InteractiveFlag.pinchZoom |
          InteractiveFlag.scrollWheelZoom |
          InteractiveFlag.doubleTapZoom |
          InteractiveFlag.flingAnimation,
          scrollWheelVelocity: 0.005,
          pinchZoomThreshold: 0.4,
        ),

        // ✅ Arrêter le suivi si l'utilisateur bouge la carte
        onPositionChanged: (camera, hasGesture) {
          if (hasGesture && _isFollowingLocation) {
            setState(() => _isFollowingLocation = false);
          }
        },
      ),
      children: [
        // ✅ 1. TileLayer (toujours en premier)
        TileLayer(
          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
          userAgentPackageName: 'com.boom.boom_mobile',
          maxZoom: 19,
          // ✅ Optimisations de performance
          maxNativeZoom: 18,     // ✅ Limite zoom natif
          keepBuffer: 2,         // ✅ Cache intelligent
          panBuffer: 1,          // ✅ Buffer panoramique
          additionalOptions: {
            'retinaMode': 'true', // ✅ Support haute résolution
          },
        ),

        // ✅ 2. Couche de position utilisateur avec bonnes constantes
        CurrentLocationLayer(
          alignPositionOnUpdate: _isFollowingLocation
              ? AlignOnUpdate.always
              : AlignOnUpdate.never,
          alignDirectionOnUpdate: AlignOnUpdate.never,
          style: LocationMarkerStyle(
            marker: DefaultLocationMarker(
              child: const Icon(
                Icons.navigation,
                color: Colors.white,
                size: 18,
              ),
            ),
            markerSize: const Size(40, 40),
            showAccuracyCircle: true,
            accuracyCircleColor: Colors.blue.withValues(alpha: 0.3),
            headingSectorColor: Colors.blue.withValues(alpha: 0.7),
            showHeadingSector: false,
          ),
        ),

        // ✅ 3. Attribution
        RichAttributionWidget(
          attributions: [
            TextSourceAttribution('© OpenStreetMap'),
          ],
          alignment: AttributionAlignment.bottomRight,
        ),
      ],
    );
  }

  // ✅ Vue quand la localisation est désactivée
  Widget _buildLocationDisabledView() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_disabled,
              size: 80,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 24),
            Text(
              _locationStatus,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // ✅ Instructions selon le type d'erreur
            if (_locationStatus.contains('Services'))
              _buildInstructionCard(
                'Activez les services de localisation',
                'Allez dans Paramètres > Confidentialité > Services de localisation',
                Icons.settings,
              )
            else if (_locationStatus.contains('Permission'))
              _buildInstructionCard(
                'Autorisez l\'accès à la localisation',
                'Allez dans Paramètres > Applications > Boom Mobile > Autorisations',
                Icons.security,
              )
            else
              _buildInstructionCard(
                'Problème de géolocalisation',
                'Vérifiez votre connexion et réessayez',
                Icons.signal_wifi_off,
              ),

            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _requestLocationPermission,
              icon: const Icon(Icons.refresh),
              label: const Text('Réessayer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ✅ Carte d'instruction
  Widget _buildInstructionCard(String title, String description, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Row(
        children: [
          Icon(icon, color: Colors.blue, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  description,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ✅ Couleur du statut selon l'état
  Color _getStatusColor() {
    if (_hasLocationPermission) return Colors.green;
    if (_locationStatus.contains('refusée')) return Colors.red;
    return Colors.orange;
  }

  // ✅ Icône du statut selon l'état
  IconData _getStatusIcon() {
    if (_hasLocationPermission) return Icons.location_on;
    if (_locationStatus.contains('refusée')) return Icons.location_disabled;
    return Icons.location_searching;
  }

  // ✅ Centrer sur la position actuelle
  void _centerOnCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final newPosition = LatLng(position.latitude, position.longitude);
      setState(() => _currentPosition = newPosition);

      _mapController.move(newPosition, 16.0);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Centré sur votre position'),
          duration: Duration(seconds: 2),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur de géolocalisation: $e')),
      );
    }
  }

  // ✅ Actualiser la position
  void _refreshLocation() async {
    setState(() => _locationStatus = 'Actualisation...');
    await _checkLocationPermissions();

    if (_currentPosition != null) {
      _mapController.move(_currentPosition!, _mapController.camera.zoom);
    }
  }

  // ✅ Basculer le suivi de position
  void _toggleLocationFollowing() {
    setState(() => _isFollowingLocation = !_isFollowingLocation);

    if (_isFollowingLocation && _currentPosition != null) {
      _mapController.move(_currentPosition!, _mapController.camera.zoom);
    }
  }

  // ✅ Demander à nouveau la permission
  void _requestLocationPermission() async {
    await _checkLocationPermissions();
  }
}