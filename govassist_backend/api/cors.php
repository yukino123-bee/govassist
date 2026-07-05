<?php
// backend/api/cors.php

$allowed_origins = [
    'http://localhost',
    'http://127.0.0.1',
    'http://192.168.100.58' // Local network IP used in Flutter app
];

if (isset($_SERVER['HTTP_ORIGIN'])) {
    if (in_array($_SERVER['HTTP_ORIGIN'], $allowed_origins)) {
        header("Access-Control-Allow-Origin: " . $_SERVER['HTTP_ORIGIN']);
    }
} else {
    // Allow requests without Origin header (e.g., from mobile apps or server-to-server)
    header("Access-Control-Allow-Origin: http://localhost");
}
header("Access-Control-Allow-Methods: GET, POST, OPTIONS, PUT, DELETE");
header("Access-Control-Allow-Headers: Content-Type, Authorization");

// Handle preflight requests
if ($_SERVER['REQUEST_METHOD'] == 'OPTIONS') {
    http_response_code(200);
    exit();
}
?>
