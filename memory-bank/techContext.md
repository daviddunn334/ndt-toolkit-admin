# Tech Context: NDT-ToolKit

## Technologies Used

### Frontend Framework
- **Flutter SDK:** 3.0+ (Dart language)
- **Platform Support:** iOS, Android, Web (PWA)
- **UI Framework:** Material Design with custom theme
- **State Management:** StatefulWidget with setState (internal state)

### Backend Services (Firebase)
- **Firebase Core:** 2.25.4 - Firebase initialization
- **Firebase Auth:** 4.17.4 - Email/password authentication
- **Cloud Firestore:** 4.15.5 - NoSQL database, real-time sync
- **Firebase Storage:** 11.6.6 - File/image storage
- **Cloud Functions:** 4.6.6 - Serverless backend (Node.js/TypeScript)
- **Firebase Analytics:** 10.8.0 - User behavior tracking
- **Firebase Crashlytics:** 3.4.9 - Crash reporting (mobile only)
- **Firebase Performance:** 0.9.4+1 - Performance monitoring

### AI & ML
- **Vertex AI (Gemini 2.5 Flash):** Defect analysis with context caching
- **Gemini Vision API:** Photo-based defect identification
- **Context Caching:** 72-hour cache for PDFs, 18x speed improvement

### Key Packages

#### PDF & Document Processing
- `syncfusion_flutter_pdfviewer: ^27.2.5` - PDF viewing
- `syncfusion_flutter_pdf: ^27.2.5` - PDF manipulation
- `pdf: ^3.11.3` - PDF generation
- `excel: ^2.1.0` - Excel file generation/parsing

#### File Handling
- `file_picker: ^6.1.1` - File selection
- `image_picker: ^1.0.7` - Camera/gallery image selection
- `path_provider: ^2.1.2` - Local file paths
- `share_plus: ^7.2.1` - Native sharing

#### Storage & Persistence
- `hive: ^2.2.3` - Local NoSQL database (coordinates logger)
- `hive_flutter: ^1.1.0` - Hive Flutter integration
- `shared_preferences: ^2.2.2` - Key-value storage

#### Networking & Connectivity
- `http: ^1.1.0` - HTTP requests
- `connectivity_plus: ^5.0.2` - Network status detection
- `url_launcher: ^6.2.4` - Open URLs, emails, phone calls

#### UI Components
- `flutter_svg: ^2.0.9` - SVG rendering
- `table_calendar: ^3.0.0` - Calendar widget
- `cupertino_icons: ^1.0.2` - iOS-style icons

#### Utilities
- `uuid: ^4.3.3` - Unique ID generation
- `intl: ^0.18.1` - Internationalization and date formatting
- `geolocator: ^11.0.0` - GPS location services

#### Development Tools
- `hive_generator: ^2.0.1` - Code generation for Hive
- `build_runner: ^2.4.8` - Build automation
- `flutter_lints: ^2.0.0` - Linting rules
- `flutter_launcher_icons: ^0.13.1` - App icon generation

## Development Setup

### Prerequisites
```bash
# Required installations
- Flutter SDK 3.0+
- Dart SDK (included with Flutter)
- Node.js 18+ (for Firebase Functions)
- Firebase CLI
- Git

# Recommended IDEs
- Visual Studio Code with Flutter extension
- Android Studio with Flutter plugin
```

### Environment Setup
```bash
# 1. Clone repository
git clone https://github.com/daviddunn334/calculator_app.git
cd calculator_app

# 2. Install Flutter dependencies
flutter pub get

# 3. Install Firebase Functions dependencies
cd functions
npm install
cd ..

# 4. Configure Firebase
# Ensure firebase_options.dart exists (auto-generated)
# Ensure google-services.json (Android) and GoogleService-Info.plist (iOS) are present
```

### Running the App

#### Web (Development)
```bash
flutter run -d chrome
# or
flutter run -d edge
```

#### Mobile (Development)
```bash
# iOS Simulator
flutter run -d ios

# Android Emulator
flutter run -d android

# Physical Device
flutter run
```

#### Web (Production Build)
```bash
# Build for web
flutter build web --release

# Deploy to Firebase Hosting
firebase deploy --only hosting
```

### Firebase Functions Development
```bash
cd functions

# Local emulation
npm run serve

# Deploy to Firebase
firebase deploy --only functions

# View logs
firebase functions:log
```

## Technical Constraints

### Platform Limitations

**Web (PWA):**
- Firebase Crashlytics not supported (using console.error instead)
- Limited access to device hardware (camera, GPS)
- Service worker caching required for offline functionality
- Browser security restrictions on file access

**Mobile (iOS/Android):**
- Platform-specific permissions (camera, storage, location)
- App store review requirements
- Code signing and provisioning profiles
- Platform-specific UI adaptations

**Cross-Platform:**
- Responsive breakpoint at 1200px
- Conditional rendering for platform-specific features
- Platform detection using `kIsWeb` constant

### Firebase Limitations

**Firestore:**
- Query limitations (no OR queries, limited array operations)
- Index creation required for complex queries
- Offline persistence limits (40MB web, larger on mobile)
- Security rules can't perform complex joins

**Storage:**
- File size limits (5GB per file in Storage)
- Bandwidth costs for file downloads
- No server-side file processing (use Cloud Functions)

**Cloud Functions:**
- Cold start latency (2-5s for first invocation)
- Timeout limits (60s for HTTP, 540s for background)
- Memory limits (default 256MB, max 8GB)
- Node.js environment (TypeScript transpiled)

**Vertex AI:**
- API rate limits (60 requests/minute for Gemini)
- Context cache TTL (72 hours max)
- Token limits (input + output combined)
- Regional availability (us-central1)

### Performance Constraints

**Target Metrics:**
- First Contentful Paint (FCP): < 1.8s
- First Input Delay (FID): < 100ms
- Largest Contentful Paint (LCP): < 2.5s
- Time to Interactive (TTI): < 3.5s

**Optimization Strategies:**
- Service worker caching for static assets
- Lazy loading for heavy screens
- Image compression (max 1MB)
- Debouncing for search inputs
- Pagination for large lists

## Development Workflow

### Branch Strategy
```
main (production)
└── develop (staging)
    └── feature/* (feature branches)
```

### Version Control
- **Format:** MAJOR.MINOR.PATCH+BUILD (e.g., 1.0.3+4)
- **Version Bump Required:** Before every deployment
- **Files to Update:** `pubspec.yaml` + `web/service-worker.js`

### Testing Strategy
```bash
# Unit tests
flutter test

# Widget tests
flutter test test/widget_test.dart

# Integration tests (if implemented)
flutter drive --target=test_driver/app.dart
```

**Current State:** Minimal automated testing. Relying on manual testing by programmer.

### Deployment Process
```bash
# 1. Version bump (CRITICAL)
# - Update pubspec.yaml version
# - Update web/service-worker.js CACHE_VERSION

# 2. Build
flutter build web --release

# 3. Test locally
firebase serve --only hosting

# 4. Deploy
firebase deploy --only hosting,functions

# 5. Verify
# - Check https://ndt-toolkit.web.app
# - Test auto-update notification
# - Verify calculator functionality
# - Check Firebase Console for errors
```

## Configuration Files

### firebase.json
```json
{
  "hosting": {
    "public": "build/web",
    "ignore": ["firebase.json", "**/.*", "**/node_modules/**"],
    "rewrites": [{"source": "**", "destination": "/index.html"}],
    "headers": [/* CORS and caching headers */]
  },
  "functions": {
    "source": "functions",
    "predeploy": ["npm --prefix functions run build"]
  }
}
```

### firestore.rules
Security rules for all collections:
- Users can read/write their own data
- Admins have elevated permissions
- Cloud Functions can update AI analysis fields
- Public read for defect types and news (authenticated users)

### firestore.indexes.json
Required composite indexes:
- `defect_entries`: userId (ASC) + createdAt (DESC)
- `photo_identifications`: userId (ASC) + createdAt (DESC)
- `method_hours`: userId (ASC) + date (DESC)

### pubspec.yaml
- App identity (name, version, description)
- Dependencies and dev dependencies
- Asset declarations (images, templates)
- App icon configuration

## Tool Usage Patterns

### Firebase CLI
```bash
# Login
firebase login

# Initialize project
firebase init

# Deploy everything
firebase deploy

# Deploy specific targets
firebase deploy --only hosting
firebase deploy --only functions
firebase deploy --only firestore:rules

# View logs
firebase functions:log
```

### Flutter CLI
```bash
# Get dependencies
flutter pub get

# Clean build
flutter clean

# Build for web
flutter build web --release

# Build for mobile
flutter build apk --release  # Android
flutter build ios --release  # iOS

# Analyze code
flutter analyze

# Format code
dart format .
```

### Git Workflow
```bash
# Check current branch
git branch

# Create feature branch
git checkout -b feature/new-calculator

# Commit changes
git add .
git commit -m "Add new calculator"

# Push to remote
git push origin feature/new-calculator

# Merge (after review)
git checkout develop
git merge feature/new-calculator
```

## Security Considerations

### Firebase Security Rules
- Authenticate all sensitive operations
- Validate data types and required fields
- Use server timestamp for createdAt/updatedAt
- Limit query results with `limit()`

### API Keys
- **Public API Keys:** Safe to commit (restricted by Firebase)
- **Service Account Keys:** NEVER commit, use environment variables
- **Vertex AI Keys:** Server-side only in Cloud Functions

### User Data Privacy
- Terms of Service and Privacy Policy required
- User consent tracking (`termsAcceptedAt`)
- Account deletion functionality
- GDPR compliance considerations

## Monitoring & Debugging

### Firebase Console
- **Analytics:** User behavior, event tracking, conversion funnels
- **Crashlytics:** Crash reports, stack traces (mobile only)
- **Performance:** Page load times, network requests, custom traces
- **Functions Logs:** Execution logs, errors, performance

### Browser DevTools (Web)
- **Console:** Error messages, analytics events
- **Network:** API calls, response times
- **Application:** Service worker status, cache storage
- **Performance:** Lighthouse scores, runtime performance

### Flutter DevTools
- **Widget Inspector:** UI hierarchy and layout debugging
- **Timeline:** Frame rendering performance
- **Memory:** Memory usage and leaks
- **Network:** HTTP requests and responses

## Known Technical Debt

1. **Limited Test Coverage:** Need unit and integration tests
2. **Hard-coded Strings:** Should use localization (i18n)
3. **Manual Version Bumping:** Could automate with CI/CD
4. **No CI/CD Pipeline:** All deployments manual
5. **Inline Styles:** Some UI code could be extracted to theme
6. **Error Handling:** Could be more comprehensive and user-friendly

## Future Technical Improvements

- Implement comprehensive test suite
- Add localization support (English, Spanish)
- Set up CI/CD pipeline (GitHub Actions)
- Migrate to Riverpod for state management
- Implement code coverage tracking
- Add A/B testing framework
- Enhance offline data sync strategies
