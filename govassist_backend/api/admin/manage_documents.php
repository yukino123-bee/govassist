<?php
// backend/api/admin/manage_documents.php
require_once '../cors.php';
require_once '../db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        $stmt = $pdo->query("
            SELECT d.*, u.full_name, u.email, s.title as service_title 
            FROM uploaded_documents d
            LEFT JOIN users u ON d.user_id = u.id
            LEFT JOIN services s ON d.service_id = s.id
            ORDER BY d.upload_date DESC
        ");
        $documents = $stmt->fetchAll();
        
        header('Content-Type: application/json');
        echo json_encode($documents);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
} elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (isset($input['id'], $input['status'])) {
        try {
            $stmt = $pdo->prepare("UPDATE uploaded_documents SET verification_status = ? WHERE id = ?");
            $stmt->execute([$input['status'], $input['id']]);
            
            http_response_code(200);
            echo json_encode(['success' => true]);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    }
}
?>
