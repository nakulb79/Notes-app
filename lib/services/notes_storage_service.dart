import 'package:hive/hive.dart';

import '../models/note.dart';

class NotesStorageService {
  static const String boxName = 'notesBox';

  Box<Map> get _box => Hive.box<Map>(boxName);

  List<Note> getAllNotes() {
    return _box.values.map(Note.fromJson).toList();
  }

  List<String> getAllTags() {
    final tags = <String>{};
    for (final note in getAllNotes()) {
      tags.addAll(note.tags.map((tag) => tag.trim()).where((tag) => tag.isNotEmpty));
    }
    final sorted = tags.toList()..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
    return sorted;
  }

  Future<void> saveNote(Note note) async {
    await _box.put(note.id, note.toJson());
  }

  Future<void> togglePin(Note note) async {
    final updated = note.copyWith(
      isPinned: !note.isPinned,
      updatedAt: DateTime.now(),
    );
    await _box.put(note.id, updated.toJson());
  }

  Future<void> addTag(String noteId, String tag) async {
    final raw = _box.get(noteId);
    if (raw == null) {
      return;
    }
    final note = Note.fromJson(raw);
    final normalized = tag.trim();
    if (normalized.isEmpty || note.tags.contains(normalized)) {
      return;
    }
    await saveNote(
      note.copyWith(tags: [...note.tags, normalized], updatedAt: DateTime.now()),
    );
  }

  Future<void> removeTag(String noteId, String tag) async {
    final raw = _box.get(noteId);
    if (raw == null) {
      return;
    }
    final note = Note.fromJson(raw);
    await saveNote(
      note.copyWith(
        tags: note.tags.where((existing) => existing != tag).toList(),
        updatedAt: DateTime.now(),
      ),
    );
  }

  Future<void> deleteNote(String id) async {
    await _box.delete(id);
  }
}
