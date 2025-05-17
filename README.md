Legal Dost
Overview
Legal Dost is a pioneering legal tech platform designed to democratize access to legal services for students, citizens, and law professionals in India and beyond. Founded by Abhishek Kumar, Legal Dost addresses the fragmentation in existing legal tech solutions by offering an all-in-one Android app that integrates legal information, AI-driven guidance, case management, and lawyer connections. Built with Flutter and Firebase, the app provides a lightweight, user-friendly experience, making legal support accessible, affordable, and efficient. Our mission is to bridge the gap between legal needs and technology, empowering users with tools for education, crime reporting, case tracking, and professional legal assistance.
Problem Statement
The legal tech landscape is riddled with fragmented solutions that offer limited functionality—static law databases, legal news, or basic AI chatbots—leaving users without a comprehensive platform. Victims struggle to report crimes or connect with verified lawyers, students lack engaging legal education tools, and citizens face barriers to affordable legal support. Legal Dost solves these challenges by providing a unified, intuitive app that combines essential legal services, enhancing accessibility and inclusivity for diverse users.
Key Features
Legal Dost offers a robust set of features to address diverse legal needs:
Current Features

Legal Information Access: Quick access to laws, rights, and procedures for informed decision-making.
Interactive Quizzes: Engaging quizzes to help law students build and test legal knowledge.
e-FIR Filing: Streamlined digital filing of First Information Reports (FIRs) for efficient crime reporting.
Case Management: Tools to organize and track small case assignments within the app.
Lawyer Marketplace: Connects users with verified lawyers based on expertise, location, and experience.
AI-Driven Legal Suggestions: Personalized legal guidance powered by AI for quick, relevant advice.
User and Lawyer Role Selection: Tailored experience based on user roles (student, citizen, lawyer).
Lawyer Registration System: Lawyers register with details (name, email, expertise, state, district, bio) for credibility.
Firebase Integration: Real-time data management for seamless performance and updates.
Flutter-Based Development: Lightweight, cross-platform app for a smooth user experience.
Small App Size: Compact design for easy downloads on low-storage devices.
User-Friendly Interface: Intuitive navigation for students, citizens, and professionals.

Planned Features

Premium AI Features: Enhanced AI-driven responses for subscribers seeking faster, more accurate guidance.
Multilingual Interface: Support for multiple languages to expand accessibility across diverse markets.
Advertising and Partnerships: Integration of targeted ads from legal firms and law schools for revenue and user benefits.

Tech Stack

Frontend: Flutter (Dart) for cross-platform mobile development with a responsive, intuitive UI.
Backend: Firebase for real-time database, authentication, and cloud functions.
Database: Firebase Firestore for storing legal information, case data, lawyer profiles, and quiz content.
Authentication: Firebase Authentication for secure user and lawyer login (email/password, role-based).
AI Integration: Planned integration of AI/ML APIs (e.g., NLP models) for advanced legal suggestions.
Tools: Android Studio, VS Code, Git for development and version control.
Dependencies:
flutter_bloc for state management.
firebase_core, firebase_auth, cloud_firestore for backend services.
http for future API integrations.
shared_preferences for local storage.



Project Structure
legal-dost/
├── android/                # Android-specific configurations
├── ios/                    # iOS-specific configurations (planned)
├── lib/                    # Flutter source code
│   ├── core/               # Constants, utilities, and app-wide configurations
│   │   ├── constants/      # API endpoints, app constants
│   │   └── utils/          # Helper functions, validators
│   ├── data/               # Data layer (Firebase services, repositories)
│   │   ├── models/         # Data models (User, Lawyer, Case, Quiz)
│   │   └── services/       # Firebase and API integration
│   ├── domain/             # Business logic (use cases, BLoC)
│   │   ├── blocs/          # State management logic
│   │   └── usecases/       # Feature-specific business rules
│   ├── presentation/       # UI layer (screens, widgets)
│   │   ├── screens/        # Main screens (Home, e-FIR, Marketplace)
│   │   └── widgets/        # Reusable UI components
│   └── main.dart           # App entry point
├── test/                   # Unit and widget tests
├── pubspec.yaml            # Flutter dependencies
├── README.md               # Project documentation

Installation
Prerequisites

Flutter SDK (v3.10.0 or higher)
Dart (v3.0 or higher)
Android Studio or VS Code
Firebase account and project
Git

Setup Instructions

Install Dependencies:
flutter pub get


Configure Firebase:

Create a Firebase project at console.firebase.google.com.
Add an Android app and download the google-services.json file.
Place google-services.json in android/app.
Enable Firebase Authentication (Email/Password) and Firestore in the Firebase console.


Run the App:
flutter run

Use an Android emulator or physical device.

Build for Release:
flutter build apk --release



Troubleshooting

Execution Policy Error (Windows): If PowerShell blocks virtual environment activation, run:Set-ExecutionPolicy -Scope CurrentUser -ExecutionPolicy RemoteSigned

or bypass for the session:.\venv\Scripts\activate.ps1


Firebase Setup: Ensure google-services.json is correctly placed and Firebase rules are configured for read/write access.

Usage

Onboarding:

Sign up and select a role (student, citizen, lawyer).
Lawyers provide registration details (expertise, location, bio) for verification.


Core Functionalities:

Legal Information: Browse laws and rights via the app’s database.
Quizzes: Take interactive quizzes to test legal knowledge (ideal for law students).
e-FIR Filing: File crime reports digitally with a user-friendly form.
Case Management: Track and manage small cases within the app.
Lawyer Marketplace: Connect with verified lawyers for consultations.
AI Suggestions: Get personalized legal advice powered by AI.


Navigation:

Use the intuitive dashboard to access all features.
Role-based UI ensures relevant tools are prioritized (e.g., quizzes for students, e-FIR for citizens).


Future Features:

Subscribe to premium AI for enhanced guidance.
Access the app in multiple languages (planned).
Engage with targeted ads from legal partners (planned).

Contributing
We welcome contributions to Legal Dost! To contribute:

Fork the repository.
Create a feature branch (git checkout -b feature/your-feature).
Commit changes (git commit -m "Add your feature").
Push to the branch (git push origin feature/your-feature).
Open a pull request with a clear description.

Guidelines

Follow the Flutter Style Guide.
Write clear commit messages (e.g., “Add e-FIR form validation”).
Include unit tests for new features.
Ensure compatibility with Flutter 3.10+ and Firebase.

Testing

Unit Tests: Cover models (User, Lawyer, Case) and services (Firebase CRUD operations).
Widget Tests: Validate UI components (e.g., quiz screen, e-FIR form).
Integration Tests: Test end-to-end flows (e.g., user signup to lawyer connection).
Run tests with:flutter test


Data Privacy

Compliance: Adheres to data privacy laws (e.g., GDPR, India’s DPDP Act) with secure Firebase storage.
Security: Uses Firebase Authentication for secure logins and Firestore rules for access control.
User Trust: Transparent data handling with user consent for AI and marketplace features.

License
This project is licensed under the MIT License. See the LICENSE file for details.
Contact

Email: aabhishekkpers@gmail.com
GitHub Issues: Report bugs or suggest features at GitHub Issues.

Join us in transforming legal access with Legal Dost!
