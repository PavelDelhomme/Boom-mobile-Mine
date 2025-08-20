import 'package:flutter/material.dart';

class MapFilterPanel extends StatelessWidget {
  const MapFilterPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.9,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            children: [
              const SizedBox(height: 16),
              const Text(
                "Filtres de carte",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),

              // --- Liste des titres textuels ---
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Numéro Station", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text("Par essence", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text("Par état sanitaire", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text("Par intérêt biodiversité/environnement", style: TextStyle(fontWeight: FontWeight.bold)),
                    SizedBox(height: 12),
                    Text("Par stade de développement", style: TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              const Spacer(),

              // --- Boutons Annuler / Valider ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
                child: Row(
                  children: [
                    Expanded(
                      child: MaterialButton(
                        onPressed: () => Navigator.pop(context),
                        child: const Text("Annuler", style: TextStyle(color: Colors.orange, fontSize: 18)),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: MaterialButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Appliquer les filtres
                        },
                        child: const Text("Valider", style: TextStyle(color: Colors.green, fontSize: 18)),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
