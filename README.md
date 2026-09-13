# ⚽ SQL Football Player Analytics

## 📌 Project Overview

This project is an end-to-end **SQL Server football analytics project** built using player statistics from the **2025/26 football season**.

The project demonstrates how raw football data can be transformed into a structured analytical database through:

* Data Cleaning
* Data Standardization
* Data Quality Validation
* Dimensional Modeling
* Fact and Dimension Views
* Exploratory Data Analysis
* Magnitude Analysis
* Ranking Analysis
* Part-to-Whole Analysis
* Player Segmentation
* Business Insights

The project is designed to demonstrate practical **SQL Data Analyst skills**, from raw data preparation to analytical insights.

---

# 🎯 Project Objectives

The main objectives of this project are to:

1. Clean and standardize raw football player data.
2. Handle missing and inconsistent values.
3. Remove irrelevant goalkeeper-specific data from the analysis.
4. Standardize player names, clubs, competitions, positions, and nationalities.
5. Create a reusable `PlayerID` for player-level analysis.
6. Build a simple dimensional model using dimension and fact views.
7. Explore the structure and characteristics of the dataset.
8. Analyze player statistics across:

   * Competitions
   * Countries
   * Clubs
   * Positions
   * Ages
9. Identify top-performing players and clubs.
10. Measure the contribution of competitions, players, and positions.
11. Segment players according to age groups.
12. Generate analytical outputs that can support football performance analysis.

---

# 📊 Dataset

### Source

The project uses the table:

```sql
[players_data_light-2025_2026]
```

The dataset contains football player statistics for the **2025/26 season**.

Important fields include:

| Column | Description                |
| ------ | -------------------------- |
| Player | Player name                |
| Nation | Player nationality         |
| Pos    | Playing position           |
| Squad  | Club                       |
| Comp   | Competition                |
| Age    | Player age                 |
| Born   | Birth year                 |
| MP     | Matches played             |
| Starts | Matches started            |
| Min    | Minutes played             |
| Gls    | Goals                      |
| Ast    | Assists                    |
| G+A    | Goals + Assists            |
| G-PK   | Non-penalty goals          |
| PK     | Penalty goals              |
| PKatt  | Penalty attempts           |
| CrdY   | Yellow cards               |
| CrdR   | Red cards                  |
| Sh     | Shots                      |
| SoT    | Shots on target            |
| SoT%   | Shots on target percentage |
| Crs    | Crosses                    |
| TklW   | Tackles won                |
| Int    | Interceptions              |
| Fld    | Fouls drawn                |
| Fls    | Fouls committed            |
| OG     | Own goals                  |

---

# 🛠️ Tools & Technologies

* **SQL Server**
* **SQL Server Management Studio (SSMS)**
* SQL
* Window Functions
* CTEs
* Aggregate Functions
* CASE Expressions
* JOINs
* Views
* Data Cleaning
* Data Standardization
* Dimensional Modeling

---

# 🗂️ Project Structure

```text
sql-football-player-analytics/
│
├── 1-Data Cleaning.sql
├── 2-Data Modeling.sql
│
├── 3-Explore_the_database.sql
├── 4-Magnitude_analysis.sql
├── 5-Ranking_analysis.sql
├── 6-Part_to_whole_analysis.sql
├── 7-Segmentation_analysis.sql
│
└── README.md
```

---

# 🔄 Project Workflow

```text
Raw Football Dataset
        │
        ▼
Data Cleaning
        │
        ├── Duplicate Detection
        ├── Missing Value Handling
        ├── Remove Goalkeepers
        ├── Remove Unwanted Columns
        ├── Data Type Conversion
        └── Data Standardization
        │
        ▼
player_data_staging
        │
        ├── Player Standardization
        ├── Competition Standardization
        ├── Club Standardization
        ├── Position Standardization
        ├── Country Mapping
        └── PlayerID Creation
        │
        ▼
Dimensional Modeling
        │
        ├── dim_players
        ├── dim_clubs
        ├── dim_competitions
        └── fact_stats
        │
        ▼
SQL Analysis
        │
        ├── Exploration
        ├── Magnitude Analysis
        ├── Ranking Analysis
        ├── Part-to-Whole Analysis
        └── Segmentation Analysis
        │
        ▼
Business Insights
```

---

# 1️⃣ Data Cleaning

## Creating the Staging Table

The raw dataset is copied into a staging table so that all cleaning operations can be performed without modifying the original source.

```sql
SELECT *
INTO player_data_staging
FROM [players_data_light-2025_2026];
```

---

## Duplicate Detection

Potential duplicate records are identified using:

```sql
ROW_NUMBER() OVER(
    PARTITION BY Player,Nation,Pos,Squad,Comp,Age,Born
    ORDER BY Rk
)
```

Example:

```sql
SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY Player,Nation,Pos,Squad,Comp,Age,Born
        ORDER BY Rk
    ) AS Checking_Duplicates
FROM player_data_staging
ORDER BY Rk;
```

This allows duplicate records to be identified without immediately deleting them.

---

## Handling Empty Values

Several statistical columns contained empty strings.

They were converted to `0.0`:

```sql
UPDATE player_data_staging
SET [SoT%] = '0.0'
WHERE [SoT%] = '';

UPDATE player_data_staging
SET [G Sh] = '0.0'
WHERE [G Sh] = '';

UPDATE player_data_staging
SET [G SoT] = '0.0'
WHERE [G SoT] = '';
```

---

## Removing Goalkeepers

Goalkeepers were removed because the project focuses on outfield player statistics.

```sql
DELETE FROM player_data_staging
WHERE Pos = 'GK';
```

Goalkeeper-specific columns were also removed:

```sql
ALTER TABLE player_data_staging
DROP COLUMN GA,GA90,SoTA,Saves,[Save%],W,D,L,CS,[CS%],
PKatt_stats_keeper,PKA,PKsv,PKm,
PK_stats_shooting,PKatt_stats_shooting,
CrdY_stats_misc,CrdR_stats_misc;
```

---

# 🔢 Data Type Conversion

Because the source data was imported from CSV, several columns initially required data type conversion.

Examples:

```sql
ALTER TABLE player_data_staging
ALTER COLUMN Rk INT;

ALTER TABLE player_data_staging
ALTER COLUMN Age INT;

ALTER TABLE player_data_staging
ALTER COLUMN Born INT;

ALTER TABLE player_data_staging
ALTER COLUMN MP INT;

ALTER TABLE player_data_staging
ALTER COLUMN Starts INT;

ALTER TABLE player_data_staging
ALTER COLUMN [Min] INT;

ALTER TABLE player_data_staging
ALTER COLUMN [90s] FLOAT;
```

Performance metrics were also converted:

```sql
ALTER TABLE player_data_staging
ALTER COLUMN Gls INT;

ALTER TABLE player_data_staging
ALTER COLUMN Ast INT;

ALTER TABLE player_data_staging
ALTER COLUMN [G+A] INT;

ALTER TABLE player_data_staging
ALTER COLUMN [G-PK] INT;

ALTER TABLE player_data_staging
ALTER COLUMN PK INT;

ALTER TABLE player_data_staging
ALTER COLUMN PKatt INT;

ALTER TABLE player_data_staging
ALTER COLUMN CrdY INT;

ALTER TABLE player_data_staging
ALTER COLUMN CrdR INT;

ALTER TABLE player_data_staging
ALTER COLUMN [G+A-PK] FLOAT;

ALTER TABLE player_data_staging
ALTER COLUMN SH INT;

ALTER TABLE player_data_staging
ALTER COLUMN SoT INT;

ALTER TABLE player_data_staging
ALTER COLUMN [SoT%] FLOAT;

ALTER TABLE player_data_staging
ALTER COLUMN [Sh 90] FLOAT;

ALTER TABLE player_data_staging
ALTER COLUMN [SoT 90] FLOAT;

ALTER TABLE player_data_staging
ALTER COLUMN [G Sh] FLOAT;

ALTER TABLE player_data_staging
ALTER COLUMN [G SoT] FLOAT;
```

Additional defensive and discipline metrics were converted:

```sql
ALTER TABLE player_data_staging
ALTER COLUMN Crs INT;

ALTER TABLE player_data_staging
ALTER COLUMN TklW INT;

ALTER TABLE player_data_staging
ALTER COLUMN [Int] INT;

ALTER TABLE player_data_staging
ALTER COLUMN Fld INT;

ALTER TABLE player_data_staging
ALTER COLUMN [2CrdY] INT;

ALTER TABLE player_data_staging
ALTER COLUMN Fls INT;

ALTER TABLE player_data_staging
ALTER COLUMN OG INT;
```

---

# 🌍 Data Standardization

## Player Names

The raw dataset contained encoding problems such as:

```text
Ã©
Å¾
Ä‡
í¡
í³
```

These were corrected using `REPLACE()`.

Example:

```sql
UPDATE player_data_staging
SET Player = REPLACE(Player, 'Ã©', 'é')
WHERE Player LIKE '%Ã©%';
```

Other encoding corrections were applied similarly.

A validation query was then used to find suspicious remaining values:

```sql
SELECT DISTINCT Player
FROM player_data_staging
WHERE Player LIKE '%Ã%'
   OR Player LIKE '%Â%'
   OR Player LIKE '%Ä%'
   OR Player LIKE '%Å%'
   OR Player LIKE '%í%'
   OR Player LIKE '%�%'
   OR Player LIKE '%?%';
```

---

# 🏆 Competition Standardization

Competition names were standardized.

For example:

```text
eng Premier League → Premier League
es La Liga         → La Liga
fr Ligue 1         → Ligue 1
it Serie A         → Serie A
de Bundesliga      → Bundesliga
```

SQL:

```sql
UPDATE player_data_staging
SET Comp = REPLACE(Comp, 'eng Premier League', 'Premier League')
WHERE Comp = 'eng Premier League';

UPDATE player_data_staging
SET Comp = REPLACE(Comp, 'es La Liga', 'La Liga')
WHERE Comp = 'es La Liga';

UPDATE player_data_staging
SET Comp = REPLACE(Comp, 'fr Ligue 1', 'Ligue 1')
WHERE Comp = 'fr Ligue 1';

UPDATE player_data_staging
SET Comp = REPLACE(Comp, 'it Serie A', 'Serie A')
WHERE Comp = 'it Serie A';

UPDATE player_data_staging
SET Comp = REPLACE(Comp, 'de Bundesliga', 'Bundesliga')
WHERE Comp = 'de Bundesliga';
```

---

# 🏟️ Club Standardization

Examples:

```text
KÃ¶ln            → Köln
AlavÃ©s          → Alavés
AtlÃ©tico Madrid → Atlético Madrid
```

Example:

```sql
UPDATE player_data_staging
SET Squad = REPLACE(Squad, 'KÃ¶ln', 'Köln')
WHERE Squad = 'KÃ¶ln';
```

---

# ⚽ Position Standardization

Different position combinations were simplified into three main groups:

* MF
* DF
* FW

```sql
UPDATE player_data_staging
SET Pos = 'MF'
WHERE Pos LIKE 'MF%';

UPDATE player_data_staging
SET Pos = 'DF'
WHERE Pos LIKE 'DF%';

UPDATE player_data_staging
SET Pos = 'FW'
WHERE Pos LIKE 'FW%';
```

This makes position-level analysis easier.

---

# 🌎 Country Mapping

A dedicated mapping table was created to transform raw country codes into standardized country names.

```sql
CREATE TABLE country_mapping (
    raw_country NVARCHAR(20) PRIMARY KEY,
    standard_country NVARCHAR(100)
);
```

Example mappings:

```sql
INSERT INTO country_mapping
(raw_country, standard_country)
VALUES
('eg EGY', 'Egypt'),
('eng ENG', 'England'),
('dz ALG', 'Algeria'),
('fr FRA', 'France'),
('br BRA', 'Brazil'),
('ar ARG', 'Argentina'),
('de GER', 'Germany'),
('it ITA', 'Italy');
```

The complete mapping table contains the country mappings required by the dataset.

The staging table is then updated through a join:

```sql
UPDATE p
SET p.Nation = m.standard_country
FROM player_data_staging AS p
INNER JOIN country_mapping AS m
    ON LTRIM(RTRIM(p.Nation)) = m.raw_country;
```

This transforms values such as:

```text
eg EGY → Egypt
eng ENG → England
dz ALG → Algeria
```

Validation:

```sql
SELECT DISTINCT Nation
FROM player_data_staging;
```

---

# 🆔 Creating PlayerID

A `PlayerID` was added to uniquely identify players across their different club records.

```sql
ALTER TABLE player_data_staging
ADD PlayerID INT;
```

`DENSE_RANK()` was used to generate the IDs:

```sql
WITH CTE_Player_ID AS
(
    SELECT
        Player,
        DENSE_RANK() OVER (ORDER BY Player) AS NewPlayerID
    FROM player_data_staging
)
UPDATE p
SET PlayerID = c.NewPlayerID
FROM player_data_staging p
JOIN CTE_Player_ID c
    ON p.Player = c.Player;
```

This allows multiple records for the same player to share the same `PlayerID`.

---

# 2️⃣ Dimensional Modeling

After cleaning, the staging table was transformed into a simple analytical model consisting of:

```text
                  dim_players
                       │
                       │
                       ▼
dim_clubs ───────► fact_stats ◄────── dim_competitions
```

## Dimension Views

### `dim_players`

Contains player-level descriptive information:

```text
PlayerID
PlayerName
Nationality
Position
Age
BirthYear
```

Duplicate player records are removed using `ROW_NUMBER()`.

```sql
CREATE OR ALTER VIEW dim_players AS
WITH CTE_Players AS
(
    SELECT
        PlayerID,
        Player AS PlayerName,
        Nation AS Nationality,
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
```

---

## `dim_clubs`

```sql
CREATE OR ALTER VIEW dim_clubs AS
SELECT
    ROW_NUMBER() OVER (ORDER BY Squad) AS ClubID,
    Squad AS Club
FROM (
    SELECT DISTINCT Squad
    FROM player_data_staging
    WHERE Squad IS NOT NULL
) AS c;
```

---

## `dim_competitions`

```sql
CREATE OR ALTER VIEW dim_competitions AS
SELECT
    ROW_NUMBER() OVER (ORDER BY Comp) AS CompID,
    Comp AS Competition
FROM (
    SELECT DISTINCT Comp
    FROM player_data_staging
    WHERE Comp IS NOT NULL
) AS c;
```

---

# 📈 Fact View

The `fact_stats` view stores measurable football performance metrics.

```sql
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
```

---

# 3️⃣ Exploratory Analysis

The first analysis phase explores the database structure and available dimensions.

## Database Structure

```sql
SELECT *
FROM INFORMATION_SCHEMA.COLUMNS
WHERE TABLE_NAME = 'dim_players'
   OR TABLE_NAME = 'dim_competitions'
   OR TABLE_NAME = 'dim_clubs'
   OR TABLE_NAME = 'fact_stats';
```

The dimensions were also explored using:

```sql
SELECT DISTINCT Nationality
FROM dim_players;

SELECT DISTINCT Position
FROM dim_players;

SELECT DISTINCT Age
FROM dim_players
ORDER BY Age;

SELECT DISTINCT BirthYear
FROM dim_players
ORDER BY BirthYear;
```

Competitions:

```sql
SELECT DISTINCT Competition
FROM dim_competitions;
```

Clubs:

```sql
SELECT DISTINCT Club
FROM dim_clubs;
```

---

# 📊 Key Project Measures

The project calculates several high-level KPIs:

* Total Players
* Total Countries
* Total Competitions
* Total Clubs
* Estimated Total Matches
* Total Goals
* Total Assists
* Total Penalties
* Total Yellow Cards
* Total Red Cards
* Own Goals

Example:

```sql
SELECT 'Total Players' AS [Players_Stats],
       COUNT(DISTINCT PlayerID) AS Report
FROM dim_players

UNION ALL

SELECT 'Total Countries',
       COUNT(DISTINCT Nationality)
FROM dim_players

UNION ALL

SELECT 'Total Competitions',
       COUNT(DISTINCT CompID)
FROM dim_competitions

UNION ALL

SELECT 'Total Clubs',
       COUNT(DISTINCT ClubID)
FROM dim_clubs

UNION ALL

SELECT 'Total Goals',
       SUM(Goals)
FROM fact_stats

UNION ALL

SELECT 'Total Assists',
       SUM(Assists)
FROM fact_stats;
```

---

# 4️⃣ Magnitude Analysis

Magnitude analysis answers questions such as:

> How large is each competition, country, position, age group, or club in terms of players and performance?

---

## Competition Analysis

Metrics include:

* Number of players
* Number of countries
* Number of clubs
* Average age
* Total goals
* Total assists
* Total rounds
* Total penalties
* Yellow cards
* Red cards
* Own goals
* Estimated matches
* Average goals per match
* Average goals per player

Example:

```sql
SELECT *,
    (TotalClub / 2) * TotalRounds AS TotalMatchesByComp,
    SUM((TotalClub / 2) * TotalRounds) OVER() AS TotalMatches,
    ROUND(
        CAST(TotalGoals AS FLOAT) /
        ((TotalClub / 2) * TotalRounds),2
    ) AS AverageGoalsPerMatch,
    ROUND(
        CAST(TotalGoals AS FLOAT) / PlayersCount,2
    ) AS AverageGoalsForPlayer
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
ORDER BY TotalRounds DESC;
```

---

## Country Analysis

The project compares nationalities based on:

* Players
* Competitions
* Clubs
* Average age
* Goals
* Assists
* Penalties
* Cards
* Goal contributions per player

---

## Position Analysis

The project compares:

```text
MF
DF
FW
```

based on:

* Players
* Countries
* Average age
* Goals
* Assists
* Penalties
* Yellow cards
* Red cards
* Own goals

---

## Age Analysis

Age-level analysis evaluates:

* Players
* Countries
* Clubs
* Estimated matches
* Goals
* Assists
* Penalties
* Cards
* Own goals

---

## Club Analysis

Club-level analysis evaluates:

* Players
* Countries represented
* Average age
* Goals
* Assists
* Penalties
* Cards
* Own goals
* Average goal contributions per player

---

# 5️⃣ Ranking Analysis

Ranking analysis identifies the highest-performing players and clubs.

---

## 🥇 Top 10 Goal Scorers

The ranking considers:

1. Total goals — descending
2. Matches played — ascending as a tie-breaker

```sql
DENSE_RANK() OVER(
    ORDER BY
        SUM(s.Goals) DESC,
        SUM(s.MatchesPlayed) ASC
) AS rn
```

The use of `SUM()` is important because a player may have statistics for multiple clubs.

---

## 🅰️ Top 10 Assist Providers

The same ranking approach is applied to assists:

```sql
DENSE_RANK() OVER(
    ORDER BY
        SUM(s.Assists) DESC,
        SUM(s.MatchesPlayed) ASC
) AS rn
```

---

## ⚡ Top 10 Goal Contributors

Goal contributions are ranked using:

```sql
DENSE_RANK() OVER(
    ORDER BY
        SUM(s.GoalsContributions) DESC,
        SUM(s.MatchesPlayed) ASC
) AS rn
```

---

## 🏟️ Top 10 Clubs by Goals

Clubs are ranked according to total goals:

```sql
DENSE_RANK() OVER(
    ORDER BY SUM(s.Goals) DESC
) AS rn
```

This identifies the clubs with the highest total goal output.

---

# 6️⃣ Part-to-Whole Analysis

Part-to-whole analysis answers:

> How much does each component contribute to the overall total?

---

## Competition Goal Contribution

The percentage of total goals scored in each competition is calculated using:

```sql
ROUND(
    CAST(TotalGoalsByComp AS FLOAT)
    / SUM(TotalGoalsByComp) OVER(),
    3
) * 100 AS GoalsPrc
```

This allows each competition's goal production to be compared with the overall dataset.

---

## Real Madrid Player Effect

A detailed player-level analysis was performed for **Real Madrid**.

The analysis evaluates:

* Matches played
* Matches started
* Goals
* Penalty attempts
* Penalty goals
* Assists
* Goal contributions
* Own goals
* Yellow cards
* Red cards

### Penalty Contribution

```sql
CONCAT(
    ROUND(
        CAST(PenaltyAttempts AS FLOAT)
        / SUM(PenaltyAttempts) OVER(),
        2
    ) * 100,
    '%'
) AS ShootingPenaltyPcr
```

### Player Effect

```sql
CONCAT(
    ROUND(
        CAST(GoalsContributions AS FLOAT)
        / ClubGoalsCount,
        2
    ) * 100,
    '%'
) AS PlayerEffect
```

This provides a player-level view of contribution to the club's overall goal contributions.

---

# ⚽ Position Contribution

The project also measures how much each position contributes to total goals.

```sql
SELECT
    p.Position,
    SUM(s.Goals) AS TotalGoals,
    ROUND(
        CAST(SUM(s.Goals) AS FLOAT)
        / NULLIF(SUM(SUM(s.Goals)) OVER (), 0)
        * 100,
        2
    ) AS GoalsPct
FROM fact_stats s
INNER JOIN dim_players p
    ON p.PlayerID = s.PlayerID
GROUP BY Position
ORDER BY TotalGoals DESC;
```

The same methodology is applied to assists.

```sql
SELECT
    p.Position,
    SUM(s.Assists) AS TotalAssists,
    ROUND(
        CAST(SUM(s.Assists) AS FLOAT)
        / NULLIF(SUM(SUM(s.Assists)) OVER (), 0)
        * 100,
        2
    ) AS AssistPct
FROM fact_stats s
INNER JOIN dim_players p
    ON p.PlayerID = s.PlayerID
GROUP BY Position
ORDER BY TotalAssists DESC;
```

---

# 7️⃣ Segmentation Analysis

The players are segmented into age groups:

| Age   | Segment |
| ----- | ------- |
| < 21  | U21     |
| 21–24 | 21-24   |
| 25–28 | 25-28   |
| 29–32 | 29-32   |
| 33+   | 33+     |

The segmentation is created using a `CASE` expression:

```sql
CASE
    WHEN p.Age < 21 THEN 'U21'
    WHEN p.Age BETWEEN 21 AND 24 THEN '21-24'
    WHEN p.Age BETWEEN 25 AND 28 THEN '25-28'
    WHEN p.Age BETWEEN 29 AND 32 THEN '29-32'
    ELSE '33+'
END AS AgeGroup
```

The final analysis calculates:

* Players count
* Countries count
* Average matches
* Total goals
* Average goals
* Penalties
* Penalty goals
* Assists
* Average assists
* Goal contributions
* Average goal contributions
* Own goals
* Yellow cards
* Red cards

Example:

```sql
SELECT 
    AgeGroup,
    COUNT(DISTINCT PlayerID) AS PlayersCount,
    COUNT(DISTINCT Nationality) AS CountriesCount,
    ROUND(AVG(CAST(MatchesPlayed AS FLOAT)),2) AS AverageMatches,
    SUM(Goals) AS GoalsCount,
    ROUND(AVG(CAST(Goals AS FLOAT)),2) AS AverageGoals,
    SUM(PenaltyAttempts) AS PenaltiesCount,
    SUM(PenaltyGoals) AS PenaltiesGoalsCount,
    SUM(Assists) AS AssistsCount,
    ROUND(AVG(CAST(Assists AS FLOAT)),2) AS AverageAssists,
    SUM(GoalsContributions) AS GoalsContributionsCount,
    ROUND(
        AVG(CAST(GoalsContributions AS FLOAT)),2
    ) AS AverageGoalsContributions,
    SUM(OwnGoals) AS OwnGoalsCount,
    SUM(YellowCards) AS YellowCardsCount,
    SUM(RedCards) AS RedCardsCount
FROM CTE_Age_Group
GROUP BY AgeGroup
ORDER BY AgeGroup;
```

---

# 🧠 Key SQL Techniques Demonstrated

This project demonstrates a wide range of SQL Server techniques.

### Data Cleaning

* `UPDATE`
* `DELETE`
* `ALTER TABLE`
* `DROP COLUMN`
* `LTRIM()`
* `RTRIM()`
* `REPLACE()`
* `LIKE`

### Data Types

* `INT`
* `FLOAT`
* `NVARCHAR`

### Aggregation

* `SUM()`
* `AVG()`
* `COUNT()`
* `COUNT(DISTINCT)`

### Window Functions

* `ROW_NUMBER()`
* `DENSE_RANK()`
* `SUM() OVER()`

### Query Organization

* CTEs
* Views
* Subqueries

### Conditional Logic

* `CASE`
* `NULLIF()`

### Joins

* `INNER JOIN`
* `LEFT JOIN`
* `RIGHT JOIN`

### Analytical Techniques

* Ranking
* Part-to-whole analysis
* Segmentation
* Contribution analysis
* KPI calculation
* Aggregation across dimensions
* Tie-breaking logic

---

# 📌 Business Questions Answered

The project is designed to answer questions such as:

### Competition

* Which competitions contain the most players?
* Which competitions have the largest number of clubs?
* How many goals are produced by each competition?
* What percentage of total goals comes from each competition?
* What is the estimated number of matches in each competition?
* What is the average number of goals per match?

### Players

* Who are the top goal scorers?
* Who provides the most assists?
* Who has the highest total goal contributions?
* Which players contribute the most to their clubs?

### Clubs

* Which clubs have the highest total goals?
* Which clubs have the largest player pools?
* Which clubs have the highest average goal contribution per player?

### Countries

* Which nationalities have the most players?
* Which countries are represented across the most clubs and competitions?
* Which nationalities produce the highest total goals?

### Positions

* Which positions contribute the most goals?
* Which positions contribute the most assists?
* What percentage of total goals comes from each position?

### Age

* Which age groups contain the most players?
* Which age groups produce the most goals?
* How does average performance vary by age group?
* How do goal contributions differ between younger and older players?

---

# 💡 Analytical Insights Framework

The project is structured to move from **numbers → analysis → business/football meaning**.

For example:

```text
Metric
  ↓
Comparison
  ↓
Identify Pattern
  ↓
Investigate Possible Reason
  ↓
Football Insight
  ↓
"So What?"
```

Examples of questions that can be investigated from the outputs:

* Does a larger player population translate into greater goal production?
* Are younger players contributing significantly to attacking output?
* Which positions dominate goal contribution?
* Are high-scoring clubs dependent on a small number of players?
* Which competitions have higher goal productivity per match?
* Which players have unusually high contribution relative to their playing time?

---

# 🧱 Data Modeling Approach

The project follows a simplified **star-schema approach**.

### Dimensions

```text
dim_players
dim_clubs
dim_competitions
```

### Fact

```text
fact_stats
```

### Relationships

```text
dim_players
     │
     │ PlayerID
     ▼
fact_stats
     ▲
     │ ClubID
     │
dim_clubs

fact_stats
     ▲
     │ CompID
     │
dim_competitions
```

This structure separates:

* **Descriptive attributes** → Dimensions
* **Numerical measurements** → Fact table

This makes analytical queries easier to write and maintain.

---

# 🔍 Data Quality Decisions

Several important data-quality decisions were made:

### 1. Staging Layer

The original dataset was preserved while cleaning was performed on:

```text
player_data_staging
```

### 2. Missing Values

Empty statistical values were converted to zero where appropriate.

### 3. Duplicate Detection

Potential duplicate records were identified using `ROW_NUMBER()`.

### 4. Standardized Countries

A dedicated mapping table was created instead of repeatedly hard-coding country transformations.

### 5. Standardized Positions

Multiple position combinations were grouped into:

```text
MF
DF
FW
```

### 6. Player Identity

A `PlayerID` was generated so the same player can be analyzed across different club records.

---

# 📈 Skills Demonstrated

This project demonstrates practical skills in:

* SQL Server
* Data Cleaning
* Data Transformation
* Data Quality
* Data Standardization
* Relational Data Modeling
* Star Schema Concepts
* Fact and Dimension Design
* SQL Views
* CTEs
* Window Functions
* Ranking
* Aggregation
* Analytical SQL
* Football Performance Analysis
* Business Question Formulation
* Data Storytelling

---

# 🚀 Future Improvements

Possible future extensions include:

* Player performance indexes
* Goals per 90 minutes
* Assists per 90 minutes
* Goal contribution per 90 minutes
* Club attacking efficiency
* Competition comparison
* Player efficiency rankings
* Young-player performance analysis
* Position-specific player rankings
* Offensive vs defensive player profiles
* Advanced player segmentation
* Trend analysis
* Power BI dashboard
* Automated ETL pipeline
* Additional football seasons for historical comparison

---

# 🏁 Conclusion

This project demonstrates a complete SQL-based football analytics workflow starting from raw player statistics and progressing through:

```text
Raw Data
   ↓
Data Cleaning
   ↓
Data Standardization
   ↓
Player Identification
   ↓
Dimensional Modeling
   ↓
Exploration
   ↓
Magnitude Analysis
   ↓
Ranking Analysis
   ↓
Part-to-Whole Analysis
   ↓
Segmentation
   ↓
Football Insights
```

The project showcases how SQL can be used not only for querying data, but also for building a structured analytical workflow capable of supporting **player performance analysis, club analysis, competition analysis, and football-related decision making**.

---

## 👤 Author

**Osama**

Data Scientist & Data Analyst
Faculty of Computers and Artificial Intelligence — Helwan University

### Focus Areas

* Data Analysis
* SQL
* Python
* Excel
* Power BI
* Machine Learning
* Sports Analytics
