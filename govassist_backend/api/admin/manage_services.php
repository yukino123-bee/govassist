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
    exit;
}

// We expect a JSON payload for POST, PUT, DELETE
$input = json_decode(file_get_contents('php://input'), true);

if (!$input) {
    http_response_code(400);
    echo json_encode(['error' => 'Invalid JSON input']);
    exit;
}

try {
    $pdo->beginTransaction();
    
    if ($method === 'POST') {
        // Add a new service
        if (isset($input['title'], $input['description'])) {
            $id = 'srv_' . uniqid();
            $categoryId = $input['categoryId'] ?? 'cat_1';

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
            
            // Insert requirements (as array of objects)
            if (isset($input['requirements']) && is_array($input['requirements'])) {
                $reqStmt = $pdo->prepare("INSERT INTO requirements (id, service_id, name, is_required) VALUES (?, ?, ?, ?)");
                foreach ($input['requirements'] as $req) {
                    $reqName = trim($req['name'] ?? '');
                    if (!empty($reqName)) {
                        $reqId = 'req_' . uniqid();
                        $reqStmt->execute([
                            $reqId, 
                            $id, 
                            $reqName,
                            isset($req['isRequired']) ? (int)$req['isRequired'] : 1
                        ]);
                    }
                }
            }

            // Insert eligibility questions
            if (isset($input['eligibilityQuestions']) && is_array($input['eligibilityQuestions'])) {
                $eqStmt = $pdo->prepare("INSERT INTO eligibility_questions (id, service_id, question_text, expected_answer, options) VALUES (?, ?, ?, ?, ?)");
                foreach ($input['eligibilityQuestions'] as $eq) {
                    $qText = trim($eq['questionText'] ?? '');
                    if (!empty($qText)) {
                        $optionsJson = null;
                        if (isset($eq['options']) && is_array($eq['options']) && !empty($eq['options'])) {
                            $optionsJson = json_encode($eq['options']);
                        }
                        $eqStmt->execute([
                            'eq_' . uniqid(),
                            $id,
                            $qText,
                            $eq['expectedAnswer'] ?? '1',
                            $optionsJson
                        ]);
                    }
                }
            }

            $pdo->commit();
            http_response_code(200);
            echo json_encode(['success' => true, 'id' => $id]);
        } else {
            throw new Exception('Missing title or description');
        }

    } elseif ($method === 'PUT') {
        // Update a service
        if (isset($input['id'], $input['title'], $input['description'])) {
            $serviceId = $input['id'];

            $stmt = $pdo->prepare("
                UPDATE services 
                SET category_id=?, title=?, titleLocal=?, description=?, descriptionLocal=?, procedures=?, proceduresLocal=?
                WHERE id=?
            ");
            $stmt->execute([
                $input['categoryId'] ?? 'cat_1',
                $input['title'],
                $input['titleLocal'] ?? '',
                $input['description'],
                $input['descriptionLocal'] ?? '',
                $input['procedures'] ?? '',
                $input['proceduresLocal'] ?? '',
                $serviceId
            ]);
            
            // Replace requirements
            $pdo->prepare("DELETE FROM requirements WHERE service_id=?")->execute([$serviceId]);
            if (isset($input['requirements']) && is_array($input['requirements'])) {
                $reqStmt = $pdo->prepare("INSERT INTO requirements (id, service_id, name, is_required) VALUES (?, ?, ?, ?)");
                foreach ($input['requirements'] as $req) {
                    $reqName = trim($req['name'] ?? '');
                    if (!empty($reqName)) {
                        $reqId = 'req_' . uniqid();
                        $reqStmt->execute([
                            $reqId, 
                            $serviceId, 
                            $reqName,
                            isset($req['isRequired']) ? (int)$req['isRequired'] : 1
                        ]);
                    }
                }
            }

            // Replace eligibility questions
            $pdo->prepare("DELETE FROM eligibility_questions WHERE service_id=?")->execute([$serviceId]);
            if (isset($input['eligibilityQuestions']) && is_array($input['eligibilityQuestions'])) {
                $eqStmt = $pdo->prepare("INSERT INTO eligibility_questions (id, service_id, question_text, expected_answer, options) VALUES (?, ?, ?, ?, ?)");
                foreach ($input['eligibilityQuestions'] as $eq) {
                    $qText = trim($eq['questionText'] ?? '');
                    if (!empty($qText)) {
                        $optionsJson = null;
                        if (isset($eq['options']) && is_array($eq['options']) && !empty($eq['options'])) {
                            $optionsJson = json_encode($eq['options']);
                        }
                        $eqStmt->execute([
                            'eq_' . uniqid(),
                            $serviceId,
                            $qText,
                            $eq['expectedAnswer'] ?? '1',
                            $optionsJson
                        ]);
                    }
                }
            }

            $pdo->commit();
            http_response_code(200);
            echo json_encode(['success' => true]);
        } else {
            throw new Exception('Missing id, title or description');
        }

    } elseif ($method === 'DELETE') {
        // Delete a service
        if (isset($input['id'])) {
            $serviceId = $input['id'];
            
            // Delete child dependencies first
            $pdo->prepare("DELETE FROM requirements WHERE service_id=?")->execute([$serviceId]);
            $pdo->prepare("DELETE FROM eligibility_questions WHERE service_id=?")->execute([$serviceId]);
            
            // Delete service
            $stmt = $pdo->prepare("DELETE FROM services WHERE id=?");
            $stmt->execute([$serviceId]);
            
            $pdo->commit();
            http_response_code(200);
            echo json_encode(['success' => true]);
        } else {
            throw new Exception('Missing id');
        }
    } else {
        throw new Exception('Method not allowed');
    }

} catch (Exception $e) {
    if ($pdo->inTransaction()) {
        $pdo->rollBack();
    }
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
?>
