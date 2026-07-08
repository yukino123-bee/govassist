<?php
// backend/api/mailer.php

use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Require Composer's autoloader
require_once __DIR__ . '/../vendor/autoload.php';

/**
 * Sends a verification email with the given OTP.
 * 
 * @param string $toEmail The recipient's email address
 * @param string $otpCode The 6-digit verification code
 * @return bool True if successful, false otherwise
 */
function sendVerificationEmail($toEmail, $otpCode) {
    $subject = "GovAssist - Verify your email address";
    
    $message = "
        <div style='font-family: Arial, sans-serif; max-width: 600px; margin: 0 auto; padding: 20px; border: 1px solid #ddd; border-radius: 5px;'>
            <h2 style='color: #2c3e50; text-align: center;'>Welcome to GovAssist!</h2>
            <p>Thank you for registering. To complete your registration and verify your email address, please use the following verification code:</p>
            <div style='background-color: #f8f9fa; padding: 15px; text-align: center; margin: 20px 0; border-radius: 5px;'>
                <h1 style='color: #007bff; margin: 0; letter-spacing: 5px;'>{$otpCode}</h1>
            </div>
            <p>Enter this code in the GovAssist app to verify your account.</p>
            <p>If you did not create an account, please ignore this email.</p>
            <hr style='border: none; border-top: 1px solid #eee; margin-top: 30px;' />
            <p style='color: #7f8c8d; font-size: 12px; text-align: center;'>&copy; " . date('Y') . " GovAssist. All rights reserved.</p>
        </div>
    ";

    // Awardspace requires the sender email to match your domain!
    $headers = "MIME-Version: 1.0\r\n";
    $headers .= "Content-type:text/html;charset=UTF-8\r\n";
    $headers .= "From: GovAssist <admin@govassist.atwebpages.com>\r\n";
    $headers .= "Reply-To: admin@govassist.atwebpages.com\r\n";

    // Use Awardspace's internal sendmail binary (bypasses outbound blocking)
    if (mail($toEmail, $subject, $message, $headers)) {
        return true;
    } else {
        $errorMsg = date('Y-m-d H:i:s') . " - Native PHP mail() failed to send.\n";
        file_put_contents(__DIR__ . '/error_log.txt', $errorMsg, FILE_APPEND);
        return false;
    }
}

/**
 * Triggers the verification email asynchronously via a fast local HTTP request.
 */
function sendVerificationEmailAsync($toEmail, $otpCode) {
    // For restrictive shared hosting like Awardspace, loopback cURL requests are often blocked.
    // To ensure 100% delivery reliability, we bypass the async script and send it synchronously.
    return sendVerificationEmail($toEmail, $otpCode);
}
?>
