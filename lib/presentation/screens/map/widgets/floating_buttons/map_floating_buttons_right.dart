import 'package:boom_mobile/presentation/screens/map/widgets/floating_buttons/map_button_group.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/floating_buttons/widgets/map_layers_panel.dart';
import 'package:boom_mobile/services/layer_service.dart';
import 'package:boom_mobile/services/station_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';
import '../../../../../core/widgets/popup/edit_drawing_popup.dart';
import '../../../../../services/draw_service.dart';
import '../map_action_button.dart';

class MapFloatingButtonsRight extends StatefulWidget {
  const MapFloatingButtonsRight({super.key});

  @override
  State<MapFloatingButtonsRight> createState() => _MapFloatingButtonsRightState();
}

class _MapFloatingButtonsRightState extends State<MapFloatingButtonsRight> {
  OverlayEntry? overlayEntry;
  String? selectedTools; // nom de l'outils actif (ex: "Draw point")


  void _toggleEditPopup() {
    // Si le popup est déjà ouvert, on ferme
    if (overlayEntry != null) {
      _closePopup();
    } else {
      _showPopup();
    }
  }

  void _closePopup() {
    overlayEntry?.remove();
    overlayEntry = null;
    setState(() => selectedTools = null); // Désactivation visuelle
  }

  void _showPopup() {
    final drawService = context.read<DrawService>();
    overlayEntry = OverlayEntry(
      builder: (context) => EditDrawingPopup(
        selectedTool: selectedTools,
        onClose: _closePopup,
        onToolSelected: (tool) {
          setState(() => selectedTools = tool);
          final drawTool = _mapStringToTool(tool);
          drawService.setTool(drawTool ?? DrawTool.none);
        },
      ),
    );
    Overlay.of(context, rootOverlay: true).insert(overlayEntry!);
  }

  @override
  Widget build(BuildContext context) {
    // Calcule de la marge bottom dynamiquement
    //final mediaQuery = MediaQuery.of(context);
    final bottomPadding = MediaQuery.of(context).padding.bottom;
    // Calcul plus précis : hauteur écran - padding bottom - hauteur nav bar - marge
    //final bottomMargin = bottomPadding + 20.0 + 16.0; // 20px pour la nav bar + 16px de marge
    final bottomNavHeight = kBottomNavigationBarHeight; // ~56px
    final safeBottomMargin = bottomPadding + bottomNavHeight + 20; // 20px de marge

    return Stack(
      children: [
        // TOP RIGHT: Layers + Position
        Positioned(
          top: 170,
          right: 16,
          child: MapButtonGroup(
            spacing: 8,
            buttons: [
              MapActionButton(iconName: 'Layer', size: 48, onTap: () {
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
              }),
              MapActionButton(
                iconName: 'Position',
                size: 48,
                onTap: () async {
                  final position = await _getCurrentPosition();
                  if (position != null) {
                    // TODO: Accès au MapController
                  }
                },
              ),
            ],
          ),
        ),


        // BOTTOM RIGHT: Rollback, Save, Edit avec positionnement corrigé
        Positioned(
          bottom: safeBottomMargin,
          right: 16,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildRollbackButton(),
              const SizedBox(height: 8),
              _buildSaveButton(),
              const SizedBox(height: 8),
              ..._buildEditButtonWithOptionalCancel(),
            ],
          ),
        ),
      ],
    );
  }

  Future<LatLng?> _getCurrentPosition() async {
    final status = await Permission.location.request();
    if (status.isGranted) {
      final position = await Geolocator.getCurrentPosition();
      return LatLng(position.latitude, position.longitude);
    }
    return null;
  }


  Widget _buildRollbackButton() {
    final hasUnsavedChanges = true; // TODO: Récupérer l'état réel depuis un Provider

    return Stack(
      children: [
        MapActionButton(
          iconName: 'Lock Screen', // ou un icône rollback approprié
          size: 48,
          onTap: () {
            // Action rollback/annuler modifications
            debugPrint("Rollback modifications");
          },
        ),
        if (hasUnsavedChanges)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 16,
              height: 16,
              decoration: const BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: const Center(
                child: Text(
                  '!',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildSaveButton() {
    final hasUnsavedChanges = true; // TODO: Récupérer l'état réel

    return Stack(
      children: [
        MapActionButton(
          iconName: 'Save',
          size: 48,
          enabled: hasUnsavedChanges, // Grisé si rien à sauvegarder
          onTap: hasUnsavedChanges ? () {
            // Action sauvegarder
            debugPrint("Sauvegarder modifications");
          } : null,
        ),
        if (hasUnsavedChanges)
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 12,
              height: 12,
              decoration: const BoxDecoration(
                color: Colors.orange,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildEditButton() {
    final drawService = context.watch<DrawService>();
    final isEditing = drawService.currentTool != DrawTool.none;

    return MapActionButton(
      iconName: isEditing ? 'EditActive' : 'Edit', // Utiliser une icône différente si actif
      size: 48,
      onTap: () {
        showModalBottomSheet(
          context: context,
          builder: (BuildContext context) {
            return Container(
              padding: const EdgeInsets.symmetric(vertical: 20),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDrawingOptionTile(
                    title: 'Ajouter un point',
                    icon: Icons.add_location,
                    tool: DrawTool.point,
                    drawService: drawService,
                  ),
                  _buildDrawingOptionTile(
                    title: 'Dessiner une ligne',
                    icon: Icons.timeline,
                    tool: DrawTool.line,
                    drawService: drawService,
                  ),
                  _buildDrawingOptionTile(
                    title: 'Dessiner un polygone',
                    icon: Icons.format_shapes,
                    tool: DrawTool.polygon,
                    drawService: drawService,
                  ),
                  _buildDrawingOptionTile(
                    title: 'Modifier une géométrie',
                    icon: Icons.edit,
                    tool: DrawTool.edit,
                    drawService: drawService,
                  ),
                  _buildDrawingOptionTile(
                    title: 'Supprimer une géométrie',
                    icon: Icons.delete,
                    tool: DrawTool.delete,
                    drawService: drawService,
                    color: Colors.red,
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildDrawingOptionTile({
    required String title,
    required IconData icon,
    required DrawTool tool,
    required DrawService drawService,
    Color color = Colors.green,
  }) {
    final isActive = drawService.currentTool == tool;

    return ListTile(
      leading: Icon(icon, color: isActive ? Colors.white : color),
      title: Text(title),
      tileColor: isActive ? color.withAlpha(204) : null, // 80% de 255 valeur alpha
      onTap: () {
        Navigator.pop(context);
        if (isActive) {
          // Désactiver si déjà actif
          drawService.setTool(DrawTool.none);
        } else {
          // Activer l'outil
          drawService.setTool(tool);
        }
      },
    );
  }
  List<Widget> _buildEditButtonWithOptionalCancel() {
    final drawService = context.watch<DrawService>();
    final stationService = context.watch<StationService>();
    final isEditing = drawService.currentTool != DrawTool.none;

    // Si on est en mode édition, ajouter un bouton pour annuler/sauvegarder
    if (isEditing) {
      return [
        // Bouton de sauvegarde toujours présent en mode édition
        Padding(
          padding: const EdgeInsets.only(bottom: 8.0),
          child: MapActionButton(
            iconName: 'Save',
            size: 48,
            onTap: () {
              // Demander confirmation
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text('Sauvegarder les modifications?'),
                  content: const Text('Voulez-vous sauvegarder les modifications de géométrie?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);

                        // Sauvegarder les géométries dans la station
                        if (drawService.currentStation != null) {
                          final geometries = drawService.getGeometriesForStation();
                          stationService.updateStationGeometries(
                            drawService.currentStation!,
                            points: geometries['points'],
                            lignes: geometries['lignes'],
                            polygones: geometries['polygones'],
                          );
                        }

                        // Désactiver le mode édition
                        drawService.setTool(DrawTool.none);

                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Géométries sauvegardées')),
                        );
                      },
                      child: const Text('Sauvegarder'),
                    ),
                  ],
                ),
              );
            },
          ),
        ),

        // Bouton principal d'édition avec option de fermeture
        MapActionButton(
          iconName: getIconForTool(drawService.currentTool),
          size: 48,
          onTap: _toggleEditPopup,
          showClose: true,
          onCloseTap: () {
            // Demander confirmation avant de quitter le mode édition
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Quitter le mode édition?'),
                content: const Text('Que voulez-vous faire des modifications?'),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);
                      // Annuler les modifications
                      drawService.setTool(DrawTool.none);
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Modifications annulées')),
                      );
                    },
                    child: const Text('Abandonner'),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(context);

                      // Sauvegarder les géométries dans la station
                      if (drawService.currentStation != null) {
                        final geometries = drawService.getGeometriesForStation();
                        stationService.updateStationGeometries(
                          drawService.currentStation!,
                          points: geometries['points'],
                          lignes: geometries['lignes'],
                          polygones: geometries['polygones'],
                        );
                      }

                      // Désactiver le mode édition
                      drawService.setTool(DrawTool.none);

                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Géométries sauvegardées')),
                      );
                    },
                    child: const Text('Sauvegarder'),
                  ),
                ],
              ),
            );
          },
        ),
      ];
    } else {
      // Mode normal, juste le bouton d'édition
      return [
        MapActionButton(
          iconName: 'Edit',
          size: 48,
          onTap: _toggleEditPopup,
        ),
      ];
    }
  }

  // Fonction pour obtenir l'icône correspondante à l'outil
  String getIconForTool(DrawTool tool) {
    switch (tool) {
      case DrawTool.point:
        return 'Draw point';
      case DrawTool.line:
        return 'Draw line';
      case DrawTool.polygon:
        return 'Draw polygon';
      case DrawTool.edit:
        return 'Edit draw';
      case DrawTool.delete:
        return 'Delete draw';
      default:
        return 'Edit';
    }
  }

  DrawTool? _mapStringToTool(String? toolName) {
    switch (toolName) {
      case 'Draw point':
        return DrawTool.point;
      case 'Draw line':
        return DrawTool.line;
      case 'Draw polygon':
        return DrawTool.polygon;
      default:
        return DrawTool.none;
    }
  }

}
