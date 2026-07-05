<?php
// backend/api/admin/admin_stats.php

require_once '../cors.php';
require_once '../db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        // Total Users
        $stmtUsers = $pdo->query("SELECT COUNT(*) as count FROM users");
        $totalUsers = $stmtUsers->fetch()['count'];

        // Total Services
        $stmtServices = $pdo->query("SELECT COUNT(*) as count FROM services");
        $totalServices = $stmtServices->fetch()['count'];

        // Open Inquiries
        $stmtOpenInquiries = $pdo->query("SELECT COUNT(*) as count FROM inquiries WHERE status = 'Open'");
        $openInquiries = $stmtOpenInquiries->fetch()['count'];

        // Total Assessments
        $stmtAssessments = $pdo->query("SELECT COUNT(*) as count FROM assessments");
        $totalAssessments = $stmtAssessments->fetch()['count'];

        header('Content-Type: application/json');
        echo json_encode([
            'totalUsers' => $totalUsers,
            'totalServices' => $totalServices,
            'openInquiries' => $openInquiries,
            'totalAssessments' => $totalAssessments
        ]);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
}
?>
