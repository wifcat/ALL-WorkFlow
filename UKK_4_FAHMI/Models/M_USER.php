<?php
// Login Account
require_once __DIR__ . '/../Database/DB_CONNECT.php';

class M_USER {
    public function M_FIND_USER($USERNAME)
    {
        global $DB_CONNECT;

        $stmt = mysqli_prepare($DB_CONNECT, "SELECT * FROM users WHERE username = ?");

        mysqli_stmt_bind_param($stmt, "s", $USERNAME);
        mysqli_stmt_execute($stmt);

        $RESULT = mysqli_stmt_get_result($stmt);

        return mysqli_fetch_assoc($RESULT);
    }
}