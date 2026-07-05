<?php
// backend/api/admin/manage_requirements.php
require_once '../cors.php';
require_once '../db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        $stmt = $pdo->query("
            SELECT r.*, s.title as service_title 
            FROM requirements r 
            LEFT JOIN services s ON r.service_id = s.id
        ");
        $requirements = $stmt->fetchAll();
        
        header('Content-Type: application/json');
        echo json_encode($requirements);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
} elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (isset($input['service_id'], $input['name'])) {
        try {
            $id = 'req_' . uniqid();
            $stmt = $pdo->prepare("
                INSERT INTO requirements (id, service_id, name, nameLocal, description, descriptionLocal, is_required) 
                VALUES (?, ?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([
                $id,
                $input['service_id'],
                $input['name'],
                $input['nameLocal'] ?? '',
                $input['description'] ?? '',
                $input['descriptionLocal'] ?? '',
                $input['is_required'] ?? 1
            ]);
            
            http_response_code(200);
            echo json_encode(['success' => true, 'id' => $id]);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid input']);
    }
} elseif ($method === 'DELETE') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (isset($input['id'])) {
        try {
            $stmt = $pdo->prepare("DELETE FROM requirements WHERE id = ?");
            $stmt->execute([$input['id']]);
            
            http_response_code(200);
            echo json_encode(['success' => true]);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    }
}
?>
