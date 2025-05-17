import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'legal_info_screen.dart';
import 'quiz_screen.dart';
import 'legal_aid_screen.dart';
import 'file_case_screen.dart';
import 'legal_suggestion_screen.dart';
import 'hire_lawyer_screen.dart';
import 'role_selection_screen.dart';
import 'LawyerRegistrationScreen.dart';
import 'LawyerProfileScreen.dart';
import 'auth_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:legal_dost/services/database_service.dart';
import 'package:legal_dost/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const LegalDostApp());
}

class LegalDostApp extends StatefulWidget {
  const LegalDostApp({super.key});

  @override
  State<LegalDostApp> createState() => _LegalDostAppState();
}

class _LegalDostAppState extends State<LegalDostApp> {
  late Locale _locale = const Locale('en');

  void _changeLanguage(String languageCode) {
    setState(() {
      _locale = Locale(languageCode);
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Legal Dost',
      theme: ThemeData(
        primarySwatch: Colors.teal,
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.teal,
          elevation: 4,
          centerTitle: true,
        ),
        textTheme: const TextTheme(
          headlineMedium: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.teal,
          ),
          bodyMedium: TextStyle(
            fontSize: 16,
            color: Colors.black87,
          ),
        ),
      ),
      locale: _locale,
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [
        Locale('en'),
        Locale('hi'),
      ],
      home: StreamBuilder(
        stream: AuthService().authStateChanges,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasData) {
            return RoleBasedNavigation(uid: snapshot.data!.uid);
          }
          return const AuthScreen();
        },
      ),
    );
  }
}

class RoleBasedNavigation extends StatelessWidget {
  final String uid;

  const RoleBasedNavigation({super.key, required this.uid});

  @override
  Widget build(BuildContext context) {
    DatabaseService databaseService = DatabaseService();

    return FutureBuilder(
      future: Future.wait([
        SharedPreferences.getInstance(),
        databaseService.getUserRole(uid),
        databaseService.getLawyerRegistrationStatus(uid) ?? Future.value(false),
      ]),
      builder: (context, AsyncSnapshot<List<dynamic>> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        SharedPreferences prefs = snapshot.data![0] as SharedPreferences;
        String? role = snapshot.data![1] as String?;
        bool isLawyerRegistered = snapshot.data![2] as bool? ?? false;

        bool hasCompletedRoleSelection = prefs.getBool('hasCompletedRoleSelection') ?? false;

        if (!hasCompletedRoleSelection) {
          databaseService.resetUserData(uid);
          return const RoleSelectionScreen();
        }

        if (role != null) {
          final onLanguageChange = (String languageCode) {
            _LegalDostAppState? state = context.findAncestorStateOfType<_LegalDostAppState>();
            state?._changeLanguage(languageCode);
          };

          if (role == 'user') {
            return HomeScreen(
              role: 'user',
              onLanguageChange: onLanguageChange,
            );
          } else if (role == 'lawyer') {
            if (isLawyerRegistered) {
              return HomeScreen(
                role: 'lawyer',
                onLanguageChange: onLanguageChange,
              );
            } else {
              return const LawyerRegistrationScreen();
            }
          }
        }
        return const RoleSelectionScreen();
      },
    );
  }
}

class HomeScreen extends StatefulWidget {
  final String role;
  final Function(String) onLanguageChange;

  const HomeScreen({
    super.key,
    required this.role,
    this.onLanguageChange = _defaultLanguageChange,
  });

  static void _defaultLanguageChange(String languageCode) {}

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _showWelcome = true;
  final AuthService _authService = AuthService();

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showWelcome = false;
        });
      }
    });
  }

  void _navigateToProfile() {
    if (widget.role == 'lawyer') {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => LawyerProfileScreen(uid: AuthService().getCurrentUserUid()!)),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User profile screen not implemented yet')),
      );
    }
  }

  void _logout() async {
    await _authService.signOut();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(AppLocalizations.of(context)!.loggedOutSuccessfully)),
    );
  }

  void _contactDeveloper() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(AppLocalizations.of(context)!.contactDeveloper),
        content: const Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Name: Abhishek'),
            SizedBox(height: 8),
            Text('Email: aabhishekk920@gmail.com'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(AppLocalizations.of(context)!.ok),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    final List<Widget> tiles = [
      FeatureTile(
        title: localizations.legalInformation,
        icon: Icons.book,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LegalInfoScreen()),
          );
        },
      ),
      FeatureTile(
        title: localizations.quizzes,
        icon: Icons.quiz,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const QuizScreen()),
          );
        },
      ),
      FeatureTile(
        title: localizations.legalAidUpdates,
        icon: Icons.update,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LegalAidScreen()),
          );
        },
      ),
      FeatureTile(
        title: localizations.fileYourCase,
        icon: Icons.edit_document,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const FileCaseScreen()),
          );
        },
      ),
      FeatureTile(
        title: localizations.getLegalSuggestions,
        icon: Icons.lightbulb,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const LegalSuggestionScreen()),
          );
        },
      ),
      FeatureTile(
        title: localizations.hireLawyer,
        icon: Icons.person,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const HireLawyerScreen()),
          );
        },
      ),
    ];

    if (widget.role == 'lawyer') {
      tiles.add(
        FeatureTile(
          title: 'View Profile',
          icon: Icons.account_circle,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => LawyerProfileScreen(uid: AuthService().getCurrentUserUid()!)),
            );
          },
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                  _navigateToProfile();
                  break;
                case 'language':
                  String currentLanguage = Localizations.localeOf(context).languageCode;
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(localizations.language),
                      content: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          RadioListTile<String>(
                            title: const Text('English'),
                            value: 'en',
                            groupValue: currentLanguage,
                            onChanged: (value) {
                              if (value != null) {
                                widget.onLanguageChange(value);
                                Navigator.pop(context);
                              }
                            },
                          ),
                          RadioListTile<String>(
                            title: const Text('हिन्दी'),
                            value: 'hi',
                            groupValue: currentLanguage,
                            onChanged: (value) {
                              if (value != null) {
                                widget.onLanguageChange(value);
                                Navigator.pop(context);
                              }
                            },
                          ),
                        ],
                      ),
                      actions: [
                        TextButton(
                          onPressed: () => Navigator.pop(context),
                          child: Text(localizations.cancel),
                        ),
                      ],
                    ),
                  );
                  break;
                case 'logout':
                  _logout();
                  break;
                case 'contact':
                  _contactDeveloper();
                  break;
              }
            },
            itemBuilder: (BuildContext context) => <PopupMenuEntry<String>>[
              PopupMenuItem<String>(
                value: 'profile',
                child: Row(
                  children: [
                    const Icon(Icons.account_circle, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(localizations.profile),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'language',
                child: Row(
                  children: [
                    const Icon(Icons.language, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(localizations.language),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'logout',
                child: Row(
                  children: [
                    const Icon(Icons.logout, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(localizations.logout),
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'contact',
                child: Row(
                  children: [
                    const Icon(Icons.email, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(localizations.contactDeveloper),
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert, color: Colors.white),
          ),
          const SizedBox(width: 16),
        ],
      ),
      body: Stack(
        children: [
          AnimatedOpacity(
            opacity: _showWelcome ? 0.0 : 1.0,
            duration: const Duration(milliseconds: 500),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 16,
                mainAxisSpacing: 16,
                children: tiles,
              ),
            ),
          ),
          AnimatedOpacity(
            opacity: _showWelcome ? 1.0 : 0.0,
            duration: const Duration(milliseconds: 500),
            child: Center(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                  borderRadius: BorderRadius.circular(15),
                  border: Border.all(color: Colors.teal, width: 3),
                ),
                padding: const EdgeInsets.all(20),
                child: Text(
                  localizations.welcomeMessage,
                  style: const TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class FeatureTile extends StatelessWidget {
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  const FeatureTile({
    super.key,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 50, color: Colors.teal),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}