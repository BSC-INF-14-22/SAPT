import 'package:flutter/material.dart';

class Sidebar extends StatelessWidget {
  final String currentRoute;

  const Sidebar({super.key, required this.currentRoute});

  Widget _buildMenuItem(
    BuildContext context, 
    String title, 
    IconData icon, 
    String route,
  ) {
    final bool isSelected = currentRoute == route;
    return ListTile(
      leading: Icon(
        icon, 
        color: isSelected ? Colors.white : Colors.white70,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white70,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.white.withOpacity(0.1),
      onTap: () {
        if (!isSelected) {
          Navigator.pushReplacementNamed(context, route);
        } else {
          // If on mobile and clicking the same active route, close the Drawer
          if (Scaffold.maybeOf(context)?.hasDrawer ?? false) {
            Navigator.pop(context);
          }
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 250,
      color: const Color(0xFF000000), // Black
      child: Column(
        children: [
          const SizedBox(
            height: 120,
            child: DrawerHeader(
              decoration: BoxDecoration(
                color: Color(0xFF000000),
              ),
              margin: EdgeInsets.zero,
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'SAPT Admin\nDashboard',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(context, 'Overview', Icons.dashboard, '/dashboard'),
                _buildMenuItem(context, 'Commodities', Icons.shopping_basket, '/commodities'),
                _buildMenuItem(context, 'Markets', Icons.store, '/markets'),
                _buildMenuItem(context, 'Prices', Icons.analytics, '/prices'),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
