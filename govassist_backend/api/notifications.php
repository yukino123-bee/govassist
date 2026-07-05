<?php
// backend/api/notifications.php

require_once 'cors.php';
require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

// Function to get user_id from token or session (For now, we'll assume it's passed via query param or headers, 
// but since the original app doesn't use JWT in the example, we'll check query param or POST body)
// In a real app, this should use a secure session/token.
function getUserId() {
    if (isset($_GET['user_id'])) return $_GET['user_id'];
    $input = json_decode(file_get_contents('php://input'), true);
    if (isset($input['user_id'])) return $input['user_id'];
    return null;
}

$user_id = getUserId();
if (!$user_id) {
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized. User ID required.']);
    exit();
}

if ($method === 'GET') {
    try {
        // Fetch all notifications for the user, ordered by newest first
        $stmt = $pdo->prepare("SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC");
        $stmt->execute([$user_id]);
        $notifications = $stmt->fetchAll();
        
        // Count unread
        $unreadStmt = $pdo->prepare("SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = 0");
        $unreadStmt->execute([$user_id]);
        $unreadCount = $unreadStmt->fetchColumn();
        
        http_response_code(200);
        echo json_encode([
            'notifications' => $notifications,
            'unreadCount' => $unreadCount
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
} elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['action']) && $input['action'] === 'mark_read') {
        try {
            if (isset($input['notification_id'])) {
                // Mark specific as read
                $stmt = $pdo->prepare("UPDATE notifications SET is_read = 1 WHERE user_id = ? AND id = ?");
                $stmt->execute([$user_id, $input['notification_id']]);
            } else {
                // Mark all as read
                $stmt = $pdo->prepare("UPDATE notifications SET is_read = 1 WHERE user_id = ?");
                $stmt->execute([$user_id]);
            }
            
            http_response_code(200);
            echo json_encode(['success' => true]);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid action']);
    }
}
?>
