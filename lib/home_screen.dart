import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'quiz_screen.dart'; // Import QuizScreen
import 'legal_aid_screen.dart'; // Import LegalAidScreen
import 'file_case_screen.dart'; // Import FileCaseScreen
import 'hire_lawyer_screen.dart'; // Import HireLawyerScreen
import 'legal_suggestion_screen.dart'; // Import LegalSuggestionScreen
import 'package:legal_dost/services/auth_service.dart'; // Import AuthService for logout

class HomeScreen extends StatelessWidget {
  final Function(String) onLanguageChange;

  const HomeScreen({super.key, required this.onLanguageChange});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final AuthService _authService = AuthService(); // For logout functionality

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'profile':
                // Navigate to profile screen (placeholder logic)
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Profile screen not implemented yet')),
                  );
                  break;
                case 'language':
                // Toggle language between English and Hindi
                  String newLanguage = Localizations.localeOf(context).languageCode == 'en' ? 'hi' : 'en';
                  onLanguageChange(newLanguage);
                  break;
                case 'logout':
                // Perform logout
                  _authService.signOut().then((_) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text(localizations.loggedOutSuccessfully)),
                    );
                  });
                  break;
                case 'contact':
                // Show contact developer dialog
                  showDialog(
                    context: context,
                    builder: (context) => AlertDialog(
                      title: Text(localizations.contactDeveloper),
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
                          child: Text(localizations.ok),
                        ),
                      ],
                    ),
                  );
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
                    Text(localizations.profile), // Assuming 'profile' is defined in AppLocalizations
                  ],
                ),
              ),
              PopupMenuItem<String>(
                value: 'language',
                child: Row(
                  children: [
                    const Icon(Icons.language, color: Colors.teal),
                    const SizedBox(width: 8),
                    Text(localizations.language), // Assuming 'language' is defined in AppLocalizations
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
                    Text(localizations.contactDeveloper), // Assuming 'contactDeveloper' is defined
                  ],
                ),
              ),
            ],
            icon: const Icon(Icons.more_vert), // Three-dot menu icon
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              localizations.welcomeMessage,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildFeatureButton(
              context,
              icon: Icons.quiz,
              title: localizations.takeQuiz,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QuizScreen()),
                );
              },
            ),
            _buildFeatureButton(
              context,
              icon: Icons.gavel,
              title: localizations.fileCase,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const FileCaseScreen()),
                );
              },
            ),
            _buildFeatureButton(
              context,
              icon: Icons.people,
              title: localizations.hireALawyer,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const HireLawyerScreen()),
                );
              },
            ),
            _buildFeatureButton(
              context,
              icon: Icons.info,
              title: localizations.legalAid,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LegalAidScreen()),
                );
              },
            ),
            _buildFeatureButton(
              context,
              icon: Icons.lightbulb,
              title: localizations.getLegalAdvice,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const LegalSuggestionScreen()),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFeatureButton(BuildContext context,
      {required IconData icon, required String title, required VoidCallback onTap}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon),
        label: Text(title, style: const TextStyle(fontSize: 18)),
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}