<?php
// backend/api/admin/manage_services.php

require_once '../cors.php';
require_once '../db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    // Return all services with their categories
    try {
        $stmt = $pdo->query("
            SELECT s.*, c.title as category_title 
            FROM services s 
            LEFT JOIN categories c ON s.category_id = c.id
        ");
        $services = $stmt->fetchAll();
        
        header('Content-Type: application/json');
        echo json_encode($services);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
} elseif ($method === 'POST') {
    // Add a new service
    $input = json_decode(file_get_contents('php://input'), true);
    if (isset($input['title'], $input['description'])) {
        try {
            $pdo->beginTransaction();

            $id = 'srv_' . uniqid();
            $categoryId = 'cat_1'; // Hardcoded fallback category

            $stmt = $pdo->prepare("
                INSERT INTO services (id, category_id, title, titleLocal, description, descriptionLocal, procedures, proceduresLocal) 
                VALUES (?, ?, ?, ?, ?, ?, ?, ?)
            ");
            $stmt->execute([
                $id,
                $categoryId,
                $input['title'],
                $input['titleLocal'] ?? '',
                $input['description'],
                $input['descriptionLocal'] ?? '',
                $input['procedures'] ?? '',
                $input['proceduresLocal'] ?? ''
            ]);
            
            if (!empty($input['requirements'])) {
                $reqs = explode("\n", str_replace("\r", "", $input['requirements']));
                $reqStmt = $pdo->prepare("
                    INSERT INTO requirements (id, service_id, name, is_required) 
                    VALUES (?, ?, ?, 1)
                ");
                
                foreach ($reqs as $req) {
                    $req = trim($req);
                    if (!empty($req)) {
                        $reqId = 'req_' . uniqid();
                        $reqStmt->execute([$reqId, $id, $req]);
                    }
                }
            }

            $pdo->commit();
            http_response_code(200);
            echo json_encode(['success' => true, 'id' => $id]);
        } catch (PDOException $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid input']);
    }
} elseif ($method === 'PUT') {
    // Update a service
    $input = json_decode(file_get_contents('php://input'), true);
    if (isset($input['id'], $input['title'], $input['description'])) {
        try {
            $pdo->beginTransaction();

            $stmt = $pdo->prepare("
                UPDATE services 
                SET title = ?, description = ?
                WHERE id = ?
            ");
            $stmt->execute([
                $input['title'],
                $input['description'],
                $input['id']
            ]);
            
            // Replace requirements
            $delStmt = $pdo->prepare("DELETE FROM requirements WHERE service_id = ?");
            $delStmt->execute([$input['id']]);

            if (!empty($input['requirements'])) {
                $reqs = explode("\n", str_replace("\r", "", $input['requirements']));
                $reqStmt = $pdo->prepare("
                    INSERT INTO requirements (id, service_id, name, is_required) 
                    VALUES (?, ?, ?, 1)
                ");
                
                foreach ($reqs as $req) {
                    $req = trim($req);
                    if (!empty($req)) {
                        $reqId = 'req_' . uniqid();
                        $reqStmt->execute([$reqId, $input['id'], $req]);
                    }
                }
            }

            $pdo->commit();
            http_response_code(200);
            echo json_encode(['success' => true]);
        } catch (PDOException $e) {
            if ($pdo->inTransaction()) {
                $pdo->rollBack();
            }
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid input']);
    }
} elseif ($method === 'DELETE') {
    // Delete a service
    $input = json_decode(file_get_contents('php://input'), true);
    if (isset($input['id'])) {
        try {
            $stmt = $pdo->prepare("DELETE FROM services WHERE id = ?");
            $stmt->execute([$input['id']]);
            
            http_response_code(200);
            echo json_encode(['success' => true]);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Invalid input']);
    }
}
?>
