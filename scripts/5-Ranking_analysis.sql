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