<?php
// Login logic
require_once __DIR__ . '/../Models/M_USER.php';

class C_LOGIN {

    public function C_LOGIN()
    {
        require __DIR__ . '/../Views/V_LOGIN_INTERFACE.php';
    }

    public function C_AUTH(){
    session_start();

    $USER_MODEL = new M_USER();
    $USERS = $USER_MODEL->M_FIND_USER($_POST['username']);

    if (!$USERS) {
        die('Username tidak ditemukan atau nonaktif');
    }

    if ($_POST['password'] !== $USERS['password']) {
        die('Password salah');
    }

    $_SESSION['login'] = true;
    $_SESSION['user'] = [
        'id' => $USERS['id'],
        'username' => $USERS['username'],
        'role' => $USERS['role']
    ];

    header("Location: index.php");
    exit;
    }
}