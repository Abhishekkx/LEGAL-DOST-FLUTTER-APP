import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;
import 'dart:convert';

class LegalSuggestionScreen extends StatefulWidget {
  const LegalSuggestionScreen({super.key});

  @override
  State<LegalSuggestionScreen> createState() => _LegalSuggestionScreenState();
}

class _LegalSuggestionScreenState extends State<LegalSuggestionScreen> {
  final TextEditingController _caseController = TextEditingController();
  final stt.SpeechToText _speech = stt.SpeechToText();
  bool _isListening = false;
  bool _isSpeechInitialized = false;
  String? _suggestionResult;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initSpeech();
  }

  void _initSpeech() async {
    try {
      bool available = await _speech.initialize(
        onStatus: (status) => print('Speech status: $status'),
        onError: (error) => print('Speech error: $error'),
      );
      if (available) {
        setState(() => _isSpeechInitialized = true);
      } else {
        setState(() => _isSpeechInitialized = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(AppLocalizations.of(context)!.speechNotAvailable)),
          );
        }
      }
    } catch (e) {
      setState(() => _isSpeechInitialized = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('${AppLocalizations.of(context)!.speechInitError}: $e')),
        );
      }
    }
  }

  void _startListening() async {
    if (!_isSpeechInitialized) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.speechNotInitialized)),
        );
      }
      return;
    }
    if (!_isListening) {
      setState(() => _isListening = true);
      try {
        await _speech.listen(
          onResult: (result) {
            setState(() {
              _caseController.text = result.recognizedWords;
            });
          },
          listenFor: const Duration(seconds: 30),
          pauseFor: const Duration(seconds: 2),
          partialResults: true,
          localeId: Localizations.localeOf(context).languageCode == 'en' ? 'en_IN' : 'hi_IN',
          cancelOnError: true,
        );
      } catch (e) {
        if (mounted) {
          setState(() => _isListening = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('${AppLocalizations.of(context)!.recordingError}: $e')),
          );
        }
      }
    }
  }

  void _stopListening() {
    if (_isListening) {
      setState(() => _isListening = false);
      _speech.stop();
    }
  }

  Future<void> _submitCase() async {
    String caseText = _caseController.text.trim();
    if (caseText.isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(AppLocalizations.of(context)!.enterCaseDetailsPrompt)),
        );
      }
      return;
    }
    setState(() => _isLoading = true);
    try {
      final response = await _fetchGeminiSuggestion(caseText);
      if (mounted) {
        setState(() {
          _suggestionResult = response;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _suggestionResult = '${AppLocalizations.of(context)!.errorFetching}: $e';
          _isLoading = false;
        });
      }
    }
  }

  Future<String> _fetchGeminiSuggestion(String caseText) async {
    const apiKey = 'AIzaSyAl2ZZno-C2hmXh58-1hHoXAJtUJqLjl3Q'; // Replace with your actual API key
    const apiUrl = 'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    final prompt = '''
You are a legal expert specializing in Indian law. Analyze the case: "$caseText". Provide a structured response with these exact sections, each starting with the heading in bold followed by a colon and concise bullet points on new lines (use "\n" for line breaks). Avoid lengthy paragraphs but ensure each bullet point is at least 2 lines or slightly more explanatory for clarity:
- **Understanding of the Case**: Summarize the situation in 2-3 lines.
- **Laws in Your Favor**: List specific IPC sections or laws with explanations (2 lines each).
- **Laws Against Your Case**: List potential legal challenges, if any (2 lines each).
- **Procedures to Follow**: List 2-3 steps to proceed legally (2 lines each).
- **Actionable Suggestions**: List 2-3 practical steps for the user (2 lines each).
Example format:
- **Understanding of the Case**:\nBag snatched by unknown person in market.\nIncident occurred during daytime with witnesses present.
- **Laws in Your Favor**:\n- Section 379 IPC: Theft, punishable up to 3 years.\nApplies as your bag was stolen without consent.\n- Section 356 IPC: Theft with force, if applicable.\nRelevant if the thief used violence during the act.
- **Laws Against Your Case**:\n- Lack of evidence may weaken your case.\nNo clear identification of the thief could be an issue.
- **Procedures to Follow**:\n- File an FIR at the nearest police station.\nInclude details like time, place, and description of the thief.\n- Provide a detailed incident description to the police.\nMention any witnesses or CCTV footage available.
- **Actionable Suggestions**:\n- Collect witness statements from people nearby.\nTheir testimony can strengthen your case in court.\n- Report immediately to the police for quick action.\nDelays may reduce chances of recovering your bag.
Respond in ${isEnglish ? 'English' : 'Hindi'} and tailor to Indian law. Keep each bullet point concise but explanatory (2-3 lines).
''';
    final requestBody = jsonEncode({
      'contents': [
        {'parts': [{'text': prompt}]}
      ],
      'generationConfig': {
        'temperature': 0.5,
        'topK': 40,
        'topP': 0.95,
        'maxOutputTokens': 512,
      },
    });
    final response = await http.post(
      Uri.parse('$apiUrl?key=$apiKey'),
      headers: {'Content-Type': 'application/json'},
      body: requestBody,
    );
    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final generatedText = data['candidates'][0]['content']['parts'][0]['text'] as String;
      print('Generated Text: $generatedText'); // Debug the raw response
      String understanding = 'Based on your input: $caseText';
      String lawsInFavor = 'No specific laws identified.';
      String lawsAgainst = 'No opposing laws identified.';
      String procedures = 'Consult a legal expert.';
      String suggestions = 'Gather evidence; seek legal aid.';
      final sections = generatedText.split('- **');
      for (var section in sections) {
        section = section.trim();
        if (section.isEmpty) continue;
        if (section.startsWith('Understanding of the Case**:')) {
          understanding = section.split('**:')[1].trim().replaceAll('-', '•').trim();
        } else if (section.startsWith('Laws in Your Favor**:')) {
          lawsInFavor = section.split('**:')[1].trim().replaceAll('-', '•').trim();
        } else if (section.startsWith('Laws Against Your Case**:')) {
          lawsAgainst = section.split('**:')[1].trim().replaceAll('-', '•').trim();
        } else if (section.startsWith('Procedures to Follow**:')) {
          procedures = section.split('**:')[1].trim().replaceAll('-', '•').trim();
        } else if (section.startsWith('Actionable Suggestions**:')) {
          suggestions = section.split('**:')[1].trim().replaceAll('-', '•').trim();
        }
      }
      understanding = understanding.isNotEmpty ? understanding.replaceAll('\n', '\n• ').trim() : 'Based on your input: $caseText';
      lawsInFavor = lawsInFavor.isNotEmpty ? lawsInFavor.replaceAll('\n', '\n• ').trim() : 'No specific laws identified.';
      lawsAgainst = lawsAgainst.isNotEmpty ? lawsAgainst.replaceAll('\n', '\n• ').trim() : 'No opposing laws identified.';
      procedures = procedures.isNotEmpty ? procedures.replaceAll('\n', '\n• ').trim() : 'Consult a legal expert.';
      suggestions = suggestions.isNotEmpty ? suggestions.replaceAll('\n', '\n• ').trim() : 'Gather evidence; seek legal aid.';
      return '''
${isEnglish ? 'Legal Analysis' : 'कानूनी विश्लेषण'}
${isEnglish ? 'Understanding Your Case' : 'आपके मामले को समझना'}
$understanding
${isEnglish ? 'Laws in Your Favor' : 'आपके पक्ष में कानून'}
$lawsInFavor
${isEnglish ? 'Laws Against Your Case' : 'आपके मामले के खिलाफ कानून'}
$lawsAgainst
${isEnglish ? 'Procedures to Follow' : 'पालन करने की प्रक्रियाएँ'}
$procedures
${isEnglish ? 'Actionable Suggestions' : 'कार्यशील सुझाव'}
$suggestions
      ''';
    } else {
      throw Exception('Failed to fetch suggestion: ${response.statusCode} - ${response.body}');
    }
  }

  @override
  void dispose() {
    _caseController.dispose();
    _speech.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.legalAdvice),
        backgroundColor: Colors.teal,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      localizations.enterCaseDetails,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: _caseController,
                      decoration: InputDecoration(
                        hintText: localizations.enterCaseDetailsHint,
                        border: const OutlineInputBorder(),
                      ),
                      maxLines: 4,
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        ElevatedButton.icon(
                          onPressed: _isListening ? _stopListening : _startListening,
                          icon: Icon(_isListening ? Icons.mic_off : Icons.mic),
                          label: Text(_isListening
                              ? localizations.stopRecording
                              : localizations.record),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: _isListening ? Colors.red : Colors.green,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                        ElevatedButton(
                          onPressed: _isLoading ? null : _submitCase,
                          child: _isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : Text(localizations.getSuggestion),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.teal,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            if (_suggestionResult != null)
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    localizations.legalSuggestions,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                  ),
                  const SizedBox(height: 10),
                  _buildSuggestionSection('Understanding Your Case', _extractSection('Understanding Your Case')),
                  _buildSuggestionSection('Laws in Your Favor', _extractSection('Laws in Your Favor')),
                  _buildSuggestionSection('Laws Against Your Case', _extractSection('Laws Against Your Case')),
                  _buildSuggestionSection('Procedures to Follow', _extractSection('Procedures to Follow')),
                  _buildSuggestionSection('Actionable Suggestions', _extractSection('Actionable Suggestions')),
                ],
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestionSection(String sectionTitle, String content) {
    final localizations = AppLocalizations.of(context)!;
    final isEnglish = Localizations.localeOf(context).languageCode == 'en';
    String title;
    switch (sectionTitle) {
      case 'Understanding Your Case':
        title = isEnglish ? localizations.understandingCase : localizations.understandingCaseHindi;
        break;
      case 'Laws in Your Favor':
        title = isEnglish ? localizations.lawsInFavor : localizations.lawsInFavorHindi;
        break;
      case 'Laws Against Your Case':
        title = isEnglish ? localizations.lawsAgainstCase : localizations.lawsAgainstCaseHindi;
        break;
      case 'Procedures to Follow':
        title = isEnglish ? localizations.proceduresToFollow : localizations.proceduresToFollowHindi;
        break;
      case 'Actionable Suggestions':
        title = isEnglish ? localizations.actionableSuggestions : localizations.actionableSuggestionsHindi;
        break;
      default:
        title = sectionTitle;
    }
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Card(
        elevation: 4,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.teal),
              ),
              const SizedBox(height: 8),
              Text(
                content.isEmpty ? 'N/A' : content,
                style: const TextStyle(fontSize: 16),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _extractSection(String title) {
    if (_suggestionResult == null) return '';
    final lines = _suggestionResult!.split('\n');
    StringBuffer content = StringBuffer();
    bool isSection = false;
    for (var i = 0; i < lines.length; i++) {
      if (lines[i].contains(title)) {
        isSection = true;
        continue;
      }
      if (isSection) {
        if (lines[i].isEmpty || lines[i].startsWith('Legal Analysis') || lines[i].startsWith('कानूनी विश्लेषण')) {
          break;
        }
        if (content.isNotEmpty) content.write('\n');
        content.write(lines[i].trim());
      }
    }
    return content.toString();
  }}