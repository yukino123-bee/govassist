<?php
// backend/api/admin/manage_templates.php
require_once '../cors.php';
require_once '../db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        $stmt = $pdo->query("
            SELECT dt.*, s.title as service_title 
            FROM document_templates dt
            LEFT JOIN services s ON dt.service_id = s.id
            ORDER BY dt.created_at DESC
        ");
        $templates = $stmt->fetchAll();
        
        header('Content-Type: application/json');
        echo json_encode($templates);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
} elseif ($method === 'POST') {
    // Handle File Upload and Insert Template
    if (isset($_POST['service_id'], $_POST['title']) && isset($_FILES['template_file'])) {
        $serviceId = $_POST['service_id'];
        $title = $_POST['title'];
        $file = $_FILES['template_file'];
        
        if ($file['error'] !== UPLOAD_ERR_OK) {
            http_response_code(400);
            echo json_encode(['error' => 'File upload failed.']);
            exit;
        }
        
        // Define upload directory relative to backend root
        $uploadDir = '../../uploads/templates/';
        if (!is_dir($uploadDir)) {
            mkdir($uploadDir, 0777, true);
        }
        
        // Sanitize file name and create a unique path
        $ext = pathinfo($file['name'], PATHINFO_EXTENSION);
        $fileName = uniqid('template_') . '.' . $ext;
        $targetPath = $uploadDir . $fileName;
        
        if (move_uploaded_file($file['tmp_name'], $targetPath)) {
            // Store relative path in DB
            $dbPath = 'uploads/templates/' . $fileName;
            
            try {
                $stmt = $pdo->prepare("INSERT INTO document_templates (service_id, title, file_path) VALUES (?, ?, ?)");
                $stmt->execute([$serviceId, $title, $dbPath]);
                
                http_response_code(200);
                echo json_encode(['success' => true]);
            } catch (PDOException $e) {
                // If DB insert fails, remove the uploaded file
                unlink($targetPath);
                http_response_code(500);
                echo json_encode(['error' => $e->getMessage()]);
            }
        } else {
            http_response_code(500);
            echo json_encode(['error' => 'Failed to move uploaded file.']);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Missing required fields or file.']);
    }
} elseif ($method === 'DELETE') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (isset($input['id'])) {
        try {
            // Get the file path first to delete it
            $stmt = $pdo->prepare("SELECT file_path FROM document_templates WHERE id = ?");
            $stmt->execute([$input['id']]);
            $template = $stmt->fetch();
            
            if ($template && file_exists('../../' . $template['file_path'])) {
                unlink('../../' . $template['file_path']);
            }
            
            $stmt = $pdo->prepare("DELETE FROM document_templates WHERE id = ?");
            $stmt->execute([$input['id']]);
            
            http_response_code(200);
            echo json_encode(['success' => true]);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Template ID is required.']);
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed.']);
}
?>
