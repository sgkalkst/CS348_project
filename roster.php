<?php
$servername = "127.0.0.1";
$username = "root";
$password = "";
$dbname = "fantasy_football";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

if (isset($_POST['obs_team_id'])) {
    $obs_team_id = $_POST['obs_team_id'];

    $sql = "CALL SP_GetTeamName(" . $obs_team_id . ")";
    $result = $conn->query($sql);
    while ($row = $result->fetch_assoc()) {
        $obs_team_name = $row['team_name'];
    }
    $result->free();
    $conn->next_result();
}

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
    }
    
    .filterDiv {
        width: 100%;
        height: 15%;
        display: flex;
        flex-direction: column;
        align-items: center;
    }

    .displayDiv {
        width: 100%;
        height: 85%;
        display: flex;
        flex-direction: column;
        margin: 0 auto;
        align-items: center;
    }

    table {
        width: 80%;
        margin: 0 auto;
        text-align: left;
        align-items: center;
    }

    button {
        margin: 0 auto;
    }

</style>
<body>
    <div class="container">
        <div class="filterDiv">
            <h2>Select a team from the dropdown menu to view its roster!</h2>
            <form method="POST" onchange="submit()">
                <select name="obs_team_id">
                    <option>Select a team...</option>
                    <?php
                    $servername = "127.0.0.1";
                    $username = "root";
                    $password = "";
                    $dbname = "fantasy_football";
                    
                    $conn = new mysqli($servername, $username, $password, $dbname);
                    
                    if ($conn->connect_error) {
                        die("Connection failed: " . $conn->connect_error);
                    }
                    
                    $sql = "CALL SP_GetTeamNames()";
                    $result = $conn->query($sql);

                    while ($row = $result->fetch_assoc()) {
                        echo "<option value=" . $row['manager_id'] . ">". $row['team_name'] . "</option>";
                    }

                    $result->free();
                    $conn->next_result();
                    ?>
                </select>
            </form>
        </div>
        <div class="displayDiv">
            <?php
                if (isset($_POST['obs_team_id'])) {
                    echo "<h2>" . $obs_team_name . "</h2>";

                    $sql = "CALL SP_GetRoster(" . $obs_team_id . ")";
                    $result = $conn->query($sql);
                    echo "<table border='1'>
                        <tr>
                            <th style='width: 30%;'>Player Name</th>
                            <th style='width: 30%;'>Position</th>
                            <th style='width: 30%;'>Player Team</th>
                            <th style='width: 10%;'>Replace</th>
                        </tr>";
                    while ($row = $result->fetch_assoc()) {
                        echo "<tr>
                                <td>{$row['player_name']}</td>
                                <td>{$row['position_name']}</td>
                                <td>{$row['nfl_team_name']}</td>
                                <td><button id='swap_{$row['player_id']}' class='swapBtn' data-id='{$row['player_id']}'>-/+</button></td>
                            </tr>";
                    }
                    echo "</table>";
                    $result->free();
                    $conn->next_result();
                }
            ?>
        </div>
    </div>
</body>
</html>
<script>
document.addEventListener("DOMContentLoaded", () => {
    document.querySelectorAll(".swapBtn").forEach(button => {
        button.addEventListener("click", (event) => {
            const buttonID = event.target.id;
            const playerID = buttonID.split("_")[1];

            const form = document.createElement("form");
            form.method = "POST";
            form.action = "index.php?page=roster_change";

            const input = document.createElement("input");
            input.type = "hidden";
            input.name = "player_id";
            input.value = playerID;

            form.appendChild(input);
            document.body.appendChild(form);
            form.submit();
        });
    });
});
</script>
