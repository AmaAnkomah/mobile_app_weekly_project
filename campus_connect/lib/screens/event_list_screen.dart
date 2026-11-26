import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/event_viewmodel.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../widgets/glass_card.dart';
import 'add_event_screen.dart';
import 'comment_screen.dart';
import 'package:intl/intl.dart';

class EventListScreen extends StatefulWidget {
  const EventListScreen({super.key});

  @override
  _EventListScreenState createState() => _EventListScreenState();
}

class _EventListScreenState extends State<EventListScreen> {
  @override
  void initState() {
    super.initState();
    Provider.of<EventViewModel>(context, listen: false).listenToEvents();
  }

  @override
  Widget build(BuildContext context) {
    final eventVm = Provider.of<EventViewModel>(context);
    final userId = Provider.of<AuthViewModel>(context, listen: false).user?.uid ?? '';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text('Campus Events', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
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
            child: eventVm.isLoading
                ? const Center(child: CircularProgressIndicator(color: Color(0xFFFFC107)))
                : eventVm.errorMessage != null
                    ? Center(child: Text(eventVm.errorMessage!, style: const TextStyle(color: Colors.white70)))
                    : eventVm.events.isEmpty
                        ? const Center(child: Text('No events yet. Create one!', style: TextStyle(color: Colors.white70)))
                        : ListView.builder(
                            padding: const EdgeInsets.all(16),
                            itemCount: eventVm.events.length,
                            itemBuilder: (context, index) {
                              final event = eventVm.events[index];
                              final isLiked = event.likes.contains(userId);
                              
                              return Padding(
                                padding: const EdgeInsets.only(bottom: 16.0),
                                child: GlassCard(
                                  opacity: 0.1,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Expanded(
                                            child: Text(
                                              event.title,
                                              style: const TextStyle(
                                                fontSize: 20,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.white,
                                              ),
                                            ),
                                          ),
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                            decoration: BoxDecoration(
                                              color: const Color(0xFFFFC107).withAlpha(51),
                                              borderRadius: BorderRadius.circular(8),
                                            ),
                                            child: Text(
                                              DateFormat('MMM dd').format(event.date),
                                              style: const TextStyle(
                                                color: Color(0xFFFFC107),
                                                fontWeight: FontWeight.bold,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        event.description,
                                        style: const TextStyle(color: Colors.white70),
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      const Divider(color: Colors.white12, height: 24),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                        children: [
                                          Row(
                                            children: [
                                              IconButton(
                                                icon: Icon(
                                                  isLiked ? Icons.favorite : Icons.favorite_border,
                                                  color: isLiked ? Colors.red : Colors.white70,
                                                ),
                                                onPressed: () => eventVm.toggleLike(event.id, userId),
                                              ),
                                              Text(
                                                '${event.likes.length}',
                                                style: const TextStyle(color: Colors.white70),
                                              ),
                                              const SizedBox(width: 16),
                                              IconButton(
                                                icon: const Icon(Icons.chat_bubble_outline, color: Colors.white70),
                                                onPressed: () => Navigator.push(context, MaterialPageRoute(
                                                  builder: (_) => CommentScreen(event: event)
                                                )),
                                              ),
                                            ],
                                          ),
                                          TextButton(
                                            onPressed: () {
                                              // TODO: View details
                                            },
                                            child: const Text('View Details', style: TextStyle(color: Color(0xFFFFC107))),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            },
                          ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => AddEventScreen())),
        backgroundColor: const Color(0xFFFFC107),
        foregroundColor: Colors.black,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: const Icon(Icons.add),
      ),
    );
  }
}
