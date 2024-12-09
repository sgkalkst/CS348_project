<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
    <link rel="preconnect" href="https://fonts.googleapis.com">
    <link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
    <link href="https://fonts.googleapis.com/css2?family=Roboto:wght@400;700&display=swap" rel="stylesheet">
</head>
<style>
    .container {
        max-width: 800px;
        min-width: 800px;
        display: flex;
        flex-direction: column;
        border: 2px solid black;
        margin: auto;
        background-color: #333;
    }
    .header {
        width: 100%;
        display: flex;
        flex-direction: column;
    }
    .logo {
        width: 100%;
        display: grid;
        place-items: center;
        padding: 5px;
    }
    .navbar {
        width: 100%;
        border-bottom: 2px solid #04AA6D;
        background-color: #333;
        display: flex;
        flex-direction: row;
        justify-content: space-between;
    }
    .content {
        width: 100%;
        height: 600px;
    }
    .element {
        border: 2px solid black;
        width: 40%;
        height: 40%;
        margin: auto;
        align-items: center;
    }
    body {
        font-family: 'Roboto', sans-serif;
        color: white;
    }
    h1, h2 {
        text-align: center;
    }
    ul {
        list-style-type: none;
        width: 100%;
        margin: 0;
        padding: 0;
        overflow: hidden;
        background-color: #333;
    }
    li {
        float: left;
        width: 25%;
    }
    li a {
        display: block;
        color: white;
        text-align: center;
        padding: 14px 16px;
        text-decoration: none;
    }
    li a:hover:not(.active) {
        background-color: #111;
    }
    .active {
        background-color: #04AA6D;
    }

</style>
<body>
<div class="container">
    <div class="header">
        <div class="logo">
            <img src="Fantasy_Football_Logo.webp" alt="Fantasy Football Logo" width="10%">
        </div>
        <hr style="border: none; height: 2px; background-color: #04AA6D; width: 50%;">
        <div class="navbar">
            <ul>
                <?php $page = isset($_GET['page']) ? $_GET['page'] : null; ?>
                <li><a <?php if ($page == 'home' || $page == null) { echo 'class="active"'; }?> href="index.php?page=home">About</a></li>
                <li><a <?php if ($page == 'players' || $page == 'edit_player') { echo 'class="active"'; }?> href="index.php?page=players">Players</a></li>
                <li><a <?php if ($page == 'roster' || $page == 'roster_change') { echo 'class="active"'; }?> href="index.php?page=roster">Edit Rosters</a></li>
                <li><a <?php if ($page == 'report') { echo 'class="active"'; }?> href="index.php?page=report">League Report</a></li>
            </ul>
        </div>
    </div>
    <div class="content">
		<?php
            $page = isset($_GET['page']) ? $_GET['page'] : 'home';
            if ($page == 'home') {
                include 'home.php';
            } elseif ($page == 'roster') {
                include 'roster.php';
            } elseif ($page == 'report') {
                include 'report.php';
            } elseif ($page == 'players') {
                include 'players.php';
            } elseif ($page == 'edit_player') {
                include 'edit_player.php';
            } elseif ($page == 'roster_change') {
                include 'roster_change.php';
            } else {
                echo "<p>Page Not Found :(</p>";
            }
		?>
    </div>
</div>    
</body>
</html>