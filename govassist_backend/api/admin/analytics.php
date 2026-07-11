<?php
// backend/api/admin/analytics.php
require_once '../cors.php';
require_once '../db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'GET') {
    try {
        $analytics = [];

        // 1. Total Registered Users (where role='Citizen')
        $stmtUsers = $pdo->query("SELECT COUNT(*) as total FROM users WHERE role = 'Citizen'");
        $analytics['total_users'] = $stmtUsers->fetch()['total'];

        // 2. Total Assessments Taken
        $stmtAssessments = $pdo->query("SELECT COUNT(*) as total FROM assessment_history");
        $analytics['total_assessments'] = $stmtAssessments->fetch()['total'];

        // 3. Total Inquiries Resolved (Closed)
        $stmtInquiries = $pdo->query("SELECT COUNT(*) as total FROM inquiries WHERE status = 'Closed'");
        $analytics['resolved_inquiries'] = $stmtInquiries->fetch()['total'];

        // 4. Average System Rating
        // We will wrap this in try-catch in case feedback table hasn't been created yet
        $analytics['average_rating'] = 0.0;
        $analytics['feedback_comments'] = [];
        try {
            $stmtRating = $pdo->query("SELECT AVG(rating) as avg_rating FROM feedback");
            $avg = $stmtRating->fetch()['avg_rating'];
            if ($avg) {
                $analytics['average_rating'] = round($avg, 1);
            }

            // Get recent comments
            $stmtComments = $pdo->query("SELECT rating, comments, created_at FROM feedback WHERE comments != '' ORDER BY created_at DESC LIMIT 20");
            $analytics['feedback_comments'] = $stmtComments->fetchAll();
        } catch (PDOException $e) {
            // Ignore if table doesn't exist yet
        }

        header('Content-Type: application/json');
        echo json_encode($analytics);
    } catch (PDOException $e) {
        http_response_code(500);
        echo json_encode(['error' => $e->getMessage()]);
    }
}
?>
