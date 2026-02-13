# Project Brief: NDT-ToolKit

## Core Identity

**Project Name:** NDT-ToolKit (calculator_app)  
**Version:** 1.0.3+4  
**Description:** Professional NDT tools and calculators for pipeline integrity inspection  
**Platform:** Flutter (iOS, Android, Web - Progressive Web App)  
**Target Users:** Pipeline inspection professionals, NDT technicians  

## Project Branches & Deployments

### Main Branch (Integrity Specialists - Company Internal)
- **Firebase Project:** integrity-tools
- **URL:** https://integrity-tools.web.app
- **For:** Internal company use by Integrity Specialists employees

### ndt-toolkit Branch (NDT-ToolKit - General Market)
- **Firebase Project:** ndt-toolkit  
- **URL:** https://ndt-toolkit.web.app
- **Storage Bucket:** ndt-toolkit.appspot.com
- **Support:** ndt-toolkit-support@gmail.com
- **For:** General market release without company-specific branding

**⚠️ Always verify which branch you're on before making changes or deployments!**

## Core Objectives

1. **Offline-First Calculators:** Provide reliable NDT calculation tools that work without internet
2. **AI-Powered Defect Analysis:** Leverage Vertex AI with context caching for rapid, cost-effective defect assessment
3. **Professional Workflow:** Method hours tracking, inspection reports, job location management
4. **Knowledge Access:** Centralized NDT procedures, formulas, terminology, safety guidelines
5. **Cross-Platform:** Seamless experience on mobile, tablet, desktop, and web

## Key Requirements

- All calculator tools must work offline
- AI analysis must be fast (<10s with cache) and cost-effective (<$0.01 per analysis)
- User authentication with role-based access (users vs admins)
- Firebase backend for real-time data sync
- Progressive Web App with install prompts and auto-updates
- Responsive design with 1200px breakpoint
- Firebase Analytics tracking for all major user interactions

## Critical Rules

- **Never commit/push** until instructed
- **Always bump versions** (service-worker.js + pubspec.yaml) before deployment
- Use internal state management in MainScreen, NOT Navigator.pushNamed()
- Update firestore.rules when adding Firestore collections
- Add analytics tracking for new user features
- Test on both mobile and desktop layouts
- Follow existing file organization structure

## Success Metrics

- Performance: FCP < 1.8s, FID < 100ms, LCP < 2.5s
- AI Cost: < $0.005 per defect analysis
- AI Speed: < 10s with cache (18x faster than cold start)
- Offline Capability: 100% of calculator tools
- Cross-Platform: iOS, Android, Web support

## Brand Identity

- **Colors:** Navy Blue (#1b325b), Gold (#fbcd0f)
- **Tagline:** "Professional NDT Tools & Calculators"
- **Package ID:** com.ndttoolkit.app
- **Design:** Clean, modern, professional with cards and subtle shadows
