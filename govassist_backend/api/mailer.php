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
    $config = require __DIR__ . '/mail_config.php';
    
    // If config hasn't been set up yet, silently fail or return false
    // so we don't break the flow if the user forgets to add credentials
    if ($config['smtp_user'] === 'your_email@gmail.com') {
        error_log("GovAssist Mailer: SMTP credentials not configured in mail_config.php.");
        return false;
    }

    $mail = new PHPMailer(true);

    try {
        // Server settings
        $mail->isSMTP();
        $mail->Host       = $config['smtp_host'];
        $mail->SMTPAuth   = true;
        $mail->Username   = $config['smtp_user'];
        $mail->Password   = $config['smtp_pass'];
        $mail->SMTPSecure = PHPMailer::ENCRYPTION_STARTTLS;
        $mail->Port       = $config['smtp_port'];

        // Recipients
        $mail->setFrom($config['from_email'], $config['from_name']);
        $mail->addAddress($toEmail);

        // Content
        $mail->isHTML(true);
        $mail->Subject = 'GovAssist - Verify your email address';
        $mail->Body    = "
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
        $mail->AltBody = "Welcome to GovAssist! Your verification code is: {$otpCode}";

        $mail->send();
        return true;
    } catch (Exception $e) {
        error_log("GovAssist Mailer Error: {$mail->ErrorInfo}");
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
