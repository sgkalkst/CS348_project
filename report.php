<?php
$servername = "127.0.0.1";
$username = "root";
$password = "";
$dbname = "fantasy_football";

$conn = new mysqli($servername, $username, $password, $dbname);

if ($conn->connect_error) {
    die("Connection failed: " . $conn->connect_error);
}

// Retrieve game dates
$dates = [];
$sql = "CALL SP_GetGameDates()";
if ($result = $conn->query($sql)) {
    while ($row = $result->fetch_assoc()) {
        $dates[] = $row['game_date'];
    }
    $result->free();
    $conn->next_result();
} else {
    echo "Error retrieving dates: " . $conn->error;
}

// Retrieve teams
$team_names = [];
$team_ids = [];
$sql = "CALL SP_GetTeamNames()";
if ($result = $conn->query($sql)) {
    while ($row = $result->fetch_assoc()) {
        $team_names[] = $row['team_name'];
        $team_ids[] = $row['manager_id'];
    }
    $result->free();
    $conn->next_result();
} else {
    echo "Error retrieving teams: " . $conn->error;
}
?>

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
    .reportContainer {
        height: 100%;
        width: 100%;
        display: flex;
        flex-direction: column;
    }
    .message {
        text-align: center;
    }
    .filters {
        height: 20%;
        display: flex;
        padding: 1.5%;
    }
    .formSubContainer {
        width: 33.33%;
        float: left;
        padding: 4px;
    }
    .teamFrame {
        width: 100%;
        display: flex;
        flex-direction: row;
    }
    .team {
        width: 50%;
        margin: 0 auto;
        display: flex;
        flex-direction: column;
        align-items: center;
    }
    body {
        font-family: 'Roboto', sans-serif;
        color: white;
    }
</style>
<body>
    <div class="reportContainer">
        <form method="POST" action="index?page=report">
            <div class="filters">
                <div class="formSubContainer">
                    <label for="game_date">Select Game Date:</label>
                    <select id="game_date" name="game_date" selected="<?php if(isset($_POST['game_date'])) { echo $_POST['game_date']; } else { echo "";}?>"required>
                        <option value="">Select a date...</option>
                        <?php
                        foreach ($dates as $date) {
                            echo "<option value='" . $date . "'>" . $date . "</option>";
                        }
                        ?>
                    </select>
                </div>
                <div class="formSubContainer">
                    <label for="team1">Select Team 1:</label>
                    <select id="team1" name="team1" required>
                        <option value="">Select a team...</option>
                        <?php
                        for ($i = 0; $i < count($team_names); $i++) {
                            echo "<option value='" . $team_ids[$i] . "'>" . $team_names[$i] . "</option>";
                        }
                        ?>
                    </select>
                </div>
                <div class="formSubContainer">
                    <label for="team2">Select Team 2:</label>
                    <select id="team2" name="team2" required>
                        <option value="">Select a team...</option>
                        <?php
                        for ($i = 0; $i < count($team_names); $i++) {
                            echo "<option value='" . $team_ids[$i] . "'>" . $team_names[$i] . "</option>";
                        }
                        ?>
                    </select>
                </div>
            </div>
        <div class="message">
            <button type="submit" style="margin-top: 20px;">Compare</button>
        </form>
            <?php 
                if (!isset($_POST['game_date'])) {
                    echo "<h2>Select a game date and two teams to see who would have won!</h2>";
                } else {
                    echo "<h2>{$_POST['game_date']}</h2>";
                }
            ?>
        </div>
        <div class="teamFrame">
            <div class="team">
                <?php
                    if (isset($_POST['team1'])) {
                        $team = $_POST['team1'];
                        $game_date = $_POST['game_date'];
                        echo "<h2>" . $team_names[array_search($team, $team_ids)] . "</h2>";
                       
                        // GET ROSTER REPORT
                        $stmt = $conn->prepare(
                            "SELECT * from vw_calculatedgamelog
                            WHERE game_date = ?
                            AND player_id IN (SELECT DISTINCT player_id FROM rosters WHERE manager_id = ?)"
                        );
                        
                        $stmt->bind_param("si", $game_date, $team);

                        if ($stmt->execute()) {
                            $result = $stmt->get_result();

                            if ($result->num_rows > 0) {
                                echo "<table border='1'>";
                                echo "<tr><th>Player Name</th><th>Position</th><th>Fantasy Points</th></tr>";
                    
                                while ($row = $result->fetch_assoc()) {
                                    echo "<tr>";
                                    echo "<td>" . $row['player_name'] . "</td>";
                                    echo "<td>" . $row['position_name'] . "</td>";
                                    echo "<td>" . $row['fantasy_points'] . "</td>";
                                    echo "</tr>";
                                }
                                
                                $result->free();
                                $stmt->close();

                                // GET TOTAL POINT SUM

                                $stmt = $conn->prepare(
                                    "SELECT SUM(fantasy_points) AS total_points FROM vw_calculatedgamelog
                                    WHERE game_date = ?
                                    AND player_id IN (SELECT DISTINCT player_id FROM rosters WHERE manager_id = ?)"
                                );

                                $stmt->bind_param("si", $game_date, $team);
                                
                                if ($stmt->execute()) {
                                    $result = $stmt->get_result();
                                    if ($result->num_rows > 0) {
                                        while ($row = $result->fetch_assoc()) {
                                            echo "<tr>";
                                            echo "<td> Total Points </td>";
                                            echo "<td></td>";
                                            echo "<td>" . $row['total_points'] . "</td>";
                                            echo "</tr>";
                                        }
                                    }
                                }

                                echo "</table>";
                            }
                        }
                        $result->free();
                        $conn->next_result();
                    }
                ?>
            </div>
            <div class="team">
                <?php
                    if (isset($_POST['team2'])) {
                        $team = $_POST['team2'];

                        echo "<h2>" . $team_names[array_search($team, $team_ids)] . "</h2>";
                        
                        // GET ROSTER REPORT
                        $stmt = $conn->prepare(
                            "SELECT * from vw_calculatedgamelog
                            WHERE game_date = ?
                            AND player_id IN (SELECT DISTINCT player_id FROM rosters WHERE manager_id = ?)"
                        );

                        $stmt->bind_param("si", $game_date, $team);
                        
                        if ($stmt->execute()) {
                            $result = $stmt->get_result();

                            if ($result->num_rows > 0) {
                                echo "<table border='1'>";
                                echo "<tr><th>Player Name</th><th>Position</th><th>Fantasy Points</th></tr>";
                    
                                while ($row = $result->fetch_assoc()) {
                                    echo "<tr>";
                                    echo "<td>" . $row['player_name'] . "</td>";
                                    echo "<td>" . $row['position_name'] . "</td>";
                                    echo "<td>" . $row['fantasy_points'] . "</td>";
                                    echo "</tr>";
                                }

                                $result->free();
                                $stmt->close();

                                // GET TOTAL POINT SUM

                                $stmt = $conn->prepare(
                                    "SELECT SUM(fantasy_points) AS total_points FROM vw_calculatedgamelog
                                    WHERE game_date = ?
                                    AND player_id IN (SELECT DISTINCT player_id FROM rosters WHERE manager_id = ?)"
                                );

                                $stmt->bind_param("si", $game_date, $team);
                                
                                if ($stmt->execute()) {
                                    $result = $stmt->get_result();
                                    if ($result->num_rows > 0) {
                                        while ($row = $result->fetch_assoc()) {
                                            echo "<tr>";
                                            echo "<td> Total Points </td>";
                                            echo "<td></td>";
                                            echo "<td>" . $row['total_points'] . "</td>";
                                            echo "</tr>";
                                        }
                                    }
                                }
                    
                                echo "</table>";
                            }
                        }
                        $result->free();
                        $stmt->close();
                        $conn->next_result();
                    }
                ?>
            </div>
        </div>  
    </div>
</body>
</html>