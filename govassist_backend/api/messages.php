<?php
// backend/api/messages.php

require_once 'cors.php';
require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    if (isset($_GET['ticket_id'])) {
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
