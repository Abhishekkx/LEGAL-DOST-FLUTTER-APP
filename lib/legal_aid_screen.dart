import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:url_launcher/url_launcher.dart';

class LegalAidScreen extends StatelessWidget {
  const LegalAidScreen({super.key});

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    try {
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri);
      } else {
        throw Exception('Could not launch $url');
      }
    } catch (e) {
      // Handle errors gracefully
      debugPrint('Error launching URL: $e');
    }
  }

  Widget _buildSectionCard(String title, List<Widget> children) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
            ),
            const SizedBox(height: 10),
            ...children,
          ],
        ),
      ),
    );
  }

  Widget _buildPoint(String title, {String? description, String? url, String? phone}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text("• ", style: TextStyle(fontSize: 18)),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (url != null)
                  InkWell(
                    onTap: () => _launchURL(url),
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 16, color: Colors.teal, decoration: TextDecoration.underline),
                    ),
                  )
                else if (phone != null)
                  InkWell(
                    onTap: () => _launchURL("tel:$phone"),
                    child: Text(
                      title,
                      style: const TextStyle(fontSize: 16, color: Colors.teal, decoration: TextDecoration.underline),
                    ),
                  )
                else
                  Text(
                    title,
                    style: const TextStyle(fontSize: 16),
                  ),
                if (description != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    description,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.legalAidUpdates),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Legal Aid Types Section
            _buildSectionCard(
              localizations.typesOfLegalAid,
              [
                _buildPoint(
                  localizations.freeLegalServices,
                  description: localizations.freeLegalServicesDescription,
                ),
                _buildPoint(
                  localizations.legalAidClinics,
                  description: localizations.legalAidClinicsDescription,
                ),
                _buildPoint(localizations.helplines),
                _buildPoint(
                  localizations.nationalLegalHelpline,
                  phone: '15100',
                ),
                _buildPoint(
                  localizations.womenHelpline,
                  phone: '181',
                ),
                _buildPoint(
                  localizations.childHelpline,
                  phone: '1098',
                ),
                _buildPoint(
                  localizations.publicInterestLitigation,
                  description: localizations.publicInterestLitigationDescription,
                ),
                _buildPoint(
                  localizations.ngoSupport,
                  description: localizations.ngoSupportDescription,
                  url: 'https://www.cry.org',
                ),
              ],
            ),

            // Procedure to Get Legal Aid Section
            _buildSectionCard(
              localizations.howToGetLegalAid,
              [
                _buildPoint(
                  localizations.verifyEligibility,
                  description: localizations.verifyEligibilityDescription,
                ),
                _buildPoint(
                  localizations.approachLegalServicesAuthority,
                  description: localizations.approachLegalServicesAuthorityDescription,
                ),
                _buildPoint(
                  localizations.submitApplication,
                  description: localizations.submitApplicationDescription,
                ),
                _buildPoint(
                  localizations.legalAidAssignment,
                  description: localizations.legalAidAssignmentDescription,
                ),
                _buildPoint(
                  localizations.followUp,
                  description: localizations.followUpDescription,
                ),
              ],
            ),

            // Official Resources Section
            _buildSectionCard(
              localizations.officialResources,
              [
                ElevatedButton(
                  onPressed: () => _launchURL('https://nalsa.gov.in/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    localizations.nalsaWebsite,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: () => _launchURL('https://www.mha.gov.in/'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                  ),
                  child: Text(
                    localizations.ministryOfHomeAffairs,
                    style: const TextStyle(fontSize: 16),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}