import 'package:flutter/material.dart';
import '../../data/service_data.dart';
import '../../core/translations.dart';
import 'package:intl/intl.dart';

class AdminApplicationsScreen extends StatefulWidget {
  const AdminApplicationsScreen({super.key});

  @override
  State<AdminApplicationsScreen> createState() => _AdminApplicationsScreenState();
}

class _AdminApplicationsScreenState extends State<AdminApplicationsScreen> {
  List<dynamic> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchApplications();
  }

  Future<void> _fetchApplications() async {
    setState(() => _isLoading = true);
    final res = await ServiceData.fetchAdminApplications();
    if (mounted) {
      setState(() {
        if (res.containsKey('applications')) {
          _applications = res['applications'];
        }
        _isLoading = false;
      });
    }
  }

  Future<void> _updateStatus(String id, String status) async {
    final res = await ServiceData.updateApplicationStatus(id, status);
    if (res['success'] == true) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Application $status successfully'.tr())),
        );
      }
      _fetchApplications();
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(res['error'] ?? 'Failed to update'.tr())),
        );
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'requirements_needed': return Colors.orange;
      default: return Colors.blue;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Manage Applications'.tr()),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchApplications,
          ),
        ],
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : _applications.isEmpty
          ? Center(child: Text('No applications found.'.tr()))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _applications.length,
              itemBuilder: (context, index) {
                final app = _applications[index];
                final status = app['status'] ?? 'pending';
                final date = DateTime.parse(app['submitted_at']);

                return Card(
                  margin: const EdgeInsets.only(bottom: 16),
                  elevation: 2,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                app['service_title'] ?? 'Unknown Service',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                              ),
                            ),
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(status).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _getStatusColor(status)),
                              ),
                              child: Text(
                                status.toUpperCase(),
                                style: TextStyle(
                                  color: _getStatusColor(status),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Text('Applicant: ${app['first_name']} ${app['last_name']} (${app['email']})'),
                        Text('Submitted: ${DateFormat('MMM dd, yyyy').format(date)}'),
                        const SizedBox(height: 16),
                        Row(
                          children: [
                            if (status == 'pending' || status == 'requirements_needed') ...[
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                                  onPressed: () => _updateStatus(app['id'].toString(), 'approved'),
                                  child: const Text('Approve'),
                                ),
                              ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
                                  onPressed: () => _updateStatus(app['id'].toString(), 'rejected'),
                                  child: const Text('Reject'),
                                ),
                              ),
                            ] else ...[
                              Expanded(
                                child: OutlinedButton(
                                  onPressed: () => _updateStatus(app['id'].toString(), 'pending'),
                                  child: const Text('Re-evaluate'),
                                ),
                              ),
                            ]
                          ],
                        )
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }
}
