import 'package:flutter/material.dart';
import '../../core/theme.dart';
import '../../data/service_data.dart';
import '../../models/uploaded_document_model.dart';
import 'package:intl/intl.dart';

class AdminDocumentsScreen extends StatefulWidget {
  const AdminDocumentsScreen({super.key});

  @override
  State<AdminDocumentsScreen> createState() => _AdminDocumentsScreenState();
}

class _AdminDocumentsScreenState extends State<AdminDocumentsScreen> {
  bool _isLoading = true;
  String? _error;
  List<UploadedDocument> _documents = [];

  @override
  void initState() {
    super.initState();
    _loadDocuments();
  }

  Future<void> _loadDocuments() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final docs = await ServiceData.fetchAllDocuments();
      if (mounted) {
        setState(() {
          _documents = docs;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = 'Error loading documents.';
          _isLoading = false;
        });
      }
    }
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'verified':
        return AppTheme.successColor;
      case 'rejected':
        return AppTheme.errorColor;
      default:
        return AppTheme.accentColor; // Pending
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Manage Documents',
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Color(0xFF1a2b4c), // Dark blue-ish standard color
          ),
        ),
        const SizedBox(height: 24),
        if (_isLoading)
          const Expanded(child: Center(child: CircularProgressIndicator()))
        else if (_error != null)
          Expanded(
            child: Text(
              _error!,
              style: const TextStyle(color: Colors.black87),
            ),
          )
        else if (_documents.isEmpty)
          const Expanded(
            child: Center(
              child: Text(
                'No documents found.',
                style: TextStyle(color: Colors.grey),
              ),
            ),
          )
        else
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: SingleChildScrollView(
                  child: DataTable(
                    headingRowColor: WidgetStateProperty.all(Colors.grey.shade50),
                    columns: const [
                      DataColumn(label: Text('ID')),
                      DataColumn(label: Text('Uploader')),
                      DataColumn(label: Text('Requirement')),
                      DataColumn(label: Text('Date')),
                      DataColumn(label: Text('Status')),
                      DataColumn(label: Text('Action')),
                    ],
                    rows: _documents.map((doc) {
                      return DataRow(
                        cells: [
                          DataCell(Text('#${doc.id}')),
                          DataCell(
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(doc.uploaderName ?? 'Unknown', style: const TextStyle(fontWeight: FontWeight.bold)),
                                Text(doc.uploaderEmail ?? 'No email', style: TextStyle(fontSize: 12, color: Colors.grey.shade600)),
                              ],
                            ),
                          ),
                          DataCell(Text(doc.requirementName)),
                          DataCell(Text(DateFormat('MMM dd, yyyy').format(doc.uploadedAt))),
                          DataCell(
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              decoration: BoxDecoration(
                                color: _getStatusColor(doc.verificationStatus).withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: _getStatusColor(doc.verificationStatus)),
                              ),
                              child: Text(
                                doc.verificationStatus,
                                style: TextStyle(
                                  color: _getStatusColor(doc.verificationStatus),
                                  fontWeight: FontWeight.bold,
                                  fontSize: 12,
                                ),
                              ),
                            ),
                          ),
                          DataCell(
                            TextButton(
                              onPressed: () => _showReviewDialog(doc),
                              child: const Text('Review'),
                            ),
                          ),
                        ],
                      );
                    }).toList(),
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }

  void _showReviewDialog(UploadedDocument doc) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Review Document: ${doc.requirementName}'),
          content: SizedBox(
            width: double.maxFinite,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Uploader: ${doc.uploaderName}'),
                Text('Date: ${DateFormat('MMM dd, yyyy').format(doc.uploadedAt)}'),
                const SizedBox(height: 16),
                Expanded(
                  child: InteractiveViewer(
                    child: Image.network(
                      '${ServiceData.baseUrl}/uploads/${doc.filePath}',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => const Text('Image not found or could not be loaded.'),
                    ),
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                _updateStatus(doc.id, 'Rejected');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.errorColor, foregroundColor: Colors.white),
              child: const Text('Reject'),
            ),
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                _updateStatus(doc.id, 'Verified');
              },
              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.successColor, foregroundColor: Colors.white),
              child: const Text('Approve'),
            ),
          ],
        );
      },
    );
  }

  Future<void> _updateStatus(String docId, String status) async {
    setState(() => _isLoading = true);
    final result = await ServiceData.updateDocumentStatus(docId, status);
    if (mounted) {
      if (result['success'] == true) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Document status updated to $status')));
        _loadDocuments();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error updating status: ${result['error']}')));
        setState(() => _isLoading = false);
      }
    }
  }
}
