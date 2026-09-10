----- Create Staging Table to perform Data Cleansing on it -----
SELECT *
into player_data_staging
FROM [players_data_light-2025_2026]

----- Checking For Duplicates -----
SELECT *,
ROW_NUMBER() OVER(PARTITION BY Player,Nation,Pos,Squad,Comp,Age,Born ORDER BY Rk) AS Checking_Duplicates
FROM player_data_staging
ORDER BY Rk

----- Handell Nulls and Empty Values -----
UPDATE player_data_staging
SET [SoT%] = '0.0'
WHERE [SoT%] = ''

UPDATE player_data_staging
SET [G Sh] = '0.0'
WHERE [G Sh] = ''

UPDATE player_data_staging
SET [G SoT] = '0.0'
WHERE [G SoT] = ''

----- Remove Unwanted Coulmns and Rows -----
DELETE FROM player_data_staging WHERE Pos = 'GK' 

ALTER TABLE player_data_staging 
DROP COLUMN GA,GA90,SoTA,Saves,[Save%],W,D,L,CS,[CS%],
PKatt_stats_keeper,PKA,PKsv,PKm,PK_stats_shooting,PKatt_stats_shooting,CrdY_stats_misc,CrdR_stats_misc

----- Change Columns Data Type -----
ALTER TABLE player_data_staging
ALTER COLUMN Rk INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN Age INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN Born INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN MP INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN Starts INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN [Min] INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN [90s] FLOAT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN Gls INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN Ast INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN [G+A] INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN [G-PK] INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN PK INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN PKatt INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN CrdY INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN CrdR INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN [G+A-PK] FLOAT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN SH INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN SoT INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN [SoT%] FLOAT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN [Sh 90] FLOAT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN [SoT 90] FLOAT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN [G Sh] FLOAT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN [G SoT] FLOAT;


GO

ALTER TABLE player_data_staging
ALTER COLUMN Crs INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN TklW INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN [Int] INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN Fld INT;


GO

ALTER TABLE player_data_staging
ALTER COLUMN [2CrdY] INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN Fls INT;

GO

ALTER TABLE player_data_staging
ALTER COLUMN OG INT;


----- Standrize Data -----

---- 1- Updating Players Name ----
UPDATE player_data_staging
SET Player = REPLACE(Player, 'Ã©', 'é')
WHERE Player LIKE '%Ã©%';

UPDATE player_data_staging
SET Player = REPLACE(Player, 'AntaÃ±Ã³n', 'Antañón')
WHERE Player LIKE '%AntaÃ±Ã³n%';

UPDATE player_data_staging
SET Player = REPLACE(Player, 'Ã', 'í')
WHERE Player LIKE '%Ã%';

UPDATE player_data_staging
SET Player = REPLACE(Player, 'Aí¯', 'Aï')
WHERE Player LIKE '%Aí¯%';

UPDATE player_data_staging
SET Player = REPLACE(Player, 'Å¾', 'ž')
WHERE Player LIKE '%Å¾%';

UPDATE player_data_staging
SET Player = REPLACE(Player, 'Ä‡', 'ć')
WHERE Player LIKE '%Ä‡%';

UPDATE player_data_staging
SET Player = REPLACE(Player, 'í¡', 'á')
WHERE Player LIKE '%í¡%';

UPDATE player_data_staging
SET Player = REPLACE(Player, 'í­', 'í')
WHERE Player LIKE '%í­%';

UPDATE player_data_staging
SET Player = REPLACE(Player, 'í³', 'ó')
WHERE Player LIKE '%í³%';

UPDATE player_data_staging
SET Player = REPLACE(Player, 'íº', 'ú')
WHERE Player LIKE '%íº%';

UPDATE player_data_staging
SET Player = REPLACE(Player, 'í±', 'ñ')
WHERE Player LIKE '%í±%';

UPDATE player_data_staging
SET Player = REPLACE(Player, 'í²', 'ò')
WHERE Player LIKE '%í²%';

UPDATE player_data_staging
SET Player = REPLACE(Player, 'í©', 'é')
WHERE Player LIKE '%í©%';

UPDATE player_data_staging
SET Player = REPLACE(Player, 'í¨', 'è')
WHERE Player LIKE '%í¨%';

UPDATE player_data_staging
SET Player = REPLACE(Player, 'í«', 'ë')
WHERE Player LIKE '%í«%';

UPDATE player_data_staging
SET Player = REPLACE(Player, 'í­', 'í')
WHERE Player LIKE '%í­%';
 
SELECT DISTINCT Player -- Find remaining suspicious names
FROM player_data_staging
WHERE Player LIKE '%Ã%'
   OR Player LIKE '%Â%'
   OR Player LIKE '%Ä%'
   OR Player LIKE '%Å%'
   OR Player LIKE '%í%'
   OR Player LIKE '%�%'
   OR Player LIKE '%?%';

---- 2- Updating Compitions Name ----
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

---- 3- Updating Squads Name ----
UPDATE player_data_staging
SET Squad = REPLACE(Squad, 'KÃ¶ln', 'Köln')
WHERE Squad = 'KÃ¶ln';

UPDATE player_data_staging
SET Squad = REPLACE(Squad, 'AlavÃ©s', 'Alavés')
WHERE Squad = 'AlavÃ©s';

UPDATE player_data_staging
SET Squad = REPLACE(Squad, 'AtlÃ©tico Madrid', 'Atlético Madrid')
WHERE Squad = 'AtlÃ©tico Madrid';



----- Creating PlayerID Coulmn -----
ALTER TABLE player_data_staging
ADD PlayerID INT;

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


