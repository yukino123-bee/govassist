import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../widgets/custom_widgets.dart';
import '../../data/service_data.dart';

class AssessmentResultScreen extends StatefulWidget {
  final GovernmentService service;
  final bool isEligible;

  const AssessmentResultScreen({super.key, required this.service, required this.isEligible});

  @override
  State<AssessmentResultScreen> createState() => _AssessmentResultScreenState();
}

class _AssessmentResultScreenState extends State<AssessmentResultScreen> {
  String refNumber = '';
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _saveResult();
  }

  Future<void> _saveResult() async {
    final result = await ServiceData.saveAssessment(widget.service.title, widget.isEligible);
    if (mounted) {
      setState(() {
        if (result['success'] == true) {
          refNumber = result['reference_number'] ?? 'REF-UNKNOWN';
        } else {
          refNumber = 'ERROR-SAVING';
        }
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Result'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.isEligible ? Icons.check_circle : Icons.cancel,
                size: 100,
                color: widget.isEligible ? Colors.green : Colors.red,
              ),
              const SizedBox(height: 24),
              Text(
                widget.isEligible ? 'You are Eligible!' : 'Not Eligible at this time',
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                widget.isEligible
                    ? 'Based on your answers, you meet the initial criteria for ${widget.service.title}. You may proceed with the application.'
                    : 'Unfortunately, you do not meet all the requirements for ${widget.service.title} based on your responses.',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              if (widget.isEligible)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Column(
                    children: [
                      const Text('Reference Number', style: TextStyle(color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(refNumber, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
              const SizedBox(height: 32),
              const Divider(),
              const SizedBox(height: 16),
              const Text('Rate your experience', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (index) {
                  return IconButton(
                    icon: Icon(Icons.star_border, color: Colors.orange, size: 32),
                    onPressed: () {
                      _showFeedbackDialog(context, index + 1);
                    },
                  );
                }),
              ),
              const SizedBox(height: 16),
              CustomButton(
                text: 'Back to Eligibility Home',
                onPressed: () {
                  Navigator.of(context).popUntil((route) => route.isFirst);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showFeedbackDialog(BuildContext context, int rating) {
    final TextEditingController commentsController = TextEditingController();
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Thank you!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('You rated us $rating stars.'),
              const SizedBox(height: 16),
              TextField(
                controller: commentsController,
                decoration: const InputDecoration(
                  labelText: 'Optional comments',
                  border: OutlineInputBorder(),
                ),
                maxLines: 3,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Skip'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await ServiceData.submitFeedback(rating, commentsController.text.trim());
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Feedback submitted!')));
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
