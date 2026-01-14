<?php

$DB_CONNECT = mysqli_connect("localhost", "root", "", "FAHMI_PERPUS");

if (!$DB_CONNECT) {
    echo mysqli_connect_error();
}

?>