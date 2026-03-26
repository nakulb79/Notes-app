import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:image_picker/image_picker.dart';

import '../models/note.dart';
import '../services/notes_storage_service.dart';
import '../widgets/markdown_toolbar.dart';
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
  final _imagePicker = ImagePicker();

  late List<String> _tags;
  late List<String> _attachments;
  List<String> _suggestedTags = const [];
  String _selectedColor = '#FFFFFF';
  bool _isPreview = false;

  bool get _isEditing => widget.note != null;

  @override
  void initState() {
    super.initState();
    final note = widget.note;
    _tags = List<String>.from(note?.tags ?? const []);
    _attachments = List<String>.from(note?.getAttachments() ?? const []);
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
      _suggestedTags =
          _suggestedTags.where((existing) => existing != tag).toList();
    });
  }

  void _removeTag(String tag) {
    setState(() {
      _tags = _tags.where((existing) => existing != tag).toList();
    });
    _refreshSuggestions();
  }

  Future<void> _addImage() async {
    final picked = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (picked == null) {
      return;
    }
    if (!mounted) {
      return;
    }
    setState(() {
      if (!_attachments.contains(picked.path)) {
        _attachments = [..._attachments, picked.path];
      }
    });
  }

  void _removeAttachment(String path) {
    setState(() {
      _attachments = _attachments.where((item) => item != path).toList();
    });
  }


  void _insertMarkdown(String prefix, {String suffix = ''}) {
    final value = _contentController.value;
    final start = value.selection.start;
    final end = value.selection.end;

    if (start < 0 || end < 0) {
      final appended = value.text + prefix + suffix;
      _contentController.value = value.copyWith(
        text: appended,
        selection: TextSelection.collapsed(
          offset: appended.length - suffix.length,
        ),
      );
      return;
    }

    final selectedText = value.text.substring(start, end);
    final replacement = '$prefix$selectedText$suffix';
    final newText = value.text.replaceRange(start, end, replacement);
    final cursorOffset = selectedText.isEmpty
        ? start + prefix.length
        : start + replacement.length;

    _contentController.value = value.copyWith(
      text: newText,
      selection: TextSelection.collapsed(offset: cursorOffset),
    );
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
      metadata: <String, dynamic>{...?existing?.metadata},
    ).withColor(_selectedColor).withAttachments(_attachments);

    await _storageService.saveNote(note);
    if (!mounted) {
      return;
    }
    Navigator.of(context).pop();
  }

  Widget _buildAttachments() {
    if (_attachments.isEmpty) {
      return const SizedBox.shrink();
    }

    return Align(
      alignment: Alignment.centerLeft,
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: _attachments.map((path) {
          return Stack(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: Image.file(
                  File(path),
                  width: 90,
                  height: 90,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => Container(
                    width: 90,
                    height: 90,
                    color: Colors.black12,
                    alignment: Alignment.center,
                    child: const Icon(Icons.broken_image),
                  ),
                ),
              ),
              Positioned(
                right: 0,
                top: 0,
                child: GestureDetector(
                  onTap: () => _removeAttachment(path),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    padding: const EdgeInsets.all(2),
                    child: const Icon(Icons.close, size: 14, color: Colors.white),
                  ),
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markdownStyle =
        MarkdownStyleSheet.fromTheme(Theme.of(context)).copyWith(
      h1: Theme.of(context).textTheme.headlineMedium,
      h2: Theme.of(context).textTheme.headlineSmall,
      p: Theme.of(context).textTheme.bodyLarge,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Edit Note' : 'Add Note'),
        actions: [
          IconButton(
            onPressed: () {
              setState(() {
                _isPreview = !_isPreview;
              });
            },
            icon: Icon(_isPreview ? Icons.edit : Icons.visibility),
            tooltip: _isPreview ? 'Switch to edit' : 'Preview markdown',
          ),
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
                    final color =
                        Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
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
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Attachments',
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ),
              const SizedBox(height: 8),
              _buildAttachments(),
              Align(
                alignment: Alignment.centerLeft,
                child: TextButton.icon(
                  onPressed: _addImage,
                  icon: const Icon(Icons.image_outlined),
                  label: const Text('Add image'),
                ),
              ),
              const SizedBox(height: 12),
              Expanded(
                child: _isPreview
                    ? Container(
                        width: double.infinity,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Theme.of(context)
                                .colorScheme
                                .outline
                                .withOpacity(0.5),
                          ),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: ListView(
                          padding: const EdgeInsets.all(12),
                          children: [
                            MarkdownBody(
                              data: _contentController.text,
                              selectable: true,
                              styleSheet: markdownStyle,
                            ),
                            if (_attachments.isNotEmpty) ...[
                              const SizedBox(height: 12),
                              Text(
                                'Attachments',
                                style: Theme.of(context).textTheme.titleSmall,
                              ),
                              const SizedBox(height: 8),
                              _buildAttachments(),
                            ],
                          ],
                        ),
                      )
                    : Column(
                        children: [
                          MarkdownToolbar(
                            onBold: () => _insertMarkdown('**', suffix: '**'),
                            onItalic: () => _insertMarkdown('_', suffix: '_'),
                            onCode: () => _insertMarkdown('`', suffix: '`'),
                            onList: () => _insertMarkdown('- '),
                            onHeading: () => _insertMarkdown('# '),
                          ),
                          Expanded(
                            child: TextFormField(
                              controller: _contentController,
                              decoration: const InputDecoration(
                                labelText: 'Content',
                                border: OutlineInputBorder(),
                                alignLabelWithHint: true,
                                helperText:
                                    'Markdown supported: # Header  **Bold**  - List  `Code`',
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
                        ],
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
