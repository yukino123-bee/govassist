<?php
require_once '../db.php';

try {
    $sql = "CREATE TABLE IF NOT EXISTS document_templates (
        id INT AUTO_INCREMENT PRIMARY KEY,
        service_id VARCHAR(50) NOT NULL,
        title VARCHAR(255) NOT NULL,
        file_path VARCHAR(255) NOT NULL,
        created_at DATETIME DEFAULT CURRENT_TIMESTAMP,
        FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
    )";
    $pdo->exec($sql);
    echo "Table document_templates created successfully.";
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>
