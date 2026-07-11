<?php
require '../db.php';
$stmt = $pdo->query('DESCRIBE assessments');
print_r($stmt->fetchAll(PDO::FETCH_COLUMN));
