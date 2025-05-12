# PawPals Firebase Setup

This guide will help you set up the Firebase backend for the PawPals app.

## Prerequisites

- A Firebase account (sign up at [firebase.google.com](https://firebase.google.com) if you don't have one)
- An existing Firebase project (as shown in your screenshot)
- Flutter and Dart installed on your development machine

## Setup Steps

### 1. Add Firebase to Your Flutter App

#### Install the FlutterFire CLI

The FlutterFire CLI is a tool that helps you configure Firebase for your Flutter apps.

```bash
dart pub global activate flutterfire_cli
```

#### Configure Firebase for Your Flutter App

Run the following command in your project directory:

```bash
flutterfire configure --project=pawpals
```

This will:
- Select your Firebase project
- Configure platforms (Android, iOS, web, etc.)
- Generate the necessary configuration files

### 2. Update Dependencies in pubspec.yaml

Add the following Firebase dependencies to your `pubspec.yaml` file:

```yaml
dependencies:
  # Firebase core
  firebase_core: ^2.25.4
  
  # Authentication
  firebase_auth: ^4.17.4
  
  # Cloud Firestore (database)
  cloud_firestore: ^4.15.4
  
  # Firebase Storage (for images)
  firebase_storage: ^11.6.5
  
  # Firebase Analytics (optional)
  firebase_analytics: ^10.8.5
```

Then run:

```bash
flutter pub get
```

### 3. Initialize Firebase in Your App

Update your `lib/main.dart` file to initialize Firebase:

```dart
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  
  runApp(const PawPalsApp());
}
```

### 4. Set Up Firebase Authentication

1. In the Firebase console, go to Authentication > Sign-in method
2. Enable Email/Password authentication
3. Optionally enable other providers (Google, Facebook, etc.)

### 5. Set Up Cloud Firestore

1. In the Firebase console, go to Firestore Database
2. Click "Create database"
3. Choose either production mode or test mode (you can change this later)
4. Select a location for your database

#### Create Firestore Collections

Create the following collections:

- `users` - for user profiles
- `dogs` - for dog profiles
- `playdates` - for scheduling playdates
- `places` - for dog-friendly places
- `appointments` - for vet appointments and other events
- `meal_plans` - for dog meal plans

### 6. Set Up Firebase Storage

1. In the Firebase console, go to Storage
2. Click "Get started"
3. Choose your security rules (start with test mode for development)
4. Create the following folders:
   - `profile-pictures` - for user profile images
   - `dog-pictures` - for dog profile images
   - `place-pictures` - for place images

### 7. Configure Security Rules

#### Firestore Security Rules

Go to Firestore Database > Rules and update with:

```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // Users collection
    match /users/{userId} {
      allow read: if request.auth != null && request.auth.uid == userId;
      allow create: if request.auth != null && request.auth.uid == userId;
      allow update: if request.auth != null && request.auth.uid == userId;
      allow delete: if request.auth != null && request.auth.uid == userId;
    }
    
    // Dogs collection
    match /dogs/{dogId} {
      allow read: if request.auth != null;
      allow create: if request.auth != null && request.resource.data.ownerId == request.auth.uid;
      allow update, delete: if request.auth != null && resource.data.ownerId == request.auth.uid;
    }
    
    // Places collection
    match /places/{placeId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // Other collections follow similar patterns
    // Add more rules as needed
  }
}
```

#### Storage Security Rules

Go to Storage > Rules and update with:

```
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /profile-pictures/{userId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == userId;
    }
    
    match /dog-pictures/{ownerId}/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null && request.auth.uid == ownerId;
    }
    
    match /place-pictures/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## Testing Your Setup

1. Run your Flutter app
2. Try to sign up for a new account
3. If the signup is successful, check your Firebase Authentication console to see if a new user was created

## Troubleshooting

- If you encounter authentication issues, check the Firebase Authentication logs in the console
- Make sure your app has internet permissions in the Android and iOS configuration files
- Verify that your Firebase configuration files are correctly set up
- Check the Firebase console for any error messages or warnings
