<?php
require 'api/db.php';
try {
    $pdo->exec("ALTER TABLE users 
    ADD COLUMN email_verified_at DATETIME DEFAULT NULL,
    ADD COLUMN verification_code VARCHAR(10) DEFAULT NULL,
    ADD COLUMN dob DATE DEFAULT NULL,
    ADD COLUMN address TEXT DEFAULT NULL,
    ADD COLUMN civil_status VARCHAR(50) DEFAULT NULL,
    ADD COLUMN contact_number VARCHAR(50) DEFAULT NULL,
    ADD COLUMN valid_id_path VARCHAR(255) DEFAULT NULL,
    ADD COLUMN profile_picture VARCHAR(255) DEFAULT NULL");
    echo "Users table altered successfully.\n";
} catch(PDOException $e) {
    echo "Error altering users: " . $e->getMessage() . "\n";
}

try {
    $pdo->exec("CREATE TABLE IF NOT EXISTS notifications (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        title VARCHAR(255) NOT NULL,
        message TEXT NOT NULL,
        type VARCHAR(50) NOT NULL,
        is_read BOOLEAN DEFAULT FALSE,
        created_at DATETIME NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
    )");
    echo "Notifications table created successfully.\n";
} catch(PDOException $e) {
    echo "Error creating notifications: " . $e->getMessage() . "\n";
}

try {
    $pdo->exec("CREATE TABLE IF NOT EXISTS applications (
        id INT AUTO_INCREMENT PRIMARY KEY,
        user_id INT NOT NULL,
        service_id VARCHAR(50) NOT NULL,
        status VARCHAR(50) NOT NULL,
        submitted_at DATETIME NOT NULL,
        updated_at DATETIME NOT NULL,
        FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE,
        FOREIGN KEY (service_id) REFERENCES services(id) ON DELETE CASCADE
    )");
    echo "Applications table created successfully.\n";
} catch(PDOException $e) {
    echo "Error creating applications: " . $e->getMessage() . "\n";
}
?>
