<?php
// backend/api/admin_get_documents.php

require_once 'cors.php';
require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        // Fetch all documents and join with users to get the uploader's name
        $stmt = $pdo->prepare("
            SELECT d.id, d.user_id, d.service_id, d.requirement_name, d.file_path, d.status, d.uploaded_at,
                   u.full_name, u.email
            FROM documents d
            LEFT JOIN users u ON d.user_id = u.id
            ORDER BY d.uploaded_at DESC
        ");
        $stmt->execute();
        $documents = $stmt->fetchAll();
        
        header('Content-Type: application/json');
        echo json_encode($documents);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
}
?>
