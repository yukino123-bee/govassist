<?php
require_once 'mailer.php';

// Enable error display for this script
ini_set('display_errors', 1);
ini_set('display_startup_errors', 1);
error_reporting(E_ALL);

$toEmail = 'cagatinmark26@gmail.com'; // User's own email to test
$otpCode = '123456';

echo "Testing mailer...\n";

$result = sendVerificationEmailAsync($toEmail, $otpCode);

if ($result) {
    echo "Async mail trigger executed.\n";
} else {
    echo "Async mail trigger failed.\n";
}
?>
