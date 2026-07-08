<?php
// backend/api/async_mail.php

ignore_user_abort(true);
set_time_limit(0);

// Close connection early so the caller doesn't wait
ob_end_clean();
header("Connection: close");
ob_start();
echo "Processing...";
header("Content-Length: " . ob_get_length());
ob_end_flush();
flush();
if (function_exists('fastcgi_finish_request')) {
    fastcgi_finish_request();
}

require_once 'mailer.php';

// Only allow requests that have the correct secret token
$secret_token = 'govassist_internal_async_secret_2026';
if (!isset($_POST['token']) || $_POST['token'] !== $secret_token) {
    exit('Forbidden');
}

if ($_SERVER['REQUEST_METHOD'] === 'POST') {
    $email = $_POST['email'] ?? '';
    $code = $_POST['code'] ?? '';
    
    if ($email && $code) {
        // Send the email synchronously in this background process
        sendVerificationEmail($email, $code);
    }
}
?>
