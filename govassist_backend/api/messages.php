<?php
// backend/api/messages.php

require_once 'cors.php';
require_once 'db.php';
require_once 'auth_middleware.php';

$user_id = getAuthenticatedUser();

// Check if user is admin
$isAdmin = false;
try {
    $adminStmt = $pdo->prepare("SELECT is_admin FROM users WHERE id = ?");
    $adminStmt->execute([$user_id]);
    $userRow = $adminStmt->fetch();
    if ($userRow && isset($userRow['is_admin']) && $userRow['is_admin'] == 1) {
        $isAdmin = true;
    }
} catch (PDOException $e) {
    // Ignore error, assume not admin
}

function userOwnsTicket($pdo, $ticketId, $userId) {
    $stmt = $pdo->prepare("SELECT id FROM inquiries WHERE id = ? AND user_id = ?");
    $stmt->execute([$ticketId, $userId]);
    return $stmt->rowCount() > 0;
}

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    if (isset($_GET['ticket_id'])) {
        $ticketId = $_GET['ticket_id'];
        
        if (!$isAdmin && !userOwnsTicket($pdo, $ticketId, $user_id)) {
            http_response_code(403);
            echo json_encode(['error' => 'Access denied']);
            exit();
        }

        try {
            $stmt = $pdo->prepare("SELECT id, message_text, is_user, timestamp FROM messages WHERE ticket_id = ? ORDER BY timestamp ASC");
            $stmt->execute([$_GET['ticket_id']]);
            $messages = $stmt->fetchAll();
            
            foreach ($messages as &$msg) {
                $msg['is_user'] = (bool)$msg['is_user'];
            }
            
            header('Content-Type: application/json');
            echo json_encode($messages);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'ticket_id parameter is missing']);
    }
} elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['ticketId']) && isset($input['text']) && isset($input['isUser']) && isset($input['timestamp'])) {
        $ticketId = $input['ticketId'];
        
        if (!$isAdmin && !userOwnsTicket($pdo, $ticketId, $user_id)) {
            http_response_code(403);
            echo json_encode(['error' => 'Access denied']);
            exit();
        }

        try {
            $stmt = $pdo->prepare("INSERT INTO messages (ticket_id, message_text, is_user, timestamp) VALUES (?, ?, ?, ?)");
            
            $stmt->execute([
                $input['ticketId'],
                $input['text'],
                $input['isUser'] ? 1 : 0,
                $input['timestamp']
            ]);
            
            http_response_code(200);
            echo json_encode(['success' => true]);
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
