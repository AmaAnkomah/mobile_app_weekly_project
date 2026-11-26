import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/note.dart';
import '../utils/encryption_helper.dart';
import 'secure_storage_service.dart';


class NotesService {
  // Singleton pattern
  static final NotesService _instance = NotesService._internal();
  factory NotesService() => _instance;
  NotesService._internal();


  List<Note> _notes = [];


  List<Note> get notes => _notes;


  Future<void> loadNotes() async {
    try {
      final encryptedJson = await SecureStorageService.loadNotes();
      if (encryptedJson == null) {
        _notes = [];
        await _addSampleNotes();
        return;
      }
      
      try {
        final decryptedJson = EncryptionHelper.decrypt(encryptedJson);
        final List<dynamic> decoded = jsonDecode(decryptedJson);
        _notes = decoded.map((item) => Note.fromJson(item)).toList();
      } catch (e) {
        // If decryption fails (e.g. invalid key or corrupted data)
        // reset to factory samples to prevent permanent app hang/crash
        _notes = [];
        await _addSampleNotes();
      }
    } catch (e) {
      _notes = [];
    }
  }


  Future<void> _addSampleNotes() async {
    try {
      _notes = [
        Note(
          id: const Uuid().v4(),
          title: '🔒 Welcome to Secure Notes',
          content: 'Your notes are protected with AES encryption and biometrics. Tap the + button to add your first secret!',
          lastEdited: DateTime.now(),
        ),
        Note(
          id: const Uuid().v4(),
          title: '💡 Capstone Project Ideas',
          content: '1. Secure Authentication Flow\n2. AES-256 Encryption Integration\n3. Biometric Hardware Access\n4. Premium UI/UX Design',
          lastEdited: DateTime.now().subtract(const Duration(hours: 2)),
        ),
      ];
      await _saveNotes();
    } catch (e) {
      // Sample addition failed
    }
  }


  Future<void> _saveNotes() async {
    try {
      final jsonString = jsonEncode(_notes.map((n) => n.toJson()).toList());
      final encrypted = EncryptionHelper.encrypt(jsonString);
      await SecureStorageService.saveNotes(encrypted);
    } catch (e) {
      // Save failed
    }
  }


  Future<void> addNote(Note note) async {
    // Ensure notes are loaded before adding a new one
    if (_notes.isEmpty) await loadNotes();
    
    _notes.insert(0, note);
    await _saveNotes();
  }


  Future<void> updateNote(Note note) async {
    final index = _notes.indexWhere((n) => n.id == note.id);
    if (index != -1) {
      _notes[index] = note;
      await _saveNotes();
    }
  }


  Future<void> deleteNote(String id) async {
    _notes.removeWhere((n) => n.id == id);
    await _saveNotes();
  }
}
