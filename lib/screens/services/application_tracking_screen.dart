import 'package:flutter/material.dart';
import '../../core/user_session.dart';
import '../../data/service_data.dart';

class ApplicationTrackingScreen extends StatefulWidget {
  const ApplicationTrackingScreen({super.key});

  @override
  State<ApplicationTrackingScreen> createState() => _ApplicationTrackingScreenState();
}

class _ApplicationTrackingScreenState extends State<ApplicationTrackingScreen> {
  List<dynamic> _applications = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadApplications();
  }

  Future<void> _loadApplications() async {
    final userId = UserSession().currentUser?['id']?.toString();
    if (userId == null) return;

    final result = await ServiceData.fetchApplications(userId);
    if (mounted) {
      setState(() {
        _applications = result['applications'] ?? [];
        _isLoading = false;
      });
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved': return Colors.green;
      case 'rejected': return Colors.red;
      case 'under review': return Colors.orange;
      default: return Colors.blue; // submitted
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Applications'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _applications.isEmpty
              ? const Center(child: Text('You have not submitted any applications yet.'))
              : ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: _applications.length,
                  itemBuilder: (context, index) {
                    final app = _applications[index];
                    final status = app['status'] ?? 'Submitted';
                    final color = _getStatusColor(status);

                    return Card(
                      margin: const EdgeInsets.only(bottom: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Expanded(
                                  child: Text(
                                    app['service_title'] ?? 'Service Application',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                  decoration: BoxDecoration(
                                    color: color.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Text(
                                    status,
                                    style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text('Submitted on: ${app['submitted_at']}'),
                            if (app['updated_at'] != null && app['updated_at'] != app['submitted_at']) ...[
                              const SizedBox(height: 4),
                              Text('Last updated: ${app['updated_at']}'),
                            ]
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
