<?php
// backend/api/profile.php

require_once 'cors.php';
require_once 'db.php';
require_once 'auth_middleware.php';

set_error_handler(function($errno, $errstr, $errfile, $errline) {
    if (error_reporting() & $errno) {
        http_response_code(500);
        echo json_encode(['error' => "PHP Error [$errno]: $errstr in $errfile on line $errline"]);
        exit();
    }
    return false;
});

set_exception_handler(function($exception) {
    http_response_code(500);
    echo json_encode(['error' => "PHP Exception: " . $exception->getMessage() . " in " . $exception->getFile() . " on line " . $exception->getLine()]);
    exit();
});

$method = $_SERVER['REQUEST_METHOD'];

// Get user ID securely from JWT token
$user_id = getAuthenticatedUser();

if ($method === 'GET') {
    try {
        $stmt = $pdo->prepare("SELECT id, full_name, email, dob, address, civil_status, contact_number, valid_id_path, profile_picture FROM users WHERE id = ?");
        $stmt->execute([$user_id]);
        $user = $stmt->fetch();
        
        if ($user) {
            http_response_code(200);
            echo json_encode(['profile' => $user]);
        } else {
            http_response_code(404);
            echo json_encode(['error' => 'User not found']);
        }
    } catch (PDOException $e) {
        error_log("Database error in profile.php GET: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'A database error occurred. Please try again later.']);
    }
} elseif ($method === 'POST') {
    // Note: since we need file upload, we use multipart/form-data, so we read from $_POST and $_FILES
    try {
        $full_name = $_POST['full_name'] ?? null;
        $email = $_POST['email'] ?? null;
        $password = $_POST['password'] ?? null;
        $dob = $_POST['dob'] ?? null;
        $address = $_POST['address'] ?? null;
        $civil_status = $_POST['civil_status'] ?? null;
        $contact_number = $_POST['contact_number'] ?? null;
        
        $valid_id_path = null;
        $profile_picture_path = $_POST['profile_picture'] ?? null;
        
        // Handle file upload for valid_id
        if (isset($_FILES['valid_id'])) {
            if ($_FILES['valid_id']['error'] === UPLOAD_ERR_OK) {
                $uploadDir = '../uploads/ids/';
                if (!file_exists($uploadDir)) {
                    mkdir($uploadDir, 0777, true);
                }
                $fileExtension = pathinfo($_FILES['valid_id']['name'], PATHINFO_EXTENSION);
                $fileName = 'user_' . $user_id . '_' . time() . '.' . $fileExtension;
                $destination = $uploadDir . $fileName;
                if (move_uploaded_file($_FILES['valid_id']['tmp_name'], $destination)) {
                    $valid_id_path = 'uploads/ids/' . $fileName;
                } else {
                    http_response_code(500);
                    echo json_encode(['error' => 'Failed to save valid ID on server']);
                    exit();
                }
            } else if ($_FILES['valid_id']['error'] !== UPLOAD_ERR_NO_FILE) {
                http_response_code(400);
                echo json_encode(['error' => 'Valid ID upload error: ' . $_FILES['valid_id']['error']]);
                exit();
            }
        }
        
        // Build update query dynamically
        $updates = [];
        $params = [];
        
        if ($full_name) { $updates[] = "full_name = ?"; $params[] = $full_name; }
        if ($email) { $updates[] = "email = ?"; $params[] = $email; }
        if ($password) { 
            $updates[] = "password_hash = ?"; 
            $params[] = password_hash($password, PASSWORD_BCRYPT); 
        }
        if ($dob) { $updates[] = "dob = ?"; $params[] = $dob; }
        if ($address) { $updates[] = "address = ?"; $params[] = $address; }
        if ($civil_status) { $updates[] = "civil_status = ?"; $params[] = $civil_status; }
        if ($contact_number !== null) { $updates[] = "contact_number = ?"; $params[] = $contact_number; }
        if ($valid_id_path) { $updates[] = "valid_id_path = ?"; $params[] = $valid_id_path; }
        if ($profile_picture_path) { $updates[] = "profile_picture = ?"; $params[] = $profile_picture_path; }
        
        if (!empty($updates)) {
            $sql = "UPDATE users SET " . implode(", ", $updates) . " WHERE id = ?";
            $params[] = $user_id;
            
            $stmt = $pdo->prepare($sql);
            $stmt->execute($params);
        }
        
        http_response_code(200);
        
        // Fetch updated user to return
        $stmt = $pdo->prepare("SELECT id, full_name, email, dob, address, civil_status, contact_number, valid_id_path, profile_picture FROM users WHERE id = ?");
        $stmt->execute([$user_id]);
        $updatedUser = $stmt->fetch();
        
        echo json_encode(['success' => true, 'message' => 'Profile updated successfully', 'user' => $updatedUser]);
        
    } catch (Exception $e) {
        error_log("Database error in profile.php POST: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'A database error occurred. Please try again later.']);
    }
}
?>
