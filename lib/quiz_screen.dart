import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'services/api_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService();
  String _locale = 'en';
  late TabController _tabController;
  String _currentSection = 'general'; // Default to general section

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(_handleTabChange);
  }

  void _handleTabChange() {
    if (!_tabController.indexIsChanging) return;

    setState(() {
      _currentSection = _tabController.index == 0 ? 'general' : 'scenario';
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = Localizations.localeOf(context).languageCode;
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.quizzes),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          tabs: [
            Tab(text: localizations.generalActs),
            Tab(text: localizations.scenarioBased),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _QuizContent(
            tabController: _tabController,
            apiService: _apiService,
            questionType: 'general',
            index: 0,
          ),
          _QuizContent(
            tabController: _tabController,
            apiService: _apiService,
            questionType: 'scenario',
            index: 1,
          ),
        ],
      ),
    );
  }
}

class _QuizContent extends StatefulWidget {
  final TabController tabController;
  final ApiService apiService;
  final String questionType;
  final int index;

  const _QuizContent({
    required this.tabController,
    required this.apiService,
    required this.questionType,
    required this.index,
    super.key,
  });

  @override
  State<_QuizContent> createState() => _QuizContentState();
}

class _QuizContentState extends State<_QuizContent> {
  late Future<Map<String, dynamic>> _quizFuture;
  String _locale = 'en';
  String? _selectedOption;
  bool _isSubmitted = false;
  String? _feedbackMessage;
  bool? _isCorrect;

  @override
  void initState() {
    super.initState();
    _quizFuture = widget.apiService.fetchQuizQuestion(_locale, questionType: widget.questionType);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = Localizations.localeOf(context).languageCode;
  }

  void _resetState() {
    _selectedOption = null;
    _isSubmitted = false;
    _feedbackMessage = null;
    _isCorrect = null;
  }

  void _nextQuestion() {
    setState(() {
      _quizFuture = widget.apiService.fetchQuizQuestion(_locale, questionType: widget.questionType);
      _resetState();
    });
  }

  void _submitAnswer(String correctAnswer) {
    setState(() {
      _isSubmitted = true;
      _isCorrect = _selectedOption == correctAnswer;
      _feedbackMessage = _locale == 'en'
          ? (_isCorrect! ? 'Correct!' : 'Wrong! The correct answer is $correctAnswer.')
          : (_isCorrect! ? 'सही!' : 'गलत! सही उत्तर है $correctAnswer.');
    });
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage,
            style: const TextStyle(fontSize: 18, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              setState(() {
                _quizFuture = widget.apiService.fetchQuizQuestion(_locale, questionType: widget.questionType);
              });
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: Text(AppLocalizations.of(context)!.retry),
          ),
        ],
      ),
    );
  }

  Widget _buildNoContentWidget() {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.noQuizAvailable,
        style: const TextStyle(fontSize: 18, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Only rebuild the content when this tab is active
    if (widget.tabController.index != widget.index) {
      return const SizedBox.shrink();
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: _quizFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: Image.asset(
              'assets/loader.gif', // Path to your custom loader GIF
              width: 100,
              height: 100,
            ),
          );
        } else if (snapshot.hasError || (snapshot.data?.containsKey('error') ?? false)) {
          final error = snapshot.error ?? snapshot.data?['error'] ?? 'Unknown error';
          return _buildErrorWidget(error.toString());
        } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
          return _buildNoContentWidget();
        }

        final quiz = snapshot.data!;
        final question = _locale == 'en' ? quiz['question_en']! : quiz['question_hi']!;
        final options = _locale == 'en' ? quiz['options_en']! as List<String> : quiz['options_hi']! as List<String>;
        final correctAnswer = _locale == 'en' ? quiz['correct_en']! : quiz['correct_hi']!;

        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(question, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              ...options.map((option) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _selectedOption == option
                        ? Colors.blue.withOpacity(0.7)
                        : Colors.grey.withOpacity(0.3),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  onPressed: _isSubmitted
                      ? null
                      : () {
                    setState(() {
                      _selectedOption = option;
                    });
                  },
                  child: Text(option, style: const TextStyle(fontSize: 16)),
                ),
              )),
              const SizedBox(height: 20),
              if (_isSubmitted && _feedbackMessage != null)
                Container(
                  padding: const EdgeInsets.all(12.0),
                  decoration: BoxDecoration(
                    color: _isCorrect! ? Colors.green.withOpacity(0.2) : Colors.red.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: _isCorrect! ? Colors.green : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    _feedbackMessage!,
                    style: TextStyle(
                      color: _isCorrect! ? Colors.green[900] : Colors.red[900],
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _selectedOption == null || _isSubmitted
                        ? null
                        : () => _submitAnswer(correctAnswer),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(AppLocalizations.of(context)!.submit),
                  ),
                  ElevatedButton(
                    onPressed: _isSubmitted ? _nextQuestion : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                    ),
                    child: Text(AppLocalizations.of(context)!.next),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }
}