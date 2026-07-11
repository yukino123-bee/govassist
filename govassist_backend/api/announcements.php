<?php
// backend/api/announcements.php
require_once 'cors.php';
require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        $stmt = $pdo->query("SELECT id, title, content, created_at, updated_at FROM announcements ORDER BY created_at DESC");
        $announcements = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode(['success' => true, 'announcements' => $announcements]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed.']);
}
?>
