import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../models/service_model.dart';
import '../../widgets/custom_widgets.dart';

class RequirementsScreen extends StatefulWidget {
  final GovernmentService service;

  const RequirementsScreen({super.key, required this.service});

  @override
  State<RequirementsScreen> createState() => _RequirementsScreenState();
}

class _RequirementsScreenState extends State<RequirementsScreen> {
  final Map<String, bool> _checklistStatus = {};
  List<Requirement> _requirements = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchRequirements();
  }

  void _fetchRequirements() {
    final reqs = widget.service.requirements;
    if (mounted) {
      setState(() {
        _requirements = reqs;
        for (var req in _requirements) {
          _checklistStatus[req.id] = false;
        }
        _isLoading = false;
      });
    }
  }

  int get _completedCount {
    return _checklistStatus.values.where((v) => v == true).length;
  }

  double get _progress {
    if (_requirements.isEmpty) return 1.0;
    return _completedCount / _requirements.length;
  }

  bool get _allChecked {
    return _progress == 1.0;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Requirements Checklist'),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Prepare these documents for:',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8),
            Text(
              widget.service.title,
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 24),
            // Progress Bar
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Completion Progress',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
                ),
                Text(
                  '$_completedCount / ${_requirements.length}',
                  style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: _progress,
              backgroundColor: Colors.grey.shade300,
              color: Theme.of(context).primaryColor,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 32),
            Expanded(
              child: _requirements.isEmpty 
              ? const Text('No requirements needed for this service.')
              : ListView.builder(
                itemCount: _requirements.length,
                itemBuilder: (context, index) {
                  final req = _requirements[index];
                  final isChecked = _checklistStatus[req.id] ?? false;
                  
                  return ScannerItemCard(
                    requirement: req.name,
                    isVerified: isChecked,
                    onVerified: () {
                      setState(() {
                        _checklistStatus[req.id] = true;
                      });
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('Document successfully scanned and verified!'),
                          backgroundColor: Colors.green,
                          duration: Duration(seconds: 2),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: CustomButton(
            text: 'I have scanned all documents',
            onPressed: _allChecked
                ? () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('All requirements verified! You can now apply.')),
                    );
                    Navigator.pop(context);
                  }
                : () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Please scan and verify all documents first.')),
                    );
                  },
          ),
        ),
      ),
    );
  }
}

class ScannerItemCard extends StatefulWidget {
  final String requirement;
  final bool isVerified;
  final VoidCallback onVerified;

  const ScannerItemCard({
    super.key,
    required this.requirement,
    required this.isVerified,
    required this.onVerified,
  });

  @override
  State<ScannerItemCard> createState() => _ScannerItemCardState();
}

class _ScannerItemCardState extends State<ScannerItemCard> with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  bool _isScanning = false;
  String? _imagePath;
  late AnimationController _scanController;
  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _scanController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    );
    _scanController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isScanning = false;
          _isExpanded = false;
        });
        widget.onVerified();
      }
    });
  }

  @override
  void dispose() {
    _scanController.dispose();
    super.dispose();
  }

  Future<void> _startScan() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.camera);
      if (image == null) return; // User cancelled
      
      setState(() {
        _imagePath = image.path;
        _isScanning = true;
      });
      _scanController.forward(from: 0.0);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to open camera: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      shape: RoundedRectangleBorder(
        side: BorderSide(
          color: widget.isVerified ? Colors.green.shade300 : Colors.grey.shade300,
          width: widget.isVerified ? 1.5 : 1.0,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      color: widget.isVerified ? Colors.green.shade50 : Colors.white,
      child: InkWell(
        onTap: widget.isVerified || _isScanning
            ? null
            : () {
                setState(() {
                  _isExpanded = !_isExpanded;
                });
              },
        borderRadius: BorderRadius.circular(12),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  SizedBox(
                    height: 24,
                    width: 24,
                    child: Checkbox(
                      value: widget.isVerified,
                      onChanged: null, 
                      fillColor: WidgetStateProperty.resolveWith((states) {
                        if (states.contains(WidgetState.selected)) {
                          return Colors.green;
                        }
                        return Colors.grey.shade300;
                      }),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      widget.requirement,
                      style: TextStyle(
                        decoration: widget.isVerified ? TextDecoration.lineThrough : null,
                        fontWeight: widget.isVerified ? FontWeight.normal : FontWeight.w600,
                        color: widget.isVerified ? Colors.grey : Colors.black87,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  if (!widget.isVerified)
                    Icon(
                      _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
                      color: Colors.grey,
                    ),
                ],
              ),
            ),
            AnimatedCrossFade(
              firstChild: const SizedBox(width: double.infinity, height: 0),
              secondChild: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16.0, bottom: 16.0),
                child: Column(
                  children: [
                    Container(
                      height: 150,
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade100,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Stack(
                        children: [
                          if (_imagePath != null)
                            ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: SizedBox(
                                width: double.infinity,
                                height: double.infinity,
                                child: Image.file(
                                  File(_imagePath!),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            )
                          else
                            Center(
                              child: Icon(Icons.document_scanner_outlined, size: 48, color: Colors.grey.shade400),
                            ),
                          if (_isScanning)
                            AnimatedBuilder(
                              animation: _scanController,
                              builder: (context, child) {
                                return Positioned(
                                  top: _scanController.value * 146,
                                  left: 0,
                                  right: 0,
                                  child: Container(
                                    height: 4,
                                    decoration: BoxDecoration(
                                      color: Theme.of(context).primaryColor,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Theme.of(context).primaryColor.withOpacity(0.5),
                                          blurRadius: 10,
                                          spreadRadius: 2,
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 12),
                    if (!_isScanning)
                      ElevatedButton.icon(
                        onPressed: _startScan,
                        icon: const Icon(Icons.camera_alt),
                        label: const Text('Take Photo'),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                        ),
                      )
                    else
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 12.0),
                        child: Text(
                          'Verifying document...',
                          style: TextStyle(fontWeight: FontWeight.bold, color: Theme.of(context).primaryColor),
                        ),
                      ),
                  ],
                ),
              ),
              crossFadeState: _isExpanded ? CrossFadeState.showSecond : CrossFadeState.showFirst,
              duration: const Duration(milliseconds: 300),
            ),
          ],
        ),
      ),
    );
  }
}
