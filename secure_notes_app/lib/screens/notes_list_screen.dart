import 'package:flutter/material.dart';
import '../services/notes_service.dart';
import 'add_edit_note_screen.dart';
import '../models/note.dart';


class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}


class _NotesListScreenState extends State<NotesListScreen> {
  final NotesService _notesService = NotesService();
  bool _isLoading = true;


  @override
  void initState() {
    super.initState();
    _loadNotes();
  }


  Future<void> _loadNotes() async {
    await _notesService.loadNotes();
    if (mounted) setState(() => _isLoading = false);
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('SECURE NOTES', style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.2)),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: Colors.blue[900],
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notesService.notes.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.notes, size: 80, color: Colors.grey[400]),
                      const SizedBox(height: 16),
                      Text('No notes yet. Tap + to create one.', style: TextStyle(color: Colors.grey[600], fontSize: 16)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: _notesService.notes.length,
                  itemBuilder: (context, index) {
                    final note = _notesService.notes[index];
                    return Hero(
                      tag: note.id,
                      child: Card(
                        elevation: 2,
                        margin: const EdgeInsets.only(bottom: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                        child: ListTile(
                          contentPadding: const EdgeInsets.all(16),
                          title: Text(
                            note.title,
                            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                          ),
                          subtitle: Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              note.content.length > 80 ? '${note.content.substring(0, 80)}...' : note.content,
                              style: TextStyle(color: Colors.grey[700]),
                            ),
                          ),
                          trailing: Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Text(
                                _formatDate(note.lastEdited),
                                style: TextStyle(color: Colors.grey[500], fontSize: 12),
                              ),
                              const Spacer(),
                              const Icon(Icons.chevron_right, color: Colors.grey),
                            ],
                          ),
                          onTap: () => _editNote(note),
                          onLongPress: () => _deleteNote(note.id),
                        ),
                      ),
                    );
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: _addNote,
        backgroundColor: Colors.blue[900],
        child: const Icon(Icons.add, color: Colors.white, size: 30),
      ),
    );
  }


  void _addNote() async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => const AddEditNoteScreen()));
    if (result == true) {
      _loadNotes();
    }
  }


  void _editNote(Note note) async {
    final result = await Navigator.push(context, MaterialPageRoute(builder: (_) => AddEditNoteScreen(note: note)));
    if (result == true) {
      _loadNotes();
    }
  }


  Future<void> _deleteNote(String id) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to permanently delete this note?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await _notesService.deleteNote(id);
      _loadNotes();
    }
  }


  String _formatDate(DateTime date) => '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute.toString().padLeft(2, '0')}';
}
