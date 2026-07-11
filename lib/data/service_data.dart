import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../models/service_model.dart';
import '../models/uploaded_document_model.dart';
import 'dart:io';

class ServiceData {
  // Production Backend URL
  static const String baseUrl = 'http://govassist.atwebpages.com';

  static String? _token;

  static Map<String, String> get _headers {
    final headers = {'Content-Type': 'application/json'};
    if (_token != null) {
      headers['Authorization'] = 'Bearer $_token';
    }
    return headers;
  }

  static Future<List<ServiceCategory>> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/categories.php'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse
            .map(
              (data) => ServiceCategory(
                id: data['id'],
                title: data['title'],
                iconAsset: data['iconAsset'],
              ),
            )
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching categories: $e');
      return [];
    }
  }

  static List<GovernmentService>? _cachedServices;

  static Future<List<GovernmentService>> fetchServices({
    String query = '',
    bool forceRefresh = false,
  }) async {
    if (!forceRefresh && _cachedServices != null && query.isEmpty) {
      return _cachedServices!;
    }

    try {
      String url = '$baseUrl/services.php';
      if (query.isNotEmpty) {
        url += '?search=${Uri.encodeComponent(query)}';
      }
      final response = await http.get(Uri.parse(url), headers: _headers);
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        final parsedServices = jsonResponse.map((data) {
          return GovernmentService(
            id: data['id'],
            categoryId: data['category_id'],
            title: data['title'],
            titleLocal: data['titleLocal'] ?? '',
            description: data['description'] ?? '',
            descriptionLocal: data['descriptionLocal'] ?? '',
            procedures: data['procedures'] ?? '',
            proceduresLocal: data['proceduresLocal'] ?? '',
            requirements: (data['requirements'] as List? ?? [])
                .map(
                  (req) => Requirement(
                    id: req['id'],
                    serviceId: req['service_id'],
                    name: req['name'],
                    nameLocal: req['nameLocal'] ?? '',
                    description: req['description'] ?? '',
                    descriptionLocal: req['descriptionLocal'] ?? '',
                    isRequired:
                        req['is_required'] == 1 || req['is_required'] == true,
                  ),
                )
                .toList(),
            eligibilityQuestions: (data['eligibilityQuestions'] as List? ?? [])
                .map(
                  (q) => EligibilityQuestion(
                    id: q['id'],
                    serviceId: q['service_id'],
                    questionText: q['question_text'],
                    questionTextLocal: q['question_textLocal'] ?? '',
                    expectedAnswer: q['expected_answer'].toString(),
                    options: q['options'] != null
                        ? List<String>.from(q['options'])
                        : null,
                  ),
                )
                .toList(),
          );
        }).toList();
        
        if (query.isEmpty) {
          _cachedServices = parsedServices;
        }
        return parsedServices;
      } else {
        return [];
      }
    } catch (e) {
      debugPrint('Error fetching services: $e');
      return [];
    }
  }

  static Future<List<FaqItem>> fetchFaqs() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/faqs.php'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse
            .map(
              (data) =>
                  FaqItem(question: data['question'], answer: data['answer']),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching FAQs: $e');
    }
    return [];
  }

  static Future<List<AssessmentHistory>> fetchAssessments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/assessments.php'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse
            .map(
              (data) => AssessmentHistory(
                id: data['id'].toString(),
                serviceTitle: data['service_title'],
                date: DateTime.parse(data['date']),
                isEligible: data['is_eligible'] == 1 || data['is_eligible'] == true,
                referenceNumber: data['reference_number']?.toString() ?? '',
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching assessments: $e');
    }
    return [];
  }

  static Future<bool> saveAssessment(
    String serviceTitle,
    bool isEligible,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/assessments.php'),
        headers: _headers,
        body: json.encode({
          'serviceTitle': serviceTitle,
          'isEligible': isEligible,
          'date': DateTime.now().toIso8601String(),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error saving assessment: $e');
      return false;
    }
  }

  static Future<List<InquiryTicket>> fetchInquiries() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/inquiries.php'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse
            .map(
              (data) => InquiryTicket(
                id: data['id'].toString(),
                subject: data['subject'],
                status: data['status'],
                dateSubmitted: DateTime.parse(data['date_submitted']),
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching inquiries: $e');
    }
    return [];
  }

  static Future<bool> createInquiry(
    String subject,
    String category,
    String description,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/inquiries.php'),
        headers: _headers,
        body: json.encode({
          'subject': '[$category] $subject',
          'description': description,
          'status': 'Open',
          'dateSubmitted': DateTime.now().toIso8601String(),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error creating inquiry: $e');
      return false;
    }
  }

  static Future<List<InquiryMessage>> fetchMessages(String ticketId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/messages.php?ticket_id=$ticketId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse
            .map(
              (data) => InquiryMessage(
                id: data['id'].toString(),
                text: data['message_text'],
                isUser: data['is_user'] == 1 || data['is_user'] == true,
                timestamp: DateTime.parse(data['timestamp']),
              ),
            )
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching messages: $e');
    }
    return [];
  }

  static Future<bool> sendMessage(String ticketId, String text) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/messages.php'),
        headers: _headers,
        body: json.encode({
          'ticketId': ticketId,
          'text': text,
          'isUser': true,
          'timestamp': DateTime.now().toIso8601String(),
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      debugPrint('Error sending message: $e');
      return false;
    }
  }

  // DOCUMENT UPLOADS

  static Future<List<UploadedDocument>> fetchUploadedDocuments(
    String userId,
  ) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/get_documents.php?user_id=$userId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((data) => UploadedDocument.fromJson(data))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching documents: $e');
    }
    return [];
  }

  static Future<List<UploadedDocument>> fetchAllDocuments() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin_get_documents.php'),
      );
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        return jsonResponse
            .map((data) => UploadedDocument.fromJson(data))
            .toList();
      }
    } catch (e) {
      debugPrint('Error fetching all documents: $e');
    }
    return [];
  }

  static Future<Map<String, dynamic>> uploadDocument(
    String userId,
    String serviceId,
    String requirementName,
    File document,
  ) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/upload.php'),
      );
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }
      request.fields['user_id'] = userId;
      request.fields['service_id'] = serviceId;
      request.fields['requirement_name'] = requirementName;

      request.files.add(
        await http.MultipartFile.fromPath('document', document.path),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      return json.decode(responseData);
    } catch (e) {
      return {'status': 'error', 'message': 'Upload error: $e'};
    }
  }

  // AUTHENTICATION

  static Future<Map<String, dynamic>> login(
    String email,
    String password,
  ) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/login.php'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({'email': email, 'password': password}),
          )
          .timeout(const Duration(seconds: 20));

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        if (data['token'] != null) {
          _token = data['token'];
        }
        return {'success': true, 'user': data['user']};
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Login failed',
          'unverified': data['unverified'] ?? false,
        };
      }
    } catch (e) {
      debugPrint('Error during login: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> register({
    required String fullName,
    required String email,
    required String password,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/register.php'),
            headers: {'Content-Type': 'application/json'},
            body: json.encode({
              'fullName': fullName,
              'email': email,
              'password': password,
            }),
          )
          .timeout(const Duration(seconds: 20));

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true};
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      debugPrint('Error during registration: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> verifyEmail(
    String email,
    String code,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/verify_email.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email, 'code': code}),
      );
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? data['error'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> resendVerification(String email) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/resend_verification.php'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({'email': email}),
      );
      final data = json.decode(response.body);
      return {
        'success': response.statusCode == 200,
        'message': data['message'] ?? data['error'],
      };
    } catch (e) {
      return {'success': false, 'message': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> fetchProfile() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile.php'),
        headers: _headers,
      );
      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['profile'] != null) {
        return {'success': true, 'user': data['profile']};
      }
      return {'success': false, 'error': data['error'] ?? 'Failed to fetch profile'};
    } catch (e) {
      return {'success': false, 'error': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> updateProfile({
    required String userId,
    required String fullName,
    required String email,
    String? password,
    String? dob,
    String? address,
    String? civilStatus,
    String? contactNumber,
    dynamic
    idImage, // Can be File or XFile depending on platform, usually dart:io File
    dynamic profilePicture,
  }) async {
    try {
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('$baseUrl/profile.php'),
      );
      if (_token != null) {
        request.headers['Authorization'] = 'Bearer $_token';
      }

      request.fields['user_id'] = userId;
      request.fields['full_name'] = fullName;
      request.fields['email'] = email;

      if (password != null && password.isNotEmpty) {
        request.fields['password'] = password;
      }
      if (dob != null && dob.isNotEmpty) {
        request.fields['dob'] = dob;
      }
      if (address != null && address.isNotEmpty) {
        request.fields['address'] = address;
      }
      if (civilStatus != null && civilStatus.isNotEmpty) {
        request.fields['civil_status'] = civilStatus;
      }
      if (contactNumber != null && contactNumber.isNotEmpty) {
        request.fields['contact_number'] = contactNumber;
      }

      if (idImage != null) {
        request.files.add(
          await http.MultipartFile.fromPath('valid_id', idImage.path),
        );
      }

      if (profilePicture != null) {
        request.files.add(
          await http.MultipartFile.fromPath(
            'profile_picture',
            profilePicture.path,
          ),
        );
      }

      final streamedResponse = await request.send().timeout(
        const Duration(seconds: 20),
      );
      final response = await http.Response.fromStream(streamedResponse);

      final data = json.decode(response.body);
      if (response.statusCode == 200 && data['success'] == true) {
        return {'success': true, 'user': data['user']};
      } else {
        return {
          'success': false,
          'error': data['error'] ?? 'Profile update failed',
        };
      }
    } catch (e) {
      debugPrint('Error during profile update: $e');
      return {'success': false, 'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> fetchNotifications(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/notifications.php?user_id=$userId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'error': 'Failed to fetch notifications'};
    } catch (e) {
      return {'error': 'Network error'};
    }
  }

  static Future<bool> markNotificationRead(
    String userId, {
    String? notificationId,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/notifications.php'),
        headers: _headers,
        body: json.encode({
          'user_id': userId,
          'action': 'mark_read',
          'notification_id': notificationId,
        }),
      );
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }

  static Future<Map<String, dynamic>> getProfile(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/profile.php?user_id=$userId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'error': 'Failed to fetch profile'};
    } catch (e) {
      return {'error': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> submitApplication(
    String userId,
    String serviceId,
  ) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/applications.php'),
        headers: _headers,
        body: json.encode({'user_id': userId, 'service_id': serviceId}),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> fetchApplications(String userId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/applications.php?user_id=$userId'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'error': 'Failed to load applications'};
    } catch (e) {
      return {'error': 'Network error'};
    }
  }

  // ADMIN APPLICATION ENDPOINTS
  static Future<Map<String, dynamic>> fetchAdminApplications() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/admin/manage_applications.php'),
        headers: _headers,
      );
      if (response.statusCode == 200) {
        return json.decode(response.body);
      }
      return {'error': 'Failed to load applications'};
    } catch (e) {
      return {'error': 'Network error'};
    }
  }

  static Future<Map<String, dynamic>> updateApplicationStatus(String applicationId, String status) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/manage_applications.php'),
        headers: _headers,
        body: json.encode({
          'application_id': applicationId,
          'status': status,
        }),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Network error'};
    }
  }

  // ADMIN SERVICE MANAGEMENT API
  static Future<Map<String, dynamic>> adminCreateService(Map<String, dynamic> payload) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/admin/manage_services.php'),
        headers: _headers,
        body: json.encode(payload),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> adminUpdateService(Map<String, dynamic> payload) async {
    try {
      final response = await http.put(
        Uri.parse('$baseUrl/admin/manage_services.php'),
        headers: _headers,
        body: json.encode(payload),
      );
      return json.decode(response.body);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  static Future<Map<String, dynamic>> adminDeleteService(String serviceId) async {
    try {
      final request = http.Request('DELETE', Uri.parse('$baseUrl/admin/manage_services.php'));
      request.headers.addAll(_headers);
      request.body = json.encode({'id': serviceId});
      final response = await request.send();
      final respStr = await response.stream.bytesToString();
      return json.decode(respStr);
    } catch (e) {
      return {'error': 'Network error: $e'};
    }
  }

  // GOVBOT API
  static Future<String> sendGovBotQuery(String message) async {
    try {
      final response = await http
          .post(
            Uri.parse('$baseUrl/govbot.php'),
            headers: _headers,
            body: json.encode({'message': message}),
          )
          .timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['response'] ?? 'Sorry, I could not process your request.';
      }
      return 'Sorry, my server is currently unavailable.';
    } catch (e) {
      return 'Sorry, I am having trouble connecting to the network.';
    }
  }
}
