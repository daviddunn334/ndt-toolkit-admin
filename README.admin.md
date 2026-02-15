# NDT-ToolKit Admin Panel

This is the administrative dashboard for NDT-ToolKit. It provides tools for managing users, analytics, feedback, and system content.

## 🔐 Access

- **URL**: https://admin.ndt-toolkit.com
- **Access**: Requires administrator privileges
- **Authentication**: Firebase Auth with admin flag verification

## 🚀 Deployment

The admin panel is automatically deployed to Firebase Hosting when changes are pushed to the `main` branch via GitHub Actions.

### Manual Deployment

```bash
# Install dependencies
flutter pub get

# Build the web app
flutter build web --release

# Deploy to Firebase
firebase deploy --only hosting:admin
```

## 📁 Project Structure

```
lib/
├── screens/admin/          # Admin screens
│   ├── admin_main_screen.dart
│   ├── analytics_screen.dart
│   ├── user_management_screen.dart
│   ├── employee_management_screen.dart
│   ├── feedback_management_screen.dart
│   ├── pdf_management_screen.dart
│   └── admin_reports_screen.dart
├── services/              # Service layer
│   ├── admin_metrics_service.dart
│   ├── analytics_service.dart
│   └── ... (shared services)
├── widgets/              # Reusable widgets
│   └── admin_drawer.dart
└── main.dart            # Admin-specific entry point
```

## 🔧 Configuration

### Firebase Setup

The admin panel uses the same Firebase project as the main app:
- **Project ID**: ndt-toolkit
- **Hosting Site**: admin-ndt-toolkit
- **Domain**: admin.ndt-toolkit.com

### GitHub Secrets

Required secrets for GitHub Actions deployment:
- `FIREBASE_SERVICE_ACCOUNT` - Firebase service account JSON

## 👥 Admin Features

- **User Management**: View and manage user accounts
- **Employee Management**: Manage employee records
- **Analytics Dashboard**: View app usage and metrics
- **Feedback Management**: Review and respond to user feedback
- **PDF Management**: Upload and manage reference PDFs
- **Reports**: Generate and view system reports

## 🛠️ Development

### Prerequisites

- Flutter SDK (stable channel)
- Firebase CLI
- Git

### Local Development

```bash
# Clone the repository
git clone https://github.com/daviddunn334/ndt-toolkit-admin.git
cd ndt-toolkit-admin

# Install dependencies
flutter pub get

# Run the app
flutter run -d chrome
```

### Testing Admin Access

To test admin functionality:
1. Ensure your user account has `isAdmin: true` in Firestore
2. Sign in through the login screen
3. You'll be granted access to the admin panel

## 🔗 Related Repositories

- **Main App**: https://github.com/daviddunn334/ndt-toolkit
- **Marketing Site**: https://github.com/daviddunn334/ndt-toolkit-marketing

## 📝 Notes

- This repo shares Firebase configuration with the main app
- Services and models are duplicated from the main repo for independence
- Changes to shared code should be synchronized manually if needed

## 🆘 Support

For issues or questions, contact the development team.
