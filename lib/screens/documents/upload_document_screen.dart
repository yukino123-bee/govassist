import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../../core/theme.dart';
import '../../data/service_data.dart';
import '../../models/service_model.dart';
import '../../core/user_session.dart';

class UploadDocumentScreen extends StatefulWidget {
  const UploadDocumentScreen({super.key});

  @override
  State<UploadDocumentScreen> createState() => _UploadDocumentScreenState();
}

class _UploadDocumentScreenState extends State<UploadDocumentScreen> {
  final _formKey = GlobalKey<FormState>();
  final _requirementController = TextEditingController();
  
  List<GovernmentService> _services = [];
  String? _selectedServiceId;
  File? _selectedFile;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadServices();
  }

  Future<void> _loadServices() async {
    final services = await ServiceData.fetchServices();
    setState(() {
      _services = services;
    });
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    
    if (pickedFile != null) {
      setState(() {
        _selectedFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitUpload() async {
    if (!_formKey.currentState!.validate() || _selectedFile == null || _selectedServiceId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please complete all fields and select a document.')),
      );
      return;
    }

    setState(() => _isLoading = true);
    final userId = UserSession().currentUser?['id']?.toString() ?? '';

    if (userId.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('User not logged in.')));
      setState(() => _isLoading = false);
      return;
    }

    final response = await ServiceData.uploadDocument(
      userId,
      _selectedServiceId!,
      _requirementController.text,
      _selectedFile!,
    );

    setState(() => _isLoading = false);

    if (mounted) {
      if (response['status'] == 'success') {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document uploaded successfully!')),
        );
        Navigator.pop(context, true);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response['message'] ?? 'Upload failed.')),
        );
      }
    }
  }

  @override
  void dispose() {
    _requirementController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Upload Document')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('Select Service:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    DropdownButtonFormField<String>(
                      value: _selectedServiceId,
                      decoration: const InputDecoration(border: OutlineInputBorder()),
                      hint: const Text('Select a Service'),
                      items: _services.map((srv) {
                        return DropdownMenuItem(
                          value: srv.id,
                          child: Text(srv.title),
                        );
                      }).toList(),
                      onChanged: (val) => setState(() => _selectedServiceId = val),
                      validator: (val) => val == null ? 'Please select a service' : null,
                    ),
                    const SizedBox(height: 16),
                    const Text('Requirement Name:', style: TextStyle(fontWeight: FontWeight.bold)),
                    const SizedBox(height: 8),
                    TextFormField(
                      controller: _requirementController,
                      decoration: const InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'e.g., Valid ID, Medical Certificate',
                      ),
                      validator: (val) => val!.isEmpty ? 'Please enter requirement name' : null,
                    ),
                    const SizedBox(height: 24),
                    Container(
                      height: 150,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade200,
                        border: Border.all(color: Colors.grey.shade400, style: BorderStyle.solid),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _selectedFile != null
                          ? Stack(
                              children: [
                                Positioned.fill(
                                  child: Image.file(_selectedFile!, fit: BoxFit.cover),
                                ),
                                Positioned(
                                  top: 8,
                                  right: 8,
                                  child: IconButton(
                                    icon: const Icon(Icons.close, color: Colors.white),
                                    onPressed: () => setState(() => _selectedFile = null),
                                    style: IconButton.styleFrom(backgroundColor: Colors.black54),
                                  ),
                                ),
                              ],
                            )
                          : InkWell(
                              onTap: _pickImage,
                              child: const Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.add_photo_alternate, size: 50, color: Colors.grey),
                                  SizedBox(height: 8),
                                  Text('Tap to select document image', style: TextStyle(color: Colors.grey)),
                                ],
                              ),
                            ),
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryColor,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _submitUpload,
                      child: const Text('Submit Document', style: TextStyle(fontSize: 16)),
                    ),
                  ],
                ),
              ),
            ),
    );
  }
}
