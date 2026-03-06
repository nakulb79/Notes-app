import 'package:hive/hive.dart';

import '../models/note.dart';

class NotesStorageService {
  static const String boxName = 'notesBox';

  Box<Map> get _box => Hive.box<Map>(boxName);

  List<Note> getAllNotes() {
    return _box.values.map(Note.fromJson).toList();
  }

  Future<void> saveNote(Note note) async {
    await _box.put(note.id, note.toJson());
  }

  Future<void> deleteNote(String id) async {
    await _box.delete(id);
  }
}
