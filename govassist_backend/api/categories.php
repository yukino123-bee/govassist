<?php
// backend/api/categories.php

require_once 'cors.php';
require_once 'db.php';

try {
    $stmt = $pdo->query("SELECT id, title, iconAsset FROM categories");
    $categories = $stmt->fetchAll();
    
    header('Content-Type: application/json');
    echo json_encode($categories);
} catch (PDOException $e) {
    http_response_code(500);
    echo json_encode(['error' => $e->getMessage()]);
}
?>
