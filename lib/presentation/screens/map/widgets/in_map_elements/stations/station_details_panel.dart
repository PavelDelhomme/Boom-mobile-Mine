import 'package:boom_mobile/core/theme/app_colors.dart';
import 'package:boom_mobile/presentation/screens/map/widgets/in_map_elements/stations/bottomsheet/tabs/formes_tab.dart';
import 'package:flutter/material.dart';
import '../../../../../../core/widgets/buttons/copy_button.dart';
import '../../../../../../domain/entities/station.dart';
import 'bottomsheet/tabs/context_tab.dart';
import 'bottomsheet/tabs/identity_tab.dart';
import 'bottomsheet/station_tab_bar_headers.dart';

class StationDetailsPanel extends StatefulWidget {
  final Station station;
  final VoidCallback? onEditGeometry; // Ajout du callback pour l'édition de géométrie

  const StationDetailsPanel({
    super.key,
    required this.station,
    this.onEditGeometry, // Paramètre optionnel
  });

  @override
  State<StationDetailsPanel> createState() => _StationDetailsPanelState();
}

class _StationDetailsPanelState extends State<StationDetailsPanel> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: FractionallySizedBox(
        heightFactor: 0.95,
        child: Container(
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              StationTabBarHeaders(
                currentIndex: _tabController.index,
                onTap: (i) => setState(() => _tabController.index = i),
              ),
              const SizedBox(height: 8),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
                    StationContextTab(
                      station: widget.station,
                      onModified: () {}, // Ajoute ce callback
                    ),
                    StationIdentiteTab(
                      station: widget.station,
                      onModified: () {}, // Ajoute ce callback
                      onPhotosUpdated: (newPhotos) {
                        setState(() {
                          widget.station.photoUrls = newPhotos;
                        });
                      },
                    ),
                    StationFormesTab(
                      station: widget.station,
                      onModified: () {}, // Ajoute ce callback
                      onEditGeometry: widget.onEditGeometry, // Transmission du callback
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

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Text(
                "Station ${widget.station.numeroStation}",
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppColors.primaryGreen,
                ),
              ),
              if (widget.onEditGeometry != null)
                IconButton(
                  icon: const Icon(Icons.edit_location_alt, color: AppColors.primaryGreen),
                  tooltip: "Éditer les géométries",
                  onPressed: widget.onEditGeometry,
                ),
            ],
          ),
          Row(
            children: [
              BoomCopyButton(onTap: () {
                // Copier les coordonnées ou l'ID de la station
              }),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
        ],
      ),
    );
  }
}