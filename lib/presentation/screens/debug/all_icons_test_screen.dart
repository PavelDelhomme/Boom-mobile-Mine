import 'dart:developer';

import 'package:flutter/material.dart';
import '../../../core/constants/icon_constants.dart';


class AllMapButtonsTestScreen extends StatefulWidget {
  const AllMapButtonsTestScreen({super.key});

  @override
  State<AllMapButtonsTestScreen> createState() => _AllMapButtonsTestScreenState();
}

class _AllMapButtonsTestScreenState extends State<AllMapButtonsTestScreen> {
  double _iconSize = 64.0;
  bool _showAsButton = true;
  List<String> deletedIcons = [];
  List<MapEntry<String, String>> iconsValidated = [];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Validation des icônes")),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                const Text("Taille : "),
                Expanded(
                  child: Slider(
                    value: _iconSize,
                    min: 24,
                    max: 128,
                    divisions: 20,
                    label: _iconSize.round().toString(),
                    onChanged: (v) => setState(() => _iconSize = v),
                  ),
                ),
                const Text("Bouton"),
                Switch(
                  value: _showAsButton,
                  onChanged: (val) => setState(() => _showAsButton = val),
                ),
              ],
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              padding: const EdgeInsets.all(12),
              childAspectRatio: 0.5,
              children: travailIcons.entries.map((entry) {
                if (deletedIcons.contains(entry.key)) {
                  return const SizedBox(); // Ignore deleted
                }
                return Column(
                  children: [
                    if (_showAsButton)
                      Container(
                        width: _iconSize + 24,
                        height: _iconSize + 24,
                        decoration: BoxDecoration(
                          color: Colors.green,
                          shape: BoxShape.circle,
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Image.asset(
                          entry.value,
                          fit: BoxFit.contain,
                        ),
                      )
                    else
                      Image.asset(
                        entry.value,
                        width: _iconSize,
                        height: _iconSize,
                        fit: BoxFit.contain,
                      ),
                    const SizedBox(height: 8),
                    Text(
                      entry.key,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 11),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () => _markAsOk(entry.key, entry.value),
                          style: ElevatedButton.styleFrom(minimumSize: const Size(50, 24), padding: EdgeInsets.zero),
                          child: const Text("OK"),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () => _deleteIcon(entry.key),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            minimumSize: const Size(50, 24),
                            padding: EdgeInsets.zero,
                          ),
                          child: const Text("X"),
                        ),
                      ],
                    ),
                  ],
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _exportValidatedIcons,
        tooltip: "Exporter les icônes validés",
        child: const Icon(Icons.download),
      ),
    );
  }
  void _exportValidatedIcons() {
    if (iconsValidated.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Aucune icône validée.'), duration: Duration(seconds: 2)),
      );
      return;
    }

    final buffer = StringBuffer();
    buffer.writeln('const Map<String, String> okIcons = {');

    for (final icon in iconsValidated) {
      buffer.writeln('  "${icon.key}": "${icon.value}",');
    }

    buffer.writeln('};');

    // Affiche le résultat dans la console
    log(buffer.toString());

    // Et montre une snackbar
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('✅ Export prêt ! Copie dans la console.'), duration: Duration(seconds: 2)),
    );
  }

  void _markAsOk(String name, String path) async {
    setState(() {
      iconsValidated.add(MapEntry(name, path.replaceFirst('assets/icons/travail/', 'assets/icons/ok/')));
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('✅ Icône validé : $name'), duration: Duration(seconds: 1)),
    );
  }
  void _deleteIcon(String name) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirmation'),
        content: Text('Veux-tu vraiment supprimer "$name" ?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: const Text('Annuler'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(true),
            child: const Text('Oui'),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      setState(() {
        deletedIcons.add(name);
      });
      log('❌ Icône supprimé: $name');
    }
  }
}