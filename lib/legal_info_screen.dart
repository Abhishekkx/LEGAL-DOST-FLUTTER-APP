import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'services/api_service.dart';

class LegalInfoScreen extends StatefulWidget {
  const LegalInfoScreen({super.key});

  @override
  State<LegalInfoScreen> createState() => _LegalInfoScreenState();
}

class _LegalInfoScreenState extends State<LegalInfoScreen> {
  final ApiService _apiService = ApiService();
  late Future<List<Map<String, String>>> _legalContentFuture;
  final TextEditingController _searchController = TextEditingController();
  String _locale = 'en';
  int _currentContentIndex = 0;
  List<Map<String, String>> _allLegalContent = [];

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _locale = Localizations.localeOf(context).languageCode;
    _refreshContent();
  }

  void _refreshContent() {
    setState(() {
      _currentContentIndex = 0;
      _legalContentFuture = _apiService.fetchLegalContent(
        _locale,
        query: _searchController.text,
      );
    });
  }

  void _searchContent() {
    _refreshContent();
  }

  void _nextContent() {
    if (_currentContentIndex < _allLegalContent.length - 1) {
      setState(() {
        _currentContentIndex++;
      });
    } else {
      _refreshContent();
    }
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            errorMessage,
            style: const TextStyle(fontSize: 16, color: Colors.red),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _refreshContent,
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.teal,
              foregroundColor: Colors.white,
            ),
            child: const Text('Retry'),
          ),
        ],
      ),
    );
  }

  Widget _buildNoContentWidget() {
    return Center(
      child: Text(
        AppLocalizations.of(context)!.noContentAvailable,
        style: const TextStyle(fontSize: 18, color: Colors.grey),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildContent(List<Map<String, String>> legalContent) {
    final localizations = AppLocalizations.of(context)!;
    _allLegalContent = legalContent;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: ListView(
        children: [
          // Sections
          ...legalContent.asMap().entries.map((entry) {
            final index = entry.key;
            final item = entry.value;
            final title = _locale == 'en' ? item['en']! : item['hi']!;
            final description = _locale == 'en' ? item['desc_en']! : item['desc_hi']!;
            final points = description.split('. ').where((point) => point.isNotEmpty).toList();

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                const SizedBox(height: 8),
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: points.length,
                  itemBuilder: (context, pointIndex) {
                    final point = points[pointIndex].trim();
                    if (point.isEmpty) return const SizedBox.shrink();
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('• ', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                          Expanded(
                            child: Text(
                              point + (point.endsWith('.') ? '' : '.'),
                              style: const TextStyle(fontSize: 16),
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
                const SizedBox(height: 16),
              ],
            );
          }).toList(),
          // Footer with counter and button
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '${_currentContentIndex + 1}/${legalContent.length}',
                    style: const TextStyle(color: Colors.grey),
                  ),
                  ElevatedButton(
                    onPressed: _nextContent,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.teal,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(localizations.next),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(localizations.legalInformation),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshContent,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: localizations.searchLegalTopics,
                border: const OutlineInputBorder(
                  borderRadius: BorderRadius.all(Radius.circular(12)),
                ),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: _searchContent,
                ),
              ),
              onSubmitted: (_) => _searchContent(),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<Map<String, String>>>(
              future: _legalContentFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: Colors.teal),
                  );
                } else if (snapshot.hasError) {
                  return _buildErrorWidget('Error: ${snapshot.error}');
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return _buildNoContentWidget();
                }

                final legalContent = snapshot.data!;
                return _buildContent(legalContent);
              },
            ),
          ),
        ],
      ),
    );
  }
}