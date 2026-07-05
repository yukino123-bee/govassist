<?php
// backend/api/verify_email.php

require_once 'cors.php';
require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['email']) && isset($input['code'])) {
        try {
            $stmt = $pdo->prepare("SELECT id, verification_code, email_verified_at FROM users WHERE email = ?");
            $stmt->execute([$input['email']]);
            $user = $stmt->fetch();
            
            if (!$user) {
                http_response_code(404);
                echo json_encode(['error' => 'User not found']);
                exit();
            }

            if ($user['email_verified_at'] !== null) {
                http_response_code(400);
                echo json_encode(['error' => 'Email is already verified']);
                exit();
            }

            if ($user['verification_code'] !== $input['code']) {
                http_response_code(400);
                echo json_encode(['error' => 'Invalid verification code']);
                exit();
            }

            // Code matches, update the user
            $updateStmt = $pdo->prepare("UPDATE users SET email_verified_at = ?, verification_code = NULL WHERE id = ?");
            $updateStmt->execute([date('Y-m-d H:i:s'), $user['id']]);

            http_response_code(200);
            echo json_encode(['success' => true, 'message' => 'Email verified successfully']);
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
