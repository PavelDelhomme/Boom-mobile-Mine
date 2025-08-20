import 'package:flutter/rendering.dart';
import 'package:flutter/foundation.dart';

class DebugService extends ChangeNotifier {
  static final DebugService _inst = DebugService._internal();
  factory DebugService() => _inst;
  DebugService._internal();

  bool _enabled = false;
  bool get enabled => _enabled;

  void toggle() {
    _enabled = !_enabled;
    debugPaintSizeEnabled = _enabled;   // active / désactive les cadres bleus
    notifyListeners();                  // force le rebuild du bouton si besoin
  }
}
