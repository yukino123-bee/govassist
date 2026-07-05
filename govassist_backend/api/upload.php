<?php
// backend/api/upload.php
require_once 'cors.php';
require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    // Check if file and required fields are present
    if (isset($_FILES['document']) && isset($_POST['user_id']) && isset($_POST['requirement_name']) && isset($_POST['service_id'])) {
        
        $userId = $_POST['user_id'];
        $serviceId = $_POST['service_id'];
        $reqName = $_POST['requirement_name'];
        
        $uploadDir = '../uploads/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }
        
        $fileName = time() . '_' . basename($_FILES['document']['name']);
        $targetFilePath = $uploadDir . $fileName;
        
        if (move_uploaded_file($_FILES['document']['tmp_name'], $targetFilePath)) {
            try {
                $stmt = $pdo->prepare("
                    INSERT INTO uploaded_documents (user_id, service_id, requirement_name, file_path, verification_status, uploaded_at) 
                    VALUES (?, ?, ?, ?, 'Pending', NOW())
                ");
                $stmt->execute([$userId, $serviceId, $reqName, 'uploads/' . $fileName]);
                
                http_response_code(200);
                echo json_encode(['status' => 'success', 'message' => 'File uploaded successfully']);
            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(['status' => 'error', 'message' => $e->getMessage()]);
            }
        } else {
            http_response_code(500);
            echo json_encode(['status' => 'error', 'message' => 'Failed to move uploaded file']);
        }
    } else {
        http_response_code(400);
        echo json_encode(['status' => 'error', 'message' => 'Missing required fields or file']);
    }
}
?>
