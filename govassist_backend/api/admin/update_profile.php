<?php
// backend/api/admin/update_profile.php
require_once '../cors.php';
require_once '../db.php';
require_once '../auth_middleware.php';

$method = $_SERVER['REQUEST_METHOD'];

// Get user ID securely from JWT token
$user_id = getAuthenticatedUser();

if ($method === 'POST') {
    // If we receive JSON, fallback
    // Fallback for JSON body if needed
    $input = json_decode(file_get_contents('php://input'), true);
    
    // We ignore user-provided ID and use the securely verified $user_id
    $id = $user_id;
    $full_name = $_POST['full_name'] ?? ($input['full_name'] ?? null);
    $email = $_POST['email'] ?? ($input['email'] ?? null);
    
    if ($id && $full_name && $email) {
        try {
            $dob = !empty($_POST['dob']) ? $_POST['dob'] : (!empty($input['dob']) ? $input['dob'] : null);
            $address = !empty($_POST['address']) ? $_POST['address'] : (!empty($input['address']) ? $input['address'] : null);
            $civil_status = !empty($_POST['civil_status']) ? $_POST['civil_status'] : (!empty($input['civil_status']) ? $input['civil_status'] : null);
            $contact_number = !empty($_POST['contact_number']) ? $_POST['contact_number'] : (!empty($input['contact_number']) ? $input['contact_number'] : null);
            $password = $_POST['password'] ?? ($input['password'] ?? null);
            
            // Profile Picture Logic
            $profile_picture = null;
            if (isset($_FILES['profile_picture'])) {
                if ($_FILES['profile_picture']['error'] === UPLOAD_ERR_OK) {
                    $uploadDir = '../../uploads/profiles/';
                    if (!file_exists($uploadDir)) {
                        mkdir($uploadDir, 0777, true);
                    }
                    
                    $fileExtension = pathinfo($_FILES['profile_picture']['name'], PATHINFO_EXTENSION);
                    $fileName = 'profile_' . $id . '_' . time() . '.' . $fileExtension;
                    $destination = $uploadDir . $fileName;
                    
                    if (move_uploaded_file($_FILES['profile_picture']['tmp_name'], $destination)) {
                        $profile_picture = 'uploads/profiles/' . $fileName;
                    } else {
                        http_response_code(500);
                        echo json_encode(['error' => 'Failed to move uploaded profile picture. Check server permissions.']);
                        exit();
                    }
                } else {
                    http_response_code(400);
                    echo json_encode(['error' => 'Profile picture upload error code: ' . $_FILES['profile_picture']['error']]);
                    exit();
                }
            }
            
            // Build dynamic query
            $updates = ["full_name = ?", "email = ?", "dob = ?", "address = ?", "civil_status = ?", "contact_number = ?"];
            $params = [$full_name, $email, $dob, $address, $civil_status, $contact_number];
            
            if (!empty($password)) {
                $updates[] = "password_hash = ?";
                $params[] = password_hash($password, PASSWORD_DEFAULT);
            }
            
            if ($profile_picture) {
                $updates[] = "profile_picture = ?";
                $params[] = $profile_picture;
            }
            
            $params[] = $id;
            
            $sql = "UPDATE users SET " . implode(", ", $updates) . " WHERE id = ?";
            $stmt = $pdo->prepare($sql);
            $stmt->execute($params);
            
            // Return updated user (excluding password)
            $stmt = $pdo->prepare("SELECT id, full_name, email, is_admin, dob, address, civil_status, contact_number, profile_picture FROM users WHERE id = ?");
            $stmt->execute([$id]);
            $user = $stmt->fetch();
            
            http_response_code(200);
            echo json_encode(['success' => true, 'user' => $user]);
        } catch (PDOException $e) {
            error_log("Database error in admin update_profile.php: " . $e->getMessage());
            http_response_code(500);
            echo json_encode(['error' => 'A database error occurred. Please try again later.']);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Missing required fields']);
    }
}
?>
