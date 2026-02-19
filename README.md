# Notes App

A simple and elegant notes management app built with Flutter.

## Features

- ✨ Create, edit, and delete notes
- 💾 Local storage using SharedPreferences
- 📝 Clean and intuitive user interface
- 🕒 Timestamps for note creation and updates
- 📱 Material Design 3 UI

## Getting Started

### Prerequisites

- Flutter SDK (>=3.0.0)
- Dart SDK

### Installation

1. Clone the repository:
```bash
git clone https://github.com/nakulb79/Notes-app.git
cd Notes-app
```

2. Install dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## Running Tests

To run the tests:
```bash
flutter test
```

## Project Structure

```
lib/
├── main.dart                 # App entry point
├── models/
│   └── note.dart            # Note data model
├── screens/
│   ├── notes_list_screen.dart    # Home screen with notes list
│   └── note_editor_screen.dart   # Screen for creating/editing notes
└── services/
    └── notes_service.dart   # Service for managing note storage
```

## Usage

1. **Create a Note**: Tap the "+" floating action button
2. **Edit a Note**: Tap on any note in the list
3. **Delete a Note**: Tap the delete icon on any note
4. **Save a Note**: Tap the checkmark icon in the editor

## Technologies Used

- **Flutter**: Cross-platform UI framework
- **SharedPreferences**: Local data persistence
- **Material Design 3**: Modern UI components

## License

This project is open source and available under the MIT License.
