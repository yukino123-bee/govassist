import 'package:flutter/material.dart';
import '../../core/user_session.dart';
import 'admin_sidebar.dart';
import 'admin_documents_screen.dart';
import 'admin_applications_screen.dart';
import '../../data/service_data.dart';
import '../../models/service_model.dart';
import 'package:intl/intl.dart';

class AdminDashboardScreen extends StatefulWidget {
  const AdminDashboardScreen({super.key});

  @override
  State<AdminDashboardScreen> createState() => _AdminDashboardScreenState();
}

class _AdminDashboardScreenState extends State<AdminDashboardScreen> {
  String _currentRoute = 'Documents';

  void _logout() {
    UserSession().clearSession();
    Navigator.of(context).pushReplacementNamed('/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      body: Row(
        children: [
          AdminSidebar(
            currentRoute: _currentRoute,
            onNavigate: (route) {
              setState(() {
                _currentRoute = route;
              });
            },
            onSignOut: _logout,
          ),
          Expanded(
            child: Column(
              children: [
                // Top App Bar
                Container(
                  height: 64,
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                    border: Border(bottom: BorderSide(color: Colors.black12)),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      CircleAvatar(
                        radius: 16,
                        backgroundColor: Theme.of(context).primaryColor,
                        child: const Text('A', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Admin User',
                        style: TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ],
                  ),
                ),
                // Main Content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: _buildContent(),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() {
    switch (_currentRoute) {
      case 'Applications':
        return const AdminApplicationsScreen();
      case 'Documents':
        return const AdminDocumentsScreen();
      case 'Dashboard':
      case 'Inquiries':
        return const AdminInquiriesScreen(); // Keeping the old inquiries logic in a separated widget
      default:
        return Center(
          child: Text(
            '$_currentRoute is under construction.',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
        );
    }
  }
}

// Separated the old inquiries list logic here so it isn't lost
class AdminInquiriesScreen extends StatefulWidget {
  const AdminInquiriesScreen({super.key});

  @override
  State<AdminInquiriesScreen> createState() => _AdminInquiriesScreenState();
}

class _AdminInquiriesScreenState extends State<AdminInquiriesScreen> {
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
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manage Inquiries',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a2b4c),
          ),
        ),
        const SizedBox(height: 24),
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: _fetchInquiries,
                  child: _inquiries.isEmpty
                      ? const Center(child: Text("No inquiries found."))
                      : ListView.builder(
                          itemCount: _inquiries.length,
                          itemBuilder: (context, index) {
                            final ticket = _inquiries[index];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 12),
                              child: ListTile(
                                title: Text(ticket.subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                                subtitle: Text('Status: ${ticket.status}\nSubmitted: ${DateFormat('MMM dd, yyyy').format(ticket.dateSubmitted)}'),
                                isThreeLine: true,
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                  decoration: BoxDecoration(
                                    color: ticket.status == 'Closed' ? Colors.green.withValues(alpha: 0.1) : Colors.orange.withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    ticket.status,
                                    style: TextStyle(
                                      color: ticket.status == 'Closed' ? Colors.green : Colors.orange,
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(content: Text('Admin viewing ticket: ${ticket.id}')),
                                  );
                                },
                              ),
                            );
                          },
                        ),
                ),
        ),
      ],
    );
  }
}
