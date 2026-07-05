import 'package:flutter/material.dart';
import '../../widgets/custom_widgets.dart';
import '../../core/theme.dart';
import '../../data/service_data.dart';

class SubmitInquiryScreen extends StatefulWidget {
  const SubmitInquiryScreen({super.key});

  @override
  State<SubmitInquiryScreen> createState() => _SubmitInquiryScreenState();
}

class _SubmitInquiryScreenState extends State<SubmitInquiryScreen> {
  String? _selectedCategory;
  final TextEditingController _descController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  bool _isLoading = false;

  final List<String> _categories = [
    'Educational Assistance',
    'Burial Assistance',
    'Medical Assistance',
    'Employment Assistance',
    'Transportation Assistance',
    'Other'
  ];

  @override
  void dispose() {
    _descController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  void _submit() async {
    final subject = _subjectController.text.trim();
    final description = _descController.text.trim();

    if (_selectedCategory == null || subject.isEmpty || description.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all fields and select a category')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final success = await ServiceData.createInquiry(subject, _selectedCategory!, description);

    setState(() {
      _isLoading = false;
    });

    if (success) {
      if (mounted) {
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Inquiry submitted successfully!')),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Failed to submit inquiry. Please try again.')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Submit Inquiry'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'How can we help?',
              style: Theme.of(context).textTheme.displayMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'Please provide details about your issue or question.',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 32),
            CustomTextField(
              controller: _subjectController,
              label: 'Subject',
              hint: 'Brief summary of your inquiry',
            ),
            const SizedBox(height: 16),
            const Text(
              'Category',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              value: _selectedCategory,
              hint: const Text('Select a program or category'),
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Colors.grey.shade300),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide(color: Theme.of(context).primaryColor, width: 2),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              icon: const Icon(Icons.arrow_drop_down_rounded),
              items: _categories.map((category) {
                return DropdownMenuItem<String>(
                  value: category,
                  child: Text(category),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _selectedCategory = value;
                });
              },
            ),
            const SizedBox(height: 16),
            CustomTextField(
              controller: _descController,
              label: 'Description',
              hint: 'Provide as much detail as possible',
              maxLines: 5,
            ),
            const SizedBox(height: 32),
            _isLoading
                ? const Center(child: CircularProgressIndicator())
                : CustomButton(
                    text: 'Submit Inquiry',
                    onPressed: _submit,
                  ),
          ],
        ),
      ),
    );
  }
}
