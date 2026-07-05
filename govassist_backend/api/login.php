<?php
// backend/api/login.php

require_once 'cors.php';
require_once 'db.php';
require_once 'jwt.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['email']) && isset($input['password'])) {
        try {
            $stmt = $pdo->prepare("SELECT id, full_name, email, password_hash, email_verified_at, is_admin, dob, address, civil_status, contact_number, profile_picture FROM users WHERE email = ?");
            $stmt->execute([$input['email']]);
            
            if ($stmt->rowCount() > 0) {
                $user = $stmt->fetch();
                
                if (password_verify($input['password'], $user['password_hash'])) {
                    if ($user['email_verified_at'] === null) {
                        http_response_code(403); // Forbidden
                        echo json_encode(['error' => 'Email not verified', 'unverified' => true]);
                        exit();
                    }
                    
                    // Remove password_hash before sending back to client
                    unset($user['password_hash']);
                    
                    // Generate JWT
                    $token = JWT::encode(['user_id' => $user['id']]);
                    
                    http_response_code(200);
                    echo json_encode([
                        'success' => true, 
                        'token' => $token,
                        'user' => $user
                    ]);
                } else {
                    http_response_code(401); // Unauthorized
                    echo json_encode(['error' => 'Invalid email or password']);
                }
            } else {
                http_response_code(401); // Unauthorized
                echo json_encode(['error' => 'Invalid email or password']);
            }
        } catch (PDOException $e) {
            error_log("Database error in login.php: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'A database error occurred. Please try again later.']);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Email and password required']);
    }
}
?>
