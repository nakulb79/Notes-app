import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/notes_storage_service.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _storageService = NotesStorageService();

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    if (note != null) {
      _titleController.text = note.title;
      _contentController.text = note.content;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  Future<void> _saveNote() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    final now = DateTime.now();
    final existing = widget.note;
    final note = Note(
      id: existing?.id ?? now.microsecondsSinceEpoch.toString(),
      title: _titleController.text.trim(),
      content: _contentController.text.trim(),
      createdAt: existing?.createdAt ?? now,
      updatedAt: now,
      isPinned: existing?.isPinned ?? false,
    );

    await _storageService.saveNote(note);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'Add Note'),
        actions: [
          IconButton(
            onPressed: _saveNote,
            icon: const Icon(Icons.check),
            tooltip: 'Save',
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: 'Title',
                  border: OutlineInputBorder(),
                ),
                textInputAction: TextInputAction.next,
              ),
              const SizedBox(height: 12),
              Expanded(
                child: TextFormField(
                  controller: _contentController,
                  decoration: const InputDecoration(
                    labelText: 'Content',
                    border: OutlineInputBorder(),
                    alignLabelWithHint: true,
                  ),
                  maxLines: null,
                  expands: true,
                  textAlignVertical: TextAlignVertical.top,
                  validator: (value) {
                    if ((value ?? '').trim().isEmpty) {
                      return 'Content cannot be empty';
                    }
                    return null;
                  },
                ),
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: _saveNote,
                  icon: const Icon(Icons.save),
                  label: Text(_isEditing ? 'Update Note' : 'Save Note'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
