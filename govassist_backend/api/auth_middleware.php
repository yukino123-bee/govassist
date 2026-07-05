<?php
// backend/api/auth_middleware.php
require_once 'jwt.php';

function getAuthenticatedUser() {
    $headers = apache_request_headers();
    
    // Check if Authorization header is set
    if (!isset($headers['Authorization']) && !isset($headers['authorization'])) {
        http_response_code(401);
        echo json_encode(['error' => 'Unauthorized. Missing Authorization header.']);
        exit();
    }
    
    $authHeader = isset($headers['Authorization']) ? $headers['Authorization'] : $headers['authorization'];
    
    // Check if it's a Bearer token
    if (preg_match('/Bearer\s(\S+)/', $authHeader, $matches)) {
        $token = $matches[1];
        
        $decoded = JWT::decode($token);
        
        if ($decoded && isset($decoded['user_id'])) {
            return $decoded['user_id'];
        }
    }
    
    http_response_code(401);
    echo json_encode(['error' => 'Unauthorized. Invalid or expired token.']);
    exit();
}
?>
