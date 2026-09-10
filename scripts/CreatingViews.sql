----- Divide The table into Dims Table and Fact Table -----
CREATE OR ALTER VIEW dim_players AS
WITH CTE_Players AS
(
    SELECT
        PlayerID,
        Player AS PlayerName,
        RIGHT(Nation, 3) AS Nationality,
        Pos AS Position,
        Age,
        Born AS BirthYear,

        ROW_NUMBER() OVER
        (
            PARTITION BY PlayerID
            ORDER BY PlayerID
        ) AS rn

    FROM player_data_staging
)
SELECT
    PlayerID,
    PlayerName,
    Nationality,
    Position,
    Age,
    BirthYear
FROM CTE_Players
WHERE rn = 1;
-------------------------------------------
CREATE OR ALTER VIEW dim_clubs AS
SELECT
    ROW_NUMBER() OVER (ORDER BY Squad) AS ClubID,
    Squad AS Club
FROM (
    SELECT DISTINCT Squad
    FROM player_data_staging
    WHERE Squad IS NOT NULL
) AS c;
-------------------------------------------
CREATE OR ALTER VIEW dim_competitions AS
SELECT
    ROW_NUMBER() OVER (ORDER BY Comp) AS CompID,
    Comp AS Competition
FROM (
    SELECT DISTINCT Comp
    FROM player_data_staging
    WHERE Comp IS NOT NULL
) AS c;
------------------------------------------------
CREATE OR ALTER VIEW fact_stats AS 
SELECT 
    s.PlayerID,
    c.ClubID,
    co.CompID,

    s.MP AS MatchesPlayed,
    s.Starts AS MatchesStarted,
    s.[Min] AS MinutesPlayed,
    s.[90s] AS Minutes90s,
    s.Gls AS Goals,
    s.Ast AS Assists,
    s.[G+A] AS GoalsContributions,
    s.[G-PK] AS NonPenaltyGoals,
    s.PK AS PenaltyGoals,
    s.PKatt AS PenaltyAttempts,
    s.CrdY AS YellowCards,
    s.CrdR AS RedCards,
    s.Sh AS Shots,
    s.SoT AS ShotsOnTarget,
    s.[SoT%] AS ShotsOnTargetPct,
    s.[Sh 90] AS ShotsPer90min,
    s.[SoT 90] AS ShotsOnTargetPer90min,
    s.[G Sh] AS GoalsPerShot,
    s.[G SoT] AS GoalsPerShotOnTarget,
    s.Crs AS Crosses,
    s.TklW AS TacklesWon,
    s.[Int] AS Interceptions,
    s.Fld AS FoulsDrawn,
    s.[2CrdY] AS SecondYellowCards,
    s.Fls AS FoulsCommitted,
    s.OG AS OwnGoals

FROM player_data_staging s
JOIN dim_clubs c
    ON s.Squad = c.Club
JOIN dim_competitions co
    ON s.Comp = co.Competition;


