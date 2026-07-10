import 'package:flutter/material.dart';
import '../../data/service_data.dart';
import '../../models/service_model.dart';
import 'package:intl/intl.dart';

class InquiryTrackingScreen extends StatefulWidget {
  const InquiryTrackingScreen({super.key});

  @override
  State<InquiryTrackingScreen> createState() => _InquiryTrackingScreenState();
}

class _InquiryTrackingScreenState extends State<InquiryTrackingScreen> {
  List<InquiryTicket> _inquiries = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchInquiries();
  }

  Future<void> _fetchInquiries() async {
    final tickets = await ServiceData.fetchInquiries();
    if (mounted) {
      setState(() {
        _inquiries = tickets;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Inquiries')),
      body: RefreshIndicator(
        onRefresh: _fetchInquiries,
        child: _isLoading 
          ? const Center(child: CircularProgressIndicator())
          : _inquiries.isEmpty 
              ? const SingleChildScrollView(
                  physics: AlwaysScrollableScrollPhysics(),
                  child: SizedBox(
                    height: 400,
                    child: Center(child: Text("No inquiries found.")),
                  ),
                )
              : ListView.builder(
                  physics: const AlwaysScrollableScrollPhysics(),
                  padding: const EdgeInsets.all(16.0),
                  itemCount: _inquiries.length,
                  itemBuilder: (context, index) {
                    final ticket = _inquiries[index];
                    Color statusColor;
                    switch (ticket.status) {
                      case 'Resolved':
                      case 'Closed':
                        statusColor = Colors.green;
                        break;
                      case 'In Progress':
                        statusColor = Colors.orange;
                        break;
                      default:
                        statusColor = Theme.of(context).primaryColor;
                    }

                    DateTime date = ticket.dateSubmitted;

                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  ticket.id,
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.grey,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: statusColor.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    ticket.status,
                                    style: TextStyle(
                                      color: statusColor,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Text(
                              ticket.subject,
                              style: Theme.of(context).textTheme.titleLarge,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Submitted on: ${DateFormat('MMM dd, yyyy').format(date)}',
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
      ),
    );
  }
}
