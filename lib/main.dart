import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'screens/notes_list_screen.dart';
import 'services/notes_storage_service.dart';
import 'theme/theme_controller.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox<Map>(NotesStorageService.boxName);
  final settingsBox = await Hive.openBox(ThemeController.settingsBoxName);
  final themeController = ThemeController(settingsBox);
  runApp(NotesApp(themeController: themeController));
}

class NotesApp extends StatelessWidget {
  final ThemeController themeController;

  const NotesApp({super.key, required this.themeController});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeController,
      builder: (context, themeMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'Notes App',
          themeMode: themeMode,
          theme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
          ),
          darkTheme: ThemeData(
            useMaterial3: true,
            colorSchemeSeed: Colors.indigo,
            brightness: Brightness.dark,
          ),
          home: NotesListScreen(themeController: themeController),
        );
      },
    );
  }
}
