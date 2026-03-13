import 'package:flutter/material.dart';

import '../models/note.dart';
import '../services/notes_storage_service.dart';
import '../widgets/tag_chip.dart';

class AddEditNoteScreen extends StatefulWidget {
  final Note? note;

  const AddEditNoteScreen({super.key, this.note});

  @override
  State<AddEditNoteScreen> createState() => _AddEditNoteScreenState();
}

class _AddEditNoteScreenState extends State<AddEditNoteScreen> {
  static const List<String> _noteColors = [
    '#FFFFFF',
    '#FFF59D',
    '#C8E6C9',
    '#BBDEFB',
    '#E1BEE7',
    '#FFCDD2',
  ];

  final _formKey = GlobalKey<FormState>();
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  final _tagController = TextEditingController();
  final _storageService = NotesStorageService();

  late List<String> _tags;
  List<String> _suggestedTags = const [];
  String _selectedColor = '#FFFFFF';

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _tags = List<String>.from(note?.tags ?? const []);
    if (note != null) {
      _titleController.text = note.title;
      _contentController.text = note.content;
      _selectedColor = (note.metadata?['color'] as String?) ?? '#FFFFFF';
    }
    _refreshSuggestions(notify: false);
  }

  void _refreshSuggestions({bool notify = true}) {
    final allTags = _storageService.getAllTags();
    final next = allTags.where((tag) => !_tags.contains(tag)).toList();
    if (notify) {
      setState(() {
        _suggestedTags = next;
      });
      return;
    }
    _suggestedTags = next;
  }

  void _addTag(String rawTag) {
    final tag = rawTag.trim();
    if (tag.isEmpty || _tags.contains(tag)) {
      return;
    }
    setState(() {
      _tags = [..._tags, tag];
      _tagController.clear();
      _suggestedTags = _suggestedTags.where((existing) => existing != tag).toList();
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _tags = _tags.where((existing) => existing != tag).toList();
    });
    _refreshSuggestions();
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    _tagController.dispose();
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
      tags: _tags,
      metadata: <String, dynamic>{...?existing?.metadata, 'color': _selectedColor},
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
              TextField(
                controller: _tagController,
                decoration: InputDecoration(
                  labelText: 'Add tag',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    onPressed: () => _addTag(_tagController.text),
                    icon: const Icon(Icons.add),
                    tooltip: 'Add tag',
                  ),
                ),
                textInputAction: TextInputAction.done,
                onSubmitted: _addTag,
              ),
              const SizedBox(height: 8),
              if (_tags.isNotEmpty)
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    children: _tags
                        .map(
                          (tag) => TagChip(
                            label: tag,
                            onDeleted: () => _removeTag(tag),
                          ),
                        )
                        .toList(),
                  ),
                ),
              if (_suggestedTags.isNotEmpty) ...[
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Text(
                    'Suggestions',
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                ),
                const SizedBox(height: 4),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    children: _suggestedTags
                        .take(8)
                        .map(
                          (tag) => TagChip(
                            label: tag,
                            onTap: () => _addTag(tag),
                          ),
                        )
                        .toList(),
                  ),
                ),
              ],

              const SizedBox(height: 12),
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Note Color',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const SizedBox(height: 8),
              Align(
                alignment: Alignment.centerLeft,
                child: Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _noteColors.map((hex) {
                    final color = Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
                    final isSelected = _selectedColor == hex;
                    return GestureDetector(
                      onTap: () {
                        setState(() {
                          _selectedColor = hex;
                        });
                      },
                      child: Container(
                        width: 28,
                        height: 28,
                        decoration: BoxDecoration(
                          color: color,
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onSurface
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
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
