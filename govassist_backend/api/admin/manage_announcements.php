<?php
// backend/api/admin/manage_announcements.php
require_once '../cors.php';
require_once '../db.php';
require_once '../auth_middleware.php';

// Only admins can manage announcements
$admin_id = getAuthenticatedUser();
$stmt = $pdo->prepare("SELECT is_admin FROM users WHERE id = ?");
$stmt->execute([$admin_id]);
$admin = $stmt->fetch();

if (!$admin || $admin['is_admin'] != 1) {
    http_response_code(403);
    echo json_encode(['error' => 'Forbidden: Admins only.']);
    exit();
}

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    // List all announcements
    try {
        $stmt = $pdo->query("SELECT * FROM announcements ORDER BY created_at DESC");
        $announcements = $stmt->fetchAll(PDO::FETCH_ASSOC);
        echo json_encode(['success' => true, 'announcements' => $announcements]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
    }
} elseif ($method === 'POST') {
    // Create new announcement
    $input = json_decode(file_get_contents('php://input'), true);
    if (!isset($input['title']) || !isset($input['content'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Missing title or content.']);
        exit();
    }
    
    try {
        $stmt = $pdo->prepare("INSERT INTO announcements (title, content) VALUES (?, ?)");
        $stmt->execute([$input['title'], $input['content']]);
        $id = $pdo->lastInsertId();
        
        $stmt = $pdo->prepare("SELECT * FROM announcements WHERE id = ?");
        $stmt->execute([$id]);
        $announcement = $stmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode(['success' => true, 'message' => 'Announcement created successfully', 'announcement' => $announcement]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
    }
} elseif ($method === 'PUT') {
    // Update existing announcement
    $input = json_decode(file_get_contents('php://input'), true);
    if (!isset($input['id']) || !isset($input['title']) || !isset($input['content'])) {
        http_response_code(400);
        echo json_encode(['error' => 'Missing id, title or content.']);
        exit();
    }
    
    try {
        $stmt = $pdo->prepare("UPDATE announcements SET title = ?, content = ? WHERE id = ?");
        $stmt->execute([$input['title'], $input['content'], $input['id']]);
        
        $stmt = $pdo->prepare("SELECT * FROM announcements WHERE id = ?");
        $stmt->execute([$input['id']]);
        $announcement = $stmt->fetch(PDO::FETCH_ASSOC);
        
        echo json_encode(['success' => true, 'message' => 'Announcement updated successfully', 'announcement' => $announcement]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
    }
} elseif ($method === 'DELETE') {
    // Delete announcement
    $id = isset($_GET['id']) ? $_GET['id'] : null;
    if (!$id) {
        http_response_code(400);
        echo json_encode(['error' => 'Missing announcement id.']);
        exit();
    }
    
    try {
        $stmt = $pdo->prepare("DELETE FROM announcements WHERE id = ?");
        $stmt->execute([$id]);
        echo json_encode(['success' => true, 'message' => 'Announcement deleted successfully']);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => 'Database error: ' . $e->getMessage()]);
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed.']);
}
?>
