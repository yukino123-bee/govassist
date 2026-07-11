import 'package:flutter/material.dart';
import '../../data/service_data.dart';
import 'package:intl/intl.dart';

class AdminAnalyticsScreen extends StatefulWidget {
  const AdminAnalyticsScreen({super.key});

  @override
  State<AdminAnalyticsScreen> createState() => _AdminAnalyticsScreenState();
}

class _AdminAnalyticsScreenState extends State<AdminAnalyticsScreen> {
  bool _isLoading = true;
  Map<String, dynamic>? _analyticsData;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    final data = await ServiceData.fetchAnalytics();
    if (mounted) {
      setState(() {
        _analyticsData = data;
        _isLoading = false;
      });
    }
  }

  Widget _buildKpiCard(String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.2),
              child: Icon(icon, color: color),
            ),
            const SizedBox(width: 16),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontSize: 12, color: Colors.grey)),
                Text(value, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_analyticsData == null) {
      return const Center(child: Text("Error loading analytics data."));
    }

    final totalUsers = _analyticsData!['total_users']?.toString() ?? '0';
    final totalAssessments = _analyticsData!['total_assessments']?.toString() ?? '0';
    final resolvedInquiries = _analyticsData!['resolved_inquiries']?.toString() ?? '0';
    final averageRating = _analyticsData!['average_rating']?.toString() ?? '0.0';
    final List comments = _analyticsData!['feedback_comments'] ?? [];

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'System Evaluation & Analytics',
                style: Theme.of(context).textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.refresh),
                onPressed: _fetchData,
              )
            ],
          ),
          const SizedBox(height: 24),
          // KPIs
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _buildKpiCard('Total Users', totalUsers, Icons.people, Colors.blue),
              _buildKpiCard('Assessments Taken', totalAssessments, Icons.assignment, Colors.orange),
              _buildKpiCard('Resolved Inquiries', resolvedInquiries, Icons.check_circle, Colors.green),
              _buildKpiCard('Average Rating', '$averageRating / 5.0', Icons.star, Colors.amber),
            ],
          ),
          const SizedBox(height: 32),
          Text('Recent Citizen Feedback', style: Theme.of(context).textTheme.titleLarge),
          const SizedBox(height: 16),
          Expanded(
            child: comments.isEmpty
                ? const Center(child: Text("No feedback comments yet."))
                : ListView.builder(
                    itemCount: comments.length,
                    itemBuilder: (context, index) {
                      final comment = comments[index];
                      final rating = int.tryParse(comment['rating'].toString()) ?? 0;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor: Colors.amber.withValues(alpha: 0.1),
                            child: Text(rating.toString(), style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                          ),
                          title: Text(comment['comments'] ?? ''),
                          subtitle: Text(DateFormat('MMM dd, yyyy').format(DateTime.parse(comment['created_at']))),
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
