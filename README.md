# Trestle

A modern Flutter note-taking application with AppWrite backend integration.

## 🚀 Features

- **Create & Edit Notes** - Build notes with text and image blocks
- **Reorderable Content** - Drag-and-drop text/image blocks to customize layout
- **Cloud Sync** - AppWrite backend for persistent storage (free tier available)
- **Modern UI/UX** - Material Design 3 components, floating action buttons
- **Responsive Layout** - Works on mobile and tablet devices

## 🏗️ Project Structure

```
lib/
├── main.dart              # App entry point
├── screens/
│   ├── home_page.dart    # Note list & FAB navigation
│   └── edit_document_page.dart  # Document editor
├── widgets/
│   ├── note_card.dart        # Note item in list
│   └── image_block.dart      # Image widget with options
└── services/
    └── appwrite_service.dart # AppWrite backend integration
```

## 📦 Setup & Installation

### Prerequisites
- Flutter SDK >= 3.24.0
- Dart SDK >= 3.9.0

### Get Dependencies
```bash
flutter pub get
```

### Run the App
```bash
# For mobile/web/desktop
flutter run

# Specific platforms
flutter run -d chrome    # Web browser
flutter run -d windows   # Desktop Windows
```

## 🔧 Development Commands

```bash
# Hot reload
flutter run

# Format code
dart format .

# Run tests
flutter test

# Analyze code
flutter analyze
```

## 📱 Supported Platforms

- Android
- iOS  
- Web (Chrome/Firefox/Safari)
- Windows / macOS / Linux

## 🌐 Backend Setup (AppWrite)

1. Create free account at [appwrite.io](https://appwrite.io)
2. Create a project
3. Configure database: `trestle_notes`, collection: `trestle_docs`
4. Update `lib/services/appwrite_service.dart` with your endpoint

## 📝 License

MIT License - See LICENSE file for details

## 👤 Author

Marc Velasquez | [GitHub Profile](https://github.com/marccodesstuff)

---

*Built with ❤️ using Flutter & AppWrite*
