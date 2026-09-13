-----1- Explore The DataBase -----
SELECT * FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_players' OR TABLE_NAME = 'dim_competitions'
	  OR TABLE_NAME = 'dim_clubs' OR TABLE_NAME = 'fact_stats';

SELECT * FROM dim_players;
SELECT * FROM dim_competitions;
SELECT * FROM dim_clubs;
SELECT * FROM fact_stats;

-----2- Explore The Dimention Views -----
-----2.A Explore dim_players ----- 
SELECT DISTINCT
	Nationality
FROM dim_players;

SELECT DISTINCT
	Position
FROM dim_players;

SELECT DISTINCT
	Age
FROM dim_players
ORDER BY Age;

SELECT DISTINCT
	BirthYear
FROM dim_players
ORDER BY BirthYear 

-----2.B Explore dim_competitions ----- 
SELECT DISTINCT
	Competition
FROM dim_competitions;

-----2.C Explore dim_clubs ----- 
SELECT DISTINCT
	Club
FROM dim_clubs;

-----3- Explore The measures -----
SELECT 'Total Players' AS [Players_Stats],COUNT(DISTINCT PlayerID) AS Report FROM dim_players
UNION ALL 
SELECT 'Total Countries' , COUNT(DISTINCT Nationality) FROM dim_players
UNION ALL 
SELECT 'Total Competitions' , COUNT(DISTINCT CompID) FROM dim_competitions
UNION ALL 
SELECT 'Total Clubs' , COUNT(DISTINCT ClubID) FROM dim_clubs
UNION ALL 
SELECT 'Total Matches',* 
FROM(SELECT SUM((TotalClub / 2) * TotalRounds) AS TotalMatches
	FROM (SELECT CompID,MAX(MatchesPlayed) AS TotalRounds,COUNT(DISTINCT ClubID) AS TotalClub	
		FROM fact_stats GROUP BY CompID)b)T
UNION ALL 
SELECT 'Total Goals' , SUM(Goals) FROM fact_stats
UNION ALL 
SELECT 'Total Assists' , SUM(Assists) FROM fact_stats
UNION ALL 
SELECT 'Total Penalties' , SUM(PenaltyAttempts) FROM fact_stats
UNION ALL 
SELECT 'Total Yellow Cards' , SUM(YellowCards) FROM fact_stats
UNION ALL 
SELECT 'Total Red Cards' , SUM(RedCards) FROM fact_stats
UNION ALL 
SELECT 'Own Goals' , SUM(OwnGoals) FROM fact_stats
