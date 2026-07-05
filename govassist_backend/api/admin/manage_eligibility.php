<?php
// backend/api/admin/manage_eligibility.php
require_once '../cors.php';
require_once '../db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        $stmt = $pdo->query("
            SELECT e.*, s.title as service_title 
            FROM eligibility_questions e 
            LEFT JOIN services s ON e.service_id = s.id
        ");
        $questions = $stmt->fetchAll();
        
        header('Content-Type: application/json');
        echo json_encode($questions);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
} elseif ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    if (isset($input['service_id'], $input['question_text'], $input['expected_answer'])) {
        try {
            $options = isset($input['options']) ? json_encode($input['options']) : null;
            
            if (isset($input['id']) && !empty($input['id'])) {
                // Update existing record
                $id = $input['id'];
                $stmt = $pdo->prepare("
                    UPDATE eligibility_questions 
                    SET service_id = ?, question_text = ?, question_textLocal = ?, expected_answer = ?, options = ?
                    WHERE id = ?
                ");
                $stmt->execute([
                    $input['service_id'],
                    $input['question_text'],
                    $input['question_textLocal'] ?? '',
                    $input['expected_answer'],
                    $options,
                    $id
                ]);
            } else {
                // Insert new record
                $id = 'eq_' . uniqid();
                $stmt = $pdo->prepare("
                    INSERT INTO eligibility_questions (id, service_id, question_text, question_textLocal, expected_answer, options) 
                    VALUES (?, ?, ?, ?, ?, ?)
                ");
                $stmt->execute([
                    $id,
                    $input['service_id'],
                    $input['question_text'],
                    $input['question_textLocal'] ?? '',
                    $input['expected_answer'],
                    $options
                ]);
            }
            
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
            $stmt = $pdo->prepare("DELETE FROM eligibility_questions WHERE id = ?");
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
