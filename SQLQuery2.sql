-- Find the total spending on players for each team:

SELECT 
	Team, SUM(Price_in_cr) AS Total_Spending
FROM 
	IPLPlayers
GROUP BY Team
ORDER BY Total_Spending DESC


-- Find the top 3 highest-paid "All-rounders" across all teams:

SELECT 
	TOP 3 Player, Team, Price_in_cr
FROM 
	IPLPlayers
WHERE Role = 'All-rounder'
ORDER BY Price_in_cr DESC


-- Find the highest-priced player in each team:

WITH CTE_MaxPrice AS (
	SELECT Team, MAX(Price_in_cr) AS Highest_Priced
	FROM IPLPlayers
	GROUP BY Team
)
SELECT p.Player, p.Team, Highest_Priced
FROM IPLPlayers p
JOIN CTE_MaxPrice m ON p.Team = m.Team 
WHERE p.Price_in_cr = m.Highest_Priced


--  Rank players by their price within each team and list the top 2 for every team:

WITH CTE_Ranked AS (
	SELECT Player, Team, Price_in_cr,
		ROW_NUMBER() OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS Price_Rank
	FROM IPLPlayers
)
SELECT Player, Team, Price_in_cr, Price_Rank
FROM CTE_Ranked
WHERE Price_Rank <= 2

-- Find the most expensive player from each team, along with the second most expensive player's name and price:

WITH CTE_Ranked AS (
	SELECT Player, Team, Price_in_cr,
		ROW_NUMBER() OVER (PARTITION BY Team ORDER BY Price_in_cr DESC) AS Price_Rank
	FROM IPLPlayers
)
SELECT 
	Team,
	MAX(CASE WHEN Price_Rank = 1 THEN Player END) AS Most_Expensive_Player,
	MAX(CASE WHEN Price_Rank = 1 THEN Price_in_cr END) AS Most_Expensive_Price,
	MAX(CASE WHEN Price_Rank = 2 THEN Player END) AS Second_Most_Expensive_Player,
	MAX(CASE WHEN Price_Rank = 2 THEN Price_in_cr END) AS Second_Most_Expensive_Price
	FROM CTE_Ranked
	GROUP BY Team

-- Calculate the percentage contribution of each player's price to their team's total spending:

SELECT 
	Player, 
	Team, 
	Price_in_cr, 
	CAST(Price_in_cr * 100.0 / (SUM(Price_in_cr) OVER (PARTITION BY Team)) AS DECIMAL(10,2)) AS Percentage_Contribution
	FROM
	IPLPlayers


-- Classify players as 'High', 'Medium', or 'Low' priced based on the following rules:
-- High: Price > 15 cr
-- Medium: Price between 5 cr and 15 cr
-- Low: Price < 5 cr
-- and find out the number of players in each bracket for each team:

WITH CTE_PriceBracket AS (
	SELECT 
		Team, Player, Price_in_cr,
		CASE 
			WHEN Price_in_cr > 15 THEN 'High'
			WHEN Price_in_cr BETWEEN 5 AND 15 THEN 'Medium' 
			ELSE 'Low'
		END AS Price_Bracket
	FROM IPLPlayers
)
SELECT 
	Team, Price_Bracket, COUNT(*) AS Player_Count
	FROM CTE_PriceBracket
	GROUP BY Team, Price_Bracket
	ORDER BY Team, Price_Bracket







SELECT * FROM IPLPlayers