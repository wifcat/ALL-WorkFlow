<?php
    require_once __DIR__ . '/../Database/DB_CONNECT.php';
?>

<!DOCTYPE html>
<html lang="en">
    <head>
        <meta charset="UTF-8">
        <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <title>Registrasi</title>
    </head>
    <body class="bg-light">

    <div class="container">
        <div class="row justify-content-center align-items-center vh-100">
            <div class="col-md-4">
                <div class="card shadow-sm">
                    <div class="card-body">
                        <img src="Assets/LibLogo.png" alt="Logo" width="100" height="100" class="d-block mx-auto">
                        <h3 class="text-center mb-4">Registrasi Anggota</h3>

                        <form action="/register" method="POST">
                            <div class="mb-3">
                                <label for="username" class="form-label">Buat Username</label>
                                <input type="text" id="username" name="username" class="form-control" placeholder="Masukkan username" required>
                            </div>

                            <div class="mb-3">
                                <label for="password" class="form-label">Buat Password</label>
                                <input type="password" id="password" name="password" class="form-control" placeholder="Masukkan password" required>
                                <a href="V_LOGIN_INTERFACE.php"> Sudah punya akun? </a>
                            </div>

                            <button type="submit" class="btn btn-primary w-100">
                                Registrasi
                            </button>
                        </form>

                    </div>
                </div>
            </div>
        </div>
    </div>
    <script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
    </body>
</html>