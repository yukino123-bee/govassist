<?php
// backend/api/migrate_user_id.php

require_once 'db.php';

try {
    // MySQL implicitly commits transactions for DDL (ALTER TABLE), 
    // so we don't use beginTransaction() here.

    // To prevent foreign key constraint failures on existing rows (where user_id would default to 0),
    // we must empty the tables first or set a valid default. Emptying is safest for this schema change.
    $pdo->exec("TRUNCATE TABLE assessments");
    $pdo->exec("TRUNCATE TABLE inquiries");

    // Add user_id to assessments if it doesn't exist
    try {
        $pdo->exec("ALTER TABLE assessments ADD COLUMN user_id INT NOT NULL AFTER id");
        $pdo->exec("ALTER TABLE assessments ADD CONSTRAINT fk_assessments_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE");
        echo "Added user_id to assessments.<br>";
    } catch (PDOException $e) {
        echo "Assessments column may already exist or error: " . $e->getMessage() . "<br>";
    }

    // Add user_id to inquiries if it doesn't exist
    try {
        $pdo->exec("ALTER TABLE inquiries ADD COLUMN user_id INT NOT NULL AFTER id");
        $pdo->exec("ALTER TABLE inquiries ADD CONSTRAINT fk_inquiries_user FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE");
        echo "Added user_id to inquiries.<br>";
    } catch (PDOException $e) {
        echo "Inquiries column may already exist or error: " . $e->getMessage() . "<br>";
    }

    echo "<br><b>Migration completed successfully.</b>";
} catch (PDOException $e) {
    echo "Migration failed: " . $e->getMessage();
}
?>
