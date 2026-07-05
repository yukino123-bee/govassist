<?php
require_once 'db.php';

$faqs = [
    // Physical Location & Contact
    ['question' => 'Where is the municipal office located?', 'answer' => 'The Municipal Office is located at the Town Hall, Poblacion. You can visit us during office hours from Monday to Friday, 8:00 AM to 5:00 PM.'],
    ['question' => 'How can I inquire directly to the Admin?', 'answer' => 'You can submit a manual inquiry using the "Edit Document" icon at the top right of this screen, or visit the MSWDO Help Desk at the Municipal Hall.'],
    ['question' => 'What are your office hours?', 'answer' => 'We are open from Monday to Friday, 8:00 AM to 5:00 PM, excluding regular holidays.'],
    ['question' => 'Is there a contact number for emergencies?', 'answer' => 'For extreme emergencies, you can contact the Municipal Disaster Risk Reduction and Management Office (MDRRMO) hotline. For regular assistance, please visit the MSWDO office.'],
    ['question' => 'Who do I look for when I arrive at the municipal office?', 'answer' => 'Proceed directly to the Municipal Social Welfare and Development Office (MSWDO) and approach the front desk officer.'],
    
    // General Process
    ['question' => 'How do I apply for assistance?', 'answer' => 'To apply, select the specific assistance program from the Home screen, pass the Eligibility Assessment, and upload the required documents. Once approved, you will be notified.'],
    ['question' => 'How long does the approval process take?', 'answer' => 'The approval process usually takes 3 to 5 working days depending on the volume of applications and the completeness of your submitted documents.'],
    ['question' => 'How will I know if my application is approved?', 'answer' => 'You can track the status of your application in your Profile under "My Documents" or "Assessments". You will also see status updates in the app.'],
    ['question' => 'Can I apply for multiple assistance programs at once?', 'answer' => 'Yes, you can apply for multiple programs provided you meet the specific eligibility requirements for each program.'],
    ['question' => 'Do I need to pay any fees to apply?', 'answer' => 'No. Application for all municipal social welfare assistance programs is completely free of charge.'],
    ['question' => 'What happens if my application is rejected?', 'answer' => 'If your application is rejected, you will be informed of the reason. You may reapply once you have resolved the issues, such as providing correct or updated documents.'],
    ['question' => 'Can someone else apply on my behalf?', 'answer' => 'Yes, an immediate family member can apply on your behalf provided they have an Authorization Letter and a photocopy of your valid ID.'],
    
    // Eligibility General
    ['question' => 'Who is eligible for these programs?', 'answer' => 'Eligibility varies per program, but the primary requirement is that you must be a bona fide resident of the municipality.'],
    ['question' => 'How do you verify my residency?', 'answer' => 'Residency is verified through your Barangay Certificate of Residency and your Voter\'s ID.'],
    ['question' => 'I am a new resident. Can I apply?', 'answer' => 'Generally, you must be a resident for at least 6 months to 1 year. Please present a Certificate of Residency from your Barangay Captain.'],
    ['question' => 'Do you cater to senior citizens?', 'answer' => 'Yes, we have specialized programs and priority lanes for Senior Citizens. Ensure you have your Senior Citizen ID registered with OSCA.'],
    ['question' => 'Do you cater to Persons with Disabilities (PWD)?', 'answer' => 'Yes. PWDs are eligible for various forms of assistance. A valid PWD ID issued by the municipality is required.'],
    
    // Medical Assistance
    ['question' => 'What is Medical Assistance?', 'answer' => 'Medical Assistance provides financial help to indigent residents to cover hospital bills, medicines, and medical procedures.'],
    ['question' => 'What are the requirements for Medical Assistance?', 'answer' => 'You will need a Medical Certificate or Clinical Abstract, a Statement of Account from the hospital, a Barangay Certificate of Indigency, and a valid ID.'],
    ['question' => 'Can I use Medical Assistance for purchasing medicines?', 'answer' => 'Yes. You must provide a valid Doctor\'s Prescription along with the price quotation from the pharmacy.'],
    ['question' => 'Does Medical Assistance cover surgery?', 'answer' => 'Yes, surgical procedures are covered. You must submit the surgical quotation and medical abstract.'],
    ['question' => 'Can I apply for Medical Assistance while currently admitted to the hospital?', 'answer' => 'Yes, you can apply. You will need a partial Statement of Account from the hospital billing section.'],
    ['question' => 'Is Medical Assistance given in cash?', 'answer' => 'No. Medical Assistance is usually given as a Guarantee Letter (GL) addressed to the partner hospital or pharmacy.'],
    ['question' => 'Which hospitals accept the Guarantee Letter?', 'answer' => 'We partner with the Provincial Hospital and several government hospitals. Please check the MSWDO for the updated list of partner private hospitals.'],
    
    // Educational Assistance
    ['question' => 'What is Educational Assistance?', 'answer' => 'It is a financial grant given to indigent but deserving students to help them with their tuition and school fees.'],
    ['question' => 'Who can apply for Educational Assistance?', 'answer' => 'College students and Senior High School students who are residents of the municipality and belong to low-income families.'],
    ['question' => 'What are the requirements for Educational Assistance?', 'answer' => 'Requirements include a Certificate of Enrollment (Registration Form), a valid School ID, Report Card or copy of grades, and a Barangay Certificate of Indigency.'],
    ['question' => 'Is there a grade requirement for the scholarship?', 'answer' => 'Yes, applicants must have a passing general weighted average and no failing grades or incomplete marks in the previous semester.'],
    ['question' => 'When is the deadline for Educational Assistance?', 'answer' => 'Application periods open twice a year, usually in August (1st Semester) and January (2nd Semester). Watch out for announcements.'],
    ['question' => 'Do I need to re-apply every semester?', 'answer' => 'Yes. Educational Assistance must be renewed every semester by submitting your latest grades and new certificate of enrollment.'],
    ['question' => 'Is Educational Assistance given in cash?', 'answer' => 'Depending on the program rules, it may be given as a cash payout to the student or as a voucher directly to the school.'],
    
    // Burial Assistance
    ['question' => 'What is Burial Assistance?', 'answer' => 'Burial Assistance is financial support provided to the bereaved family of a deceased resident to help cover funeral expenses.'],
    ['question' => 'What are the requirements for Burial Assistance?', 'answer' => 'You need the Registered Death Certificate, Funeral Contract, Barangay Certificate of Indigency, and the claimant\'s Valid ID.'],
    ['question' => 'Who can claim the Burial Assistance?', 'answer' => 'The claimant must be an immediate family member of the deceased (spouse, child, parent, or sibling).'],
    ['question' => 'How much is the Burial Assistance?', 'answer' => 'The amount varies depending on the current municipal budget and the assessment of the social worker, usually ranging from PHP 3,000 to PHP 5,000.'],
    ['question' => 'Is there a time limit to apply for Burial Assistance?', 'answer' => 'Yes, claims must typically be filed within 30 days from the date of death of the deceased.'],
    ['question' => 'Can I still apply if the burial has already taken place?', 'answer' => 'Yes, as long as you apply within the 30-day period and provide all necessary receipts and documents.'],
    
    // Employment Assistance
    ['question' => 'What is Employment Assistance?', 'answer' => 'Employment Assistance involves job referrals, skills training endorsements, and livelihood program support for unemployed residents.'],
    ['question' => 'What are the requirements for Employment Assistance?', 'answer' => 'Prepare your Personal Data Sheet (PDS) or Resume, a valid ID, and your Barangay Clearance.'],
    ['question' => 'Do you provide direct hiring?', 'answer' => 'The municipal office coordinates with the Public Employment Service Office (PESO) for job matching and referrals to private companies and government agencies.'],
    ['question' => 'Can I get capital for a small business?', 'answer' => 'Yes, through the Livelihood Assistance program. You will need to submit a project proposal or attend skills training first.'],
    ['question' => 'Are there programs for Out-of-School Youth (OSY)?', 'answer' => 'Yes. OSY can be endorsed to TESDA for skills training or integrated into the Special Program for Employment of Students (SPES) during summer.'],
    
    // Transportation Assistance
    ['question' => 'What is Transportation Assistance?', 'answer' => 'It is financial aid given to individuals who are stranded, victims of pickpockets, or indigents who need to travel for medical referrals or returning to their home province.'],
    ['question' => 'What are the requirements for Transportation Assistance?', 'answer' => 'You need a valid ID, a Barangay Blotter (if victim of a crime), or a medical referral (if traveling for health reasons).'],
    ['question' => 'How is Transportation Assistance released?', 'answer' => 'Usually, the MSWDO will purchase the bus or boat ticket directly for the client to ensure the assistance is used for travel.'],
    ['question' => 'Can I get Transportation Assistance to go abroad?', 'answer' => 'No. Transportation Assistance is only strictly for domestic travel within the Philippines for emergency or essential purposes.'],
    
    // Technical/App Issues
    ['question' => 'I forgot my password, what should I do?', 'answer' => 'Currently, please ask the admin at the MSWDO office to manually reset your account, or create a new account if you haven\'t uploaded files yet.'],
    ['question' => 'My document upload failed, what do I do?', 'answer' => 'Ensure your file size is not too large and that your internet connection is stable. Try logging out and logging back in.'],
    ['question' => 'The voice bot is not functioning, how do I fix it?', 'answer' => 'Please ensure you have granted microphone permissions to the GovAssist app in your phone settings.'],
    ['question' => 'Can I change my profile information?', 'answer' => 'Yes, go to the Profile tab, update your details, and tap the "Save Changes" button.'],
    ['question' => 'Is my personal data secure?', 'answer' => 'Yes, your data is securely stored in the municipal database and is only accessible by authorized social workers and administrators in compliance with the Data Privacy Act.'],
    ['question' => 'Who developed this GovAssist app?', 'answer' => 'The GovAssist app was developed to digitize and streamline the social welfare services of the municipality for the convenience of the residents.']
];

try {
    // Clear existing FAQs
    $pdo->exec("TRUNCATE TABLE faqs");

    // Prepare insert statement
    $stmt = $pdo->prepare("INSERT INTO faqs (question, answer) VALUES (:question, :answer)");

    // Insert all FAQs
    foreach ($faqs as $faq) {
        $stmt->execute([
            ':question' => $faq['question'],
            ':answer' => $faq['answer']
        ]);
    }

    echo "Successfully seeded " . count($faqs) . " FAQs into the database.\n";
} catch (PDOException $e) {
    echo "Database Error: " . $e->getMessage() . "\n";
}
?>
