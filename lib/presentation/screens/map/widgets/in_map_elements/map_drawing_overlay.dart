import 'package:boom_mobile/domain/entities/station.dart';
import 'package:boom_mobile/services/draw_service.dart';
import 'package:boom_mobile/services/station_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';

class MapDrawingOverlay extends StatelessWidget {
  final Station? selectedStation;

  const MapDrawingOverlay({
    super.key,
    this.selectedStation,
  });

  @override
  Widget build(BuildContext context) {
    // Solution 1: Modifier le Provider.of pour utiliser une version nullable
    final StationService? stationService = Provider.of<StationService?>(context, listen: false);

    // Solution 2 (alternative): Obtenir StationService sans erreur
    /*
    StationService? stationService;
    try {
      stationService = Provider.of<StationService>(context, listen: false);
    } catch (e) {
      // Ignorer l'erreur et laisser stationService comme null
    }
    */

    return MultiProvider(
      providers: [
        // Fournir le service de dessin avec stationService nullable
        ChangeNotifierProvider<DrawService>(
          create: (_) => DrawService(
            stationService: stationService,
          ),
        ),
      ],
      child: _MapDrawingContent(selectedStation: selectedStation),
    );
  }
}

class _MapDrawingContent extends StatefulWidget {
  final Station? selectedStation;

  const _MapDrawingContent({
    Key? key,
    this.selectedStation,
  }) : super(key: key);

  @override
  State<_MapDrawingContent> createState() => _MapDrawingContentState();
}

class _MapDrawingContentState extends State<_MapDrawingContent> {
  DrawTool _selectedTool = DrawTool.none;
  bool _showToolPanel = false;

  @override
  void initState() {
    super.initState();

    // Définir la station sélectionnée si elle est fournie
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.selectedStation != null) {
        final drawService = Provider.of<DrawService>(context, listen: false);
        drawService.selectStation(widget.selectedStation!);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<DrawService>(
      builder: (context, drawService, child) {
        return Stack(
          children: [
            // Les couches de dessin pour FlutterMap
            _buildDrawingLayers(drawService),

            // Les contrôles d'édition
            Positioned(
              right: 16,
              bottom: 100, // Au-dessus des contrôles de carte standards
              child: _buildDrawingControls(drawService),
            ),

            // Panneau d'outils de dessin (visible si _showToolPanel est true)
            if (_showToolPanel)
              Positioned(
                right: 70,
                bottom: 100,
                child: _buildToolPanel(drawService),
              ),

            // Instructions de dessin (selon l'outil sélectionné)
            if (_selectedTool != DrawTool.none)
              Positioned(
                top: 16,
                left: 0,
                right: 0,
                child: _buildInstructions(),
              ),
          ],
        );
      },
    );
  }

  Widget _buildDrawingLayers(DrawService drawService) {
    // Obtenir les éléments dessinés
    final markers = [
      ...drawService.getPointMarkers(),
      ...drawService.getEditVertexMarkers(),
    ];
    final polylines = drawService.getPolylines();
    final polygons = drawService.getPolygons();

    return Stack(
      children: [
        // Polygones
        if (polygons.isNotEmpty)
          PolygonLayer(
            polygons: polygons,
            polygonCulling: true,
            simplificationTolerance: 0.5,
          ),

        // Polylignes
        if (polylines.isNotEmpty)
          PolylineLayer(polylines: polylines),

        // Marqueurs
        if (markers.isNotEmpty)
          MarkerLayer(markers: markers),
      ],
    );
  }

  Widget _buildDrawingControls(DrawService drawService) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Bouton principal pour afficher/masquer les outils
        FloatingActionButton(
          heroTag: 'toggleDrawTools',
          backgroundColor: _showToolPanel ? Colors.green : Colors.white,
          child: Icon(
            _showToolPanel ? Icons.close : Icons.edit,
            color: _showToolPanel ? Colors.white : Colors.green,
          ),
          onPressed: () {
            setState(() {
              _showToolPanel = !_showToolPanel;

              // Si on masque le panneau, réinitialiser l'outil
              if (!_showToolPanel) {
                _selectedTool = DrawTool.none;
                drawService.setTool(DrawTool.none);
              }
            });
          },
        ),

        // Boutons d'actions supplémentaires selon l'outil sélectionné
        if (_selectedTool != DrawTool.none && _selectedTool != DrawTool.point)
          const SizedBox(height: 8),

        // Bouton pour terminer le dessin (si ligne ou polygone)
        if (_selectedTool == DrawTool.line || _selectedTool == DrawTool.polygon)
          FloatingActionButton.small(
            heroTag: 'finishDrawing',
            backgroundColor: Colors.blue,
            child: const Icon(Icons.check, color: Colors.white),
            onPressed: () {
              drawService.finishDrawing();

              // Rester en mode dessin pour faciliter l'ajout de plusieurs formes
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Forme sauvegardée'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),

        // Bouton pour annuler le dessin en cours
        if (_selectedTool != DrawTool.none)
          const SizedBox(height: 8),

        if (_selectedTool != DrawTool.none)
          FloatingActionButton.small(
            heroTag: 'cancelDrawing',
            backgroundColor: Colors.red,
            child: const Icon(Icons.cancel, color: Colors.white),
            onPressed: () {
              drawService.cancelDrawing();

              // Revenir à l'outil précédent
              setState(() {
                _selectedTool = DrawTool.none;
                drawService.setTool(DrawTool.none);
              });
            },
          ),

        // Bouton pour effacer tous les dessins
        const SizedBox(height: 8),
        FloatingActionButton.small(
          heroTag: 'clearAllDrawings',
          backgroundColor: Colors.white,
          child: const Icon(Icons.delete_sweep, color: Colors.red),
          onPressed: () {
            showDialog(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Réinitialiser la carte'),
                content: const Text(
                  'Voulez-vous vraiment effacer tous les dessins de la carte ?',
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Annuler'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      drawService.reset();
                      setState(() {
                        _selectedTool = DrawTool.none;
                      });
                    },
                    child: const Text('Réinitialiser'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildToolPanel(DrawService drawService) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            blurRadius: 6,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text(
            "Outils de dessin",
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Outil Point
              _buildToolButton(
                icon: Icons.location_on,
                tooltip: 'Point',
                isSelected: _selectedTool == DrawTool.point,
                onPressed: () {
                  setState(() {
                    _selectedTool = DrawTool.point;
                    drawService.setTool(DrawTool.point);
                  });
                },
              ),

              // Outil Ligne
              _buildToolButton(
                icon: Icons.timeline,
                tooltip: 'Ligne',
                isSelected: _selectedTool == DrawTool.line,
                onPressed: () {
                  setState(() {
                    _selectedTool = DrawTool.line;
                    drawService.setTool(DrawTool.line);
                  });
                },
              ),

              // Outil Polygone
              _buildToolButton(
                icon: Icons.pentagon,
                tooltip: 'Polygone',
                isSelected: _selectedTool == DrawTool.polygon,
                onPressed: () {
                  setState(() {
                    _selectedTool = DrawTool.polygon;
                    drawService.setTool(DrawTool.polygon);
                  });
                },
              ),

              // Outil Édition
              _buildToolButton(
                icon: Icons.edit,
                tooltip: 'Éditer',
                isSelected: _selectedTool == DrawTool.edit,
                onPressed: () {
                  setState(() {
                    _selectedTool = DrawTool.edit;
                    drawService.setTool(DrawTool.edit);
                  });
                },
              ),

              // Outil Suppression
              _buildToolButton(
                icon: Icons.delete,
                tooltip: 'Supprimer',
                isSelected: _selectedTool == DrawTool.delete,
                onPressed: () {
                  setState(() {
                    _selectedTool = DrawTool.delete;
                    drawService.setTool(DrawTool.delete);
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildToolButton({
    required IconData icon,
    required String tooltip,
    required bool isSelected,
    required VoidCallback onPressed,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Tooltip(
        message: tooltip,
        child: Material(
          color: isSelected ? Colors.green : Colors.white,
          borderRadius: BorderRadius.circular(8),
          child: InkWell(
            onTap: onPressed,
            borderRadius: BorderRadius.circular(8),
            child: Container(
              width: 40,
              height: 40,
              alignment: Alignment.center,
              child: Icon(
                icon,
                color: isSelected ? Colors.white : Colors.green,
                size: 24,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildInstructions() {
    String message = "";

    switch (_selectedTool) {
      case DrawTool.point:
        message = "Cliquez sur la carte pour ajouter un point";
        break;
      case DrawTool.line:
        message = "Cliquez pour ajouter des points à la ligne. Cliquez sur ✓ pour terminer.";
        break;
      case DrawTool.polygon:
        message = "Cliquez pour ajouter des points au polygone. Cliquez sur ✓ pour terminer.";
        break;
      case DrawTool.edit:
        message = "Cliquez sur un élément pour le modifier";
        break;
      case DrawTool.delete:
        message = "Cliquez sur un élément pour le supprimer";
        break;
      default:
        message = "";
    }

    if (message.isEmpty) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.black.withOpacity(0.7),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        message,
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}