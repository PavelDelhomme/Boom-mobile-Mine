// map_editor.dart - Version simplifiée et corrigée
import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/data/services/draw_service.dart';
import 'package:boom_mobile/data/services/station_service.dart';
import 'package:boom_mobile/domain/entities/station.dart';
import 'package:boom_mobile/data/interfaces/draw_service_interface.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

enum EditMode {
  view,      // Mode visualisation
  addPoint,  // Mode ajout de points
  movePoint, // Mode déplacement de points
  deletePoint, // Mode suppression de points
}

class MapEditor extends StatefulWidget {
  final Station? station;
  final VoidCallback? onClose;
  final VoidCallback? onSave;

  const MapEditor({
    super.key,
    this.station,
    this.onClose,
    this.onSave,
  });

  @override
  State<MapEditor> createState() => _MapEditorState();
}

class _MapEditorState extends State<MapEditor> {
  final MapController _mapController = MapController();
  EditMode _currentMode = EditMode.view;
  int? _selectedPointIndex;
  bool _hasUnsavedChanges = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeEditor();
    });
  }

  void _initializeEditor() {
    if (widget.station != null) {
      final drawService = context.read<DrawService>();
      drawService.setCurrentStation(widget.station!);
      drawService.enableEditMode();

      // Centrer la carte sur la station
      if (widget.station!.latitude != 0 && widget.station!.longitude != 0) {
        _mapController.move(
          LatLng(widget.station!.latitude, widget.station!.longitude),
          16.0,
        );
      }
    }
  }

  void _setMode(EditMode mode) {
    setState(() {
      _currentMode = mode;
      _selectedPointIndex = null;
    });

    final drawService = context.read<DrawService>();

    switch (mode) {
      case EditMode.view:
        drawService.setTool(DrawTool.none);
        break;
      case EditMode.addPoint:
        drawService.setTool(DrawTool.point);
        break;
      case EditMode.movePoint:
      case EditMode.deletePoint:
        drawService.setTool(DrawTool.none);
        break;
    }
  }

  void _handleMapTap(TapPosition tapPosition, LatLng point) {
    switch (_currentMode) {
      case EditMode.addPoint:
        _addPoint(point);
        break;
      case EditMode.movePoint:
        _selectPointForMove(point);
        break;
      case EditMode.deletePoint:
        _selectPointForDelete(point);
        break;
      case EditMode.view:
        _selectPoint(point);
        break;
    }
  }

  void _addPoint(LatLng point) {
    final drawService = context.read<DrawService>();
    drawService.addPoint(point);

    if (widget.station != null) {
      final stationService = context.read<StationService>();
      stationService.addPointToStation(widget.station!, point);
    }

    setState(() {
      _hasUnsavedChanges = true;
    });

    _showSnackBar('Point ajouté', Colors.green);
  }

  void _selectPoint(LatLng tapPoint) {
    final drawService = context.read<DrawService>();
    final points = drawService.points;

    for (int i = 0; i < points.length; i++) {
      if (_isPointNear(tapPoint, points[i])) {
        setState(() {
          _selectedPointIndex = i;
        });
        drawService.selectPoint(points[i], i);
        _showPointDetails(i, points[i]);
        return;
      }
    }

    // Aucun point sélectionné
    setState(() {
      _selectedPointIndex = null;
    });
  }

  void _selectPointForMove(LatLng tapPoint) {
    final drawService = context.read<DrawService>();
    final points = drawService.points;

    for (int i = 0; i < points.length; i++) {
      if (_isPointNear(tapPoint, points[i])) {
        _showMovePointDialog(i, points[i]);
        return;
      }
    }

    _showSnackBar('Aucun point trouvé à cette position', Colors.orange);
  }

  void _selectPointForDelete(LatLng tapPoint) {
    final drawService = context.read<DrawService>();
    final points = drawService.points;

    for (int i = 0; i < points.length; i++) {
      if (_isPointNear(tapPoint, points[i])) {
        _showDeleteConfirmation(i);
        return;
      }
    }

    _showSnackBar('Aucun point trouvé à cette position', Colors.orange);
  }

  bool _isPointNear(LatLng tapPoint, LatLng targetPoint, {double threshold = 0.0005}) {
    final latDiff = (tapPoint.latitude - targetPoint.latitude).abs();
    final lngDiff = (tapPoint.longitude - targetPoint.longitude).abs();
    return latDiff < threshold && lngDiff < threshold;
  }

  void _showPointDetails(int index, LatLng point) {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Point ${index + 1}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text('Latitude: ${point.latitude.toStringAsFixed(6)}'),
              Text('Longitude: ${point.longitude.toStringAsFixed(6)}'),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showMovePointDialog(index, point);
                    },
                    icon: const Icon(Icons.open_with),
                    label: const Text('Déplacer'),
                  ),
                  ElevatedButton.icon(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDeleteConfirmation(index);
                    },
                    icon: const Icon(Icons.delete),
                    label: const Text('Supprimer'),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  void _showMovePointDialog(int index, LatLng currentPoint) {
    final latController = TextEditingController(
      text: currentPoint.latitude.toStringAsFixed(6),
    );
    final lngController = TextEditingController(
      text: currentPoint.longitude.toStringAsFixed(6),
    );

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Déplacer le point ${index + 1}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: latController,
                decoration: const InputDecoration(
                  labelText: 'Latitude',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: lngController,
                decoration: const InputDecoration(
                  labelText: 'Longitude',
                  border: OutlineInputBorder(),
                ),
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
              ),
              const SizedBox(height: 12),
              const Text(
                'Ou touchez la carte pour placer le point',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                final lat = double.tryParse(latController.text);
                final lng = double.tryParse(lngController.text);

                if (lat != null && lng != null) {
                  _movePoint(index, LatLng(lat, lng));
                  Navigator.pop(context);
                } else {
                  _showSnackBar('Coordonnées invalides', Colors.red);
                }
              },
              child: const Text('Déplacer'),
            ),
          ],
        );
      },
    );
  }

  void _movePoint(int index, LatLng newPosition) {
    final drawService = context.read<DrawService>();
    drawService.movePoint(index, newPosition);

    if (widget.station != null) {
      final stationService = context.read<StationService>();
      final updatedPoints = List<LatLng>.from(drawService.points);
      stationService.updateStation(widget.station!, points: updatedPoints);
    }

    setState(() {
      _hasUnsavedChanges = true;
      _selectedPointIndex = index;
    });

    _showSnackBar('Point déplacé', Colors.green);
  }

  void _showDeleteConfirmation(int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Supprimer le point'),
          content: Text('Êtes-vous sûr de vouloir supprimer le point ${index + 1} ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _deletePoint(index);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Supprimer'),
            ),
          ],
        );
      },
    );
  }

  void _deletePoint(int index) {
    final drawService = context.read<DrawService>();
    drawService.deletePoint(index);

    if (widget.station != null) {
      final stationService = context.read<StationService>();
      final updatedPoints = List<LatLng>.from(drawService.points);
      stationService.updateStation(widget.station!, points: updatedPoints);
    }

    setState(() {
      _hasUnsavedChanges = true;
      if (_selectedPointIndex == index) {
        _selectedPointIndex = null;
      }
    });

    _showSnackBar('Point supprimé', Colors.orange);
  }

  void _clearAllPoints() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Effacer tous les points'),
          content: const Text('Êtes-vous sûr de vouloir supprimer tous les points ?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Annuler'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                final drawService = context.read<DrawService>();
                drawService.clearPoints();

                if (widget.station != null) {
                  final stationService = context.read<StationService>();
                  stationService.updateStation(widget.station!, points: []);
                }

                setState(() {
                  _hasUnsavedChanges = true;
                  _selectedPointIndex = null;
                });

                _showSnackBar('Tous les points supprimés', Colors.orange);
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('Effacer tout'),
            ),
          ],
        );
      },
    );
  }

  void _saveChanges() {
    if (widget.onSave != null) {
      widget.onSave!();
    }

    setState(() {
      _hasUnsavedChanges = false;
    });

    _showSnackBar('Modifications sauvegardées', Colors.green);
  }

  void _closeEditor() {
    if (_hasUnsavedChanges) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Modifications non sauvegardées'),
            content: const Text('Voulez-vous sauvegarder avant de fermer ?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  if (widget.onClose != null) {
                    widget.onClose!();
                  }
                },
                child: const Text('Ignorer'),
              ),
              ElevatedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _saveChanges();
                  if (widget.onClose != null) {
                    widget.onClose!();
                  }
                },
                child: const Text('Sauvegarder'),
              ),
            ],
          );
        },
      );
    } else {
      if (widget.onClose != null) {
        widget.onClose!();
      }
    }
  }

  void _showSnackBar(String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Widget _buildToolbar() {
    return Container(
      height: 60,
      color: Colors.white,
      child: Row(
        children: [
          // Boutons de mode
          Expanded(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildModeButton('Vue', Icons.visibility, EditMode.view),
                _buildModeButton('Ajouter', Icons.add_location_alt, EditMode.addPoint),
                _buildModeButton('Déplacer', Icons.open_with, EditMode.movePoint),
                _buildModeButton('Supprimer', Icons.delete_forever, EditMode.deletePoint),
              ],
            ),
          ),
          // Séparateur
          Container(width: 1, height: 40, color: Colors.grey[300]),
          // Actions
          Row(
            children: [
              IconButton(
                onPressed: _clearAllPoints,
                icon: const Icon(Icons.clear_all),
                tooltip: 'Effacer tout',
                color: Colors.red,
              ),
              IconButton(
                onPressed: _hasUnsavedChanges ? _saveChanges : null,
                icon: const Icon(Icons.save),
                tooltip: 'Sauvegarder',
                color: _hasUnsavedChanges ? AppColors.primaryGreen : Colors.grey,
              ),
              IconButton(
                onPressed: _closeEditor,
                icon: const Icon(Icons.close),
                tooltip: 'Fermer',
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildModeButton(String label, IconData icon, EditMode mode) {
    final isActive = _currentMode == mode;
    return GestureDetector(
      onTap: () => _setMode(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: isActive ? AppColors.primaryGreen : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              size: 20,
              color: isActive ? Colors.white : Colors.grey[600],
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                color: isActive ? Colors.white : Colors.grey[600],
                fontWeight: isActive ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    String instruction = '';
    Color bgColor = Colors.blue[50]!;

    switch (_currentMode) {
      case EditMode.view:
        instruction = 'Touchez un point pour voir ses détails';
        break;
      case EditMode.addPoint:
        instruction = 'Touchez la carte pour ajouter un point';
        bgColor = Colors.green[50]!;
        break;
      case EditMode.movePoint:
        instruction = 'Touchez un point pour le déplacer';
        bgColor = Colors.orange[50]!;
        break;
      case EditMode.deletePoint:
        instruction = 'Touchez un point pour le supprimer';
        bgColor = Colors.red[50]!;
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          Icon(Icons.info_outline, size: 16, color: Colors.grey[600]),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              instruction,
              style: TextStyle(fontSize: 14, color: Colors.grey[700]),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: [
          // Barre d'outils
          _buildToolbar(),

          // Instructions
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            child: _buildInstructions(),
          ),

          // Carte
          Expanded(
            child: Consumer<DrawService>(
              builder: (context, drawService, child) {
                return FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: widget.station != null
                        ? LatLng(widget.station!.latitude, widget.station!.longitude)
                        : const LatLng(48.8566, 2.3522),
                    initialZoom: 16.0,
                    onTap: _handleMapTap,
                    interactionOptions: const InteractionOptions(
                      flags: InteractiveFlag.all & ~InteractiveFlag.rotate,
                    ),
                  ),
                  children: [
                    // Tuiles
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.boom.boom_mobile',
                    ),

                    // Marqueurs de points
                    if (drawService.getPointMarkers().isNotEmpty)
                      MarkerLayer(
                        markers: drawService.getPointMarkers(),
                      ),

                    // Marqueurs d'édition
                    if (drawService.getEditVertexMarkers().isNotEmpty)
                      MarkerLayer(
                        markers: drawService.getEditVertexMarkers(),
                      ),

                    // Marqueur de la station
                    if (widget.station != null)
                      MarkerLayer(
                        markers: [
                          Marker(
                            point: LatLng(widget.station!.latitude, widget.station!.longitude),
                            width: 40,
                            height: 40,
                            alignment: Alignment.center,
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.red,
                                shape: BoxShape.circle,
                                border: Border.all(color: Colors.white, width: 3),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withValues(alpha: 0.3),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  widget.station!.numeroStation.toString(),
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                  ],
                );
              },
            ),
          ),

          // Barre d'état
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.grey[100],
              border: Border(top: BorderSide(color: Colors.grey[300]!)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Consumer<DrawService>(
                  builder: (context, drawService, child) {
                    return Text(
                      '${drawService.points.length} point(s)',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    );
                  },
                ),
                if (_hasUnsavedChanges)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.orange,
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Text(
                      'Non sauvegardé',
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}