import 'package:flutter/material.dart';
import '../../data/service_data.dart';
import 'package:intl/intl.dart';

class AdminAssessmentsScreen extends StatefulWidget {
  const AdminAssessmentsScreen({super.key});

  @override
  State<AdminAssessmentsScreen> createState() => _AdminAssessmentsScreenState();
}

class _AdminAssessmentsScreenState extends State<AdminAssessmentsScreen> {
  List<dynamic> _assessments = [];
  List<dynamic> _filteredAssessments = [];
  bool _isLoading = true;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _fetchAssessments();
  }

  Future<void> _fetchAssessments() async {
    setState(() => _isLoading = true);
    final data = await ServiceData.adminFetchAssessments();
    if (mounted) {
      setState(() {
        _assessments = data;
        _filteredAssessments = data;
        _isLoading = false;
      });
    }
  }

  void _filterAssessments(String query) {
    setState(() {
      _searchQuery = query;
      if (query.isEmpty) {
        _filteredAssessments = _assessments;
      } else {
        _filteredAssessments = _assessments.where((item) {
          final title = item['service_title']?.toString().toLowerCase() ?? '';
          final name = '${item['first_name']} ${item['last_name']}'.toLowerCase();
          final ref = item['reference_number']?.toString().toLowerCase() ?? '';
          final lowerQuery = query.toLowerCase();
          return title.contains(lowerQuery) || name.contains(lowerQuery) || ref.contains(lowerQuery);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Eligibility Assessments Log',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchAssessments,
                tooltip: 'Refresh',
              ),
            ],
          ),
          const SizedBox(height: 16),
          TextField(
            onChanged: _filterAssessments,
            decoration: InputDecoration(
              hintText: 'Search by citizen name, service, or reference number...',
              prefixIcon: const Icon(Icons.search),
              filled: true,
              fillColor: Colors.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _filteredAssessments.isEmpty
                    ? Center(
                        child: Text(
                          _searchQuery.isEmpty ? 'No assessments recorded yet.' : 'No matches found.',
                          style: const TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      )
                    : ListView.builder(
                        itemCount: _filteredAssessments.length,
                        itemBuilder: (context, index) {
                          final item = _filteredAssessments[index];
                          final isEligible = item['is_eligible'] == true || item['is_eligible'] == 1;
                          final dateStr = item['date'];
                          DateTime? date;
                          if (dateStr != null) {
                            date = DateTime.tryParse(dateStr);
                          }
                          
                          return Card(
                            margin: const EdgeInsets.only(bottom: 12),
                            elevation: 1,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: isEligible ? Colors.green.withValues(alpha: 0.1) : Colors.red.withValues(alpha: 0.1),
                                child: Icon(
                                  isEligible ? Icons.check_circle : Icons.cancel,
                                  color: isEligible ? Colors.green : Colors.red,
                                ),
                              ),
                              title: Text(
                                '${item['first_name'] ?? 'Unknown'} ${item['last_name'] ?? 'User'}',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const SizedBox(height: 4),
                                  Text(
                                    item['service_title'] ?? 'Unknown Service',
                                    style: const TextStyle(color: Colors.black87),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    date != null ? DateFormat('MMM dd, yyyy • hh:mm a').format(date) : 'Unknown date',
                                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                                  ),
                                  const SizedBox(height: 8),
                                  if (item['reference_number'] != null && item['reference_number'].toString().isNotEmpty)
                                    Container(
                                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                      decoration: BoxDecoration(
                                        color: Colors.blueGrey.withValues(alpha: 0.1),
                                        borderRadius: BorderRadius.circular(4),
                                      ),
                                      child: Text(
                                        'Ref: ${item['reference_number']}',
                                        style: const TextStyle(
                                          fontSize: 12,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blueGrey,
                                        ),
                                      ),
                                    ),
                                ],
                              ),
                              trailing: Chip(
                                label: Text(isEligible ? 'Eligible' : 'Not Eligible'),
                                backgroundColor: isEligible ? Colors.green.shade50 : Colors.red.shade50,
                                labelStyle: TextStyle(
                                  color: isEligible ? Colors.green.shade900 : Colors.red.shade900,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
