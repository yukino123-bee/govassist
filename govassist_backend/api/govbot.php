<?php
// backend/api/govbot.php

require_once 'cors.php';
require_once 'db.php';

$method = $_SERVER['REQUEST_METHOD'];

if ($method === 'POST') {
    $input = json_decode(file_get_contents('php://input'), true);
    $message = isset($input['message']) ? trim(strtolower($input['message'])) : '';

    if (empty($message)) {
        http_response_code(400);
        echo json_encode(['error' => 'Message is required']);
        exit();
    }

    try {
        // Simple NLP Matching Logic
        $tokens = preg_split('/[\s,\.\?\!]+/', $message);
        // Remove common stop words that don't add much meaning
        $stopWords = ['a', 'an', 'the', 'is', 'are', 'was', 'were', 'to', 'for', 'of', 'in', 'on', 'at', 'i', 'me', 'my', 'you', 'your'];
        $filteredTokens = array_filter($tokens, function($token) use ($stopWords) {
            return !in_array($token, $stopWords) && strlen($token) > 2;
        });

        // Basic intent detection
        if (in_array('hi', $tokens) || in_array('hello', $tokens) || in_array('hey', $tokens)) {
            echo json_encode(['response' => "Hello! I am GovBot. Ask me about how to apply, who qualifies, or the requirements for our assistance programs."]);
            exit();
        }

        $bestScore = 0;
        $bestResponse = "I am an automated assistant. For specific inquiries not covered here, please submit a formal inquiry using the 'Submit Inquiry' button.";

        // 1. Search FAQs
        $stmt = $pdo->query("SELECT question, answer FROM faqs");
        $faqs = $stmt->fetchAll();

        foreach ($faqs as $faq) {
            $score = 0;
            $content = strtolower($faq['question'] . ' ' . $faq['answer']);
            foreach ($filteredTokens as $token) {
                if (strpos($content, $token) !== false) {
                    $score += 1;
                    // Boost score if it matches the question closely
                    if (strpos(strtolower($faq['question']), $token) !== false) {
                        $score += 2; 
                    }
                }
            }
            if ($score > $bestScore) {
                $bestScore = $score;
                $bestResponse = $faq['answer'];
            }
        }

        // 2. Search Services
        $stmt = $pdo->query("SELECT id, title, titleLocal, description FROM services");
        $services = $stmt->fetchAll();

        foreach ($services as $service) {
            $score = 0;
            $content = strtolower($service['title'] . ' ' . $service['titleLocal'] . ' ' . $service['description']);
            foreach ($filteredTokens as $token) {
                if (strpos($content, $token) !== false) {
                    $score += 1;
                    if (strpos(strtolower($service['title']), $token) !== false) {
                        $score += 3; // Title match is very strong
                    }
                }
            }

            // Also search requirements for this service
            $reqStmt = $pdo->prepare("SELECT requirement_name FROM requirements WHERE service_id = ?");
            $reqStmt->execute([$service['id']]);
            $requirements = $reqStmt->fetchAll();
            
            $reqListText = "";
            foreach ($requirements as $req) {
                $reqContent = strtolower($req['requirement_name']);
                $reqListText .= "- " . $req['requirement_name'] . "\n";
                foreach ($filteredTokens as $token) {
                    if (strpos($reqContent, $token) !== false) {
                        $score += 1;
                    }
                }
            }

            if ($score > $bestScore) {
                $bestScore = $score;
                // Determine if they asked for requirements or general info
                if (in_array('requirement', $filteredTokens) || in_array('requirements', $filteredTokens) || in_array('document', $filteredTokens) || in_array('documents', $filteredTokens)) {
                    $bestResponse = "Here are the requirements for " . $service['title'] . ":\n" . $reqListText;
                } else if (in_array('how', $filteredTokens) && in_array('apply', $filteredTokens)) {
                     $bestResponse = "To apply for " . $service['title'] . ", go to the Home screen, select it from the list, review the requirements, and tap 'Start Eligibility Assessment'.";
                } else {
                    $bestResponse = $service['title'] . ": " . $service['description'];
                }
            }
        }

        // Minimum threshold to prevent random loose matches from firing
        if ($bestScore < 2 && !empty($filteredTokens)) {
            // Check for general keywords if no specific service/faq matched
            if (in_array('how', $tokens) && (in_array('apply', $tokens) || in_array('process', $tokens))) {
                $bestResponse = 'To apply for any program, go to the Home screen, select a specific assistance service, review the requirements, and tap "Start Eligibility Assessment" to begin.';
            } else if (in_array('who', $tokens) || in_array('qualify', $tokens) || in_array('eligible', $tokens) || in_array('eligibility', $tokens)) {
                $bestResponse = 'Eligibility depends on the specific program. Generally, you must be a resident of the municipality. Please check the specific program\'s page for detailed applicant qualifications.';
            } else if (in_array('requirement', $tokens) || in_array('documents', $tokens)) {
                $bestResponse = 'Requirements vary by program. Please navigate to the specific program on the Home screen to view its complete list of required documents.';
            }
        }

        echo json_encode(['response' => $bestResponse]);

    } catch (PDOException $e) {
        error_log("Database error in govbot.php: " . $e->getMessage());
        http_response_code(500);
        echo json_encode(['error' => 'A database error occurred.']);
    }
} else {
    http_response_code(405);
    echo json_encode(['error' => 'Method not allowed']);
}
?>
