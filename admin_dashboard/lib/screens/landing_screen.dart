import 'package:flutter/material.dart';

class LandingScreen extends StatelessWidget {
  const LandingScreen({super.key});

  Widget _buildPortalCard(
    BuildContext context, 
    String title, 
    String description, 
    IconData icon, 
    String route,
    {bool primary = false}
  ) {
    return InkWell(
      onTap: () => Navigator.pushNamed(context, route),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: primary ? const Color(0xFF2E7D32) : Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              // ignore: deprecated_member_use
              color: Colors.black.withOpacity(0.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
          border: primary ? null : Border.all(color: Colors.grey.shade200),
        ),
        child: Column(
          children: [
            Icon(
              icon, 
              size: 48, 
              color: primary ? Colors.white : const Color(0xFF2E7D32),
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: primary ? Colors.white : Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                // ignore: deprecated_member_use
                color: primary ? Colors.white.withOpacity(0.9) : Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureItem(IconData icon, String title, String description) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: const Color(0xFF2E7D32), size: 32),
          const SizedBox(height: 12),
          Text(
            title,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 4),
          Text(
            description,
            textAlign: TextAlign.center,
            style: const TextStyle(color: Colors.black54, fontSize: 13),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final bool isMobile = MediaQuery.of(context).size.width < 800;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Hero Section
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(
                vertical: isMobile ? 60 : 100,
                horizontal: 24,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF000000), // Black background for Hero
                image: DecorationImage(
                  image: NetworkImage('https://images.unsplash.com/photo-1500382017468-9049fed747ef?ixlib=rb-4.0.3&auto=format&fit=crop&w=1600&q=80'),
                  fit: BoxFit.cover,
                  opacity: 0.4,
                ),
              ),
              child: Column(
                children: [
                  const Text(
                    'Smart Agricultural Produce\nPrice Tracker',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 40,
                      fontWeight: FontWeight.bold,
                      height: 1.2,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 800),
                    child: const Text(
                      'Empowering Malawi\'s agriculture with real-time market intelligence, connecting farmers, cooperatives, and administrators for a transparent and efficient marketplace.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 18,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Features Section
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 60, horizontal: 24),
              child: Column(
                children: [
                  const Text(
                    'System Features',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 48),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 1000),
                    child: isMobile 
                      ? Column(
                          children: [
                            _buildFeatureItem(Icons.analytics, 'Real-time Tracking', 'Monitor produce prices across all national markets instantly.'),
                            const SizedBox(height: 32),
                            _buildFeatureItem(Icons.trending_up, 'Market Insights', 'Data-driven analytics to identify trends and optimize sales.'),
                            const SizedBox(height: 32),
                            _buildFeatureItem(Icons.security, 'Verified Data', 'Secure and accurate price entries managed by authorized personnel.'),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildFeatureItem(Icons.analytics, 'Real-time Tracking', 'Monitor produce prices across all national markets instantly.'),
                            _buildFeatureItem(Icons.trending_up, 'Market Insights', 'Data-driven analytics to identify trends and optimize sales.'),
                            _buildFeatureItem(Icons.security, 'Verified Data', 'Secure and accurate price entries managed by authorized personnel.'),
                          ],
                        ),
                  ),
                ],
              ),
            ),

            // Portal Selection Section
            Container(
              width: double.infinity,
              color: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 80, horizontal: 24),
              child: Column(
                children: [
                  const Text(
                    'Select Your Portal',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'Choose the access point relevant to your role.',
                    style: TextStyle(color: Colors.black54, fontSize: 16),
                  ),
                  const SizedBox(height: 60),
                  Container(
                    constraints: const BoxConstraints(maxWidth: 1200),
                    child: isMobile
                      ? Column(
                          children: [
                            _buildPortalCard(context, 'Admin Portal', 'Manage markets, commodities, and verified price entries.', Icons.admin_panel_settings, '/dashboard', primary: true),
                            const SizedBox(height: 24),
                            _buildPortalCard(context, 'Farmer Portal', 'Access market prices and track produce demand.', Icons.agriculture, '/farmer'),
                            const SizedBox(height: 24),
                            _buildPortalCard(context, 'Cooperative Portal', 'Manage collective sales and community insights.', Icons.groups, '/cooperative'),
                          ],
                        )
                      : Row(
                          children: [
                            Expanded(child: _buildPortalCard(context, 'Admin Portal', 'Manage markets, commodities, and verified price entries.', Icons.admin_panel_settings, '/dashboard', primary: true)),
                            const SizedBox(width: 24),
                            Expanded(child: _buildPortalCard(context, 'Farmer Portal', 'Access market prices and track produce demand.', Icons.agriculture, '/farmer')),
                            const SizedBox(width: 24),
                            Expanded(child: _buildPortalCard(context, 'Cooperative Portal', 'Manage collective sales and community insights.', Icons.groups, '/cooperative')),
                          ],
                        ),
                  ),
                ],
              ),
            ),

            // Footer
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(48),
              color: const Color(0xFFF8F9FA),
              child: const Column(
                children: [
                  Text(
                    '© 2026 SAPT - Malawi Agricultural Intelligence System',
                    style: TextStyle(color: Colors.black54),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
