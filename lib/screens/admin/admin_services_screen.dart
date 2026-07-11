import 'package:flutter/material.dart';
import '../../data/service_data.dart';
import '../../models/service_model.dart';
import 'admin_service_editor_screen.dart';

class AdminServicesScreen extends StatefulWidget {
  const AdminServicesScreen({super.key});

  @override
  State<AdminServicesScreen> createState() => _AdminServicesScreenState();
}

class _AdminServicesScreenState extends State<AdminServicesScreen> {
  List<GovernmentService> _services = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    setState(() => _isLoading = true);
    final services = await ServiceData.fetchServices(forceRefresh: true);
    if (mounted) {
      setState(() {
        _services = services;
        _isLoading = false;
      });
    }
  }

  Future<void> _deleteService(GovernmentService service) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Service'),
        content: Text('Are you sure you want to delete "${service.title}"? This will also delete all associated requirements and eligibility questions.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            style: TextButton.styleFrom(foregroundColor: Colors.red),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm == true) {
      setState(() => _isLoading = true);
      final result = await ServiceData.adminDeleteService(service.id);
      
      if (mounted) {
        if (result['success'] == true) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Service deleted successfully')),
          );
          _fetchServices();
        } else {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Failed to delete: ${result['error']}')),
          );
        }
      }
    }
  }

  void _openEditor({GovernmentService? service}) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AdminServiceEditorScreen(service: service),
      ),
    );

    if (result == true) {
      _fetchServices();
    }
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
                'Manage Services',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              ElevatedButton.icon(
                onPressed: () => _openEditor(),
                icon: const Icon(Icons.add),
                label: const Text('Add New Service'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF1E3A8A),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _services.isEmpty
                    ? const Center(child: Text('No services found. Add one!'))
                    : ListView.builder(
                        itemCount: _services.length,
                        itemBuilder: (context, index) {
                          final service = _services[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 16),
                            elevation: 2,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: ListTile(
                              contentPadding: const EdgeInsets.all(16),
                              leading: CircleAvatar(
                                backgroundColor: const Color(0xFF1E3A8A).withValues(alpha: 0.1),
                                child: const Icon(Icons.home_repair_service, color: Color(0xFF1E3A8A)),
                              ),
                              title: Text(
                                service.title,
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              ),
                              subtitle: Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      service.description,
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    const SizedBox(height: 8),
                                    Row(
                                      children: [
                                        Chip(
                                          label: Text('${service.requirements.length} Requirements'),
                                          backgroundColor: Colors.blue.shade50,
                                          labelStyle: TextStyle(color: Colors.blue.shade900, fontSize: 12),
                                          padding: EdgeInsets.zero,
                                        ),
                                        const SizedBox(width: 8),
                                        Chip(
                                          label: Text('${service.eligibilityQuestions.length} Questions'),
                                          backgroundColor: Colors.green.shade50,
                                          labelStyle: TextStyle(color: Colors.green.shade900, fontSize: 12),
                                          padding: EdgeInsets.zero,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: const Icon(Icons.edit, color: Colors.blue),
                                    onPressed: () => _openEditor(service: service),
                                    tooltip: 'Edit Service',
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red),
                                    onPressed: () => _deleteService(service),
                                    tooltip: 'Delete Service',
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
    );
  }
}
