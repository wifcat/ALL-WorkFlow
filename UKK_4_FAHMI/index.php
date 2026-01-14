<?php

session_start(); 

require_once 'Controllers/C_LOGIN.php';

$URL = parse_url($_SERVER['REQUEST_URI'], PHP_URL_PATH);
$URL = str_replace('/00_T', '', $URL); 

$AUTH = new C_LOGIN();

// Logout
if ($URL === '/index.php' && ($_GET['action'] ?? '') === 'logout') {
    session_destroy();
    header("Location: index.php");
    exit;
}

// Kalau sudah login, tampil halaman utama
if (isset($_SESSION['login']) && $_SESSION['login'] === true) {
    require 'Views/index.php';
    exit;
}

// Kalau belum login, tampil login page
if (($URL === '/' || $URL === '/index.php') && $_SERVER['REQUEST_METHOD'] === 'GET') {
    $AUTH->C_LOGIN();
}

// Proses login
elseif (($URL === '/' || $URL === '/index.php') && $_SERVER['REQUEST_METHOD'] === 'POST') {
    $AUTH->C_AUTH();
}
else {
    echo "Error 404!";
}
