<?php
$servername = "127.0.0.1";
$username = "root";
$password = "";
$dbname = "fantasy_football";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$player_name = $_POST['player_name'];
$position_id = $_POST['position_id'];
$nfl_team_id = $_POST['nfl_team_id'];

$sql = "CALL SP_AddPlayer(?, ?, ?)";
$stmt = $conn->prepare($sql);
$stmt->bind_param("sii", $player_name, $position_id, $nfl_team_id);

if ($stmt->execute()) {
    echo "Player added successfully!";
    header("Location: index.php?page=players"); 
    exit;
} else {
    echo "Error: " . $stmt->error;
}

$stmt->close();
$conn->close();
?>
