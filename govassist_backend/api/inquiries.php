<?php
// backend/api/inquiries.php

require_once 'cors.php';
require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        $stmt = $pdo->query("SELECT id, subject, status, date_submitted FROM inquiries ORDER BY date_submitted DESC");
        $inquiries = $stmt->fetchAll();
        
        header('Content-Type: application/json');
        echo json_encode($inquiries);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
} elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['subject']) && isset($input['description']) && isset($input['status']) && isset($input['dateSubmitted'])) {
        try {
            $pdo->beginTransaction();
            
            $stmt = $pdo->prepare("INSERT INTO inquiries (id, subject, status, date_submitted) VALUES (?, ?, ?, ?)");
            $ticketId = 'TKT-' . strtoupper(substr(md5(uniqid()), 0, 6));
            
            $stmt->execute([
                $ticketId,
                $input['subject'],
                $input['status'],
                $input['dateSubmitted']
            ]);
            
            // Also insert the initial message (description)
            $msgStmt = $pdo->prepare("INSERT INTO messages (ticket_id, message_text, is_user, timestamp) VALUES (?, ?, ?, ?)");
            $msgStmt->execute([
                $ticketId,
                $input['description'],
                1, // is_user = true
                $input['dateSubmitted']
            ]);
            
            $pdo->commit();
            
            http_response_code(200);
            echo json_encode(['success' => true, 'ticket_id' => $ticketId]);
        } catch (PDOException $e) {
            $pdo->rollBack();
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid input']);
    }
}
?>
