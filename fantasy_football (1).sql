-- phpMyAdmin SQL Dump
-- version 5.2.1
-- https://www.phpmyadmin.net/
--
-- Host: 127.0.0.1
-- Generation Time: Dec 09, 2024 at 06:03 PM
-- Server version: 10.4.32-MariaDB
-- PHP Version: 8.2.12

SET SQL_MODE = "NO_AUTO_VALUE_ON_ZERO";
START TRANSACTION;
SET time_zone = "+00:00";


/*!40101 SET @OLD_CHARACTER_SET_CLIENT=@@CHARACTER_SET_CLIENT */;
/*!40101 SET @OLD_CHARACTER_SET_RESULTS=@@CHARACTER_SET_RESULTS */;
/*!40101 SET @OLD_COLLATION_CONNECTION=@@COLLATION_CONNECTION */;
/*!40101 SET NAMES utf8mb4 */;

--
-- Database: `fantasy_football`
--

DELIMITER $$
--
-- Procedures
--
CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_AddPlayer` (IN `in_player_name` VARCHAR(100), IN `in_position_id` INT, IN `in_nfl_team_id` INT)   BEGIN
    DECLARE player_exists INT;

    SELECT COUNT(1)
    INTO player_exists
    FROM players
    WHERE player_name = in_player_name;

    IF player_exists > 0 THEN
        ROLLBACK;
    ELSE
        START TRANSACTION;
        INSERT INTO players (player_name, position_id, nfl_team_id)
        VALUES (in_player_name, in_position_id, in_nfl_team_id);
        COMMIT;
    END IF;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_DeletePlayer` (IN `in_player_id` INT)   IF EXISTS(SELECT 1 FROM players WHERE player_id = in_player_id) THEN
	DELETE FROM players
	WHERE player_id = in_player_id;
    Commit;
ELSE
	ROLLBACK;
END IF$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_EditPlayer` (IN `in_player_id` INT, IN `in_nfl_team_id` INT)   BEGIN
    START TRANSACTION;
        UPDATE players
        SET nfl_team_id = in_nfl_team_id
        WHERE player_id = in_player_id;

        COMMIT;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GetAvailablePlayers` (IN `in_player_id` INT)   SELECT * FROM players p
NATURAL JOIN positions
NATURAL JOIN nfl_teams
WHERE player_id NOT IN (SELECT player_id FROM rosters)
	AND position_id = (SELECT position_id FROM players WHERE player_id = in_player_id)$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GetGameDates` ()   BEGIN
	SELECT DISTINCT(g.date) AS game_date FROM games g;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GetNFLTeamNames` ()   SELECT * from nfl_teams$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GetPlayerInfo` (IN `in_player_id` INT)   SELECT * from players
NATURAL JOIN positions
NATURAL JOIN nfl_teams
WHERE player_id = in_player_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GetPlayerNames` ()   SELECT player_id, player_name FROM players$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GetPlayers` ()   SELECT p.player_id, p.player_name, po.position_id, po.position_name, n.nfl_team_id, n.nfl_team_name, 
CASE 
	WHEN p.player_id IN (SELECT player_id FROM rosters) THEN 
 		true
	ELSE
 		false
 END AS is_on_roster
FROM players p
NATURAL JOIN positions po
NATURAL JOIN nfl_teams n
ORDER BY player_name$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GetPositions` ()   BEGIN
	SELECT position_id, position_name FROM positions;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GetRoster` (IN `in_manager_id` INT)   BEGIN
    SELECT r.roster_player_id, pl.player_id, pl.player_name, p.position_name, n.nfl_team_name FROM rosters r
    JOIN players pl ON pl.player_id = r.player_id
    JOIN positions p ON p.position_id = pl.position_id
    JOIN nfl_teams n ON n.nfl_team_id = pl.nfl_team_id
    WHERE r.manager_id = in_manager_id;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GetTeamName` (IN `in_manager_id` INT)   SELECT team_name FROM managers
WHERE manager_id = in_manager_id$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_GetTeamNames` ()   BEGIN
    SELECT manager_id, team_name FROM managers;
END$$

CREATE DEFINER=`root`@`localhost` PROCEDURE `SP_SwapPlayers` (IN `in_player_id_drop` INT, IN `in_player_id_add` INT)   BEGIN
    DECLARE temp_manager_id INT;

    START TRANSACTION;

    SELECT manager_id INTO temp_manager_id
    FROM rosters
    WHERE player_id = in_player_id_drop;

    DELETE FROM rosters
    WHERE player_id = in_player_id_drop;

    INSERT INTO rosters (manager_id, player_id)
    VALUES (temp_manager_id, in_player_id_add);

    COMMIT;
END$$

DELIMITER ;

-- --------------------------------------------------------

--
-- Table structure for table `games`
--

CREATE TABLE `games` (
  `game_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `date` date NOT NULL,
  `passing_yards` int(11) DEFAULT 0,
  `passing_touchdowns` int(11) DEFAULT 0,
  `other_yards` int(11) DEFAULT 0,
  `other_touchdowns` int(11) DEFAULT 0
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `games`
--

INSERT INTO `games` (`game_id`, `player_id`, `date`, `passing_yards`, `passing_touchdowns`, `other_yards`, `other_touchdowns`) VALUES
(1, 1, '2024-09-01', 289, 1, 0, 0),
(2, 2, '2024-09-01', 345, 2, 0, 0),
(3, 3, '2024-09-01', 197, 4, 0, 0),
(4, 4, '2024-09-01', 241, 3, 0, 0),
(5, 5, '2024-09-01', 338, 3, 0, 0),
(6, 6, '2024-09-01', 257, 4, 0, 0),
(7, 7, '2024-09-01', 339, 2, 0, 0),
(8, 8, '2024-09-01', 329, 3, 0, 0),
(9, 9, '2024-09-01', 224, 2, 0, 0),
(10, 10, '2024-09-01', 294, 2, 0, 0),
(11, 11, '2024-09-01', 190, 1, 0, 0),
(12, 12, '2024-09-01', 217, 3, 0, 0),
(13, 13, '2024-09-01', 215, 4, 0, 0),
(14, 14, '2024-09-01', 164, 4, 0, 0),
(15, 15, '2024-09-01', 213, 1, 0, 0),
(16, 16, '2024-09-01', 171, 1, 0, 0),
(17, 17, '2024-09-01', 301, 2, 0, 0),
(18, 18, '2024-09-01', 203, 2, 0, 0),
(19, 19, '2024-09-01', 293, 2, 0, 0),
(20, 20, '2024-09-01', 343, 2, 0, 0),
(21, 21, '2024-09-01', 0, 0, 105, 1),
(22, 22, '2024-09-01', 0, 0, 150, 0),
(23, 23, '2024-09-01', 0, 0, 79, 1),
(24, 24, '2024-09-01', 0, 0, 149, 1),
(25, 25, '2024-09-01', 0, 0, 142, 0),
(26, 26, '2024-09-01', 0, 0, 131, 2),
(27, 27, '2024-09-01', 0, 0, 141, 1),
(28, 28, '2024-09-01', 0, 0, 102, 2),
(29, 29, '2024-09-01', 0, 0, 87, 0),
(30, 30, '2024-09-01', 0, 0, 88, 0),
(31, 31, '2024-09-01', 0, 0, 91, 0),
(32, 32, '2024-09-01', 0, 0, 111, 0),
(33, 33, '2024-09-01', 0, 0, 85, 0),
(34, 34, '2024-09-01', 0, 0, 100, 2),
(35, 35, '2024-09-01', 0, 0, 68, 2),
(36, 36, '2024-09-01', 0, 0, 89, 2),
(37, 37, '2024-09-01', 0, 0, 126, 1),
(38, 38, '2024-09-01', 0, 0, 125, 1),
(39, 39, '2024-09-01', 0, 0, 66, 1),
(40, 40, '2024-09-01', 0, 0, 87, 1),
(41, 41, '2024-09-01', 0, 0, 49, 2),
(42, 42, '2024-09-01', 0, 0, 49, 2),
(43, 43, '2024-09-01', 0, 0, 73, 0),
(44, 44, '2024-09-01', 0, 0, 95, 0),
(45, 45, '2024-09-01', 0, 0, 119, 0),
(46, 46, '2024-09-01', 0, 0, 66, 1),
(47, 47, '2024-09-01', 0, 0, 116, 0),
(48, 48, '2024-09-01', 0, 0, 60, 2),
(49, 49, '2024-09-01', 0, 0, 79, 1),
(50, 50, '2024-09-01', 0, 0, 68, 1),
(51, 51, '2024-09-01', 0, 0, 90, 0),
(52, 52, '2024-09-01', 0, 0, 59, 2),
(53, 53, '2024-09-01', 0, 0, 82, 2),
(54, 54, '2024-09-01', 0, 0, 96, 2),
(55, 55, '2024-09-01', 0, 0, 103, 0),
(56, 56, '2024-09-01', 0, 0, 59, 2),
(57, 57, '2024-09-01', 0, 0, 92, 1),
(58, 58, '2024-09-01', 0, 0, 120, 1),
(59, 59, '2024-09-01', 0, 0, 99, 2),
(60, 60, '2024-09-01', 0, 0, 48, 2),
(61, 61, '2024-09-01', 0, 0, 53, 1),
(62, 62, '2024-09-01', 0, 0, 39, 1),
(63, 63, '2024-09-01', 0, 0, 70, 1),
(64, 64, '2024-09-01', 0, 0, 77, 1),
(65, 65, '2024-09-01', 0, 0, 76, 0),
(66, 66, '2024-09-01', 0, 0, 54, 0),
(67, 67, '2024-09-01', 0, 0, 73, 0),
(68, 68, '2024-09-01', 0, 0, 24, 0),
(69, 69, '2024-09-01', 0, 0, 66, 0),
(70, 70, '2024-09-01', 0, 0, 74, 1),
(71, 71, '2024-09-01', 0, 0, 21, 1),
(72, 72, '2024-09-01', 0, 0, 47, 1),
(73, 73, '2024-09-01', 0, 0, 75, 1),
(74, 74, '2024-09-01', 0, 0, 52, 1),
(75, 75, '2024-09-01', 0, 0, 70, 0),
(76, 76, '2024-09-01', 0, 0, 70, 1),
(77, 77, '2024-09-01', 0, 0, 62, 0),
(78, 78, '2024-09-01', 0, 0, 73, 0),
(79, 79, '2024-09-01', 0, 0, 32, 1),
(80, 80, '2024-09-01', 0, 0, 68, 0),
(81, 1, '2024-09-08', 0, 0, 57, 1),
(82, 2, '2024-09-08', 0, 0, 84, 1),
(83, 3, '2024-09-08', 0, 0, 56, 1),
(84, 4, '2024-09-08', 226, 4, 15, 0),
(85, 5, '2024-09-08', 0, 0, 110, 1),
(86, 6, '2024-09-08', 0, 0, 86, 1),
(87, 7, '2024-09-08', 0, 0, 51, 0),
(88, 8, '2024-09-08', 296, 1, 14, 0),
(89, 9, '2024-09-08', 0, 0, 77, 0),
(90, 10, '2024-09-08', 0, 0, 41, 2),
(91, 11, '2024-09-08', 0, 0, 41, 0),
(92, 12, '2024-09-08', 203, 1, 8, 1),
(93, 13, '2024-09-08', 0, 0, 63, 0),
(94, 14, '2024-09-08', 0, 0, 79, 0),
(95, 15, '2024-09-08', 0, 0, 24, 0),
(96, 16, '2024-09-08', 265, 2, 10, 0),
(97, 17, '2024-09-08', 0, 0, 53, 1),
(98, 18, '2024-09-08', 0, 0, 41, 2),
(99, 19, '2024-09-08', 0, 0, 56, 0),
(100, 20, '2024-09-08', 329, 3, 1, 0),
(101, 21, '2024-09-08', 0, 0, 136, 0),
(102, 22, '2024-09-08', 0, 0, 108, 1),
(103, 23, '2024-09-08', 0, 0, 71, 0),
(104, 24, '2024-09-08', 197, 1, 16, 1),
(105, 25, '2024-09-08', 0, 0, 79, 0),
(106, 26, '2024-09-08', 0, 0, 82, 2),
(107, 27, '2024-09-08', 0, 0, 89, 1),
(108, 28, '2024-09-08', 284, 3, 7, 0),
(109, 29, '2024-09-08', 0, 0, 105, 1),
(110, 30, '2024-09-08', 0, 0, 59, 1),
(111, 31, '2024-09-08', 0, 0, 97, 2),
(112, 32, '2024-09-08', 225, 2, 9, 0),
(113, 33, '2024-09-08', 0, 0, 118, 1),
(114, 34, '2024-09-08', 0, 0, 47, 1),
(115, 35, '2024-09-08', 0, 0, 110, 2),
(116, 36, '2024-09-08', 241, 4, 13, 0),
(117, 37, '2024-09-08', 0, 0, 62, 1),
(118, 38, '2024-09-08', 0, 0, 95, 0),
(119, 39, '2024-09-08', 0, 0, 54, 0),
(120, 40, '2024-09-08', 269, 3, 4, 0),
(121, 41, '2024-09-08', 0, 0, 93, 0),
(122, 42, '2024-09-08', 0, 0, 64, 1),
(123, 43, '2024-09-08', 0, 0, 98, 1),
(124, 44, '2024-09-08', 212, 2, 17, 0),
(125, 45, '2024-09-08', 0, 0, 84, 1),
(126, 46, '2024-09-08', 0, 0, 75, 0),
(127, 47, '2024-09-08', 0, 0, 60, 2),
(128, 48, '2024-09-08', 305, 3, 2, 0),
(129, 49, '2024-09-08', 0, 0, 73, 0),
(130, 50, '2024-09-08', 0, 0, 49, 1),
(131, 51, '2024-09-08', 0, 0, 55, 1),
(132, 52, '2024-09-08', 213, 2, 5, 0),
(133, 53, '2024-09-08', 0, 0, 114, 0),
(134, 54, '2024-09-08', 0, 0, 83, 1),
(135, 55, '2024-09-08', 0, 0, 59, 2),
(136, 56, '2024-09-08', 269, 3, 12, 0),
(137, 57, '2024-09-08', 0, 0, 109, 1),
(138, 58, '2024-09-08', 0, 0, 65, 0),
(139, 59, '2024-09-08', 0, 0, 90, 1),
(140, 60, '2024-09-08', 184, 1, 3, 1),
(141, 61, '2024-09-08', 0, 0, 72, 1),
(142, 62, '2024-09-08', 0, 0, 38, 0),
(143, 63, '2024-09-08', 0, 0, 76, 0),
(144, 64, '2024-09-08', 213, 2, 10, 0),
(145, 65, '2024-09-08', 0, 0, 44, 1),
(146, 66, '2024-09-08', 0, 0, 83, 0),
(147, 67, '2024-09-08', 0, 0, 91, 0),
(148, 68, '2024-09-08', 205, 1, 5, 0),
(149, 69, '2024-09-08', 0, 0, 70, 1),
(150, 70, '2024-09-08', 0, 0, 69, 1),
(151, 71, '2024-09-08', 0, 0, 55, 1),
(152, 72, '2024-09-08', 291, 3, 18, 0),
(153, 73, '2024-09-08', 0, 0, 67, 0),
(154, 74, '2024-09-08', 0, 0, 74, 1),
(155, 75, '2024-09-08', 0, 0, 58, 0),
(156, 76, '2024-09-08', 183, 2, 0, 1),
(157, 77, '2024-09-08', 0, 0, 85, 0),
(158, 78, '2024-09-08', 0, 0, 93, 0),
(159, 79, '2024-09-08', 0, 0, 60, 1),
(160, 80, '2024-09-08', 178, 2, 0, 0);

-- --------------------------------------------------------

--
-- Table structure for table `managers`
--

CREATE TABLE `managers` (
  `manager_id` int(11) NOT NULL,
  `manager_name` varchar(100) NOT NULL,
  `team_name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `managers`
--

INSERT INTO `managers` (`manager_id`, `manager_name`, `team_name`) VALUES
(1, 'Alice', 'Team Alpha'),
(2, 'Bob', 'Team Beta'),
(3, 'Charlie', 'Team Gamma'),
(4, 'Diana', 'Team Delta');

-- --------------------------------------------------------

--
-- Table structure for table `nfl_teams`
--

CREATE TABLE `nfl_teams` (
  `nfl_team_id` int(11) NOT NULL,
  `nfl_team_name` varchar(100) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `nfl_teams`
--

INSERT INTO `nfl_teams` (`nfl_team_id`, `nfl_team_name`) VALUES
(1, 'Arizona Cardinals'),
(2, 'Atlanta Falcons'),
(3, 'Baltimore Ravens'),
(4, 'Buffalo Bills'),
(5, 'Carolina Panthers'),
(6, 'Chicago Bears'),
(7, 'Cincinnati Bengals'),
(8, 'Cleveland Browns'),
(9, 'Dallas Cowboys'),
(10, 'Denver Broncos'),
(11, 'Detroit Lions'),
(12, 'Green Bay Packers'),
(13, 'Houston Texans'),
(14, 'Indianapolis Colts'),
(15, 'Jacksonville Jaguars'),
(16, 'Kansas City Chiefs'),
(17, 'Las Vegas Raiders'),
(18, 'Los Angeles Chargers'),
(19, 'Los Angeles Rams'),
(20, 'Miami Dolphins'),
(21, 'Minnesota Vikings'),
(22, 'New England Patriots'),
(23, 'New Orleans Saints'),
(24, 'New York Giants'),
(25, 'New York Jets'),
(26, 'Philadelphia Eagles'),
(27, 'Pittsburgh Steelers'),
(28, 'San Francisco 49ers'),
(29, 'Seattle Seahawks'),
(30, 'Tampa Bay Buccaneers'),
(31, 'Tennessee Titans'),
(32, 'Washington Commanders');

-- --------------------------------------------------------

--
-- Table structure for table `players`
--

CREATE TABLE `players` (
  `player_id` int(11) NOT NULL,
  `player_name` varchar(100) NOT NULL,
  `position_id` int(11) NOT NULL,
  `nfl_team_id` int(11) DEFAULT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `players`
--

INSERT INTO `players` (`player_id`, `player_name`, `position_id`, `nfl_team_id`) VALUES
(1, 'Patrick Mahomes', 1, 16),
(2, 'Josh Allen', 1, 4),
(3, 'Joe Burrow', 1, 7),
(4, 'Lamar Jackson', 1, 3),
(5, 'Justin Herbert', 1, 18),
(6, 'Jalen Hurts', 1, 26),
(7, 'Trevor Lawrence', 1, 15),
(8, 'Dak Prescott', 1, 9),
(9, 'Kirk Cousins', 1, 21),
(10, 'Tua Tagovailoa', 1, 20),
(11, 'Matthew Stafford', 1, 19),
(12, 'Derek Carr', 1, 23),
(13, 'Russell Wilson', 1, 10),
(14, 'Geno Smith', 1, 29),
(15, 'Deshaun Watson', 1, 8),
(16, 'Jared Goff', 1, 11),
(17, 'Daniel Jones', 1, 24),
(18, 'Brock Purdy', 1, 28),
(19, 'Justin Fields', 1, 6),
(20, 'Mac Jones', 1, 22),
(21, 'Christian McCaffrey', 2, 28),
(22, 'Derrick Henry', 2, 3),
(23, 'Nick Chubb', 2, 8),
(24, 'Saquon Barkley', 2, 26),
(25, 'Jonathan Taylor', 2, 14),
(26, 'Josh Jacobs', 2, 17),
(27, 'Austin Ekeler', 2, 18),
(28, 'Aaron Jones', 2, 12),
(29, 'Alvin Kamara', 2, 23),
(30, 'Tony Pollard', 2, 9),
(31, 'Najee Harris', 2, 27),
(32, 'Joe Mixon', 2, 7),
(33, 'Breece Hall', 2, 25),
(34, 'Travis Etienne', 2, 15),
(35, 'Kenneth Walker III', 2, 29),
(36, 'Dameon Pierce', 2, 13),
(37, 'Javonte Williams', 2, 10),
(38, 'Miles Sanders', 2, 5),
(39, 'David Montgomery', 2, 11),
(40, 'Rhamondre Stevenson', 2, 22),
(41, 'Justin Jefferson', 3, 21),
(42, 'Tyreek Hill', 3, 20),
(43, 'Davante Adams', 3, 25),
(44, 'Stefon Diggs', 3, 13),
(45, 'A.J. Brown', 3, 26),
(46, 'CeeDee Lamb', 3, 9),
(47, 'Ja\'Marr Chase', 3, 7),
(48, 'Amon-Ra St. Brown', 3, 11),
(49, 'Deebo Samuel', 3, 28),
(50, 'Terry McLaurin', 3, 32),
(51, 'Mike Evans', 3, 30),
(52, 'Chris Godwin', 3, 30),
(53, 'Keenan Allen', 3, 18),
(54, 'D.K. Metcalf', 3, 29),
(55, 'Tyler Lockett', 3, 29),
(56, 'DeAndre Hopkins', 3, 31),
(57, 'Michael Pittman Jr.', 3, 14),
(58, 'Amari Cooper', 3, 4),
(59, 'DJ Moore', 3, 6),
(60, 'Brandon Aiyuk', 3, 28),
(61, 'Travis Kelce', 4, 16),
(62, 'George Kittle', 4, 28),
(63, 'Mark Andrews', 4, 3),
(64, 'Darren Waller', 4, 24),
(65, 'T.J. Hockenson', 4, 21),
(66, 'Kyle Pitts', 4, 2),
(67, 'Dallas Goedert', 4, 26),
(68, 'Pat Freiermuth', 4, 27),
(69, 'David Njoku', 4, 8),
(70, 'Evan Engram', 4, 15),
(71, 'Dalton Schultz', 4, 13),
(72, 'Cole Kmet', 4, 6),
(73, 'Tyler Higbee', 4, 19),
(74, 'Hunter Henry', 4, 22),
(75, 'Gerald Everett', 4, 18),
(76, 'Noah Fant', 4, 29),
(77, 'Mike Gesicki', 4, 22),
(78, 'Logan Thomas', 4, 32),
(79, 'Irv Smith Jr.', 4, 7),
(80, 'Hayden Hurst', 4, 5),
(83, 'Adam Jones', 2, NULL),
(85, 'Aaron Rogers', 2, 15);

-- --------------------------------------------------------

--
-- Table structure for table `positions`
--

CREATE TABLE `positions` (
  `position_id` int(11) NOT NULL,
  `position_name` varchar(50) NOT NULL
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `positions`
--

INSERT INTO `positions` (`position_id`, `position_name`) VALUES
(1, 'Quarterback'),
(2, 'Running Back'),
(3, 'Wide Receiver'),
(4, 'Tight End');

-- --------------------------------------------------------

--
-- Table structure for table `rosters`
--

CREATE TABLE `rosters` (
  `roster_player_id` int(11) NOT NULL,
  `manager_id` int(11) NOT NULL,
  `player_id` int(11) NOT NULL,
  `added_date` date DEFAULT curdate()
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_general_ci;

--
-- Dumping data for table `rosters`
--

INSERT INTO `rosters` (`roster_player_id`, `manager_id`, `player_id`, `added_date`) VALUES
(2, 1, 21, '2024-11-01'),
(3, 1, 22, '2024-11-01'),
(4, 1, 41, '2024-11-01'),
(5, 1, 42, '2024-11-01'),
(6, 1, 43, '2024-11-01'),
(7, 1, 61, '2024-11-01'),
(8, 1, 62, '2024-11-01'),
(10, 2, 23, '2024-11-01'),
(13, 2, 45, '2024-11-01'),
(14, 2, 46, '2024-11-01'),
(15, 2, 63, '2024-11-01'),
(16, 2, 64, '2024-11-01'),
(18, 3, 25, '2024-11-01'),
(19, 3, 26, '2024-11-01'),
(20, 3, 47, '2024-11-01'),
(21, 3, 48, '2024-11-01'),
(22, 3, 49, '2024-11-01'),
(23, 3, 65, '2024-11-01'),
(24, 3, 66, '2024-11-01'),
(25, 4, 4, '2024-11-01'),
(26, 4, 27, '2024-11-01'),
(27, 4, 28, '2024-11-01'),
(28, 4, 50, '2024-11-01'),
(29, 4, 51, '2024-11-01'),
(30, 4, 52, '2024-11-01'),
(31, 4, 67, '2024-11-01'),
(32, 4, 68, '2024-11-01'),
(46, 3, 9, '2024-12-08'),
(47, 2, 53, '2024-12-08'),
(48, 2, 29, '2024-12-08'),
(56, 1, 5, '2024-12-09'),
(57, 2, 6, '2024-12-09');

-- --------------------------------------------------------

--
-- Stand-in structure for view `vw_calculatedgamelog`
-- (See below for the actual view)
--
CREATE TABLE `vw_calculatedgamelog` (
`game_id` int(11)
,`player_id` int(11)
,`game_date` date
,`player_name` varchar(100)
,`position_id` int(11)
,`position_name` varchar(50)
,`passing_yards` int(11)
,`passing_touchdowns` int(11)
,`other_yards` int(11)
,`other_touchdowns` int(11)
,`fantasy_points` decimal(16,2)
);

-- --------------------------------------------------------

--
-- Structure for view `vw_calculatedgamelog`
--
DROP TABLE IF EXISTS `vw_calculatedgamelog`;

CREATE ALGORITHM=UNDEFINED DEFINER=`root`@`localhost` SQL SECURITY DEFINER VIEW `vw_calculatedgamelog`  AS SELECT `g`.`game_id` AS `game_id`, `p`.`player_id` AS `player_id`, `g`.`date` AS `game_date`, `p`.`player_name` AS `player_name`, `p`.`position_id` AS `position_id`, `po`.`position_name` AS `position_name`, `g`.`passing_yards` AS `passing_yards`, `g`.`passing_touchdowns` AS `passing_touchdowns`, `g`.`other_yards` AS `other_yards`, `g`.`other_touchdowns` AS `other_touchdowns`, 0.04 * `g`.`passing_yards` + 0.1 * `g`.`other_yards` + 4 * `g`.`passing_touchdowns` + 6 * `g`.`other_touchdowns` AS `fantasy_points` FROM ((`games` `g` join `players` `p` on(`g`.`player_id` = `p`.`player_id`)) join `positions` `po` on(`po`.`position_id` = `p`.`position_id`)) ;

--
-- Indexes for dumped tables
--

--
-- Indexes for table `games`
--
ALTER TABLE `games`
  ADD PRIMARY KEY (`game_id`),
  ADD KEY `idx_games_player` (`player_id`),
  ADD KEY `idx_games_date` (`date`);

--
-- Indexes for table `managers`
--
ALTER TABLE `managers`
  ADD PRIMARY KEY (`manager_id`);

--
-- Indexes for table `nfl_teams`
--
ALTER TABLE `nfl_teams`
  ADD PRIMARY KEY (`nfl_team_id`);

--
-- Indexes for table `players`
--
ALTER TABLE `players`
  ADD PRIMARY KEY (`player_id`),
  ADD KEY `idx_players_name` (`player_name`),
  ADD KEY `idx_players_id` (`player_id`);

--
-- Indexes for table `positions`
--
ALTER TABLE `positions`
  ADD PRIMARY KEY (`position_id`);

--
-- Indexes for table `rosters`
--
ALTER TABLE `rosters`
  ADD PRIMARY KEY (`roster_player_id`),
  ADD KEY `idx_rosters_player` (`player_id`),
  ADD KEY `idx_rosters_manager` (`manager_id`);

--
-- AUTO_INCREMENT for dumped tables
--

--
-- AUTO_INCREMENT for table `games`
--
ALTER TABLE `games`
  MODIFY `game_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=161;

--
-- AUTO_INCREMENT for table `managers`
--
ALTER TABLE `managers`
  MODIFY `manager_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `nfl_teams`
--
ALTER TABLE `nfl_teams`
  MODIFY `nfl_team_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=33;

--
-- AUTO_INCREMENT for table `players`
--
ALTER TABLE `players`
  MODIFY `player_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=95;

--
-- AUTO_INCREMENT for table `positions`
--
ALTER TABLE `positions`
  MODIFY `position_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=5;

--
-- AUTO_INCREMENT for table `rosters`
--
ALTER TABLE `rosters`
  MODIFY `roster_player_id` int(11) NOT NULL AUTO_INCREMENT, AUTO_INCREMENT=58;

--
-- Constraints for dumped tables
--

--
-- Constraints for table `games`
--
ALTER TABLE `games`
  ADD CONSTRAINT `games_ibfk_1` FOREIGN KEY (`player_id`) REFERENCES `players` (`player_id`);

--
-- Constraints for table `rosters`
--
ALTER TABLE `rosters`
  ADD CONSTRAINT `rosters_ibfk_1` FOREIGN KEY (`manager_id`) REFERENCES `managers` (`manager_id`);
COMMIT;

/*!40101 SET CHARACTER_SET_CLIENT=@OLD_CHARACTER_SET_CLIENT */;
/*!40101 SET CHARACTER_SET_RESULTS=@OLD_CHARACTER_SET_RESULTS */;
/*!40101 SET COLLATION_CONNECTION=@OLD_COLLATION_CONNECTION */;
