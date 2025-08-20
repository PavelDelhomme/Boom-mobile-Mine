import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:flutter/material.dart';

class MapExportFieldSelector extends StatefulWidget {
  final Function(List<String>, DateTimeRange?) onExport;

  const MapExportFieldSelector({super.key, required this.onExport});

  @override
  State<MapExportFieldSelector> createState() => _MapExportFieldSelectorState();
}

class _MapExportFieldSelectorState extends State<MapExportFieldSelector> {
  final List<String> availableFields = [
    'Numéro de station',
    'Coordonnées GPS',
    'Essence d\'arbre',
    'État sanitaire',
    'Date dernière visite',
    'Interventions nécessaires',
    'Commentaires',
    'Photos',
  ];

  List<String> selectedFields = [];
  DateTimeRange? selectedDateRange;

  @override
  void initState() {
    super.initState();
    selectedFields = [...availableFields]; // Tous sélectionnés par défaut
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Exporter la base de données",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),

          const SizedBox(height: 16),

          // Sélection de période
          _buildDateRangeSelector(),

          const SizedBox(height: 16),

          // Sélection des champs
          const Text(
            "Champs à exporter :",
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
          ),

          const SizedBox(height: 8),

          ...availableFields.map((field) => CheckboxListTile(
            title: Text(field),
            value: selectedFields.contains(field),
            onChanged: (value) {
              setState(() {
                if (value == true) {
                  selectedFields.add(field);
                } else {
                  selectedFields.remove(field);
                }
              });
            },
          )),

          const SizedBox(height: 16),

          // Actions
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Annuler"),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: selectedFields.isNotEmpty ? () {
                    widget.onExport(selectedFields, selectedDateRange);
                    Navigator.pop(context);
                  } : null,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryGreen,
                  ),
                  child: const Text(
                    "Exporter",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildDateRangeSelector() {
    return InkWell(
      onTap: () async {
        final DateTimeRange? picked = await showDateRangePicker(
          context: context,
          firstDate: DateTime(2020),
          lastDate: DateTime.now(),
          initialDateRange: selectedDateRange,
        );
        if (picked != null) {
          setState(() {
            selectedDateRange = picked;
          });
        }
      },
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey[300]!),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            const Icon(Icons.date_range),
            const SizedBox(width: 8),
            Text(
              selectedDateRange != null
                  ? "${_formatDate(selectedDateRange!.start)} - ${_formatDate(selectedDateRange!.end)}"
                  : "Sélectionner une période",
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return "${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}";
  }
}
