-----4- Magnitude Analysis -----
-----4.A Players Stats By Competitions -----
SELECT *,
	(TotalClub / 2) * TotalRounds AS TotalMatchesByComp,
	SUM((TotalClub / 2) * TotalRounds) OVER() AS TotalMatches,
	ROUND(CAST(TotalGoals AS float) / ((TotalClub / 2) * TotalRounds),2) AS AverageGoalsPerMatch,
	ROUND(CAST(TotalGoals AS float) / PlayersCount,2) As AverageGoalsForPlayer
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
	SUM(s.OwnGoals) AS TotalOwnGoals,
	ROUND(CAST(SUM(s.GoalsContributions) AS float) / COUNT(DISTINCT s.PlayerID),2)  AS AverageGoalsContributionForPlayer
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
	SUM(s.OwnGoals) AS TotalOwnGoals,
	ROUND(CAST(SUM(s.GoalsContributions) AS float) / COUNT(DISTINCT s.PlayerID),2)  AS AverageGoalsContributionForPlayer
FROM fact_stats s
INNER JOIN dim_players p 
ON p.PlayerID = s.PlayerID
INNER JOIN dim_clubs cl
ON cl.ClubID = s.ClubID
GROUP BY cl.Club
ORDER BY PlayersCount DESC
  







