import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../widgets/custom_widgets.dart';
import '../../data/service_data.dart';
import 'dart:math';

class AssessmentResultScreen extends StatefulWidget {
  final GovernmentService service;
  final bool isEligible;

  const AssessmentResultScreen({super.key, required this.service, required this.isEligible});

  @override
  State<AssessmentResultScreen> createState() => _AssessmentResultScreenState();
}

class _AssessmentResultScreenState extends State<AssessmentResultScreen> {
  late String refNumber;

  @override
  void initState() {
    super.initState();
    refNumber = 'REF-${Random().nextInt(9000) + 1000}';
    _saveResult();
  }

  Future<void> _saveResult() async {
    await ServiceData.saveAssessment(widget.service.title, widget.isEligible);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Assessment Result'),
      ),
      body: Center(
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
}
