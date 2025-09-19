<?php
header("Content-Type: application/json");

// Load API key
$apiKey = ""; // Paste inside the quote 

// Ambil input JSON
$data = json_decode(file_get_contents("php://input"), true);
$userMessage = trim($data["message"] ?? "");

if (!$userMessage) {
    http_response_code(400);
    echo json_encode(["reply" => "Not valid input"]);
    exit;
}

// Serve payload for OpenRouter
$payload = [
    "model" => "openai/gpt-oss-20b:free", // Change this model if you want
    "messages" => [
        ["role" => "user", "content" => $userMessage]
    ]
];

// using cURL instead of Node.js
$ch = curl_init("https://openrouter.ai/api/v1/chat/completions");
curl_setopt($ch, CURLOPT_RETURNTRANSFER, true);
curl_setopt($ch, CURLOPT_POST, true);
curl_setopt($ch, CURLOPT_HTTPHEADER, [
    "Content-Type: application/json",
    "Authorization: Bearer $apiKey",
    "HTTP-Referer: http://localhost:8000", // Change it to your host or let it the same..
    "X-Title: MyChatApp"
]);
curl_setopt($ch, CURLOPT_POSTFIELDS, json_encode($payload));
curl_setopt($ch, CURLOPT_TIMEOUT, 10); // 10s timeout

$response = curl_exec($ch);
$httpCode = curl_getinfo($ch, CURLINFO_HTTP_CODE);

if (curl_errno($ch)) {
    curl_close($ch);
    http_response_code(500);
    echo json_encode(["reply" => "Gagal terhubung ke server AI"]);
    exit;
}

curl_close($ch);

// Decode response
$responseData = json_decode($response, true);

if ($httpCode !== 200 || !isset($responseData["choices"][0]["message"]["content"])) {
    $errorMsg = $responseData["error"]["message"] ?? "Model tidak merespon";
    http_response_code(500);
    echo json_encode(["reply" => $errorMsg]);
    exit;
}

// fetch AI Response
$reply = $responseData["choices"][0]["message"]["content"];
echo json_encode(["reply" => $reply]);