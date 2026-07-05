<?php
// backend/api/auth_middleware.php
require_once 'jwt.php';

function getAuthenticatedUser() {
    $headers = apache_request_headers();
    $authHeader = null;
    
    if (isset($headers['Authorization'])) {
        $authHeader = $headers['Authorization'];
    } elseif (isset($headers['authorization'])) {
        $authHeader = $headers['authorization'];
    } elseif (isset($_SERVER['HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['HTTP_AUTHORIZATION'];
    } elseif (isset($_SERVER['REDIRECT_HTTP_AUTHORIZATION'])) {
        $authHeader = $_SERVER['REDIRECT_HTTP_AUTHORIZATION'];
    }
    
    // Check if Authorization header is set
    if (!$authHeader) {
        http_response_code(401);
        echo json_encode(['error' => 'Unauthorized. Missing Authorization header.']);
        exit();
    }
    
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
