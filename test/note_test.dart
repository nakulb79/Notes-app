import 'package:flutter_test/flutter_test.dart';
import 'package:notes_app/models/note.dart';

void main() {
  group('Note Model Tests', () {
    test('Note creation', () {
      final now = DateTime.now();
      final note = Note(
        id: '1',
        title: 'Test Note',
        content: 'Test Content',
        createdAt: now,
        updatedAt: now,
      );

      expect(note.id, '1');
      expect(note.title, 'Test Note');
      expect(note.content, 'Test Content');
      expect(note.createdAt, now);
      expect(note.updatedAt, now);
    });

    test('Note toJson and fromJson', () {
      final now = DateTime.now();
      final note = Note(
        id: '1',
        title: 'Test Note',
        content: 'Test Content',
        createdAt: now,
        updatedAt: now,
      );

      final json = note.toJson();
      final noteFromJson = Note.fromJson(json);

      expect(noteFromJson.id, note.id);
      expect(noteFromJson.title, note.title);
      expect(noteFromJson.content, note.content);
      expect(noteFromJson.createdAt.toIso8601String(), 
             note.createdAt.toIso8601String());
      expect(noteFromJson.updatedAt.toIso8601String(), 
             note.updatedAt.toIso8601String());
    });

    test('Note copyWith', () {
      final now = DateTime.now();
      final note = Note(
        id: '1',
        title: 'Test Note',
        content: 'Test Content',
        createdAt: now,
        updatedAt: now,
      );

      final updatedNote = note.copyWith(
        title: 'Updated Title',
        content: 'Updated Content',
      );

      expect(updatedNote.id, note.id);
      expect(updatedNote.title, 'Updated Title');
      expect(updatedNote.content, 'Updated Content');
      expect(updatedNote.createdAt, note.createdAt);
    });
  });
}
