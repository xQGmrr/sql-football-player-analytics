# ⚽ SQL Football Player Analytics

## 📌 Project Overview

This project focuses on transforming raw football player statistics into a **clean, structured, analytics-ready SQL database**.

The project uses SQL Server to perform the complete data preparation process, including:

- Creating a staging table from the raw dataset
- Identifying potential duplicate player records
- Handling empty values
- Removing irrelevant records and columns
- Converting columns to appropriate data types
- Cleaning corrupted player names caused by encoding issues
- Standardizing competition and club names
- Creating unique player identifiers
- Designing a dimensional model using **Dimension and Fact Views**

The final structure is designed to support the next phase of the project: **Football Data Analysis**.

---

# 🎯 Project Objectives

The main objectives of this phase are to:

1. Prepare raw football statistics for analysis.
2. Improve data quality and consistency.
3. Remove irrelevant goalkeeper-specific statistics and records.
4. Standardize player, club, and competition information.
5. Create a unique `PlayerID` for each player.
6. Transform the cleaned dataset into a dimensional model.
7. Build reusable SQL views for analytical queries.

---

# 🗂️ Dataset

The project uses football player statistics for the **2025/2026 season**.

The raw dataset contains information such as:

- Player
- Nation
- Position
- Squad
- Competition
- Age
- Birth Year
- Matches Played
- Starts
- Minutes
- Goals
- Assists
- Shots
- Shots on Target
- Tackles
- Interceptions
- Cards
- Fouls
- And other performance statistics

---

# 🏗️ Project Structure

```text
SQL-Football-Analytics/
│
├── 1-Data Cleaning.sql
│
├── 2-Creating Dims and Fact Views.sql
│
└── README.md
```

> The project will be expanded with additional analysis scripts as the analysis phase is completed.

---

# 🛠️ Tools & Technologies

- **SQL Server**
- **T-SQL**
- Window Functions
- CTEs
- Views
- Data Cleaning
- Dimensional Modeling
- Data Transformation

---

# 🔄 Phase 1 — Data Preparation

## 1. Data Cleaning

### Creating the Staging Table

The raw football dataset is copied into a dedicated staging table so that the original dataset remains unchanged.

```sql
SELECT *
INTO player_data_staging
FROM [players_data_light-2025_2026];
```

The `player_data_staging` table becomes the main table used throughout the cleaning process.

---

## 2. Checking for Duplicates

Potential duplicate records are identified using `ROW_NUMBER()`.

```sql
SELECT *,
    ROW_NUMBER() OVER(
        PARTITION BY Player,
                     Nation,
                     Pos,
                     Squad,
                     Comp,
                     Age,
                     Born
        ORDER BY Rk
    ) AS Checking_Duplicates
FROM player_data_staging
ORDER BY Rk;
```

### Why?

A player can appear multiple times because of differences in competitions, clubs, or records. Before building the analytical model, duplicate patterns need to be identified.

### SQL Techniques

- `ROW_NUMBER()`
- `PARTITION BY`
- `ORDER BY`

---

# 3. Handling Empty Values

Some numerical columns contained empty strings instead of valid numerical values.

These values were replaced with `0.0`.

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

This preparation is important because these columns are later converted from text-based fields into numerical data types.

---

# 4. Removing Unwanted Rows

Goalkeepers were removed from the dataset because the project focuses on outfield-player performance.

```sql
DELETE FROM player_data_staging
WHERE Pos = 'GK';
```

This prevents goalkeeper-specific statistics from affecting the analysis of outfield players.

---

# 5. Removing Unwanted Columns

Goalkeeper-specific and unnecessary columns were removed.

```sql
ALTER TABLE player_data_staging 
DROP COLUMN 
    GA,
    GA90,
    SoTA,
    Saves,
    [Save%],
    W,
    D,
    L,
    CS,
    [CS%],
    PKatt_stats_keeper,
    PKA,
    PKsv,
    PKm,
    PK_stats_shooting,
    PKatt_stats_shooting,
    CrdY_stats_misc,
    CrdR_stats_misc;
```

### Why?

Removing irrelevant columns:

- Simplifies the dataset
- Reduces unnecessary data
- Makes the analytical model easier to understand
- Keeps the fact table focused on relevant outfield-player statistics

---

# 6. Changing Data Types

The raw dataset initially contained many columns as text-based values.

The columns were converted to appropriate numerical data types.

For example:

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

ALTER TABLE player_data_staging
ALTER COLUMN Gls INT;

ALTER TABLE player_data_staging
ALTER COLUMN Ast INT;
```

Other performance columns were also converted to suitable numerical types, including:

- `G+A`
- `G-PK`
- `PK`
- `PKatt`
- `CrdY`
- `CrdR`
- `G+A-PK`
- `SH`
- `SoT`
- `SoT%`
- `Sh 90`
- `SoT 90`
- `G Sh`
- `G SoT`
- `Crs`
- `TklW`
- `Int`
- `Fld`
- `2CrdY`
- `Fls`
- `OG`

### Main SQL Technique

`ALTER COLUMN` was used to ensure numerical calculations can be performed correctly during the analysis phase.

---

# 7. Standardizing Player Names

The source data contained several character-encoding problems.

For example, names could appear with corrupted characters such as:

```text
Ã©
Ã±
Å¾
Ä‡
```

These values were corrected using `REPLACE()`.

```sql
UPDATE player_data_staging
SET Player = REPLACE(Player, 'Ã©', 'é')
WHERE Player LIKE '%Ã©%';
```

Additional replacements were performed for other corrupted characters.

```sql
UPDATE player_data_staging
SET Player = REPLACE(Player, 'AntaÃ±Ã³n', 'Antañón')
WHERE Player LIKE '%AntaÃ±Ã³n%';
```

Other encoding corrections were applied to characters such as:

- `ž`
- `ć`
- `á`
- `í`
- `ó`
- `ú`
- `ñ`
- `é`
- `è`
- `ë`

---

# 8. Finding Remaining Encoding Problems

After the cleaning process, suspicious player names were searched for.

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

This provides a validation step to identify records that may still require manual investigation.

---

# 9. Standardizing Competition Names

Competition names were standardized by removing country prefixes.

For example:

```text
eng Premier League → Premier League
es La Liga → La Liga
fr Ligue 1 → Ligue 1
it Serie A → Serie A
de Bundesliga → Bundesliga
```

Example:

```sql
UPDATE player_data_staging
SET Comp = REPLACE(Comp, 'eng Premier League', 'Premier League')
WHERE Comp = 'eng Premier League';
```

The same approach was applied to the other competitions.

### Benefit

Standardized competition names make grouping and filtering much easier during analysis.

---

# 10. Standardizing Club Names

Club names affected by encoding problems were also corrected.

```sql
UPDATE player_data_staging
SET Squad = REPLACE(Squad, 'KÃ¶ln', 'Köln')
WHERE Squad = 'KÃ¶ln';

UPDATE player_data_staging
SET Squad = REPLACE(Squad, 'AlavÃ©s', 'Alavés')
WHERE Squad = 'AlavÃ©s';

UPDATE player_data_staging
SET Squad = REPLACE(Squad, 'AtlÃ©tico Madrid', 'Atlético Madrid')
WHERE Squad = 'AtlÃ©tico Madrid';
```

This ensures that clubs are represented consistently.

---

# 11. Creating PlayerID

A unique player identifier was created to make relationships between player information and performance statistics easier.

First, the column was added:

```sql
ALTER TABLE player_data_staging
ADD PlayerID INT;
```

Then `DENSE_RANK()` was used to generate an ID based on the standardized player name.

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

### Why `DENSE_RANK()`?

The same player name receives the same `PlayerID` across multiple records.

For example:

```text
Player             PlayerID
---------------------------
Player A              1
Player A              1
Player B              2
Player C              3
Player C              3
```

This allows multiple performance records belonging to the same player to be aggregated correctly.

---

# 🏛️ Phase 2 — Dimensional Modeling

After cleaning the staging table, the data was separated into **dimension views** and a **fact view**.

The resulting structure follows a simplified **Star Schema**.

```text
                    dim_players
                         │
                         │
                         ▼
dim_clubs ────────── fact_stats ────────── dim_competitions
```

The model consists of:

- `dim_players`
- `dim_clubs`
- `dim_competitions`
- `fact_stats`

---

# 👤 dim_players

The player dimension contains descriptive information about each player.

```sql
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
```

### Purpose

`dim_players` provides one descriptive record per `PlayerID`.

It contains:

| Column | Description |
|---|---|
| `PlayerID` | Unique player identifier |
| `PlayerName` | Player name |
| `Nationality` | Player nationality |
| `Position` | Playing position |
| `Age` | Player age |
| `BirthYear` | Year of birth |

### SQL Techniques

- CTE
- `ROW_NUMBER()`
- `PARTITION BY`
- `RIGHT()`
- View creation

---

# 🏟️ dim_clubs

A separate club dimension was created.

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

Each unique club receives a `ClubID`.

Example structure:

| ClubID | Club |
|---:|---|
| 1 | Club A |
| 2 | Club B |
| 3 | Club C |

This allows club information to be stored separately from player performance metrics.

---

# 🏆 dim_competitions

A competition dimension was created in the same way.

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

Each unique competition receives a `CompID`.

This provides a clean lookup table for competition information.

---

# 📊 fact_stats

The `fact_stats` view contains the numerical football performance metrics.

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

# 📐 Fact Table Metrics

The fact view contains measurable performance metrics including:

### Playing Time
- Matches Played
- Matches Started
- Minutes Played
- 90s Played

### Attacking
- Goals
- Assists
- Goal Contributions
- Non-Penalty Goals
- Penalty Goals
- Penalty Attempts
- Shots
- Shots on Target

### Efficiency
- Shots on Target %
- Shots per 90
- Shots on Target per 90
- Goals per Shot
- Goals per Shot on Target

### Defensive / Discipline
- Tackles Won
- Interceptions
- Fouls Drawn
- Fouls Committed
- Yellow Cards
- Red Cards
- Second Yellow Cards
- Own Goals

---

# 🔑 Key SQL Techniques Used

| Technique | Purpose |
|---|---|
| `SELECT INTO` | Create staging table |
| `UPDATE` | Clean and standardize values |
| `DELETE` | Remove unwanted records |
| `ALTER TABLE` | Modify table structure |
| `ALTER COLUMN` | Convert data types |
| `DROP COLUMN` | Remove unnecessary fields |
| `REPLACE()` | Correct corrupted text |
| `LIKE` | Detect suspicious values |
| `DISTINCT` | Identify unique clubs/competitions |
| `ROW_NUMBER()` | Detect duplicates and select one player record |
| `DENSE_RANK()` | Generate consistent player IDs |
| `CTE` | Organize transformation logic |
| `CREATE OR ALTER VIEW` | Build reusable analytical views |
| `JOIN` | Connect fact data to dimensions |

---

# 🧠 Data Modeling Approach

The project separates **descriptive attributes** from **measurable performance metrics**.

### Dimensions

```text
dim_players
    ├── PlayerID
    ├── PlayerName
    ├── Nationality
    ├── Position
    ├── Age
    └── BirthYear

dim_clubs
    ├── ClubID
    └── Club

dim_competitions
    ├── CompID
    └── Competition
```

### Fact

```text
fact_stats
    ├── PlayerID
    ├── ClubID
    ├── CompID
    ├── MatchesPlayed
    ├── MinutesPlayed
    ├── Goals
    ├── Assists
    ├── Shots
    ├── TacklesWon
    └── ...
```

This structure makes the database easier to query for analytical questions such as:

- Which players scored the most goals?
- Which clubs have the highest goal contributions?
- How does player performance differ by competition?
- Which positions generate the most goals?
- Which players have the highest shooting efficiency?

These questions will be addressed in the **Analysis Phase**.

---

# 💼 Business Value

Although this is a technical SQL project, the data model is designed around real football analytics use cases.

The resulting structure can support:

- Player performance analysis
- Club performance comparison
- Competition comparison
- Scouting analysis
- Player ranking
- Attacking efficiency analysis
- Defensive performance analysis
- Recruitment decisions
- Football performance dashboards

---

# 📈 Analysis Phase

**Status: Upcoming**

The next phase will use the dimensional model to perform analytical queries and answer football-related business questions.

Planned areas include:

- Player rankings
- Goal and assist analysis
- Club comparisons
- Competition comparisons
- Position analysis
- Player efficiency
- Performance per 90 minutes
- Advanced SQL analysis
- Business insights and recommendations

The README will be expanded with the analysis SQL, findings, and **"So What?" business interpretation** as this phase is completed.

---

# 🎓 Skills Demonstrated

This phase demonstrates practical experience in:

- SQL Server
- T-SQL
- Data Cleaning
- Data Quality Validation
- Data Transformation
- Data Standardization
- Data Modeling
- Star Schema Design
- Dimension and Fact Modeling
- Window Functions
- CTEs
- SQL Views
- Data Type Management
- Analytical Data Preparation

---

# 🚀 Conclusion

Phase 1 transformed the raw football player dataset into a structured, analytics-ready SQL model.

The workflow progressed from:

```text
Raw Dataset
     ↓
Staging Table
     ↓
Data Cleaning
     ↓
Data Standardization
     ↓
PlayerID Creation
     ↓
Dimension Views
     ↓
Fact View
     ↓
Analytics-Ready Data Model
```

The resulting model provides a strong foundation for the upcoming **Football Data Analysis Phase**, where SQL will be used to extract performance insights and answer practical football analytics questions.
