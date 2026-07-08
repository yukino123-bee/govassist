<?php
// backend/api/register.php

require_once 'cors.php';
require_once 'db.php';
require_once 'mailer.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['fullName']) && isset($input['email']) && isset($input['password'])) {
        try {
            // Check if email already exists
            $checkStmt = $pdo->prepare("SELECT id FROM users WHERE email = ?");
            $checkStmt->execute([$input['email']]);
            if ($checkStmt->rowCount() > 0) {
                http_response_code(409); // Conflict
                echo json_encode(['error' => 'Email already registered']);
                exit();
            }

            // Hash the password securely
            $passwordHash = password_hash($input['password'], PASSWORD_DEFAULT);
            $verificationCode = sprintf("%06d", mt_rand(1, 999999));
            
            $stmt = $pdo->prepare("INSERT INTO users (full_name, email, password_hash, created_at, verification_code) VALUES (?, ?, ?, ?, ?)");
            $stmt->execute([
                $input['fullName'],
                $input['email'],
                $passwordHash,
                date('Y-m-d H:i:s'),
                $verificationCode
            ]);
            
            // Send actual email asynchronously to avoid blocking the user
            $emailSent = sendVerificationEmailAsync($input['email'], $verificationCode);
            
            http_response_code(200);
            echo json_encode([
                'success' => true,
                'message' => 'Registration successful. Please check your email for the OTP.',
                'email_sent' => $emailSent
            ]);
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
