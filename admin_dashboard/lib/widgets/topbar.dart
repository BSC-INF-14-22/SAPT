import 'package:flutter/material.dart';
import '../services/auth_service.dart';

class TopBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final VoidCallback? onMenuToggle;

  const TopBar({
    super.key, 
    required this.title,
    this.onMenuToggle,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: onMenuToggle != null 
          ? IconButton(
              icon: const Icon(Icons.menu, color: Colors.black87),
              onPressed: onMenuToggle,
            )
          : null,
      title: Text(
        title,
        style: const TextStyle(color: Colors.black87, fontWeight: FontWeight.bold),
      ),
      iconTheme: const IconThemeData(color: Colors.black87),
      actions: [
        const SizedBox(width: 16),
        PopupMenuButton<String>(
          tooltip: 'Profile Options',
          offset: const Offset(0, 48),
          icon: const CircleAvatar(
            backgroundColor: Color(0xFFE53935), // Red
            child: Icon(Icons.person, color: Colors.white),
          ),
          onSelected: (value) async {
            if (value == 'logout') {
              await AuthService().signOut();
            }
          },
          itemBuilder: (BuildContext context) => [
            const PopupMenuItem<String>(
              value: 'logout',
              child: Row(
                children: [
                  Icon(Icons.logout, color: Colors.black87, size: 20),
                  SizedBox(width: 12),
                  Text('Logout'),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(width: 24),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
