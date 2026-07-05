class UploadedDocument {
  final String id;
  final String serviceId;
  final String requirementName;
  final String filePath;
  final String verificationStatus;
  final DateTime uploadedAt;

  final String? uploaderName;
  final String? uploaderEmail;

  UploadedDocument({
    required this.id,
    required this.serviceId,
    required this.requirementName,
    required this.filePath,
    required this.verificationStatus,
    required this.uploadedAt,
    this.uploaderName,
    this.uploaderEmail,
  });

  factory UploadedDocument.fromJson(Map<String, dynamic> json) {
    return UploadedDocument(
      id: json['id'].toString(),
      serviceId: json['service_id'].toString(),
      requirementName: json['requirement_name'] ?? '',
      filePath: json['file_path'] ?? '',
      verificationStatus: json['status'] ?? json['verification_status'] ?? 'Pending',
      uploadedAt: DateTime.parse(json['uploaded_at']),
      uploaderName: json['full_name'],
      uploaderEmail: json['email'],
    );
  }
}
