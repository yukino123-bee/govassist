import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import 'assessment_result_screen.dart';
import '../../core/translations.dart';

class EligibilityQuestionsScreen extends StatefulWidget {
  final GovernmentService service;

  const EligibilityQuestionsScreen({super.key, required this.service});

  @override
  State<EligibilityQuestionsScreen> createState() =>
      _EligibilityQuestionsScreenState();
}

class _EligibilityQuestionsScreenState extends State<EligibilityQuestionsScreen> {
  final Map<String, String> _answers = {};
  final Map<String, TextEditingController> _othersControllers = {};
  List<EligibilityQuestion> _questions = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchQuestions();
  }

  @override
  void dispose() {
    for (var controller in _othersControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  void _fetchQuestions() {
    final questions = widget.service.eligibilityQuestions;
    if (mounted) {
      setState(() {
        _questions = questions;
        _isLoading = false;
      });
    }
  }

  Widget _buildOptionButton(String option, bool isSelected, Color activeColor, String qId) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        InkWell(
          onTap: () {
            setState(() {
              _answers[qId] = option;
              if (option.toLowerCase() == 'others') {
                _othersControllers.putIfAbsent(qId, () => TextEditingController());
              }
            });
          },
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: isSelected
                  ? activeColor.withOpacity(0.1)
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? activeColor
                    : Colors.grey.shade300,
                width: isSelected ? 2 : 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              option.tr(),
              style: TextStyle(
                color: isSelected
                    ? activeColor
                    : Colors.grey.shade700,
                fontWeight: isSelected
                    ? FontWeight.bold
                    : FontWeight.w500,
                fontSize: 16,
              ),
            ),
          ),
        ),
        if (isSelected && option.toLowerCase() == 'others') ...[
          const SizedBox(height: 8),
          TextField(
            controller: _othersControllers[qId],
            decoration: InputDecoration(
              hintText: 'Please specify...'.tr(),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            onChanged: (val) {
              setState(() {}); // Trigger rebuild to update allAnswered state
            },
          ),
        ],
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    int totalQuestions = _questions.length;
    int answeredQuestions = _answers.length;
    double progress = totalQuestions == 0
        ? 0
        : answeredQuestions / totalQuestions;
        
    bool allAnswered = answeredQuestions == totalQuestions && totalQuestions > 0;
    if (allAnswered) {
      for (var q in _questions) {
        if (_answers[q.id]?.toLowerCase() == 'others') {
          final text = _othersControllers[q.id]?.text.trim() ?? '';
          if (text.isEmpty) {
            allAnswered = false;
            break;
          }
        }
      }
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      appBar: AppBar(
        title: Text('Eligibility Assessment'.tr()),
        elevation: 0,
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        iconTheme: const IconThemeData(color: Colors.black87),
      ),
      body: _isLoading ? const Center(child: CircularProgressIndicator()) 
        : _questions.isEmpty ? Center(child: Text("No questions for this service.".tr()))
        : Column(
        children: [
          // Progress Header
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: 24.0,
              vertical: 16.0,
            ),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Assessment Progress'.tr(),
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      '$answeredQuestions ' + 'of'.tr() + ' $totalQuestions',
                      style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: Theme.of(context).primaryColor,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey[200],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      Theme.of(context).primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Questions List
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: totalQuestions + 1,
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(
                      bottom: 24.0,
                      left: 8,
                      right: 8,
                      top: 8,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Applying for:'.tr(),
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 14,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          widget.service.title,
                          style: const TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.black87,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final qIndex = index - 1;
                final q = _questions[qIndex];
                final options = q.options ?? ['Yes', 'No'];
                final isBinary = options.length == 2;

                return Card(
                  margin: const EdgeInsets.only(bottom: 16.0),
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(color: Colors.grey.shade200),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: Theme.of(
                                  context,
                                ).primaryColor.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '${qIndex + 1}',
                                style: TextStyle(
                                  color: Theme.of(context).primaryColor,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Padding(
                                padding: const EdgeInsets.only(top: 4.0),
                                child: Text(
                                  q.questionText,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 15,
                                    height: 1.4,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        isBinary ? Row(
                          children: options.map((option) {
                            final isSelected = _answers[q.id] == option;
                            final isYes = option == 'Yes';
                            final activeColor = isYes
                                ? Colors.green.shade600
                                : Colors.red.shade500;

                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: option == options.first ? 12.0 : 0.0,
                                  left: option == options.last ? 0.0 : 0.0,
                                ),
                                child: _buildOptionButton(option, isSelected, activeColor, q.id),
                              ),
                            );
                          }).toList(),
                        ) : Column(
                          children: options.map((option) {
                            final isSelected = _answers[q.id] == option;
                            final activeColor = Theme.of(context).primaryColor;
                            
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8.0),
                              child: SizedBox(
                                width: double.infinity,
                                child: _buildOptionButton(option, isSelected, activeColor, q.id),
                              ),
                            );
                          }).toList(),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Container(
        padding: EdgeInsets.only(
          left: 24.0,
          right: 24.0,
          top: 16.0,
          bottom: MediaQuery.of(context).padding.bottom + 16.0,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: allAnswered
                ? () async {
                    bool isEligible = true;
                    for (var q in _questions) {
                      String expected = q.expectedAnswer;
                      if (expected == '1' || expected == 'true') expected = 'Yes';
                      if (expected == '0' || expected == 'false') expected = 'No';
                      
                      if (expected.isNotEmpty && _answers[q.id] != expected) {
                        isEligible = false;
                        break;
                      }
                    }
                    // Assume user id 1
                    if (mounted) {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (context) => AssessmentResultScreen(
                            service: widget.service,
                            isEligible: isEligible,
                          ),
                        ),
                      );
                    }
                  }
                : null,
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              backgroundColor: Theme.of(context).primaryColor,
              disabledBackgroundColor: Colors.grey.shade300,
              elevation: 0,
            ),
            child: Text(
              'Submit Assessment'.tr(),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: allAnswered ? Colors.white : Colors.grey.shade500,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
