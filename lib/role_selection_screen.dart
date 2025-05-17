import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:legal_dost/main.dart';
import 'LawyerRegistrationScreen.dart';
import 'package:legal_dost/services/database_service.dart';
import 'package:legal_dost/services/auth_service.dart';
import 'package:shared_preferences/shared_preferences.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  final DatabaseService _databaseService = DatabaseService();
  static const _buttonPadding = EdgeInsets.symmetric(horizontal: 50, vertical: 15);
  static const _buttonTextStyle = TextStyle(fontSize: 18, color: Colors.white);
  static const _buttonShape = RoundedRectangleBorder(
    borderRadius: BorderRadius.all(Radius.circular(30)),
  );

  void _navigateToScreen(BuildContext context, String role) async {
    try {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      String? uid = AuthService().getCurrentUserUid();
      if (uid == null) {
        throw Exception('User not authenticated');
      }
      await _databaseService.saveUserRole(uid, role);

      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setBool('hasCompletedRoleSelection', true);

      await Future.delayed(const Duration(seconds: 2));

      Navigator.pop(context);
      if (role == 'user') {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => HomeScreen(
              role: 'user',
              // onLanguageChange is now optional, so we don't need to pass it
            ),
          ),
        );
      } else if (role == 'lawyer') {
        await _databaseService.saveLawyerRegistrationStatus(uid, false);
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => const LawyerRegistrationScreen(),
          ),
        );
      }
    } catch (e) {
      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error navigating: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.appTitle),
        centerTitle: true,
        backgroundColor: Colors.teal,
        elevation: 4,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade100, Colors.white],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Select Your Role',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.teal,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: () => _navigateToScreen(context, 'user'),
                style: ElevatedButton.styleFrom(
                  padding: _buttonPadding,
                  shape: _buttonShape,
                  backgroundColor: Colors.teal,
                  elevation: 5,
                ),
                child: Text(
                  localizations.userRole,
                  style: _buttonTextStyle,
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () => _navigateToScreen(context, 'lawyer'),
                style: ElevatedButton.styleFrom(
                  padding: _buttonPadding,
                  shape: _buttonShape,
                  backgroundColor: Colors.teal.shade700,
                  elevation: 5,
                ),
                child: Text(
                  localizations.lawyerRole,
                  style: _buttonTextStyle,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}