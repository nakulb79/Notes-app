import 'package:flutter/material.dart';

class NotesSearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;

  const NotesSearchBar({
    super.key,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
      child: TextField(
        onChanged: onChanged,
        decoration: const InputDecoration(
          hintText: 'Search notes...',
          prefixIcon: Icon(Icons.search),
          border: OutlineInputBorder(),
        ),
      ),
    );
  }
}
