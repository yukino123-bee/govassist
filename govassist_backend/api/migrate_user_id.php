<?php
// backend/api/migrate_user_id.php

require_once 'db.php';

try {
    $pdo->beginTransaction();

    // Add user_id to assessments if it doesn't exist
    $pdo->exec("ALTER TABLE assessments ADD COLUMN user_id INT NOT NULL AFTER id");
    $pdo->exec("ALTER TABLE assessments ADD CONSTRAINT fk_assessments_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE");
    echo "Added user_id to assessments.\n";

    // Add user_id to inquiries if it doesn't exist
    $pdo->exec("ALTER TABLE inquiries ADD COLUMN user_id INT NOT NULL AFTER id");
    $pdo->exec("ALTER TABLE inquiries ADD CONSTRAINT fk_inquiries_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE");
    echo "Added user_id to inquiries.\n";

    $pdo->commit();
    echo "Migration completed successfully.\n";
} catch (PDOException $e) {
    $pdo->rollBack();
    echo "Migration failed: " . $e->getMessage() . "\n";
}
?>
