-----7- Segmentation Analysis -----
WITH CTE_Age_Group 
AS
(
SELECT 
	p.PlayerID,
	p.PlayerName,
	p.Nationality,
	p.Position,
	p.Age,
	CASE
    WHEN p.Age < 21 THEN 'U21'
    WHEN p.Age BETWEEN 21 AND 24 THEN '21-24'
    WHEN p.Age BETWEEN 25 AND 28 THEN '25-28'
    WHEN p.Age BETWEEN 29 AND 32 THEN '29-32'
    ELSE '33+'
    END AS AgeGroup ,
	SUM(s.MatchesPlayed) AS MatchesPlayed,
	SUM(s.Goals)AS Goals,
	SUM(s.PenaltyGoals)AS PenaltyGoals,
	SUM(s.PenaltyAttempts) AS PenaltyAttempts,
	SUM(s.Assists) AS Assists,
	SUM(s.GoalsContributions) AS GoalsContributions,
	SUM(s.OwnGoals) AS OwnGoals,
	SUM(s.YellowCards) AS YellowCards,
	SUM(s.RedCards) AS RedCards
FROM dim_players p
RIGHT JOIN fact_stats s
ON p.PlayerID = s.PlayerID
GROUP BY 
	p.PlayerID,
	p.PlayerName,
	p.Nationality,
	p.Position,
	p.Age,
	CASE
    WHEN p.Age < 21 THEN 'U21'
    WHEN p.Age BETWEEN 21 AND 24 THEN '21-24'
    WHEN p.Age BETWEEN 25 AND 28 THEN '25-28'
    WHEN p.Age BETWEEN 29 AND 32 THEN '29-32'
    ELSE '33+'
    END
)

SELECT 
	AgeGroup,
	COUNT(DISTINCT PlayerID) AS PlayersCount,
	COUNT(DISTINCT Nationality) AS CountriesCount,
	ROUND(AVG(CAST(MatchesPlayed AS float)),2) AS AverageMatches,
	SUM(Goals) AS GoalsCount,
	ROUND(AVG(CAST(Goals AS float)),2) AS AverageGoals,
	SUM(PenaltyAttempts) AS PenaltiesCount,
	SUM(PenaltyGoals) AS PenaltiesGoalsCount,
	SUM(Assists) AS AssistsCount,
	ROUND(AVG(CAST(Assists AS float)),2) AS AverageAssists,
	SUM(GoalsContributions) AS GoalsContributionsCount,
	ROUND(AVG(CAST(GoalsContributions AS float)),2) AS AverageGoalsContributions,
	SUM(OwnGoals) AS OwnGoalsCount,
	SUM(YellowCards) AS YellowCardsCount,
	SUM(RedCards) AS RedCardsCount
FROM CTE_Age_Group
GROUP BY AgeGroup
ORDER BY AgeGroup