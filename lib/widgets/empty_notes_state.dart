import 'package:flutter/material.dart';

class EmptyNotesState extends StatelessWidget {
  final String message;

  const EmptyNotesState({
    super.key,
    this.message = 'No notes yet. Tap + to add your first note.',
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(
        message,
        textAlign: TextAlign.center,
      ),
    );
  }
}
