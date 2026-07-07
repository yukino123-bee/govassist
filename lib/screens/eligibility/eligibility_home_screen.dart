import 'package:flutter/material.dart';
import '../../data/service_data.dart';
import '../../models/service_model.dart';
import '../../widgets/custom_widgets.dart';
import 'package:intl/intl.dart';
import 'eligibility_questions_screen.dart';
import '../../core/translations.dart';

class EligibilityHomeScreen extends StatefulWidget {
  const EligibilityHomeScreen({super.key});

  @override
  State<EligibilityHomeScreen> createState() => _EligibilityHomeScreenState();
}

class _EligibilityHomeScreenState extends State<EligibilityHomeScreen> {
  List<GovernmentService> _services = [];
  List<AssessmentHistory> _history = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    final services = await ServiceData.fetchServices();
    final history = await ServiceData.fetchAssessments();
    if (mounted) {
      setState(() {
        _services = services;
        _history = history;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eligibility Assessment'.tr()),
        automaticallyImplyLeading: false,
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : RefreshIndicator(
            onRefresh: _fetchData,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  Icon(Icons.assignment_turned_in, size: 40, color: Theme.of(context).primaryColor),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      'Check your eligibility for government services before applying.'.tr(),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            SectionHeader(title: 'Assess Services'.tr()),
            const SizedBox(height: 16),
            ..._services.map((service) {
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                child: ListTile(
                  title: Text(service.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EligibilityQuestionsScreen(service: service),
                      ),
                    );
                  },
                ),
              );
            }),
            const SizedBox(height: 32),
            SectionHeader(title: 'Assessment History'.tr()),
            const SizedBox(height: 16),
            _history.isEmpty ? Text('No assessment history.'.tr()) : Column(
              children: _history.map((history) {
                bool isEligible = history.isEligible;
                DateTime date = history.date;
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isEligible ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      child: Icon(
                        isEligible ? Icons.check : Icons.close,
                        color: isEligible ? Colors.green : Colors.red,
                      ),
                    ),
                    title: Text(history.serviceTitle, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        Text(DateFormat('MMM dd, yyyy • hh:mm a').format(date)),
                        if (history.referenceNumber.isNotEmpty) ...[
                          const SizedBox(height: 4),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.blueGrey.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'Ref: '.tr() + history.referenceNumber,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                color: Colors.blueGrey,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    trailing: Text(
                      isEligible ? 'Eligible'.tr() : 'Not Eligible'.tr(),
                      style: TextStyle(
                        color: isEligible ? Colors.green : Colors.red,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                );
              }).toList()
            ),
          ],
        ),
      ),
    ),
    );
  }
}
