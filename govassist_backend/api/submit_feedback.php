<?php
// backend/api/submit_feedback.php
require_once 'cors.php';
require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

// Ensure the table exists
try {
    $pdo->exec("CREATE TABLE IF NOT EXISTS feedback (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NULL,
        rating INT NOT NULL,
        comments TEXT,
        created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
    )");
} catch (PDOException $e) {
    // Ignore if exists or error
}

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    
    if (isset($input['rating'])) {
        try {
            $stmt = $pdo->prepare("INSERT INTO feedback (user_id, rating, comments) VALUES (?, ?, ?)");
            $stmt->execute([
                $input['user_id'] ?? null,
                $input['rating'],
                $input['comments'] ?? ''
            ]);
            
            http_response_code(200);
            echo json_encode(['success' => true]);
        } catch (PDOException $e) {
            http_response_code(500);
            echo json_encode(['error' => $e->getMessage()]);
        }
    } else {
        http_response_code(400);
        echo json_encode(['error' => 'Rating is required']);
    }
}
?>
