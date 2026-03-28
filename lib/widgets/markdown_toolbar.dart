import 'package:flutter/material.dart';

class MarkdownToolbar extends StatelessWidget {
  final VoidCallback onBold;
  final VoidCallback onItalic;
  final VoidCallback onCode;
  final VoidCallback onList;
  final VoidCallback onHeading;

  const MarkdownToolbar({
    super.key,
    required this.onBold,
    required this.onItalic,
    required this.onCode,
    required this.onList,
    required this.onHeading,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          IconButton(
            tooltip: 'Bold',
            icon: const Icon(Icons.format_bold),
            onPressed: onBold,
          ),
          IconButton(
            tooltip: 'Italic',
            icon: const Icon(Icons.format_italic),
            onPressed: onItalic,
          ),
          IconButton(
            tooltip: 'Code',
            icon: const Icon(Icons.code),
            onPressed: onCode,
          ),
          IconButton(
            tooltip: 'Bullet list',
            icon: const Icon(Icons.format_list_bulleted),
            onPressed: onList,
          ),
          IconButton(
            tooltip: 'Heading',
            icon: const Icon(Icons.title),
            onPressed: onHeading,
          ),
        ],
      ),
    );
  }
}
