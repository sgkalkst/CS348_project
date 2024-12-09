<?php
$servername = "127.0.0.1";
$username = "root";
$password = "";
$dbname = "fantasy_football";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

$player_id = $_POST['player_id'];

$sql = "CALL SP_GetPlayerInfo({$player_id})";
$result = $conn->query($sql);

$row = $result->fetch_assoc();
$player_name = $row['player_name'];
$position_name = $row['position_name'];
$nfl_team_name = $row['nfl_team_name'];

$result->free();
$conn->next_result();
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Document</title>
</head>
<style>
    .container {
        width: 100%;
        height: 100%;
        display: flex;
        flex-direction: column;
        margin: 0 auto;
    }

    .form-grp {
        display: flex;
        flex-direction: column;
        padding: 5%;
    }

    .formContainer {
        width: 60%;
        height: 50%;
        display: flex;
        flex-direction: column;
        margin: 0 auto;
        padding: 1%;
    }

    input, select {
        padding: 10px;
        font-size: 14px;
        border: 1px solid #ddd;
        border-radius: 4px;
        width: 100%;
        box-sizing: border-box;
    }

    input:focus, select:focus {
        border-color: #04AA6D;
        outline: none;
    }

    button {
        padding: 10px;
        background-color: #04AA6D;
        color: white;
        font-size: 14px;
        font-weight: bold;
        border: none;
        border-radius: 4px;
        cursor: pointer;
        transition: background-color 0.3s ease;
    }

    button:hover {
        background-color: #037d51;
    }
</style>
<html>
<body>
<div class="container">
    <h2>Dropping:<br> <?php echo $player_name?> <br> <?php echo $position_name?> <br> <?php echo $nfl_team_name?> </h2>
    <form method="POST" action="roster_change_processing.php">
    <div class="formContainer">
        <div class="form-grp">
            <h2>Adding:</h2>
            <select name="player_id_add">
                <option></option>
                <?php
                $sql = "CALL SP_GetAvailablePlayers({$player_id})";
                $result = $conn->query($sql);
                
                while ($row = $result->fetch_assoc()) {
                    echo "<option value='{$row['player_id']}'>{$row['player_name']} | {$row['nfl_team_name']}</option>";
                }
                
                $result->free();
                $conn->next_result();
                ?>
            </select>
        </div>
        <div class="form-grp">
            <input type="hidden" name="player_id_drop" value="<?php echo $player_id;?>">
            <button type="submit">Confirm</button>
            <button id="cancelButton" style="margin-top: 20px; background-color: red;">Cancel</button>
        </div>
    </div>
    </form>
</div>
</body>
</html>
<script>
    document.getElementById("cancelButton").addEventListener("click", function() {
        window.location.href = "index?page=roster";
    })
</script>