<?php
// backend/api/faqs.php

require_once 'cors.php';
require_once 'db.php';

try {
    $stmt = $pdo->query("SELECT question, answer FROM faqs");
    $faqs = $stmt->fetchAll();
    
    header('Content-Type: application/json');
    echo json_encode($faqs);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
?>
