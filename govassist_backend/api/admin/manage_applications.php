<?php
// backend/api/admin/manage_applications.php

require_once '../cors.php';
require_once '../db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        $stmt = $pdo->prepare("
            SELECT a.id, a.user_id, a.service_id, a.status, a.submitted_at, a.updated_at,
                   u.full_name, u.email,
                   s.title as service_title
            FROM applications a
            JOIN users u ON a.user_id = u.id
            JOIN services s ON a.service_id = s.id
            ORDER BY a.submitted_at DESC
        ");
        $stmt->execute();
        $applications = $stmt->fetchAll();
        
        echo json_encode(['applications' => $applications]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
} elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['application_id']) && isset($input['status'])) {
        try {
            $pdo->beginTransaction();
            
            $stmt = $pdo->prepare("UPDATE applications SET status = ?, updated_at = NOW() WHERE id = ?");
            $stmt->execute([$input['status'], $input['application_id']]);
            
            // Get user_id for notification
            $appStmt = $pdo->prepare("SELECT user_id, service_id FROM applications WHERE id = ?");
            $appStmt->execute([$input['application_id']]);
            $application = $appStmt->fetch();
            
            if ($application) {
                $serviceStmt = $pdo->prepare("SELECT title FROM services WHERE id = ?");
                $serviceStmt->execute([$application['service_id']]);
                $service = $serviceStmt->fetch();
                
                $title = "Application Update";
                $message = "Your application for " . $service['title'] . " is now: " . ucfirst($input['status']) . ".";
                
                $notifStmt = $pdo->prepare("INSERT INTO notifications (user_id, title, message, type, created_at) VALUES (?, ?, ?, ?, NOW())");
                $notifStmt->execute([
                    $application['user_id'],
                    $title,
                    $message,
                    'application_update'
                ]);
            }
            
            $pdo->commit();
            
            http_response_code(200);
            echo json_encode(['success' => true]);
        } catch (PDOException $e) {
            $pdo->rollBack();
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Missing application_id or status']);
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>
