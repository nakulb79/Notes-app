import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../models/note.dart';
import '../services/notes_storage_service.dart';
import '../theme/theme_controller.dart';
import '../widgets/empty_notes_state.dart';
import '../widgets/notes_search_bar.dart';
import '../widgets/tag_chip.dart';
import 'add_edit_note_screen.dart';

enum NoteSortOption { recent, oldest, title }

class NotesListScreen extends StatefulWidget {
  final ThemeController themeController;

  const NotesListScreen({super.key, required this.themeController});

  @override
  State<NotesListScreen> createState() => _NotesListScreenState();
}

class _NotesListScreenState extends State<NotesListScreen> {
  static const String _allTagsKey = '__all__';
  static const List<String> _noteColors = [
    '#FFFFFF',
    '#FFF59D',
    '#C8E6C9',
    '#BBDEFB',
    '#E1BEE7',
    '#FFCDD2',
  ];

  String _query = '';
  String _activeTag = _allTagsKey;
  NoteSortOption _sortOption = NoteSortOption.recent;
  bool _pinnedFirst = true;
  late final VoidCallback _themeListener;

  @override
  void initState() {
    super.initState();
    _themeListener = () {
      if (mounted) {
        setState(() {});
      }
    };
    widget.themeController.addListener(_themeListener);
  }

  @override
  void dispose() {
    widget.themeController.removeListener(_themeListener);
    super.dispose();
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(content: Text(message)));
  }

  List<Note> _sortNotes(List<Note> notes) {
    final sorted = List<Note>.from(notes);
    sorted.sort((a, b) {
      if (_pinnedFirst && a.isPinned != b.isPinned) {
        return a.isPinned ? -1 : 1;
      }

      switch (_sortOption) {
        case NoteSortOption.recent:
          return b.updatedAt.compareTo(a.updatedAt);
        case NoteSortOption.oldest:
          return a.createdAt.compareTo(b.createdAt);
        case NoteSortOption.title:
          return a.title.toLowerCase().compareTo(b.title.toLowerCase());
      }
    });
    return sorted;
  }

  Future<bool> _handleSwipeAction(
    DismissDirection direction,
    Note note,
    NotesStorageService storageService,
  ) async {
    if (direction == DismissDirection.startToEnd) {
      await storageService.togglePin(note);
      if (mounted) {
        _showMessage(note.isPinned ? 'Note unpinned' : 'Note pinned');
      }
      return false;
    }

    if (direction == DismissDirection.endToStart) {
      await storageService.deleteNote(note.id);
      if (mounted) {
        _showMessage('Note deleted');
      }
      return true;
    }

    return false;
  }


  Future<void> _showColorPicker(Note note, NotesStorageService storageService) async {
    await showModalBottomSheet<void>(
      context: context,
      builder: (_) {
        return Padding(
          padding: const EdgeInsets.all(16),
          child: Wrap(
            spacing: 10,
            runSpacing: 10,
            children: _noteColors.map((hex) {
              final color =
                  Color(int.parse(hex.replaceFirst('#', 'FF'), radix: 16));
              final isSelected = (note.metadata?['color'] as String?) == hex;

              return GestureDetector(
                onTap: () async {
                  final updated = note.withColor(hex).copyWith(
                        updatedAt: DateTime.now(),
                      );
                  await storageService.saveNote(updated);
                  if (!mounted) {
                    return;
                  }
                  Navigator.pop(context);
                  _showMessage('Note color updated');
                },
                child: Container(
                  width: 36,
                  height: 36,
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
        );
      },
    );
  }

  String _sortLabel(NoteSortOption option) {
    switch (option) {
      case NoteSortOption.recent:
        return 'Recent';
      case NoteSortOption.oldest:
        return 'Oldest';
      case NoteSortOption.title:
        return 'Title';
    }
  }

  String _themeLabel(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        return 'System';
      case ThemeMode.light:
        return 'Light';
      case ThemeMode.dark:
        return 'Dark';
    }
  }

  @override
  Widget build(BuildContext context) {
    final notesBox = Hive.box<Map>(NotesStorageService.boxName);
    final storageService = NotesStorageService();
    final activeThemeMode = widget.themeController.value;

    return Scaffold(
      appBar: AppBar(
        title: const Text('My Notes'),
        actions: [
          PopupMenuButton<String>(
            tooltip: 'Sort and options',
            onSelected: (value) async {
              if (value.startsWith('theme:')) {
                final rawMode = value.replaceFirst('theme:', '');
                final themeMode = ThemeMode.values.firstWhere(
                  (mode) => mode.name == rawMode,
                  orElse: () => ThemeMode.system,
                );
                await widget.themeController.setThemeMode(themeMode);
                if (mounted) {
                  _showMessage('Theme set to ${_themeLabel(themeMode)}');
                }
                return;
              }

              setState(() {
                if (value == 'togglePinnedFirst') {
                  _pinnedFirst = !_pinnedFirst;
                } else {
                  _sortOption = NoteSortOption.values.firstWhere(
                    (option) => option.name == value,
                    orElse: () => NoteSortOption.recent,
                  );
                }
              });
            },
            itemBuilder: (context) => [
              const PopupMenuItem<String>(enabled: false, child: Text('Sort by')),
              ...NoteSortOption.values.map(
                (option) => CheckedPopupMenuItem<String>(
                  value: option.name,
                  checked: _sortOption == option,
                  child: Text(_sortLabel(option)),
                ),
              ),
              const PopupMenuDivider(),
              CheckedPopupMenuItem<String>(
                value: 'togglePinnedFirst',
                checked: _pinnedFirst,
                child: const Text('Pinned first'),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem<String>(enabled: false, child: Text('Theme')),
              ...ThemeMode.values.map(
                (mode) => CheckedPopupMenuItem<String>(
                  value: 'theme:${mode.name}',
                  checked: activeThemeMode == mode,
                  child: Text(_themeLabel(mode)),
                ),
              ),
            ],
            icon: const Icon(Icons.tune),
          ),
        ],
      ),
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
                final allNotes = _sortNotes(box.values.map(Note.fromJson).toList());

                final availableTags = <String>{};
                for (final note in allNotes) {
                  availableTags.addAll(note.tags);
                }
                final sortedTags = availableTags.toList()
                  ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));

                final filteredNotes = allNotes.where((note) {
                  final matchesSearch = _query.isEmpty ||
                      note.title.toLowerCase().contains(_query) ||
                      note.content.toLowerCase().contains(_query);
                  final matchesTag =
                      _activeTag == _allTagsKey || note.tags.contains(_activeTag);
                  return matchesSearch && matchesTag;
                }).toList();

                return Column(
                  children: [
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                      child: Row(
                        children: [
                          TagChip(
                            label: 'All',
                            selected: _activeTag == _allTagsKey,
                            onTap: () => setState(() => _activeTag = _allTagsKey),
                          ),
                          ...sortedTags.map(
                            (tag) => TagChip(
                              label: tag,
                              selected: _activeTag == tag,
                              onTap: () => setState(() => _activeTag = tag),
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (filteredNotes.isEmpty)
                      Expanded(
                        child: EmptyNotesState(
                          message: _query.isEmpty && _activeTag == _allTagsKey
                              ? 'No notes yet. Tap + to add your first note.'
                              : 'No notes matched your filters.',
                        ),
                      )
                    else
                      Expanded(
                        child: ListView.separated(
                          itemCount: filteredNotes.length,
                          separatorBuilder: (_, __) => const Divider(height: 1),
                          itemBuilder: (context, index) {
                            final note = filteredNotes[index];
                            final noteColor =
                                note.getColor() ?? Theme.of(context).cardColor;

                            return Dismissible(
                              key: ValueKey(note.id),
                              direction: DismissDirection.horizontal,
                              background: Container(
                                color: Colors.green,
                                alignment: Alignment.centerLeft,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: Row(
                                  children: [
                                    Icon(
                                      note.isPinned
                                          ? Icons.push_pin_outlined
                                          : Icons.push_pin,
                                      color: Colors.white,
                                    ),
                                    const SizedBox(width: 8),
                                    Text(
                                      note.isPinned ? 'Unpin' : 'Pin',
                                      style:
                                          const TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              secondaryBackground: Container(
                                color: Colors.red,
                                alignment: Alignment.centerRight,
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 16),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Icon(Icons.delete, color: Colors.white),
                                    SizedBox(width: 8),
                                    Text(
                                      'Delete',
                                      style: TextStyle(color: Colors.white),
                                    ),
                                  ],
                                ),
                              ),
                              confirmDismiss: (direction) => _handleSwipeAction(
                                direction,
                                note,
                                storageService,
                              ),
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: noteColor,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: ListTile(
                                  title: Text(
                                    note.title.isEmpty ? 'Untitled' : note.title,
                                  ),
                                  subtitle: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        note.content,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      if (note.tags.isNotEmpty)
                                        Padding(
                                          padding:
                                              const EdgeInsets.only(top: 6),
                                          child: Wrap(
                                            children: note.tags
                                                .map(
                                                  (tag) => Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                      right: 6,
                                                    ),
                                                    child: Text(
                                                      '#$tag',
                                                      style: TextStyle(
                                                        color: Theme.of(context)
                                                            .colorScheme
                                                            .primary,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ),
                                                )
                                                .toList(),
                                          ),
                                        ),
                                    ],
                                  ),
                                  leading: IconButton(
                                    tooltip:
                                        note.isPinned ? 'Unpin note' : 'Pin note',
                                    icon: Icon(
                                      note.isPinned
                                          ? Icons.push_pin
                                          : Icons.push_pin_outlined,
                                      size: 18,
                                    ),
                                    onPressed: () async {
                                      await storageService.togglePin(note);
                                      if (mounted) {
                                        _showMessage(
                                          note.isPinned
                                              ? 'Note unpinned'
                                              : 'Note pinned',
                                        );
                                      }
                                    },
                                  ),
                                  onTap: () {
                                    Navigator.of(context).push(
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            AddEditNoteScreen(note: note),
                                      ),
                                    );
                                  },
                                  onLongPress: () =>
                                      _showColorPicker(note, storageService),
                                  trailing: IconButton(
                                    icon: const Icon(Icons.delete_outline),
                                    onPressed: () async {
                                      await storageService.deleteNote(note.id);
                                      if (mounted) {
                                        _showMessage('Note deleted');
                                      }
                                    },
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
                      ),
                  ],
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
