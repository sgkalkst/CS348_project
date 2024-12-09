<?php
$servername = "127.0.0.1";
$username = "root";
$password = "";
$dbname = "fantasy_football";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if (isset($_POST['player_id_drop'])) {
    $player_id_drop = $_POST['player_id_drop'];
    $player_id_add = $_POST['player_id_add'];

    $sql = "CALL SP_SwapPlayers({$player_id_drop}, {$player_id_add})";
    $result = $conn->query($sql);

    if ($result) {
        echo "Add drop successful!";
        header("Location: index.php?page=roster"); 
        exit;
    }
    
} else {
    echo "Invalid request.";
}

$conn->close();
?>
