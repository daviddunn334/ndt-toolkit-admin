# System Patterns: NDT-ToolKit

## Architecture Overview

### High-Level Architecture
```
┌─────────────────────────────────────────────────────────┐
│                    Flutter Frontend                      │
│  (iOS, Android, Web - Progressive Web App)              │
│                                                          │
│  ┌─────────────┐  ┌─────────────┐  ┌─────────────┐   │
│  │  Screens    │  │  Widgets    │  │ Calculators │   │
│  │  (UI)       │  │ (Reusable)  │  │  (Offline)  │   │
│  └──────┬──────┘  └──────┬──────┘  └──────┬──────┘   │
│         │                 │                 │          │
│  ┌──────▼─────────────────▼─────────────────▼──────┐  │
│  │              Services Layer                      │  │
│  │  Auth │ Firestore │ Analytics │ Performance     │  │
│  └──────┬───────────────────────────────────────────┘  │
└─────────┼─────────────────────────────────────────────┘
          │
          ▼
┌─────────────────────────────────────────────────────────┐
│                   Firebase Backend                       │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐  ┌────────┐ │
│  │   Auth   │  │Firestore │  │ Storage  │  │Functions││
│  └──────────┘  └──────────┘  └──────────┘  └────────┘ │
│                                                          │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐             │
│  │Analytics │  │ Vertex AI│  │Crashlytics│            │
│  └──────────┘  └──────────┘  └──────────┘             │
└─────────────────────────────────────────────────────────┘
```

## Key Design Patterns

### 1. Service Layer Pattern
All business logic encapsulated in service classes (singletons):

```dart
// Example: AnalyticsService (Singleton)
class AnalyticsService {
  static final AnalyticsService _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  
  Future<void> logEvent(String name, Map<String, dynamic>? params);
  Future<void> setUserProperty(String name, String value);
}
```

**Services:**
- `AuthService` - Authentication + email verification
- `AnalyticsService` - Firebase Analytics wrapper
- `PerformanceService` - Performance monitoring
- `DefectService` - Defect CRUD + AI analysis
- `DefectIdentifierService` - Photo upload + identification
- `OfflineService` - Connectivity detection
- `UpdateService` - PWA update detection
- `OnboardingService` - User tour management

### 2. State Management: Internal State
**Critical Pattern:** MainScreen uses internal `_selectedIndex` state, NOT Navigator.pushNamed()

```dart
class MainScreen extends StatefulWidget {
  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;  // Internal navigation state
  
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  
  // Render different screens based on index
  Widget _getScreen() {
    switch (_selectedIndex) {
      case 0: return HomeScreen(...);
      case 1: return MostUsedToolsScreen(...);
      // ... 14 total screens
    }
  }
}
```

**Why:** Maintains single app shell, preserves state, faster navigation, cleaner back button handling

### 3. Offline-First Calculators
All calculators are pure Dart logic with no network dependencies:

```dart
// Example: Calculator Pattern
class PitDepthCalculator extends StatefulWidget {
  @override
  _PitDepthCalculatorState createState() => _PitDepthCalculatorState();
}

class _PitDepthCalculatorState extends State<PitDepthCalculator> {
  // Local state only - no services, no async
  double _outerDiameter = 0;
  double _nominalWallThickness = 0;
  
  double _calculatePitDepth() {
    // Pure calculation logic
    return /* formula */;
  }
}
```

### 4. Vertex AI Context Caching
**Pattern:** Cache expensive PDF embeddings for 72 hours

```
First Analysis (Cold Start):
User → Cloud Function → Upload PDFs to Vertex AI → Generate Cache → Analyze → Return
Time: ~90s | Cost: ~$0.10

Subsequent Analyses (Cache Hit):
User → Cloud Function → Reuse Cache → Analyze → Return
Time: ~5-10s | Cost: ~$0.005

18x faster, 95% cost reduction
```

**Implementation:**
- Client-specific caches: `/procedure_caches/{clientName}`
- Singleton cache for photo ID: `/defect_identifier_cache/defectidentifiertool`
- MD5 hash validation for cache freshness
- Automatic invalidation on PDF changes (Storage triggers)

### 5. Progressive Web App (PWA) Auto-Updates
**Pattern:** Aggressive version-controlled cache updates

```dart
// web/service-worker.js
const CACHE_VERSION = 'v1.0.3+4';  // MUST match pubspec.yaml

// On activate: Delete old caches
self.addEventListener('activate', (event) => {
  event.waitUntil(
    caches.keys().then((cacheNames) => {
      return Promise.all(
        cacheNames.filter(name => name !== CACHE_VERSION)
                  .map(name => caches.delete(name))
      );
    })
  );
});
```

**User Experience:**
1. Service worker detects new version
2. AutoUpdateOverlay shows with countdown (5s)
3. User clicks "Update Now" or waits for auto-reload
4. Page reloads with new cache

### 6. Authentication Flow with Grandfathering
**Pattern:** Email verification required for NEW users only

```dart
// Cutoff date: February 12, 2026
final cutoffDate = DateTime(2026, 2, 12);
final accountCreated = user.metadata.creationTime;

if (accountCreated != null && accountCreated.isBefore(cutoffDate)) {
  // Grandfathered user - skip verification
  return MainScreen();
}

if (!user.emailVerified) {
  // New user - require verification
  return EmailVerificationScreen();
}
```

**Why:** Protects existing users from disruption while enforcing security for new signups

### 7. Responsive Layout Pattern
**Breakpoint:** 1200px for desktop/tablet vs mobile

```dart
Widget build(BuildContext context) {
  final isDesktop = MediaQuery.of(context).size.width >= 1200;
  
  return Scaffold(
    drawer: isDesktop ? _buildDrawer() : null,
    bottomNavigationBar: isDesktop ? null : _buildBottomNav(),
    body: /* content */,
  );
}
```

### 8. Analytics Tracking Pattern
**Consistent event logging** for all major user interactions:

```dart
// Screen views
AnalyticsService().logScreenView('defect_analyzer');

// Feature usage
AnalyticsService().logEvent('calculator_used', {
  'calculator_name': 'Pit Depth Calculator',
  'user_type': 'authenticated'
});

// AI operations
AnalyticsService().logEvent('ai_defect_analyzed', {
  'client_name': clientName,
  'cache_hit': cacheExists,
  'analysis_time_ms': duration
});
```

## Component Relationships

### Navigation Hierarchy
```
MainScreen (Root)
├─ HomeScreen (Index 0)
├─ MostUsedToolsScreen (Index 1) ⭐
│  ├─ ABS + ES Calculator
│  ├─ Pit Depth Calculator
│  ├─ Time Clock Calculator
│  └─ ... 5 more
├─ ToolsScreen (Index 2) - NDT Tools
│  ├─ Beam Geometry (Category)
│  ├─ Snell's Law Suite (Category)
│  │  ├─ Snell's Law Calculator
│  │  ├─ Mode Conversion Calculator
│  │  └─ Critical Angle Calculator
│  └─ ... 11 more categories
├─ MapsScreen (Index 3)
├─ MethodHoursScreen (Index 4)
├─ KnowledgeBaseScreen (Index 5)
├─ ProfileScreen (Index 6)
├─ InventoryScreen (Index 7)
├─ CompanyDirectoryScreen (Index 8)
├─ NewsUpdatesScreen (Index 9)
├─ EquotipDataConverter (Index 10)
├─ FeedbackScreen (Index 11)
├─ DefectAnalyzerScreen (Index 12) - AI
└─ DefectIdentifierScreen (Index 13) - AI Photo
```

### Data Flow: Defect Analysis
```
1. User fills form in DefectAnalyzerScreen
2. DefectService.createDefect() → Firestore write
3. Cloud Function triggered on document create
4. Function checks for cache → Vertex AI analysis
5. Function updates Firestore with results
6. StreamBuilder in UI receives update
7. UI shows color-coded severity and recommendations
```

### Data Flow: Photo Identification
```
1. User captures/uploads photo in DefectIdentifierScreen
2. DefectIdentifierService.uploadAndIdentify()
3. Photo → Firebase Storage
4. Firestore document created (status: processing)
5. Cloud Function triggered → Vertex AI Vision
6. Function updates Firestore with results
7. StreamBuilder updates UI with top 3 matches
```

## Critical Implementation Paths

### Path 1: Version Bump for Deployment
```
1. Update web/service-worker.js → CACHE_VERSION
2. Update pubspec.yaml → version: X.X.X+Y
3. Commit: "Bump version to X.X.X+Y for [feature]"
4. Push → Merge → Deploy
```

**⚠️ Skipping version bump = No auto-updates for web users**

### Path 2: Adding New Calculator
```
1. Create calculator file in lib/calculators/
2. Add to MostUsedToolsScreen OR ToolsScreen
3. Ensure offline capability (no async calls)
4. Add analytics tracking
5. Test on mobile and desktop layouts
6. Update documentation
```

### Path 3: Adding New Firestore Collection
```
1. Define data model in lib/models/
2. Create service in lib/services/
3. Update firestore.rules for security
4. Add indexes if querying (firestore.indexes.json)
5. Add analytics events for CRUD operations
6. Test security rules in Firebase Console
```

### Path 4: AI Feature with Caching
```
1. Define Storage path for reference files
2. Create Firestore cache collection
3. Write Cloud Function with cache logic
4. Add Storage trigger for cache invalidation
5. Test cache hit/miss scenarios
6. Monitor cost and performance
```

## Anti-Patterns to Avoid

❌ **Don't use Navigator.pushNamed() in MainScreen** → Use internal state  
❌ **Don't forget version bumps** → Web users won't get updates  
❌ **Don't add async calls to calculators** → Breaks offline capability  
❌ **Don't skip analytics tracking** → Lose usage insights  
❌ **Don't commit without testing** → Let programmer test first  
❌ **Don't deploy without security rules** → Data exposure risk  
❌ **Don't hardcode Firebase config** → Use firebase_options.dart  

## Performance Considerations

- **Lazy Loading:** Load screens only when navigated to
- **Image Optimization:** Compress before upload (max 1MB)
- **Cache Strategy:** Service worker caches static assets
- **Firestore Queries:** Index frequently queried fields
- **AI Optimization:** Vertex AI caching for repeated operations
- **Bundle Size:** Tree-shaking eliminates unused code
