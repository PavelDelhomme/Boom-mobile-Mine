import 'package:boom_mobile/domain/entities/station.dart';
import 'package:latlong2/latlong.dart';

import 'draw_service_interface.dart';

abstract class Command {
  void execute();
  void undo();
}


// Commande pour ajouter un point
class AddPointCommand implements Command {
  final DrawServiceInterface _service;
  final LatLng _point;
  final Station? _station;

  AddPointCommand(this._service, this._point, this._station);
  @override
  void execute() {
    _service.addPoint(_point);
    if (_station != null && _service.stationService != null) {
      _service.stationService!.addPointToStation(_station, _point);
    }
  }

  @override
  void undo() {
    // Utiliser les méthodes publiques au lieu des propriétés privées
    _service.undo();

    if (_station != null && _service.stationService != null) {
      // Logique pour annuler l'ajout du point à la station
      // _service.stationService!.removeLastPointFromStation(_station!);
    }
  }
}



// Gestionnaire de commandes
class CommandManager {
  final List<Command> _history = [];
  int _currentIndex = -1;

  void executeCommand(Command command) {
    // Supprimer les commandes annulées si on exécute une nouvelle commande
    if (_currentIndex < _history.length - 1) {
      _history.removeRange(_currentIndex + 1, _history.length);
    }

    // Exécuter et ajouter la commande
    command.execute();
    _history.add(command);
    _currentIndex++;
  }

  void undo() {
    if (_currentIndex >= 0) {
      _history[_currentIndex].undo();
      _currentIndex--;
    }
  }

  void redo() {
    if (_currentIndex < _history.length - 1) {
      _currentIndex++;
      _history[_currentIndex].execute();
    }
  }

  void clear() {
    _history.clear();
    _currentIndex = -1;
  }

  bool get canUndo => _currentIndex >= 0;
  bool get canRedo => _currentIndex < _history.length - 1;
}