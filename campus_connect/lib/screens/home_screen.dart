import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/quote_viewmodel.dart';
import '../widgets/glass_card.dart';
import 'event_list_screen.dart';
import 'profile_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final quoteVm = Provider.of<QuoteViewModel>(context);
    
    return Scaffold(
      appBar: AppBar(
        title: const Text('Campus Connect', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          // Background Gradient
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF1A237E), Color(0xFF121212)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Daily Inspiration',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 12),
                  GlassCard(
                    opacity: 0.1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (quoteVm.isLoading)
                          const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)))
                        else if (quoteVm.errorMessage != null)
                          const Text('Failed to load inspiration', style: TextStyle(color: Colors.white70))
                        else ...[
                          Text(
                            '"${quoteVm.currentQuote?.text}"',
                            style: const TextStyle(
                              fontSize: 22,
                              fontStyle: FontStyle.italic,
                              color: Colors.white,
                              fontWeight: FontWeight.w300,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Align(
                            alignment: Alignment.bottomRight,
                            child: Text(
                              '- ${quoteVm.currentQuote?.author}',
                              style: const TextStyle(
                                color: Color(0xFFFFC107),
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                        const SizedBox(height: 16),
                        Center(
                          child: TextButton.icon(
                            onPressed: () => quoteVm.loadRandomQuote(),
                            icon: const Icon(Icons.refresh, color: Colors.white70),
                            label: const Text('New Quote', style: TextStyle(color: Colors.white70)),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                  const Text(
                    'Explore Campus',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70,
                      letterSpacing: 1.2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Expanded(
                    child: GridView.count(
                      crossAxisCount: 2,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      children: [
                        HomeNavCard(
                          title: 'Events',
                          icon: Icons.event,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventListScreen())),
                        ),
                        HomeNavCard(
                          title: 'Profile',
                          icon: Icons.person,
                          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => ProfileScreen())),
                        ),
                        HomeNavCard(
                          title: 'Notifications',
                          icon: Icons.notifications,
                          onTap: () {
                            // TODO: Add notifications screen
                          },
                        ),
                        HomeNavCard(
                          title: 'Settings',
                          icon: Icons.settings,
                          onTap: () {
                            // TODO: Add settings screen
                          },
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class HomeNavCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const HomeNavCard({required this.title, required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: GlassCard(
        opacity: 0.1,
        padding: EdgeInsets.zero,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 40, color: const Color(0xFFFFC107)),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
