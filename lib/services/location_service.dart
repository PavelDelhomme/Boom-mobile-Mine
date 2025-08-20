
import 'package:geolocator/geolocator.dart';

class LocationService {
  static Future<LocationStatus> checkLocationStatus() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) return LocationStatus.serviceDisabled;

    LocationPermission permission = await Geolocator.checkPermission();

    switch (permission) {
      case LocationPermission.denied:
        permission = await Geolocator.requestPermission();
        return permission == LocationPermission.denied
            ? LocationStatus.permissionDenied
            : LocationStatus.granted;
      case LocationPermission.deniedForever:
        return LocationStatus.permissionDeniedForever;
      case LocationPermission.whileInUse:
        return LocationStatus.whileInUse;
      case LocationPermission.always:
        return LocationStatus.granted;
      default:
        return LocationStatus.unknown;
    }
  }
}

enum LocationStatus {
  granted,
  serviceDisabled,
  permissionDenied,
  permissionDeniedForever,
  whileInUse,
  unknown,
}