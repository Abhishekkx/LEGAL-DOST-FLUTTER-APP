import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class FileCaseScreen extends StatefulWidget {
  const FileCaseScreen({super.key});

  @override
  State<FileCaseScreen> createState() => _FileCaseScreenState();
}

class _FileCaseScreenState extends State<FileCaseScreen> {
  String _selectedState = 'Delhi'; // Default state

  // State-specific E-FIR URLs and instructions
  final Map<String, Map<String, String>> _stateEfirData = {
    'Delhi': {
      'url': 'https://delhipolice.gov.in/',
      'steps': '1. Click “Citizen Services” and choose complaint option.\n2. Register with name, email, and mobile.\n3. Fill and submit the form.\n4. Receive confirmation via email.',
    },
    'Maharashtra': {
      'url': 'https://mumbaipolice.gov.in/',
      'steps': '1. Fill the online complaint form with details.\n2. Verify with OTP sent to email.\n3. Submit and get a complaint/FIR number.',
    },
    'West Bengal': {
      'url': 'https://wbpolice.gov.in/',
      'steps': '1. Click “Report a Crime” tab.\n2. Fill complainant and incident details.\n3. Submit and receive confirmation via email.',
    },
    'Tamil Nadu': {
      'url': 'https://eservices.tnpolice.gov.in/CCTNSNICSDC/ComplaintRegistrationPage',
      'steps': '1. Click “Register online complaints”.\n2. Fill the complaint form.\n3. Submit with security code and get email confirmation.',
    },
    'Jharkhand': {
      'url': 'https://jofs.jhpolice.gov.in/',
      'steps': '1. Click the “Complaint” tab.\n2. Provide details and verify with OTP.\n3. Submit the FIR.',
    },
    'Haryana': {
      'url': 'https://haryanapolice.gov.in/',
      'steps': '1. Find “Inform Police” tab.\n2. Fill incident description and details.\n3. Submit the online complaint.',
    },
    'Madhya Pradesh': {
      'url': 'https://mppolice.gov.in/en',
      'steps': '1. Click “Report Online” under “Information to Police”.\n2. Select crime type and fill details.\n3. Submit the online report.',
    },
  };

  // Helper function to map state names to localized strings
  String getLocalizedStateName(AppLocalizations localizations, String state) {
    switch (state) {
      case 'Delhi':
        return localizations.delhi;
      case 'Maharashtra':
        return localizations.maharashtra;
      case 'West Bengal':
        return localizations.westBengal;
      case 'Tamil Nadu':
        return localizations.tamilNadu;
      case 'Jharkhand':
        return localizations.jharkhand;
      case 'Haryana':
        return localizations.haryana;
      case 'Madhya Pradesh':
        return localizations.madhyaPradesh;
      default:
        return state; // Fallback to the raw state name if no localization is found
    }
  }

  // Launch URL function
  Future<void> _launchURL(String url) async {
    final uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  // Make phone call function
  Future<void> _makePhoneCall(String number) async {
    final uri = Uri.parse('tel:$number');
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not make call to $number');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    // Get screen width and apply consistent padding
    final screenWidth = MediaQuery.of(context).size.width;
    const cardPadding = 32.0; // Total padding (16.0 on left + 16.0 on right)
    final cardWidth = screenWidth - cardPadding;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.fileYourCase),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: cardWidth,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.fileEFIR,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                      const SizedBox(height: 10),
                      DropdownButton<String>(
                        value: _selectedState,
                        hint: Text(localizations.selectState),
                        isExpanded: true, // Extend the dropdown to full width
                        items: _stateEfirData.keys.map((String state) {
                          return DropdownMenuItem<String>(
                            value: state,
                            child: Text(getLocalizedStateName(localizations, state)),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setState(() {
                            _selectedState = newValue!;
                          });
                        },
                      ),
                      const SizedBox(height: 10),
                      Text(
                        localizations.efirSteps,
                        style: const TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _stateEfirData[_selectedState]!['steps']!,
                        style: const TextStyle(fontSize: 14),
                      ),
                      const SizedBox(height: 10),
                      Center(
                        child: ElevatedButton(
                          onPressed: () => _launchURL(_stateEfirData[_selectedState]!['url']!),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                          child: Text(localizations.visitWebsite),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: cardWidth,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.reportCyberCrime,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(Icons.web),
                        title: Text(localizations.nationalCyberPortal),
                        subtitle: Text(localizations.cyberCrimePortal),
                        onTap: () => _launchURL('https://cybercrime.gov.in/'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.local_police),
                        title: Text(localizations.reportLocalPolice),
                        subtitle: Text(localizations.emailSP),
                        onTap: () {},
                      ),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: Text(localizations.emergencyHelpline),
                        subtitle: Text(localizations.emergencyNumber),
                        onTap: () => _makePhoneCall('100'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: cardWidth,
              child: Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        localizations.emergencyNumbers,
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                      ),
                      const SizedBox(height: 10),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: Text(localizations.policeEmergency),
                        onTap: () => _makePhoneCall('100'),
                      ),
                      ListTile(
                        leading: const Icon(Icons.phone),
                        title: Text(localizations.allIndiaHelpline),
                        onTap: () => _makePhoneCall('112'),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        localizations.writtenComplaint,
                        style: const TextStyle(fontSize: 16),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}