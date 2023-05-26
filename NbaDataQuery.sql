SELECT * 
FROM NbaStats

-- Pulling the start year from year

SELECT SUBSTRING(Year,1,4) AS season_start_year
FROM NbaStats

-- Now set year to that value
UPDATE NbaStats
SET Year = SUBSTRING(Year,1,4) 

-- Clean up season type
SELECT SUBSTRING(Season_type,1,CHARINDEX('%20', Season_type)-1)
FROM NbaStats
WHERE Season_type = 'Regular%20Season'


UPDATE NbaStats 
SET Season_type = SUBSTRING(Season_type,1,CHARINDEX('%20', Season_type)-1)
WHERE Season_type = 'Regular%20Season'

-- Drop the rank column
ALTER TABLE NbaStats
DROP COLUMN RANK

-- Search top 10 in total points scored in a regular season in the past 20 years
SELECT TOP 10 PLAYER, Year, PTS, GP
FROM NbaStats
WHERE Season_type = 'Regular'
ORDER BY PTS DESC

-- We can also do this for ppg
SELECT TOP 10 PLAYER, Year, PTS, GP, ROUND((PTS/GP),1) as PPG
FROM NbaStats
-- we might want some clarifying factors
WHERE GP >= 65 AND Season_type = 'Regular'  -- the new nba minimum games for awards
ORDER BY PPG DESC


-- The most total points scored in the past 20 by a player in the playoffs
SELECT TOP 10 PLAYER, SUM(GP) as total_playoffs_gp, SUM(PTS) as total_playoff_pts
FROM NbaStats
WHERE Season_type = 'Playoffs'
GROUP BY PLAYER
ORDER BY total_playoff_pts DESC

-- Highest 3pt percentage with a certain amount of games
SELECT TOP 10 PLAYER, Year, GP, FG3_PCT
FROM NbaStats
WHERE GP >= 65 AND Season_type = 'Regular' AND FG3A >= 150
ORDER BY FG3_PCT DESC

SELECT TOP 10 PLAYER, SUM(GP) as total_gp
,SUM(FG3M) AS total_fg3m,SUM(FG3A) AS total_fg3a,ROUND(SUM(FG3M)/SUM(FG3A),3) as avg_3ptpct
FROM NbaStats
WHERE Season_type = 'Regular' AND FG3A >= 500
GROUP BY PLAYER
ORDER BY avg_3ptpct DESC

-- players with highest percentage of points coming from free throws
SELECT TOP 10 PLAYER, SUM(GP) AS total_gp,SUM(FTM) AS total_ftm
,SUM(PTS) AS total_pts, ROUND(SUM(FTM)/SUM(PTS),3) AS ft_ptpct
FROM NbaStats
WHERE Season_type = 'Regular' 
GROUP BY PLAYER
HAVING SUM(PTS) > 2000
ORDER BY ft_ptpct DESC


-- lets find league leaders in ppg increases from regular season 
SELECT TOP 10 Regular.PLAYER,Regular.total_pts_per_gp,Playoffs.total_pts_per_gp
,ROUND((Playoffs.total_pts_per_gp - Regular.total_pts_per_gp), 1) AS pts_per_gp_change
FROM (
    SELECT PLAYER, ROUND(SUM(PTS) / SUM(GP),1) AS total_pts_per_gp
    FROM NbaStats
    WHERE Season_type = 'Regular'
    GROUP BY PLAYER
	HAVING ROUND(SUM(PTS) / SUM(GP),1) > 15
) AS Regular
JOIN (
    SELECT PLAYER, ROUND(SUM(PTS) / SUM(GP),1) AS total_pts_per_gp
    FROM NbaStats
    WHERE Season_type = 'Playoffs'
    GROUP BY PLAYER
	HAVING ROUND(SUM(PTS) / SUM(GP),1) > 15
) AS Playoffs
ON Regular.PLAYER = Playoffs.PLAYER
ORDER BY pts_per_gp_change DESC


-- Team with the most 3pointers made
SELECT TOP 10 TEAM, SUM(FG3M) as total_3ptm , SUM(FG3A) as total_3pta 
,ROUND(SUM(FG3M)/SUM(FG3A),3) AS total_3ptpct
FROM NbaStats
WHERE Season_type = 'Regular'
GROUP BY TEAM
ORDER BY total_3ptm DESC

-- Team with the least amount of fouls
SELECT TOP 10 TEAM, SUM(FTA) as total_fta
FROM NbaStats
WHERE Season_type = 'Regular'
GROUP BY TEAM
ORDER BY total_fta DESC


