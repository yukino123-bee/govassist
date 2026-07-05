<?php
require 'api/db.php';
$pdo->exec('ALTER TABLE eligibility_questions MODIFY expected_answer VARCHAR(255) NOT NULL;');
echo "Success";
?>
