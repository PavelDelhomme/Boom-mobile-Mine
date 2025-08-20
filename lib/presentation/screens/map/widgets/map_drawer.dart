import 'package:flutter/material.dart';

class MapDrawer extends StatelessWidget {
  const MapDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topRight: Radius.circular(40),
              bottomRight: Radius.circular(40)
          ),
      ),
      child: SafeArea(
        child: Column(
          children: [
            const SizedBox(height: 24),
            //todo injection avatar
            /*const CircleAvatar(
              radius: 40,
              backgroundImage: AssetImage(kAvatar),
            ),*/
            // todo injection nom et role
            const SizedBox(height: 12),
            const Text("Nom", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const Text("Rôle", style: TextStyle(color: Colors.grey)),

            const SizedBox(height: 24),

            // Dossiers menu dépendrond du role
            _buildDrawerTile(Icons.home_outlined, 'Dossier'),
            _buildDrawerTile(Icons.topic_outlined, 'Couches'),
            _buildDrawerTile(Icons.message_outlined, 'Messages'),
            _buildDrawerTile(Icons.notifications_outlined, 'Notifications'),
            _buildDrawerTile(Icons.bookmark_border, 'Bookmarks'),
            _buildDrawerTile(Icons.person_outline, 'Profile'),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerTile(IconData icon, String label) {
    return ListTile(
      leading: Icon(icon),
      title: Text(label),
      onTap: () {
        // todo : Naviguer ou effectuer une action ici
      },
    );
  }
}