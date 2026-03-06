import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/note.dart';
import '../services/notes_storage_service.dart';
import '../widgets/empty_notes_state.dart';
import '../widgets/notes_search_bar.dart';
import 'add_edit_note_screen.dart';

class NotesListScreen extends StatefulWidget {
  const NotesListScreen({super.key});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final notesBox = Hive.box<Map>(NotesStorageService.boxName);
    final storageService = NotesStorageService();

    return Scaffold(
      appBar: AppBar(title: const Text('My Notes')),
      body: Column(
        children: [
          NotesSearchBar(
            onChanged: (value) {
              setState(() {
                _query = value.trim().toLowerCase();
              });
            },
          ),
          Expanded(
            child: ValueListenableBuilder<Box<Map>>(
              valueListenable: notesBox.listenable(),
              builder: (context, box, _) {
                final allNotes = box.values.map(Note.fromJson).toList()
                  ..sort((a, b) {
                    if (a.isPinned != b.isPinned) {
                      return a.isPinned ? -1 : 1;
                    }
                    return b.updatedAt.compareTo(a.updatedAt);
                  });

                final filteredNotes = _query.isEmpty
                    ? allNotes
                    : allNotes.where((note) {
                        final title = note.title.toLowerCase();
                        final content = note.content.toLowerCase();
                        return title.contains(_query) || content.contains(_query);
                      }).toList();

                if (filteredNotes.isEmpty) {
                  return EmptyNotesState(
                    message: _query.isEmpty
                        ? 'No notes yet. Tap + to add your first note.'
                        : 'No notes matched your search.',
                  );
                }

                return ListView.separated(
                  itemCount: filteredNotes.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (context, index) {
                    final note = filteredNotes[index];
                    return ListTile(
                      title: Text(note.title.isEmpty ? 'Untitled' : note.title),
                      subtitle: Text(
                        note.content,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      leading: note.isPinned
                          ? const Icon(Icons.push_pin, size: 18)
                          : null,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (_) => AddEditNoteScreen(note: note),
                          ),
                        );
                      },
                      trailing: IconButton(
                        icon: const Icon(Icons.delete_outline),
                        onPressed: () => storageService.deleteNote(note.id),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (_) => const AddEditNoteScreen()),
          );
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}
