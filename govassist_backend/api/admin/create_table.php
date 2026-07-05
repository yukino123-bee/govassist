<?php
require_once 'c:/laragon/www/govassist_backend/api/db.php';

try {
    $sql = "CREATE TABLE IF NOT EXISTS uploaded_documents (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        service_id VARCHAR(50) NOT NULL,
        requirement_name VARCHAR(255) NOT NULL,
        file_path VARCHAR(255) NOT NULL,
        verification_status VARCHAR(50) DEFAULT 'Pending',
        uploaded_at DATETIME NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
    )";
    $pdo->exec($sql);
    echo "Table uploaded_documents created successfully.";
} catch (PDOException $e) {
    echo "Error: " . $e->getMessage();
}
?>
