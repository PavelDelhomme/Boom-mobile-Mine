import 'package:flutter_map/flutter_map.dart';
import 'package:flutter/material.dart';
import 'package:latlong2/latlong.dart';
import 'package:flutter_map_line_editor/flutter_map_line_editor.dart';
import 'package:flutter_map_dragmarker/flutter_map_dragmarker.dart';

class AdvancedMapEditor extends StatefulWidget {
  const AdvancedMapEditor({Key? key}) : super(key: key);

  @override
  _AdvancedMapEditorState createState() => _AdvancedMapEditorState();
}

class _AdvancedMapEditorState extends State<AdvancedMapEditor> {
  late PolyEditor polyEditor;
  List<Polyline> polylines = [];
  List<LatLng> currentPoints = [];

  @override
  void initState() {
    super.initState();

    // Initialiser avec une polyligne vide
    polylines.add(Polyline(
      points: currentPoints,
      strokeWidth: 3,
      color: Colors.blue,
    ));

    polyEditor = PolyEditor(
      points: currentPoints,
      pointIcon: const Icon(Icons.crop_square, size: 23, color: Colors.red),
      intermediateIcon: const Icon(Icons.lens, size: 15, color: Colors.grey),
      callbackRefresh: (latlng) {
        setState(() {});
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Éditeur de carte avancé'),
      ),
      body: FlutterMap(
        options: MapOptions(
          initialCenter: LatLng(48.8566, 2.3522), // Paris comme point central par défaut
          initialZoom: 13.0,
          onTap: (tapPosition, point) {
            setState(() {
              currentPoints.add(point);
              polylines[0] = Polyline(
                points: currentPoints,
                strokeWidth: 3,
                color: Colors.blue,
              );
            });
          },
        ),
        children: [
          TileLayer(
            urlTemplate: 'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
            subdomains: const ['a', 'b', 'c'],
          ),
          PolylineLayer(
            polylines: polylines,
          ),
          // Utiliser l'éditeur de polylignes ici
          DragMarkers(
            markers: polyEditor.edit(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // Effacer toutes les lignes
          setState(() {
            currentPoints.clear();
            polylines[0] = Polyline(
              points: currentPoints,
              strokeWidth: 3,
              color: Colors.blue,
            );
          });
        },
        child: const Icon(Icons.clear),
      ),
    );
  }
}