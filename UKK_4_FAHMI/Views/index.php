<?php
if (session_status() === PHP_SESSION_NONE) session_start();
// <?php echo $_SESSION['user']['username'] ?? 'Guest';
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Perpustakaan Sekolah</title>
    <!-- Bootstrap CSS -->
    <link href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css" rel="stylesheet">
    <style>
        body {
            min-height: 100vh;
            display: flex;
            flex-direction: column;
        }
        #sidebar {
            min-width: 220px;
            max-width: 220px;
            background-color: #343a40;
            color: #fff;
            min-height: calc(100vh - 56px - 40px); /* minus header + footer */
        }
        #sidebar .nav-link {
            color: #fff;
            margin-bottom: 5px;
        }
        #sidebar .nav-link:hover {
            background-color: #495057;
            border-radius: 5px;
        }
        #content {
            flex: 1;
            padding: 20px;
        }
        footer {
            background-color: #f8f9fa;
            padding: 10px;
            text-align: center;
        }
    </style>
</head>
<body>

<!-- Navbar / Header -->
<nav class="navbar navbar-expand-lg navbar-dark bg-primary">
    <div class="container-fluid">
        <a class="navbar-brand" href="#">Perpustakaan Sekolah</a>
        <div class="d-flex">
            <span class="navbar-text text-white me-3">
                <?php echo $_SESSION['user']['username'] ?? 'Guest'; ?>
            </span>
            <a href="index.php?action=logout" class="btn btn-outline-light btn-sm">Logout</a>
        </div>
    </div>
</nav>

<div class="d-flex">
    <!-- Sidebar -->
    <div id="sidebar" class="d-flex flex-column p-3">
        <h5 class="text-center">Menu</h5>
        <nav class="nav flex-column mt-3">
            <a class="nav-link" href="#">Dashboard</a>
            <a class="nav-link" href="#">Data Buku</a>
            <a class="nav-link" href="#">Data Anggota</a>
            <a class="nav-link" href="#">Peminjaman</a>
            <a class="nav-link" href="#">Pengembalian</a>
            <a class="nav-link" href="#">Laporan</a>
        </nav>
    </div>

    <!-- Content -->
    <div id="content" class="flex-grow-1">
        <h2>Dashboard</h2>
        <p>Selamat datang di sistem perpustakaan digital sekolah.</p>
    </div>
</div>

<script src="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/js/bootstrap.bundle.min.js"></script>
</body>
</html>
