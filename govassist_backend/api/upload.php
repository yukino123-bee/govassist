<?php
// backend/api/upload.php

require_once 'cors.php';
require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    if (isset($_POST['user_id']) && isset($_POST['service_id']) && isset($_POST['requirement_name']) && isset($_FILES['document'])) {
        $userId = $_POST['user_id'];
        $serviceId = $_POST['service_id'];
        $reqName = $_POST['requirement_name'];
        $file = $_FILES['document'];

        // Ensure uploads directory exists
        $uploadDir = __DIR__ . '/../uploads/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }

        // Validate file
        $allowedExtensions = ['pdf', 'jpg', 'jpeg', 'png'];
        $fileExt = strtolower(pathinfo($file['name'], PATHINFO_EXTENSION));

        if (!in_array($fileExt, $allowedExtensions)) {
            http_response_code(400);
            echo json_encode(['error' => 'Invalid file format']);
            exit();
        }

        // Secure file name
        $fileName = uniqid('doc_') . '_' . time() . '.' . $fileExt;
        $destPath = $uploadDir . $fileName;
        $dbPath = 'uploads/' . $fileName;

        if (move_uploaded_file($file['tmp_name'], $destPath)) {
            try {
                $stmt = $pdo->prepare("INSERT INTO documents (user_id, service_id, requirement_name, file_path, uploaded_at) VALUES (?, ?, ?, ?, ?)");
                $stmt->execute([
                    $userId,
                    $serviceId,
                    $reqName,
                    $dbPath,
                    date('Y-m-d H:i:s')
                ]);

                http_response_code(200);
                echo json_encode(['success' => true, 'file_path' => $dbPath]);
            } catch (PDOException $e) {
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to save file']);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Missing required fields']);
    }
}
?>
