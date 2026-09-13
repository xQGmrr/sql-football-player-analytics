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

-----6.C Position Effect on goals contribution -----
SELECT
    p.Position,
    SUM(s.Goals) AS TotalGoals,
    ROUND(CAST(SUM(s.Goals) AS FLOAT)/ NULLIF(SUM(SUM(s.Goals)) OVER (), 0) * 100,2) AS GoalsPct
FROM fact_stats s
INNER JOIN dim_players p
ON p.PlayerID = s.PlayerID
GROUP BY Position
ORDER BY TotalGoals DESC;

SELECT
    p.Position,
    SUM(s.Assists) AS TotalAssists,
    ROUND(CAST(SUM(s.Assists) AS FLOAT)/ NULLIF(SUM(SUM(s.Assists)) OVER (), 0) * 100,2) AS AssistPct
FROM fact_stats s
INNER JOIN dim_players p
ON p.PlayerID = s.PlayerID
GROUP BY Position
ORDER BY TotalAssists DESC;