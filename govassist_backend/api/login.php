<?php
// backend/api/login.php

require_once 'cors.php';
require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['email']) && isset($input['password'])) {
        try {
            $stmt = $pdo->prepare("SELECT id, full_name, email, password_hash, is_admin FROM users WHERE email = ?");
            $stmt->execute([$input['email']]);
            
            if ($stmt->rowCount() > 0) {
                $user = $stmt->fetch();
                
                if (password_verify($input['password'], $user['password_hash'])) {
                    // Remove password_hash before sending back to client
                    unset($user['password_hash']);
                    
                    http_response_code(200);
                    echo json_encode([
                        'success' => true, 
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
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Email and password required']);
    }
}
?>
