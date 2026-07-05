<?php
$ch = curl_init('http://localhost/govassist_backend/api/assessments.php');
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode([
    'serviceTitle' => 'Test Service',
    'isEligible' => true,
    'date' => date('Y-m-d\TH:i:s\Z')
]));
curl_setopt($ch, CURLOPT_HTTPHEADER, array('Content-Type: application/json'));
$result = curl_exec($ch);
echo $result;
?>
