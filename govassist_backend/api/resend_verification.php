<?php
// backend/api/resend_verification.php

require_once 'cors.php';
require_once 'db.php';
require_once 'mailer.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['email'])) {
        try {
            $stmt = $pdo->prepare("SELECT id, email_verified_at FROM users WHERE email = ?");
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

            // Generate new OTP
            $verificationCode = sprintf("%06d", mt_rand(1, 999999));

            // Update user with new OTP
            $updateStmt = $pdo->prepare("UPDATE users SET verification_code = ? WHERE id = ?");
            $updateStmt->execute([$verificationCode, $user['id']]);

            // Send actual email asynchronously to avoid blocking the user
            $emailSent = sendVerificationEmailAsync($input['email'], $verificationCode);

            http_response_code(200);
            echo json_encode([
                'success' => true, 
                'message' => 'Verification code resent. Please check your email.',
                'email_sent' => $emailSent,
                'mock_email_otp' => $verificationCode // For testing
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
