<?php
// backend/api/get_documents.php
require_once 'cors.php';
require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    if (isset($_GET['user_id'])) {
        try {
            $stmt = $pdo->prepare("SELECT * FROM uploaded_documents WHERE user_id = ? ORDER BY uploaded_at DESC");
            $stmt->execute([$_GET['user_id']]);
            $documents = $stmt->fetchAll();
            
            http_response_code(200);
            echo json_encode($documents);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'user_id is required']);
    }
}
?>
