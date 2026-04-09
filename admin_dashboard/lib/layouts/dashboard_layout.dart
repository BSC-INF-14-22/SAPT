import 'package:flutter/material.dart';
import '../widgets/sidebar.dart';
import '../widgets/topbar.dart';

class DashboardLayout extends StatefulWidget {
  final Widget child;
  final String title;
  final String currentRoute;

  const DashboardLayout({
    super.key, 
    required this.child, 
    required this.title,
    required this.currentRoute,
  });

  @override
  State<DashboardLayout> createState() => _DashboardLayoutState();
}

class _DashboardLayoutState extends State<DashboardLayout> {
  // Maintained statically so routing changes don't flash reset the sidebar
  static bool _isSidebarOpen = false;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth >= 800;

        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: isDesktop ? null : TopBar(title: widget.title),
          drawer: isDesktop ? null : Drawer(child: Sidebar(currentRoute: widget.currentRoute)),
          body: Row(
            children: [
              if (isDesktop && _isSidebarOpen)
                Sidebar(currentRoute: widget.currentRoute),
              Expanded(
                child: Column(
                  children: [
                    if (isDesktop)
                      TopBar(
                        title: widget.title,
                        onMenuToggle: () {
                          setState(() {
                            _isSidebarOpen = !_isSidebarOpen;
                          });
                        },
                      ),
                    Expanded(child: widget.child),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
