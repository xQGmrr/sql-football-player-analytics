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

-----4- Magnitude Analysis -----
-----4.A Players Stats By Competitions -----
SELECT *,
	(TotalClub / 2) * TotalRounds AS TotalMatchesByComp,
	SUM((TotalClub / 2) * TotalRounds) OVER() AS TotalMatches,
	ROUND(CAST(TotalGoals AS float) / ((TotalClub / 2) * TotalRounds),2) AS AverageGoalsPerMatch
FROM
(
SELECT
	c.Competition,
	COUNT(DISTINCT s.PlayerID) AS PlayersCount,
	COUNT(DISTINCT p.Nationality) AS CountriesCount,
	COUNT(DISTINCT s.ClubID) AS TotalClub,
	ROUND(AVG(CAST(p.Age AS FLOAT)), 1) AS AverageAge,
	SUM(Goals) AS TotalGoals,
	SUM(Assists) AS TotalAssists,
	MAX(MatchesPlayed) AS TotalRounds,
	SUM(PenaltyAttempts) AS TotalPenalties,
	SUM(YellowCards) AS TotalYellowCards,
	SUM(RedCards) AS TotalRedCards,
	SUM(OwnGoals) AS TotalOwnGoals
FROM fact_stats s
INNER JOIN dim_competitions c
ON s.CompID = c.CompID
INNER JOIN dim_players p 
ON p.PlayerID = s.PlayerID
GROUP BY c.Competition
)t
ORDER BY TotalRounds DESC

-----4.B Players Stats By Countries -----
SELECT
	p.Nationality,
	COUNT(DISTINCT s.PlayerID) AS PlayersCount,
	COUNT(DISTINCT s.CompID) AS CompetitionsCount,
	COUNT(DISTINCT s.ClubID) AS ClubsCount,
	ROUND(AVG(CAST(p.Age AS FLOAT)), 1) AS AverageAge,
	SUM(s.Goals) AS TotalGoals,
	SUM(s.Assists) AS TotalAssists,
	SUM(s.PenaltyAttempts) AS TotalPenalties,
	SUM(s.YellowCards) AS TotalYellowCards,
	SUM(s.RedCards) AS TotalRedCards,
	SUM(s.OwnGoals) AS TotalOwnGoals
FROM fact_stats s
INNER JOIN dim_players p 
ON p.PlayerID = s.PlayerID
GROUP BY p.Nationality
ORDER BY PlayersCount DESC

-----4.C Players Stats By Position -----
SELECT
	p.Position,
	COUNT(DISTINCT s.PlayerID) AS PlayersCount,
	COUNT(DISTINCT p.Nationality) AS CountriesCount,
	ROUND(AVG(CAST(p.Age AS FLOAT)), 1) AS AverageAge,
	SUM(s.Goals) AS TotalGoals,
	SUM(s.Assists) AS TotalAssists,
	SUM(s.PenaltyAttempts) AS TotalPenalties,
	SUM(s.YellowCards) AS TotalYellowCards,
	SUM(s.RedCards) AS TotalRedCards,
	SUM(s.OwnGoals) AS TotalOwnGoals
FROM fact_stats s
INNER JOIN dim_players p 
ON p.PlayerID = s.PlayerID
GROUP BY p.Position
ORDER BY PlayersCount DESC

-----4.D Players Stats By Age -----
SELECT
	p.Age,
	COUNT(DISTINCT s.PlayerID) AS PlayersCount,
	COUNT(DISTINCT p.Nationality) AS CountriesCount,
	COUNT(DISTINCT s.ClubID) AS ClubsCount,
	SUM(s.MatchesPlayed) / MAX(s.MatchesPlayed) AS TotalMatches,
	SUM(s.Goals) AS TotalGoals,
	SUM(s.Assists) AS TotalAssists,
	SUM(s.PenaltyAttempts) AS TotalPenalties,
	SUM(s.YellowCards) AS TotalYellowCards,
	SUM(s.RedCards) AS TotalRedCards,
	SUM(s.OwnGoals) AS TotalOwnGoals
FROM fact_stats s
INNER JOIN dim_players p 
ON p.PlayerID = s.PlayerID
GROUP BY p.Age
ORDER BY TotalMatches DESC

-----4.E Players Stats By Clubs -----
SELECT
	cl.Club,
	COUNT(DISTINCT s.PlayerID) AS PlayersCount,
	COUNT(DISTINCT p.Nationality) AS CountriesCount,
	ROUND(AVG(CAST(p.Age AS FLOAT)), 1) AS AverageAge,
	SUM(s.Goals) AS TotalGoals,
	SUM(s.Assists) AS TotalAssists,
	SUM(s.PenaltyAttempts) AS TotalPenalties,
	SUM(s.YellowCards) AS TotalYellowCards,
	SUM(s.RedCards) AS TotalRedCards,
	SUM(s.OwnGoals) AS TotalOwnGoals
FROM fact_stats s
INNER JOIN dim_players p 
ON p.PlayerID = s.PlayerID
INNER JOIN dim_clubs cl
ON cl.ClubID = s.ClubID
GROUP BY cl.Club
ORDER BY PlayersCount DESC
 
 -----5- Ranking Analysis -----
 -----5.A Top 10 Goals Scorer -----
 SELECT 
	PlayerName,
	Nationality,
	Position,
	Age,
	MatchesPlayed,
	TotalGoals
 FROM
 (SELECT 
	p.PlayerName,
	p.Nationality,
	p.Position,
	p.Age,
	-- IF Group of players Share the same amount of Goals we will look for player with fewer matches played
	SUM(s.MatchesPlayed) AS MatchesPlayed,
	SUM(s.Goals) AS TotalGoals, -- Used Because A player can play in multiple clubs
	DENSE_RANK() OVER(ORDER BY SUM(s.Goals) DESC,SUM(s.MatchesPlayed) ASC) AS rn -- To Share Ranking Without Gaps
 FROM fact_stats s
 INNER JOIN dim_players p
 ON p.PlayerID = s.PlayerID
 GROUP BY 
 	p.PlayerName,
	p.Nationality,
	p.Position,
	p.Age
)tt
WHERE rn <= 10 
ORDER BY TotalGoals DESC

 -----5.B Top 10 Assist Providers -----
WITH CTE_Top_Assister 
AS
(
	SELECT 
		p.PlayerName,
		p.Nationality,
		p.Position,
		p.Age,
		SUM(s.Assists) AS TotalAssists,
		SUM(s.MatchesPlayed) AS MatchesPlayed,
		-- IF Group of players Share the same amount of assists we will look for player with fewer matches played
		DENSE_RANK() OVER(ORDER BY SUM(s.Assists) DESC,SUM(s.MatchesPlayed) ASC) AS rn 
 FROM fact_stats s
 INNER JOIN dim_players p
 ON p.PlayerID = s.PlayerID
 GROUP BY 
 	p.PlayerName,
	p.Nationality,
	p.Position,
	p.Age
)

SELECT 
	PlayerName,
	Nationality,
	Position,
	Age,
	MatchesPlayed,
	TotalAssists
FROM CTE_Top_Assister
WHERE rn <= 10 
ORDER BY TotalAssists DESC

 -----5.C Top 10 Goals Contributors -----
WITH CTE_Top_Goals_Contributors 
AS
(
	SELECT 
		p.PlayerName,
		p.Nationality,
		p.Position,
		p.Age,
		SUM(s.MatchesPlayed) AS MatchesPlayed,
		SUM(s.GoalsContributions) AS TotalGoalsContributions,
		DENSE_RANK() OVER(ORDER BY SUM(s.GoalsContributions)DESC,SUM(s.MatchesPlayed) ASC) AS rn 
 FROM fact_stats s
 INNER JOIN dim_players p
 ON p.PlayerID = s.PlayerID
 GROUP BY 
 	p.PlayerName,
	p.Nationality,
	p.Position,
	p.Age
)

SELECT 
	PlayerName,
	Nationality,
	Position,
	Age,
	MatchesPlayed,
	TotalGoalsContributions
FROM CTE_Top_Goals_Contributors
WHERE rn <= 10 
ORDER BY TotalGoalsContributions DESC

----- 5.D Top 10 Goals By Club -----
WITH CTE_Top_Goals_By_Club
AS
(
	SELECT 
		cl.Club,
		SUM(s.Goals) AS TotalGoals,
		DENSE_RANK() OVER(ORDER BY SUM(s.Goals)DESC) AS rn 
 FROM fact_stats s
 INNER JOIN dim_clubs cl
 ON cl.ClubID = s.ClubID
 GROUP BY cl.Club
)

SELECT 
	Club,
	TotalGoals
FROM CTE_Top_Goals_By_Club
WHERE rn <= 10 
ORDER BY rn 

-----6- Part To Whole Analysis -----
-----6.A Competitions Goals Percentage -----
WITH CTE_Comp_Prc 
AS
(
SELECT 
	c.Competition,
	SUM(Goals) AS TotalGoalsByComp
FROM fact_stats s
INNER JOIN dim_competitions c
ON s.CompID = c.CompID
GROUP BY c.Competition
)
SELECT 
	Competition,
	TotalGoalsByComp,
	ROUND(CAST(TotalGoalsByComp AS float)/SUM(TotalGoalsByComp) OVER(),3)*100 AS GoalsPrc
FROM CTE_Comp_Prc;

-----6.B Detailed Players Effect Analysis -----
WITH CTE_RealMadrid_Stats 
AS
(
	SELECT 
		p.PlayerName,
		p.Nationality,
		p.Position,
		p.Age,
		cl.Club,
		s.MatchesPlayed,
		s.MatchesStarted,
		s.Goals,
		s.PenaltyGoals,
		s.PenaltyAttempts,
		s.Assists,
		s.GoalsContributions,
		s.OwnGoals,
		s.YellowCards,
		s.RedCards,
		34 AS AllLeagueRounds,
		SUM(Goals) Over() AS ClubGoalsCount
	FROM fact_stats s 
	LEFT JOIN dim_players p
	ON s.PlayerID = p.PlayerID
	LEFT JOIN dim_clubs cl
	ON cl.ClubID = s.ClubID
	WHERE cl.Club = 'Real Madrid'
)
SELECT 
	PlayerName,
	Nationality,
	Position,
	Age,
	Club,
	MatchesPlayed,
	MatchesStarted,
	Goals,
	PenaltyAttempts,
	PenaltyGoals,
	CONCAT(ROUND(CAST(PenaltyAttempts AS float) / SUM(PenaltyAttempts) OVER(),2)*100,'%') AS ShootingPenaltyPcr,
	Assists,
	GoalsContributions,
	CONCAT(ROUND(CAST(GoalsContributions AS float)/ClubGoalsCount,2)*100,'%') AS PlayerEffect,
	OwnGoals,
	YellowCards,
	RedCards
FROM CTE_RealMadrid_Stats
ORDER BY GoalsContributions DESC,MatchesPlayed DESC,MatchesStarted DESC

-----7- Segmentation Analysis -----
SELECT 
	AVG(FoulsCommitted) AS AverageFouls,
	AVG(RedCards) AS AverageRedCard,
	AVG(YellowCards) AS AverageYellowCard
FROM dim_players p
RIGHT JOIN fact_stats s
ON p.PlayerID = s.PlayerID


