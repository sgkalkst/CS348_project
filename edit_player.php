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

$sql = "CALL SP_GetPlayerInfo(" . $player_id . ")";
$result = $conn->query($sql);

while ($row = $result->fetch_assoc()) {
    $player_position_id = $row['position_id'];
    $player_nfl_team_id = $row['nfl_team_id'];
    $player_name = $row['player_name'];
}

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
    <h2 style="padding-top: 5%;">Edit Player</h2>
    <form method="POST" action="edit_player_processing.php">
    <div class="formContainer">
        <div class="form-grp">
            <label>Name</label>
            <input name="player_name" value="<?php echo $player_name;?>" required disabled>
            <input type="hidden" name="player_id" value="<?php echo $player_id;?>">
        </div>
        <div class="form-grp">
            <label>Position</label>
            <select name="position_id" required disabled>
                <option></option>
                <?php
                $sql = "CALL SP_GetPositions()";
                $result = $conn->query($sql);

                while ($row = $result->fetch_assoc()) {
                    if ($player_position_id == $row['position_id']) {
                        echo "<option value=". $row['position_id'] . " selected>" . $row['position_name'] . "</option>";
                    } else {
                        echo "<option value=". $row['position_id'] . ">" . $row['position_name'] . "</option>";
                    }
                }
                $result->free();
                $conn->next_result();
                ?>
            </select>
        </div>
        <div class="form-grp">
            <label>NFL Team</label>
            <select name="nfl_team_id" required>
                <option></option>
                <?php
                $sql = "CALL SP_GetNFLTeamNames()";
                $result = $conn->query($sql);

                while ($row = $result->fetch_assoc()) {
                    if ($player_nfl_team_id == $row['nfl_team_id']) {
                        echo "<option value=". $row['nfl_team_id'] . " selected>" . $row['nfl_team_name'] . "</option>";
                    } else {
                        echo "<option value=". $row['nfl_team_id'] . ">" . $row['nfl_team_name'] . "</option>";
                    }
                }
                $result->free();
                $conn->next_result();
                ?>
            </select>
        </div>
        <div class="form-grp">
            <button>Submit</button>
        </div>
    </div>
    </form>
</div>
</body>
</html>