# FlowSense Flutter App

Water monitoring mobile application built with Flutter.

## Setup

1. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

2. **Generate Hive adapters:**
   ```bash
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

3. **Run the app:**
   ```bash
   flutter run
   ```

## Configuration

### API Base URL

Default: `http://143.198.227.148/api`

To override:
```bash
flutter run --dart-define=API_BASE_URL=https://your-domain.com/api
```

Or build with:
```bash
flutter build apk --dart-define=API_BASE_URL=https://your-domain.com/api
```

## Features

- **Home Screen**: Guardian status dashboard
- **Upload Screen**: Bill photo/document upload with manual entry
- **Leak Check**: 5-step wizard for leak detection
- **History**: Timeline of bills and leak checks
- **Settings**: Demo mode, privacy settings, backend configuration
- **Find Plumber**: Location-based plumber finder

## Building

### Android APK
```bash
flutter build apk --release
```

### iOS
```bash
flutter build ios --release
```

## Dependencies

- `flutter_riverpod` - State management
- `go_router` - Navigation
- `dio` - HTTP client
- `hive` - Local storage
- `image_picker` - Camera/gallery access
- `geolocator` - Location services
- `url_launcher` - External links (phone, maps)


