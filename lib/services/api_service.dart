import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:math';
import 'package:flutter/foundation.dart';

class ApiService {
  static const String _geminiApiUrl =
      'https://generativelanguage.googleapis.com/v1beta/models/gemini-2.0-flash:generateContent';
  static const String _apiKey = 'AIzaSyAl2ZZno-C2hmXh58-1hHoXAJtUJqLjl3Q';

  Future<List<Map<String, String>>> fetchLegalContent(String locale, {String? query}) async {
    final prompt = query != null && query.isNotEmpty
        ? 'Provide detailed information about "$query" under Indian law in $locale. Include the relevant legal article or act, its implications, and recent updates if any. Format the response as a single topic with a title and description. Do not include phrases like "Okay, here is the response" or "here is 3 random".'
        : 'Provide one recent and unique Indian legal right or development from the past 5 years in $locale. Format the response as a single topic with a title and description. Do not include phrases like "Okay, here is the response" or "here is 3 random".';

    try {
      final response = await http.post(
        Uri.parse('$_geminiApiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Legal Content Response: $data');
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        return _parseLegalContent(text, locale);
      } else {
        debugPrint('Legal Content Error: ${response.statusCode} - ${response.body}');
        throw Exception('Failed to fetch legal content: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint('Legal Content Exception: $e');
      return _parseLegalContent('Title: Error\nDescription: Unable to fetch legal content. Please check your internet connection.', locale);
    }
  }

  List<Map<String, String>> _parseLegalContent(String text, String locale) {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    final List<Map<String, String>> content = [];

    if (lines.length >= 2) {
      String title = lines[0].trim();
      String description = lines.sublist(1).join('\n').trim();
      title = title.replaceAll(RegExp(r'\*+'), '').trim();
      description = description.replaceAll(RegExp(r'\*+'), '').trim();
      content.add({
        locale == 'en' ? 'en' : 'hi': title,
        'desc_${locale == 'en' ? 'en' : 'hi'}': description,
      });
    }
    return content.isEmpty ? _mockLegalContent(locale) : content;
  }

  List<Map<String, String>> _mockLegalContent(String locale) {
    final legalTopics = [
      {
        'en': 'Consumer Protection Act, 2019',
        'hi': 'उपभोक्ता संरक्षण अधिनियम, 2019',
        'desc_en': 'This act strengthens consumer rights in India, allowing for faster redressal of complaints and stricter penalties for misleading advertisements.',
        'desc_hi': 'यह अधिनियम भारत में उपभोक्ता अधिकारों को मजबूत करता है, शिकायतों के तेजी से निवारण और भ्रामक विज्ञापनों के लिए सख्त दंड की अनुमति देता है।',
      },
    ];
    return legalTopics;
  }

  Future<Map<String, dynamic>> fetchQuizQuestion(String locale, {String questionType = 'general'}) async {
    final prompt = questionType == 'scenario'
        ? 'Generate one unique legal quiz question in $locale related to Indian law, structured as a practical scenario-based situation. The question should present a realistic legal scenario and ask what the correct action or legal implication would be. For example, "If your landlord refuses to return your security deposit without reason, what is your legal recourse?" or "If you witness a car accident, what are your legal obligations?". Provide exactly 4 concise options (each less than 15 words), with one correct answer. Format the response as: Question: [scenario question text]\nOption 1: [option1]\nOption 2: [option2]\nOption 3: [option3]\nOption 4: [option4]\nCorrect Answer: [correct option]. Ensure the question clearly describes a real-life situation requiring legal knowledge.'
        : 'Generate one unique legal quiz question in $locale related to Indian law, focusing strictly on general legal awareness, acts, laws, constitutional rights, or legal principles. Examples include "Which act protects consumer rights in India?" or "Under which article is the Right to Education guaranteed?". The question should test knowledge of legal facts, not scenarios. Provide exactly 4 concise options (each less than 15 words), with one correct answer. Format the response as: Question: [question text]\nOption 1: [option1]\nOption 2: [option2]\nOption 3: [option3]\nOption 4: [option4]\nCorrect Answer: [correct option].';

    try {
      final response = await http.post(
        Uri.parse('$_geminiApiUrl?key=$_apiKey'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'contents': [
            {
              'parts': [
                {'text': prompt}
              ]
            }
          ]
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        debugPrint('Quiz Question Response: $data');
        final text = data['candidates'][0]['content']['parts'][0]['text'] as String;
        return _parseQuizQuestion(text, locale);
      } else {
        debugPrint('Quiz Question Error: ${response.statusCode} - ${response.body}');
        return {'error': 'Failed to fetch quiz question: ${response.statusCode}'};
      }
    } catch (e) {
      debugPrint('Quiz Question Exception: $e');
      return {'error': 'Error fetching quiz question: $e'};
    }
  }

  Map<String, dynamic> _parseQuizQuestion(String text, String locale) {
    final lines = text.split('\n').where((line) => line.trim().isNotEmpty).toList();
    if (lines.length < 6) {
      debugPrint('Invalid quiz response format: $text');
      return {'error': 'Invalid response format from Gemini API'};
    }

    final question = lines[0].replaceFirst('Question:', '').trim();
    final options = [
      lines[1].replaceFirst('Option 1:', '').trim(),
      lines[2].replaceFirst('Option 2:', '').trim(),
      lines[3].replaceFirst('Option 3:', '').trim(),
      lines[4].replaceFirst('Option 4:', '').trim(),
    ];
    final correctAnswer = lines[5].replaceFirst('Correct Answer:', '').trim();

    return {
      'question_${locale == 'en' ? 'en' : 'hi'}': question,
      'options_${locale == 'en' ? 'en' : 'hi'}': options,
      'correct_${locale == 'en' ? 'en' : 'hi'}': correctAnswer,
    };
  }
}