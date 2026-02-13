# Active Context: NDT-ToolKit

## Current Work Focus

**Status:** Memory Bank Initialization  
**Date:** February 12, 2026  
**Branch:** ndt-toolkit (General Market Release)  
**Version:** 1.0.3+4

This is the **initial memory bank creation**. The project is feature-complete and deployed. The memory bank has been established to provide comprehensive context for future development sessions.

## Recent Changes

### February 12, 2026 - Memory Bank Initialized
- Created complete memory bank structure with all core files
- Documented project architecture, patterns, and technical stack
- Established baseline for future development work

### Prior to Memory Bank (From Documentation)
- Added Critical Angle Calculator to Snell's Law Suite (3 calculators total)
- Implemented Vertex AI context caching for defect analysis (18x speed, 95% cost reduction)
- Added photo-based defect identification with Gemini Vision API
- Deployed Terms of Service & Privacy Policy system with consent tracking
- Implemented Firebase Performance Monitoring across web and mobile
- Created server-side Excel export for method hours tracking
- Email verification system with grandfathering (cutoff: Feb 12, 2026)

## Next Steps

### Immediate Priorities
1. **No active development** - Project is stable and deployed
2. **Monitor feedback** - Check feedback submissions for user requests
3. **Track analytics** - Review Firebase Analytics for usage patterns
4. **Bug fixes** - Address any issues reported by users

### Future Enhancements (When Requested)
- Additional calculators based on user feedback
- Enhanced AI models with improved accuracy
- Mobile app store releases (iOS App Store, Google Play)
- Real-time collaboration features
- Advanced analytics dashboard for admins
- Integration with external systems (ERP, reporting tools)

## Active Decisions & Considerations

### Architecture Decisions
✅ **Use internal state in MainScreen** - NOT Navigator.pushNamed()  
✅ **All calculators must be offline-capable** - Pure Dart logic only  
✅ **Singleton services** - Consistent pattern across codebase  
✅ **Vertex AI caching** - 72-hour TTL for cost optimization  
✅ **Grandfathering users** - Email verification only for new users (post Feb 12, 2026)

### Deployment Decisions
✅ **Version bump required before every deployment** - pubspec.yaml + service-worker.js  
✅ **Let programmer do all testing** - No automated testing in place  
✅ **Never commit without instruction** - Programmer controls git workflow  
✅ **Branch-specific Firebase projects** - main (integrity-tools) vs ndt-toolkit (ndt-toolkit)

### Design Decisions
✅ **1200px responsive breakpoint** - Drawer (desktop) vs bottom nav (mobile)  
✅ **Navy blue + gold brand colors** - Consistent across all UI  
✅ **Category-specific colors** - Visual organization for tool categories  
✅ **Clean white AppBars** - No gradients for professional look

## Important Patterns & Preferences

### Code Organization
```
lib/
├── calculators/     # Pure Dart, offline-capable tools
├── models/          # Data structures (Firestore documents)
├── screens/         # Full-page UI components
├── services/        # Business logic (singletons)
├── theme/           # AppTheme with brand identity
├── widgets/         # Reusable UI components
└── utils/           # Helper functions
```

### Naming Conventions
- **Screens:** `*_screen.dart` (e.g., `defect_analyzer_screen.dart`)
- **Widgets:** `*_widget.dart` or descriptive names (e.g., `app_drawer.dart`)
- **Services:** `*_service.dart` (e.g., `analytics_service.dart`)
- **Models:** Singular noun (e.g., `defect_entry.dart`)
- **Calculators:** `*_calculator.dart` (e.g., `pit_depth_calculator.dart`)

### Analytics Pattern
**Always log events** for major user interactions:
```dart
// Screen views
AnalyticsService().logScreenView('screen_name');

// Feature usage
AnalyticsService().logEvent('action_name', {
  'parameter': 'value',
  'user_type': 'authenticated'
});
```

### Error Handling
- Try-catch blocks for async operations
- User-friendly error messages (SnackBar)
- Log errors to console (web) or Crashlytics (mobile)
- Graceful degradation for network failures

## Learnings & Project Insights

### What Works Well
1. **Offline-first calculators** - Users love the reliability in field conditions
2. **Vertex AI caching** - Dramatic speed and cost improvements (18x faster, 95% cheaper)
3. **Progressive Web App** - Install prompts and auto-updates provide native-like experience
4. **Responsive design** - Single codebase works seamlessly across mobile, tablet, desktop
5. **Firebase integration** - Real-time sync, easy authentication, scalable backend
6. **Service layer pattern** - Clean separation of concerns, testable business logic

### Challenges & Solutions

**Challenge:** AI analysis was too slow (90s per defect)  
**Solution:** Implemented Vertex AI context caching → 5-10s with cache hit (18x faster)

**Challenge:** AI costs were unsustainable at scale  
**Solution:** Context caching reduced cost from $0.10 to $0.005 per analysis (95% reduction)

**Challenge:** Users couldn't use app offline  
**Solution:** Made all calculators pure Dart, added service worker for web caching

**Challenge:** Email verification disrupted existing users  
**Solution:** Grandfathering system - only new users (after Feb 12, 2026) require verification

**Challenge:** Web users not getting updates  
**Solution:** Version-controlled service worker + aggressive auto-update notification

**Challenge:** Navigator.pushNamed() broke state persistence  
**Solution:** Internal state management in MainScreen with _selectedIndex

### Performance Insights
- **Service worker caching** dramatically improves load times for repeat visits
- **Lazy loading** keeps initial bundle size reasonable
- **Image compression** essential for mobile data usage
- **Firestore indexes** required for complex queries to maintain speed
- **Context caching** makes AI features viable for production use

### Cost Optimization
- **Vertex AI caching** is the most impactful optimization (95% cost reduction)
- **Firebase Free Tier** sufficient for moderate usage (Auth, Firestore, Analytics)
- **Blaze Plan** required for Cloud Functions and Vertex AI
- **Storage costs** minimal with image compression
- **Functions costs** low due to infrequent invocations (defect analysis only)

### User Behavior Insights
- **Most Used Tools** section is heavily utilized (8 core calculators)
- **AI features** gaining adoption as users discover them
- **Offline mode** critical for field technicians in remote locations
- **Knowledge Base** valuable for reference and training
- **Method Hours tracking** streamlines workflow and reporting

## Current Technical State

### Stability
- ✅ No known critical bugs
- ✅ All features functioning as designed
- ✅ Performance metrics meeting targets
- ✅ AI costs within acceptable range
- ✅ User feedback generally positive

### Monitoring
- ✅ Firebase Analytics tracking all major events
- ✅ Firebase Performance monitoring page loads
- ✅ Crashlytics active on mobile (console errors on web)
- ✅ Cloud Functions logging execution and errors

### Deployment
- ✅ Web: https://ndt-toolkit.web.app (live and stable)
- ✅ Firebase Functions: All deployed and operational
- ✅ Service worker: v1.0.3+4 (auto-updates working)
- ❌ Mobile stores: Not yet published (iOS App Store, Google Play)

## Dependencies & Integrations

### External Services
- **Firebase (Google Cloud)** - Core backend infrastructure
- **Vertex AI (Google Cloud)** - AI-powered defect analysis and photo identification
- **Gemini 2.5 Flash** - Language model for defect analysis
- **Gemini Vision API** - Image analysis for photo identification

### Third-Party Packages
- **Syncfusion** - PDF viewing and manipulation (commercial license)
- **Material Design** - UI components and icons
- **Hive** - Local database for coordinates logger

### API Integrations
- **None** - All functionality self-contained or Firebase-based
- Future potential: ERP systems, third-party reporting tools

## Constraints & Limitations

### Technical Constraints
- **Web PWA limitations** - No background sync, limited file access
- **Mobile permissions** - Camera, location, storage require user approval
- **Firebase query limitations** - No OR queries, complex filtering challenging
- **Vertex AI rate limits** - 60 requests/minute (sufficient for current usage)

### Business Constraints
- **Two separate Firebase projects** - main branch vs ndt-toolkit branch
- **Manual deployments** - No CI/CD pipeline
- **No automated testing** - Relies on programmer manual testing
- **Version bumps manual** - Easy to forget, critical for PWA updates

### Resource Constraints
- **Single developer** - Limited parallel work capacity
- **Manual QA** - No dedicated testing team
- **No CI/CD** - All builds and deployments manual

## Questions & Uncertainties

### Open Questions
1. Should we pursue iOS App Store and Google Play releases?
2. Is current analytics tracking sufficient for business decisions?
3. Do we need automated testing before adding more features?
4. Should we implement localization (Spanish, other languages)?
5. Is the current state management (setState) scalable long-term?

### Areas Needing Investigation
- User adoption rates for AI features (usage analytics)
- Performance bottlenecks at scale (load testing)
- Cost projections for increased user base
- Competitive analysis (similar NDT tools)
- Mobile app store requirements and review process

## Communication Preferences

### Workflow Expectations
- **Never commit/push** until explicitly instructed
- **Let programmer test** all changes before deployment
- **Ask for clarification** when requirements are ambiguous
- **Document all changes** in commit messages
- **Update memory bank** when significant patterns emerge

### Code Review Preferences
- Clean, readable code with comments for complex logic
- Follow existing patterns and conventions
- Analytics tracking for new features
- Responsive design considerations
- Offline capability for calculators

---

**Note:** This activeContext.md will be updated as new work progresses. It represents the current state and immediate focus of development.
