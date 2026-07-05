<?php
// backend/api/admin/manage_assessments.php
require_once '../cors.php';
require_once '../db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        $stmt = $pdo->query("
            SELECT * FROM assessments
            ORDER BY date DESC
        ");
        $assessments = $stmt->fetchAll();
        
        header('Content-Type: application/json');
        echo json_encode($assessments);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
}
?>
