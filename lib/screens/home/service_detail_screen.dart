import 'package:flutter/material.dart';
import '../../models/service_model.dart';
import '../../widgets/custom_widgets.dart';
import 'requirements_screen.dart';
import '../../core/user_session.dart';
import '../../data/service_data.dart';
import '../profile/edit_profile_screen.dart';
import '../../core/translations.dart';

class ServiceDetailScreen extends StatelessWidget {
  final GovernmentService service;

  const ServiceDetailScreen({super.key, required this.service});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Service Details'.tr()),
      ),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.title,
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 24),
                  SectionHeader(title: 'Description'.tr()),
                  const SizedBox(height: 8),
                  Text(
                    service.description,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  SectionHeader(title: 'Application Procedure'.tr()),
                  const SizedBox(height: 16),
                  Text(
                    service.procedures,
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => RequirementsScreen(service: service),
                          ),
                        );
                      },
                      icon: const Icon(Icons.checklist),
                      label: Text('View Requirements'.tr()),
                      style: OutlinedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  _ApplyButton(service: service),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ApplyButton extends StatefulWidget {
  final GovernmentService service;
  const _ApplyButton({required this.service});

  @override
  State<_ApplyButton> createState() => _ApplyButtonState();
}

class _ApplyButtonState extends State<_ApplyButton> {
  bool _isLoading = false;

  void _handleApply() async {
    final user = UserSession().currentUser;
    if (user == null) return;

    // Check completeness
    final isComplete = user['dob'] != null && user['dob'].toString().isNotEmpty &&
                       user['address'] != null && user['address'].toString().isNotEmpty &&
                       user['civil_status'] != null && user['civil_status'].toString().isNotEmpty &&
                       user['contact_number'] != null && user['contact_number'].toString().isNotEmpty &&
                       user['valid_id_path'] != null && user['valid_id_path'].toString().isNotEmpty;

    if (!isComplete) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Please complete your profile and upload a valid ID before applying.'.tr())),
      );
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const EditProfileScreen()),
      );
      return;
    }

    setState(() => _isLoading = true);
    final res = await ServiceData.submitApplication(user['id'].toString(), widget.service.id);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (res['success'] == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Application submitted successfully!'.tr())),
      );
      Navigator.pop(context); // Go back after applying
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(res['error'] ?? 'Application failed')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : CustomButton(
            text: 'Apply / Request Service'.tr(),
            onPressed: _handleApply,
          );
  }
}
