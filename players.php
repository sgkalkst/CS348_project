<?php
$servername = "127.0.0.1";
$username = "root";
$password = "";
$dbname = "fantasy_football";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}
?>
<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Game Log</title>
</head>
<style>
    .playersContainer {
        width: 100%;
        height: 100%;
        display: flex;
        flex-direction: column;
        font-family: 'Roboto', sans-serif;
    }

    .spacerDiv {
        height: 5%;
    }

    .viewDiv {
        width: 90%;
        height: 75%;
        overflow-y: auto;
        margin: auto;
    }

    .addPlayerDiv {
        width: 100%;
        height: 15%;
        display: flex;
        flex-direction: column;
    }

    .formContainer {
        display: flex;
        flex-direction: row;
        align-items: center;
    }

    .form-grp {
        width: 25%;
        display: flex;
        flex-direction: column;
        padding: 1%;
    }

    th {
        position: sticky; 
        top: 0; 
        z-index: 1;
        background-color: #04AA6D;
    }

    table {
        border: none;
        width: 100%;
    }

</style>
<body>
<div class="playersContainer">
    <div class="spacerDiv"></div>
    <div class="viewDiv">
    <?php
    $sql = "CALL SP_GetPlayers()";
    $result = $conn->query($sql);

    echo "<table>";
    echo "<tr><th style='width: 28.33%;'>Name</th><th style='width: 28.33%;'>Position</th><th style='width: 28.33%;'>NFL Team</th><th colspan='2' style='width: 15%;'>Operations</th></tr>";
    while ($row = $result->fetch_assoc()) {
        echo "<tr>";
        echo "<td>{$row['player_name']}</td>";
        echo "<td>{$row['position_name']}</td>";
        echo "<td>{$row['nfl_team_name']}</td>";
        echo "<td><button id='edit_{$row['player_id']}' class='editBtn' data-id='{$row['player_id']}'>Edit</button></td>";
        if ($row['is_on_roster']) {
            echo "<td><button id='delete_{$row['player_id']}' class='deleteBtn' data-id='{$row['player_id']}' disabled>Delete</button></td>";
        } else {
            echo "<td><button id='delete_{$row['player_id']}' class='deleteBtn' data-id='{$row['player_id']}'>Delete</button></td>";
        }
        echo "</tr>";
    }
    echo "</table>";

    $result->free();
    $conn->next_result();
    ?>
    </div>
    <div class="spacerDiv"></div>
    <div class="addPlayerDiv">
        <form method="POST" action="add_player.php">
        <div class="formContainer">
            <div class="form-grp">
                <label>Name</label>
                <input name="player_name" required>
            </div>
            
            <div class="form-grp">
                <label>Position</label>
                <select name="position_id" required>
                    <option></option>
                    <?php
                    $sql = "CALL SP_GetPositions()";
                    $result = $conn->query($sql);

                    while ($row = $result->fetch_assoc()) {
                        echo "<option value=". $row['position_id'] . ">" . $row['position_name'] . "</option>";
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
                        echo "<option value=". $row['nfl_team_id'] . ">" . $row['nfl_team_name'] . "</option>";
                    }
                    $result->free();
                    $conn->next_result();
                    ?>
                </select>
            </div>

            <div class="form-grp">
                <label>Submit</label>
                <button>Add Player</button>
            </div>
        </div>
        </form>
    </div>
</div>
</body>
<script>
    document.addEventListener("DOMContentLoaded", () => {
        document.querySelectorAll(".deleteBtn").forEach(button => {
            button.addEventListener("click", (event) => {
                const buttonID = event.target.id;
                const playerID = buttonID.split("_")[1];

                if (confirm("Are you sure you want to delete this player?")) {
                    const form = document.createElement("form");
                    form.method = "POST";
                    form.action = "delete_player.php";

                    const input = document.createElement("input");
                    input.type = "hidden";
                    input.name = "player_id";
                    input.value = playerID;

                    form.appendChild(input);
                    document.body.appendChild(form);
                    form.submit();
                }
            });
        });
        document.querySelectorAll(".editBtn").forEach(button => {
            button.addEventListener("click", (event) => {
                const buttonID = event.target.id;
                const playerID = buttonID.split("_")[1];

                if (confirm("Are you sure you want to edit this player?")) {
                    const form = document.createElement("form");
                    form.method = "POST";
                    form.action = "index.php?page=edit_player";

                    const input = document.createElement("input");
                    input.type = "hidden";
                    input.name = "player_id";
                    input.value = playerID;

                    form.appendChild(input);
                    document.body.appendChild(form);
                    form.submit();
                }
            });
        });
    });
</script>
