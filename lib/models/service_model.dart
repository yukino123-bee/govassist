class ServiceCategory {
  final String id;
  final String title;
  final String iconAsset;

  ServiceCategory({
    required this.id,
    required this.title,
    required this.iconAsset,
  });
}

class GovernmentService {
  final String id;
  final String categoryId;
  final String title;
  final String titleLocal;
  final String description;
  final String descriptionLocal;
  final String procedures;
  final String proceduresLocal;
  final List<Requirement> requirements;
  final List<EligibilityQuestion> eligibilityQuestions;

  GovernmentService({
    required this.id,
    required this.categoryId,
    required this.title,
    required this.titleLocal,
    required this.description,
    required this.descriptionLocal,
    required this.procedures,
    required this.proceduresLocal,
    required this.requirements,
    required this.eligibilityQuestions,
  });
}

class Requirement {
  final String id;
  final String serviceId;
  final String name;
  final String nameLocal;
  final String description;
  final String descriptionLocal;
  final bool isRequired;

  Requirement({
    required this.id,
    required this.serviceId,
    required this.name,
    required this.nameLocal,
    required this.description,
    required this.descriptionLocal,
    this.isRequired = true,
  });
}

class EligibilityQuestion {
  final String id;
  final String serviceId;
  final String questionText;
  final String questionTextLocal;
  final String expectedAnswer;
  final List<String>? options;

  EligibilityQuestion({
    required this.id,
    required this.serviceId,
    required this.questionText,
    required this.questionTextLocal,
    required this.expectedAnswer,
    this.options,
  });
}

class AssessmentHistory {
  final String id;
  final String serviceTitle;
  final DateTime date;
  final bool isEligible;
  final String referenceNumber;

  AssessmentHistory({
    required this.id,
    required this.serviceTitle,
    required this.date,
    required this.isEligible,
    required this.referenceNumber,
  });
}

class FaqItem {
  final String question;
  final String answer;

  FaqItem({
    required this.question,
    required this.answer,
  });
}

class InquiryTicket {
  final String id;
  final String subject;
  final String status;
  final DateTime dateSubmitted;

  InquiryTicket({
    required this.id,
    required this.subject,
    required this.status,
    required this.dateSubmitted,
  });
}

class InquiryMessage {
  final String id;
  final String text;
  final bool isUser;
  final DateTime timestamp;

  InquiryMessage({
    required this.id,
    required this.text,
    required this.isUser,
    required this.timestamp,
  });
}
