import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/note.dart';

class NotesService {
  static const String _notesKey = 'notes';

  Future<List<Note>> getNotes() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final notesJson = prefs.getStringList(_notesKey) ?? [];
      
      return notesJson
          .map((noteStr) => Note.fromJson(json.decode(noteStr) as Map<String, dynamic>))
          .toList();
    } catch (e) {
      // Return empty list on error to gracefully handle corrupted data
      return [];
    }
  }

  Future<void> saveNotes(List<Note> notes) async {
    final prefs = await SharedPreferences.getInstance();
    final notesJson = notes.map((note) => json.encode(note.toJson())).toList();
    await prefs.setStringList(_notesKey, notesJson);
  }

  Future<void> addNote(Note note) async {
    final notes = await getNotes();
    notes.insert(0, note);
    await saveNotes(notes);
  }

  Future<void> updateNote(Note updatedNote) async {
    final notes = await getNotes();
    final index = notes.indexWhere((note) => note.id == updatedNote.id);
    if (index != -1) {
      notes[index] = updatedNote;
      await saveNotes(notes);
    }
    // Silently ignore if note not found (defensive programming)
  }

  Future<void> deleteNote(String id) async {
    final notes = await getNotes();
    notes.removeWhere((note) => note.id == id);
    await saveNotes(notes);
  }
}
