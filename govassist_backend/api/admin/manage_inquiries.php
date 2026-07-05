<?php
// backend/api/admin/manage_inquiries.php

require_once '../cors.php';
require_once '../db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    // Return all inquiries
    try {
        $stmt = $pdo->query("SELECT * FROM inquiries ORDER BY date_submitted DESC");
        $inquiries = $stmt->fetchAll();
        
        header('Content-Type: application/json');
        echo json_encode($inquiries);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
} elseif ($method === 'POST') {
    // Add a response to an inquiry and optionally change status
    $input = json_decode(file_get_contents('php://input'), true);
    if (isset($input['ticket_id'], $input['message_text'])) {
        try {
            // Insert admin response
            $stmt = $pdo->prepare("
                INSERT INTO messages (ticket_id, message_text, is_user, timestamp) 
                VALUES (?, ?, ?, ?)
            ");
            $stmt->execute([
                $input['ticket_id'],
                $input['message_text'],
                0, // 0 for admin/system response
                date('Y-m-d H:i:s')
            ]);
            
            // Update status if provided
            if (isset($input['status'])) {
                $statusStmt = $pdo->prepare("UPDATE inquiries SET status = ? WHERE id = ?");
                $statusStmt->execute([$input['status'], $input['ticket_id']]);
            }
            
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
