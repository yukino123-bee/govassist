import 'package:flutter/material.dart';
import '../../data/service_data.dart';
import '../../models/service_model.dart';

class AdminServiceEditorScreen extends StatefulWidget {
  final GovernmentService? service;

  const AdminServiceEditorScreen({super.key, this.service});

  @override
  State<AdminServiceEditorScreen> createState() => _AdminServiceEditorScreenState();
}

class _AdminServiceEditorScreenState extends State<AdminServiceEditorScreen> {
  final _formKey = GlobalKey<FormState>();
  
  // Basic Info Controllers
  late TextEditingController _titleCtrl;
  late TextEditingController _titleLocalCtrl;
  late TextEditingController _descCtrl;
  late TextEditingController _descLocalCtrl;
  late TextEditingController _procCtrl;
  late TextEditingController _procLocalCtrl;
  
  String _categoryId = 'cat_1';

  // Requirements List
  List<Map<String, dynamic>> _requirements = [];
  
  // Eligibility Questions List
  List<Map<String, dynamic>> _eligibilityQuestions = [];

  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    final s = widget.service;
    
    _titleCtrl = TextEditingController(text: s?.title ?? '');
    _titleLocalCtrl = TextEditingController(text: s?.titleLocal ?? '');
    _descCtrl = TextEditingController(text: s?.description ?? '');
    _descLocalCtrl = TextEditingController(text: s?.descriptionLocal ?? '');
    _procCtrl = TextEditingController(text: s?.procedures ?? '');
    _procLocalCtrl = TextEditingController(text: s?.proceduresLocal ?? '');
    
    if (s != null) {
      _categoryId = s.categoryId;
      
      _requirements = s.requirements.map((r) => {
        'name': r.name,
        'isRequired': r.isRequired ? 1 : 0,
      }).toList();
      
      _eligibilityQuestions = s.eligibilityQuestions.map((q) => {
        'questionText': q.questionText,
        'expectedAnswer': q.expectedAnswer,
        'options': q.options,
      }).toList();
    }
  }

  @override
  void dispose() {
    _titleCtrl.dispose();
    _titleLocalCtrl.dispose();
    _descCtrl.dispose();
    _descLocalCtrl.dispose();
    _procCtrl.dispose();
    _procLocalCtrl.dispose();
    super.dispose();
  }

  Future<void> _saveService() async {
    if (!_formKey.currentState!.validate()) return;
    
    setState(() => _isSaving = true);
    
    final payload = {
      'title': _titleCtrl.text.trim(),
      'titleLocal': _titleLocalCtrl.text.trim(),
      'description': _descCtrl.text.trim(),
      'descriptionLocal': _descLocalCtrl.text.trim(),
      'procedures': _procCtrl.text.trim(),
      'proceduresLocal': _procLocalCtrl.text.trim(),
      'categoryId': _categoryId,
      'requirements': _requirements,
      'eligibilityQuestions': _eligibilityQuestions,
    };

    Map<String, dynamic> result;
    if (widget.service == null) {
      result = await ServiceData.adminCreateService(payload);
    } else {
      payload['id'] = widget.service!.id;
      result = await ServiceData.adminUpdateService(payload);
    }

    if (mounted) {
      setState(() => _isSaving = false);
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Service saved successfully')),
        );
        Navigator.pop(context, true); // Return true to refresh list
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error saving: ${result['error']}')),
        );
      }
    }
  }

  void _addRequirement() {
    setState(() {
      _requirements.add({'name': '', 'isRequired': 1});
    });
  }

  void _addEligibilityQuestion() {
    setState(() {
      _eligibilityQuestions.add({
        'questionText': '',
        'expectedAnswer': '1',
        'options': null,
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: AppBar(
          title: Text(widget.service == null ? 'Add New Service' : 'Edit Service'),
          backgroundColor: const Color(0xFF1E3A8A),
          foregroundColor: Colors.white,
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: Colors.white,
            tabs: [
              Tab(text: 'Basic Info'),
              Tab(text: 'Requirements'),
              Tab(text: 'Questions'),
            ],
          ),
          actions: [
            if (_isSaving)
              const Padding(
                padding: EdgeInsets.all(16.0),
                child: SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                ),
              )
            else
              IconButton(
                icon: const Icon(Icons.save),
                onPressed: _saveService,
                tooltip: 'Save Service',
              ),
          ],
        ),
        body: Form(
          key: _formKey,
          child: TabBarView(
            children: [
              _buildBasicInfoTab(),
              _buildRequirementsTab(),
              _buildQuestionsTab(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildBasicInfoTab() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: _titleCtrl,
            decoration: const InputDecoration(labelText: 'Title (English) *', border: OutlineInputBorder()),
            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _titleLocalCtrl,
            decoration: const InputDecoration(labelText: 'Title (Local Dialect)', border: OutlineInputBorder()),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descCtrl,
            decoration: const InputDecoration(labelText: 'Description (English) *', border: OutlineInputBorder()),
            maxLines: 3,
            validator: (value) => value == null || value.isEmpty ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _descLocalCtrl,
            decoration: const InputDecoration(labelText: 'Description (Local Dialect)', border: OutlineInputBorder()),
            maxLines: 3,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _procCtrl,
            decoration: const InputDecoration(labelText: 'Procedures (English)', border: OutlineInputBorder()),
            maxLines: 5,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _procLocalCtrl,
            decoration: const InputDecoration(labelText: 'Procedures (Local Dialect)', border: OutlineInputBorder()),
            maxLines: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildRequirementsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Required Documents', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _addRequirement,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _requirements.isEmpty
              ? const Center(child: Text('No requirements added yet.'))
              : ListView.builder(
                  itemCount: _requirements.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Row(
                          children: [
                            Expanded(
                              child: TextFormField(
                                initialValue: _requirements[index]['name'],
                                decoration: InputDecoration(
                                  labelText: 'Requirement Name ${index + 1}',
                                  border: const OutlineInputBorder(),
                                ),
                                onChanged: (val) => _requirements[index]['name'] = val,
                              ),
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                setState(() => _requirements.removeAt(index));
                              },
                            )
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildQuestionsTab() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Eligibility Questions', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ElevatedButton.icon(
                onPressed: _addEligibilityQuestion,
                icon: const Icon(Icons.add),
                label: const Text('Add'),
              ),
            ],
          ),
        ),
        Expanded(
          child: _eligibilityQuestions.isEmpty
              ? const Center(child: Text('No eligibility questions added yet.'))
              : ListView.builder(
                  itemCount: _eligibilityQuestions.length,
                  itemBuilder: (context, index) {
                    return Card(
                      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: TextFormField(
                                    initialValue: _eligibilityQuestions[index]['questionText'],
                                    decoration: InputDecoration(
                                      labelText: 'Question Text ${index + 1}',
                                      border: const OutlineInputBorder(),
                                    ),
                                    maxLines: 2,
                                    onChanged: (val) => _eligibilityQuestions[index]['questionText'] = val,
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete, color: Colors.red),
                                  onPressed: () {
                                    setState(() => _eligibilityQuestions.removeAt(index));
                                  },
                                )
                              ],
                            ),
                            const SizedBox(height: 8),
                            TextFormField(
                              initialValue: _eligibilityQuestions[index]['expectedAnswer'],
                              decoration: const InputDecoration(
                                labelText: 'Expected Answer (e.g., 1 for Yes, 0 for No)',
                                border: OutlineInputBorder(),
                              ),
                              onChanged: (val) => _eligibilityQuestions[index]['expectedAnswer'] = val,
                            ),
                            // Options input could be added here if needed, keeping it simple for now
                          ],
                        ),
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }
}
