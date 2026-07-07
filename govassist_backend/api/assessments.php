<?php
// backend/api/assessments.php

require_once 'cors.php';
require_once 'db.php';
require_once 'auth_middleware.php';

$user_id = getAuthenticatedUser();

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        $stmt = $pdo->prepare("SELECT id, service_title, date, is_eligible, reference_number FROM assessments WHERE user_id = ? ORDER BY date DESC");
        $stmt->execute([$user_id]);
        $assessments = $stmt->fetchAll();
        
        foreach ($assessments as &$assessment) {
            $assessment['is_eligible'] = (bool)$assessment['is_eligible'];
        }
        
        header('Content-Type: application/json');
        echo json_encode($assessments);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
} elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['serviceTitle']) && isset($input['isEligible']) && isset($input['date'])) {
        try {
            $stmt = $pdo->prepare("INSERT INTO assessments (user_id, service_title, is_eligible, date, reference_number) VALUES (?, ?, ?, ?, ?)");
            // Generate a random reference number
            $refNumber = 'REF-' . strtoupper(substr(md5(uniqid()), 0, 8));
            $isEligible = $input['isEligible'] ? 1 : 0;
            $formattedDate = date('Y-m-d H:i:s', strtotime($input['date']));
            
            $stmt->execute([
                $user_id,
                $input['serviceTitle'],
                $isEligible,
                $formattedDate,
                $refNumber
            ]);
            
            http_response_code(200);
            echo json_encode(['success' => true, 'reference_number' => $refNumber]);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid input']);
    }
}
?>
