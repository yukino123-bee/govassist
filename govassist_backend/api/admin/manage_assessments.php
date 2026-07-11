<?php
// backend/api/admin/manage_assessments.php

require_once '../cors.php';
require_once '../db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        $stmt = $pdo->query("
            SELECT 
                a.id, 
                a.service_title, 
                a.date, 
                a.is_eligible, 
                a.reference_number,
                u.id as user_id,
                u.first_name,
                u.last_name,
                u.email
            FROM assessments a
            LEFT JOIN users u ON a.user_id = u.id
            ORDER BY a.date DESC
        ");
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
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>
