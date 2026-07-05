<?php
// backend/api/applications.php

require_once 'cors.php';
require_once 'db.php';
require_once 'auth_middleware.php';

$method = $_SERVER['REQUEST_METHOD'];

// Get user ID securely from JWT token
$user_id = getAuthenticatedUser();

if ($method === 'GET') {
    try {
        // Fetch all applications for user with service details
        $stmt = $pdo->prepare("
            SELECT a.*, s.title as service_title, s.titleLocal as service_titleLocal
            FROM applications a
            JOIN services s ON a.service_id = s.id
            WHERE a.user_id = ?
            ORDER BY a.submitted_at DESC
        ");
        $stmt->execute([$user_id]);
        $applications = $stmt->fetchAll();
        
        http_response_code(200);
        echo json_encode(['applications' => $applications]);
    } catch (PDOException $e) {
        error_log("Database error in applications.php GET: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'A database error occurred. Please try again later.']);
    }
} elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['service_id'])) {
        try {
            // 1. Validate profile completion
            $userStmt = $pdo->prepare("SELECT dob, address, civil_status, contact_number, valid_id_path FROM users WHERE id = ?");
            $userStmt->execute([$user_id]);
            $user = $userStmt->fetch();
            
            if (!$user || empty($user['dob']) || empty($user['address']) || empty($user['civil_status']) || empty($user['contact_number']) || empty($user['valid_id_path'])) {
                http_response_code(400);
                echo json_encode([
                    'error' => 'Profile incomplete. Please complete your profile (DOB, Address, Civil Status, Contact, Valid ID) before applying.',
                    'incomplete_profile' => true
                ]);
                exit();
            }
            
            // 2. Validate duplicate active application
            $dupStmt = $pdo->prepare("SELECT id FROM applications WHERE user_id = ? AND service_id = ? AND status IN ('pending', 'requirements_needed', 'approved')");
            $dupStmt->execute([$user_id, $input['service_id']]);
            if ($dupStmt->rowCount() > 0) {
                http_response_code(409); // Conflict
                echo json_encode(['error' => 'You already have an active application for this service.']);
                exit();
            }
            
            // 3. Insert application
            $insertStmt = $pdo->prepare("INSERT INTO applications (user_id, service_id, status, submitted_at, updated_at) VALUES (?, ?, 'pending', NOW(), NOW())");
            $insertStmt->execute([$user_id, $input['service_id']]);
            $application_id = $pdo->lastInsertId();
            
            // 4. Insert notification
            $notifStmt = $pdo->prepare("INSERT INTO notifications (user_id, title, message, type, created_at) VALUES (?, ?, ?, ?, NOW())");
            $notifStmt->execute([
                $user_id,
                'Application Submitted',
                'Your application has been submitted successfully and is now pending review.',
                'application_update'
            ]);
            
            http_response_code(200);
            echo json_encode(['success' => true, 'application_id' => $application_id]);
        } catch (PDOException $e) {
            error_log("Database error in applications.php POST: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'A database error occurred. Please try again later.']);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Service ID required']);
    }
}
?>
