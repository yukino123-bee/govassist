<?php
// backend/api/update_profile.php

require_once 'cors.php';
require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['user_id']) && isset($input['fullName']) && isset($input['email'])) {
        try {
            if (!empty($input['password'])) {
                // Update with password
                $passwordHash = password_hash($input['password'], PASSWORD_DEFAULT);
                $stmt = $pdo->prepare("UPDATE users SET full_name = ?, email = ?, password_hash = ? WHERE id = ?");
                $stmt->execute([$input['fullName'], $input['email'], $passwordHash, $input['user_id']]);
            } else {
                // Update without password
                $stmt = $pdo->prepare("UPDATE users SET full_name = ?, email = ? WHERE id = ?");
                $stmt->execute([$input['fullName'], $input['email'], $input['user_id']]);
            }
            
            // Fetch updated user info
            $stmt = $pdo->prepare("SELECT id, full_name, email, is_admin FROM users WHERE id = ?");
            $stmt->execute([$input['user_id']]);
            $user = $stmt->fetch();
            
            http_response_code(200);
            echo json_encode(['success' => true, 'user' => $user]);
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
