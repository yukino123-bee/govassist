import sys
import json
import re

def analyze_inquiry(subject, description):
    text = (subject + " " + description).lower()
    
    # Basic keyword-based classification since Ollama might be laggy
    categories = {
        "Educational Assistance": ["school", "tuition", "student", "education", "enrollment", "scholarship", "college"],
        "Medical Assistance": ["hospital", "sick", "health", "medical", "doctor", "medicine", "bill", "treatment", "clinic"],
        "Burial Assistance": ["death", "funeral", "burial", "cemetery", "coffin"],
        "Employment Assistance": ["job", "work", "unemployed", "employment", "hiring", "resume"],
        "Transportation Assistance": ["fare", "ticket", "travel", "transport", "bus", "jeepney", "train"]
    }
    
    detected_category = "General"
    max_score = 0
    
    for category, keywords in categories.items():
        score = sum(1 for keyword in keywords if keyword in text)
        if score > max_score:
            max_score = score
            detected_category = category
            
    # Generate automated AI response
    if detected_category == "Educational Assistance":
        response = "Thank you for reaching out regarding Educational Assistance. Please ensure you have uploaded your school ID, certificate of registration, and latest grades in the documents section. Our evaluator will review your ticket shortly."
    elif detected_category == "Medical Assistance":
        response = "We received your request for Medical Assistance. Please upload the medical certificate or hospital bill to expedite the processing of your request. A social worker will contact you if further verification is needed."
    elif detected_category == "Burial Assistance":
        response = "Our deepest condolences. For Burial Assistance, please provide a copy of the death certificate and funeral contract. Your request has been queued for immediate review."
    elif detected_category == "Employment Assistance":
        response = "Thank you for your inquiry about Employment Assistance. Our PESO office reviews these requests. Please ensure your profile is updated and your resume is uploaded."
    elif detected_category == "Transportation Assistance":
        response = "Your request for Transportation Assistance has been logged. Please upload a valid ID and proof of travel purpose (if applicable). We will update your ticket soon."
    else:
        response = "Thank you for contacting GovAssist. We have received your inquiry and our support team will get back to you as soon as possible. Please ensure any related documents are uploaded to your profile."
        
    # Formatting output for PHP to consume
    output = {
        "category": detected_category,
        "ai_response": f"[GovAssist AI]: {response}"
    }
    
    print(json.dumps(output))

if __name__ == "__main__":
    if len(sys.argv) > 2:
        subject = sys.argv[1]
        description = sys.argv[2]
        analyze_inquiry(subject, description)
    else:
        print(json.dumps({"error": "Insufficient arguments"}))
