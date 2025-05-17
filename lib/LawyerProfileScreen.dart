import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:legal_dost/services/database_service.dart';
import 'package:legal_dost/services/auth_service.dart';
// import 'chat_screen.dart'; // No longer needed

class LawyerProfileScreen extends StatelessWidget {
  final String uid;
  final bool fromSearch;

  const LawyerProfileScreen({super.key, required this.uid, this.fromSearch = false});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final DatabaseService databaseService = DatabaseService();

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.lawyerProfile),
        backgroundColor: Colors.teal,
        centerTitle: true,
        actions: fromSearch
            ? [
          IconButton(
            icon: const Icon(Icons.chat, color: Colors.white),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(localizations.chatComingSoon),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            tooltip: localizations.chatWithLawyer,
          ),
        ]
            : null,
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: databaseService.getLawyerProfile(uid),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Profile not found'));
          }

          final profile = snapshot.data!;
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundImage: profile['profileImageUrl'] != null && profile['profileImageUrl'].isNotEmpty
                      ? NetworkImage(profile['profileImageUrl'])
                      : null,
                  child: profile['profileImageUrl'] == null || profile['profileImageUrl'].isEmpty
                      ? const Icon(Icons.person, size: 50, color: Colors.teal)
                      : null,
                ),
                const SizedBox(height: 12),
                Text(
                  profile['name'] ?? 'Not specified',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: Colors.teal,
                  ),
                ),
                const SizedBox(height: 20),
                Card(
                  elevation: 3,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      children: [
                        _buildProfileField(Icons.email, localizations.email, profile['email']),
                        _buildProfileField(Icons.work, localizations.experienceYears, profile['experience']),
                        _buildProfileField(Icons.star, localizations.expertise, profile['expertise']),
                        _buildProfileField(Icons.location_on, localizations.state, profile['state']),
                        _buildProfileField(Icons.map, localizations.district, profile['district']),
                        _buildProfileField(Icons.info, localizations.bio, profile['bio']),
                      ],
                    ),
                  ),
                ),
                if (!fromSearch && uid == AuthService().getCurrentUserUid()) const SizedBox(height: 24),
                if (!fromSearch && uid == AuthService().getCurrentUserUid())
                  ElevatedButton(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(localizations.chatComingSoon),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 24),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: Text(
                      localizations.chatWithLawyer,
                      style: const TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileField(IconData icon, String label, dynamic value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.teal, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 2),
                Text(
                  value ?? 'Not specified',
                  style: const TextStyle(fontSize: 16, color: Colors.black87),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}