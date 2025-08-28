// map_floating_buttons_right.dart corrigé sans paramètres inexistants
import 'package:boom_mobile/data/interfaces/draw_service_interface.dart';
import 'package:boom_mobile/data/services/station_service.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/floating_buttons/map_button_group.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/floating_buttons/widgets/map_layers_panel.dart';
import 'package:boom_mobile/data/services/layer_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../../../core/widgets/popup/edit_drawing_popup.dart';
import '../../../../../data/services/draw_service.dart';
import '../map_action_button.dart';

class MapFloatingButtonsRight extends StatefulWidget {
  const MapFloatingButtonsRight({super.key});

  @override
  State<MapFloatingButtonsRight> createState() => _MapFloatingButtonsRightState();
}

class _MapFloatingButtonsRightState extends State<MapFloatingButtonsRight> {
  OverlayEntry? overlayEntry;
  String? selectedTool;
  bool _isEditMode = false;

  void _toggleEditPopup() {
    if (overlayEntry != null) {
      _closePopup();
    } else {
      _showPopup();
    }
  }

  void _closePopup() {
    overlayEntry?.remove();
    overlayEntry = null;
    setState(() {
      selectedTool = null;
      _isEditMode = false;
    });

    // Désactiver le mode édition dans le DrawService
    final drawService = context.read<DrawService>();
    drawService.setTool(DrawTool.none);
    drawService.disableEditMode();
  }

  void _showPopup() {
    final drawService = context.read<DrawService>();
    overlayEntry = OverlayEntry(
      builder: (context) => EditDrawingPopup(
        selectedTool: selectedTool,
        onClose: _closePopup,
        onToolSelected: (tool) {
          setState(() => selectedTool = tool);
          final drawTool = _mapStringToTool(tool);
          drawService.setTool(drawTool ?? DrawTool.none);

          if (drawTool == DrawTool.point) {
            drawService.enableEditMode();
            setState(() => _isEditMode = true);
          }
        },
      ),
    );
    Overlay.of(context).insert(overlayEntry!);
  }

  DrawTool? _mapStringToTool(String tool) {
    switch (tool) {
      case "Point": return DrawTool.point;
      case "Ligne": return DrawTool.line;
      case "Polygone": return DrawTool.polygon;
      default: return null;
    }
  }

  Future<LatLng?> _getCurrentPosition() async {
    // Vérifier les permissions
    final permission = await Permission.location.request();
    if (permission != PermissionStatus.granted) {
      return null;
    }

    try {
      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
          timeLimit: Duration(seconds: 5),
        ),
      );
      return LatLng(position.latitude, position.longitude);
    } catch (e) {
      return null;
    }
  }

  Widget _buildRollbackButton() {
    return Consumer<DrawService>(
      builder: (context, drawService, child) {
        final hasContent = drawService.points.isNotEmpty ||
            drawService.lines.isNotEmpty ||
            drawService.polygons.isNotEmpty;

        return MapActionButton(
          icon: Icons.undo,
          size: 48,
          enabled: hasContent,
          onTap: hasContent ? () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Annuler la dernière action'),
                content: const Text('Voulez-vous annuler la dernière modification ?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Non'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      drawService.undo();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Action annulée'),
                          backgroundColor: Colors.orange,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                    child: const Text('Oui'),
                  ),
                ],
              ),
            );
          } : null,
        );
      },
    );
  }

  Widget _buildSaveButton() {
    return Consumer2<DrawService, StationService>(
      builder: (context, drawService, stationService, child) {
        final hasChanges = drawService.points.isNotEmpty ||
            drawService.lines.isNotEmpty ||
            drawService.polygons.isNotEmpty;

        return MapActionButton(
          iconName: 'Export Database',
          size: 48,
          enabled: hasChanges,
          onTap: hasChanges ? () {
            // Sauvegarder les modifications
            if (drawService.selectedStation != null) {
              stationService.updateStation(
                drawService.selectedStation!,
                points: drawService.points,
                lignes: drawService.lines,
                polygones: drawService.polygons,
              );

              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Modifications sauvegardées'),
                  backgroundColor: Colors.green,
                  duration: Duration(seconds: 2),
                ),
              );
            }
          } : null,
        );
      },
    );
  }

  List<Widget> _buildEditButtonWithOptionalCancel() {
    if (_isEditMode) {
      return [
        // Bouton d'annulation du mode édition
        MapActionButton(
          icon: Icons.cancel,
          size: 48,
          onTap: _closePopup,
        ),
        const SizedBox(height: 8),
        // Bouton d'édition (maintenant en mode actif)
        MapActionButton(
          iconName: 'Edit',
          size: 48,
          onTap: _toggleEditPopup,
        ),
      ];
    } else {
      return [
        // Bouton d'édition normal
        MapActionButton(
          iconName: 'Edit',
          size: 48,
          onTap: _toggleEditPopup,
        ),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    final bottomNavHeight = kBottomNavigationBarHeight;
    final safeBottomMargin = bottomPadding + bottomNavHeight + 20;

    return Stack(
      children: [
        // TOP RIGHT: Layers + Position
        Positioned(
          top: 170,
          right: 16,
          child: MapButtonGroup(
            spacing: 8,
            buttons: [
              // Bouton Layers
              MapActionButton(
                iconName: 'Layer',
                size: 48,
                onTap: () {
                  final layerService = context.read<LayerService>();
                  showModalBottomSheet(
                    context: context,
                    isScrollControlled: true,
                    backgroundColor: Colors.transparent,
                    builder: (context) => MapLayersPanel(
                      availableLayers: layerService.availableLayers,
                      initialLayerStates: layerService.layerStates,
                      onLayersChanged: (newStates) {
                        layerService.updateLayerStates(newStates);
                      },
                    ),
                  );
                },
              ),

              // Bouton Position
              MapActionButton(
                iconName: 'Position',
                size: 48,
                onTap: () async {
                  final position = await _getCurrentPosition();
                  if (position != null) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            'Position: ${position.latitude.toStringAsFixed(4)}, ${position.longitude.toStringAsFixed(4)}'
                        ),
                        backgroundColor: Colors.green,
                      ),
                    );
                  } else {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Impossible d\'obtenir la position'),
                          backgroundColor: Colors.red,
                        ),
                      );
                    }
                  }
                },
              ),
            ],
          ),
        ),

        // BOTTOM RIGHT: Actions principales
        Positioned(
          bottom: safeBottomMargin,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Bouton Rollback
              _buildRollbackButton(),
              const SizedBox(height: 8),

              // Bouton Save
              _buildSaveButton(),
              const SizedBox(height: 8),

              // Boutons Edit avec gestion du mode
              ..._buildEditButtonWithOptionalCancel(),
            ],
          ),
        ),

        // Indicateur de mode édition
        if (_isEditMode)
          Positioned(
            top: 120,
            right: 70,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.orange,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.edit, color: Colors.white, size: 16),
                  const SizedBox(width: 4),
                  Text(
                    selectedTool ?? 'Édition',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  @override
  void dispose() {
    overlayEntry?.remove();
    super.dispose();
  }
}