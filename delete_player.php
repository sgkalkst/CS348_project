<?php
$servername = "127.0.0.1";
$username = "root";
$password = "";
$dbname = "fantasy_football";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if (isset($_POST['player_id'])) {
    $sql = "CALL SP_DeletePlayer(" . $_POST['player_id'] . ")";
    $result = $conn->query($sql);

    if ($result) {
        echo "Player added successfully!";
        header("Location: index.php?page=players"); 
        exit;
    } else {
        echo "Error: " . $conn->error;
    }
} else {
    echo "Invalid request.";
}

$conn->close();
?>
