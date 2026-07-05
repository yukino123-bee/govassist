<?php
// backend/api/services.php

require_once 'cors.php';
require_once 'db.php';

try {
    // Fetch all services
    $stmt = $pdo->query("SELECT * FROM services");
    $services = $stmt->fetchAll();

    // Fetch requirements for each service
    $reqStmt = $pdo->prepare("SELECT * FROM requirements WHERE service_id = ?");
    
    // Fetch eligibility questions for each service
    $eqStmt = $pdo->prepare("SELECT * FROM eligibility_questions WHERE service_id = ?");
    
    foreach ($services as &$service) {
        // Requirements
        $reqStmt->execute([$service['id']]);
        $service['requirements'] = $reqStmt->fetchAll();
        
        // Ensure boolean types are handled for JSON (MySQL returns tinyint as string '1' or '0')
        foreach ($service['requirements'] as &$req) {
            $req['is_required'] = (bool)$req['is_required'];
        }
        
        // Eligibility Questions
        $eqStmt->execute([$service['id']]);
        $questions = $eqStmt->fetchAll();
        
        foreach ($questions as &$q) {
            $q['expected_answer'] = (bool)$q['expected_answer'];
            if ($q['options']) {
                $q['options'] = json_decode($q['options'], true);
            }
        }
        $service['eligibilityQuestions'] = $questions;
    }
    
    header('Content-Type: application/json');
    echo json_encode($services);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
?>
