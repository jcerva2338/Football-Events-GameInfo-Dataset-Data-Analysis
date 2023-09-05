--event_type
--0	Announcement
--1	Attempt
--2	Corner
--3	Foul
--4	Yellow card
--5	Second yellow card
--6	Red card
--7	Substitution
--8	Free kick won
--9	Offside
--10	Hand ball
--11	Penalty conceded

--event_type2
--12	Key Pass
--13	Failed through ball
--14	Sending off
--15	Own goal

--side
--1	Home
--2	Away

--shot_place
--1	Bit too high
--2	Blocked
--3	Bottom left corner
--4	Bottom right corner
--5	Centre of the goal
--6	High and wide
--7	Hits the bar
--8	Misses to the left
--9	Misses to the right
--10	Too high
--11	Top centre of the goal
--12	Top left corner
--13	Top right corner

--shot_outcome
--1	On target
--2	Off target
--3	Blocked
--4	Hit the bar

--location
--1	Attacking half
--2	Defensive half
--3	Centre of the box
--4	Left wing
--5	Right wing
--6	Difficult angle and long range
--7	Difficult angle on the left
--8	Difficult angle on the right
--9	Left side of the box
--10	Left side of the six yard box
--11	Right side of the box
--12	Right side of the six yard box
--13	Very close range
--14	Penalty spot
--15	Outside the box
--16	Long range
--17	More than 35 yards
--18	More than 40 yards
--19	Not recorded

--bodypart
--1	right foot
--2	left foot
--3	head

--assist_method
--0	None
--1	Pass
--2	Cross
--3	Headed pass
--4	Through ball

--situation
--1	Open play
--2	Set piece
--3	Corner
--4	Free kick

-- Name: John Cervantes

-- Get the first 20 data entries in the events table
SELECT TOP 20 * FROM events$;

-- Get the total amount of events available
SELECT COUNT(*) FROM events$;

-- Get the frequency of each event team occurring in the dataset ordered in descending order
SELECT event_team, COUNT(event_team) AS frequency FROM events$ GROUP BY event_team ORDER BY frequency DESC;

-- Get the frequencies of each assist_method sorted by most frequent in descending order
SELECT CASE 
			WHEN assist_method = 0 THEN 'None'
			WHEN assist_method = 1 THEN 'Pass'
			WHEN assist_method = 2 THEN 'Cross'
			WHEN assist_method = 3 THEN 'Headed pass'
			WHEN assist_method = 4 THEN 'Through ball'
		END AS "assist_method",
		COUNT(*) AS frequency 
	FROM events$ WHERE shot_outcome <> 'NA' AND shot_outcome = 1 GROUP BY assist_method ORDER BY frequency DESC;

-- Grouping by each team, count the frequency of each assist_method for when a goal was scored to visualize
-- which assist type was most common and potentially most effective for each team
SELECT event_team, CASE 
			WHEN assist_method = 0 THEN 'None'
			WHEN assist_method = 1 THEN 'Pass'
			WHEN assist_method = 2 THEN 'Cross'
			WHEN assist_method = 3 THEN 'Headed pass'
			WHEN assist_method = 4 THEN 'Through ball'
		END AS "assist_method",
		COUNT(*) AS frequency 
	FROM events$ WHERE shot_outcome <> 'NA' AND shot_outcome = 1 GROUP BY event_team, assist_method ORDER BY event_team ASC, frequency DESC;

-- In any shot attempt, find the frequency of each location of shot to find trends on
-- what shot attempts are attempted by each team or as a whole
SELECT event_team, CASE 
			WHEN "location" = 1 THEN 'Attacking half'
			WHEN "location" = 2 THEN 'Defensive half'
			WHEN "location" = 3 THEN 'Centre of the box'
			WHEN "location" = 4 THEN 'Left wing'
			WHEN "location" = 5 THEN 'Right wing'
			WHEN "location" = 6 THEN 'Difficult angle and long range'
			WHEN "location" = 7 THEN 'Difficult angle on the left'
			WHEN "location" = 8 THEN 'Difficult angle on the right'
			WHEN "location" = 9 THEN 'Left side of the box'
			WHEN "location" = 10 THEN 'Left side of the six yard box'
			WHEN "location" = 11 THEN 'Right side of the box'
			WHEN "location" = 12 THEN 'Right side of the six yard box'
			WHEN "location" = 13 THEN 'Very close range'
			WHEN "location" = 14 THEN 'Penalty spot'
			WHEN "location" = 15 THEN 'Outside the box'
			WHEN "location" = 16 THEN 'Long range'
			WHEN "location" = 17 THEN 'More than 35 yards'
			WHEN "location" = 18 THEN 'More than 40 yards'
		END AS "location",
		COUNT(*) AS frequency  
	FROM events$ WHERE shot_outcome <> 'NA' AND "location" <> 19 GROUP BY event_team, "location" ORDER BY event_team ASC, frequency DESC;

-- View the frequency of events occuring per minute from 0-90
SELECT "time" AS "minute", COUNT(*) AS frequency FROM events$ GROUP BY "time" ORDER BY time ASC;

-- View the frequency of more substantial and meaningful events such as those that are not announcements (0) or substitutions (7)
-- as those events have little to no impact on a game
SELECT "time" AS "minute", COUNT(*) AS frequency FROM events$ WHERE event_type NOT IN (0, 7) GROUP BY "time" ORDER BY time ASC;

-- See what events occurred during the 0-th minute due to there being a noticeable amount of events at the time
SELECT event_type, COUNT(*) AS frequency FROM events$ WHERE "time" = 0 GROUP BY event_type ORDER BY frequency DESC;

-- Find the distribution of successful shots, meaning that a goal was scored as a result
SELECT shot_place, COUNT(*) AS goals FROM events$ WHERE shot_place <> 'NA' AND shot_outcome <> 'NA' AND shot_outcome = 1 GROUP BY shot_place ORDER BY goals;

-- Out off all potential locations for a shot on target, accumulate the total for each unique location and calculate the percentage of total for each location
-- to find the most common shot place for goals
--
-- Note: The "NULL" shot_place row comes from the future update to the dataset below where 'Top center' was added as a shot_place category given that
-- it was previously marking all 'high centre of goal' shot_place goals as 'NA'
SELECT *, SUM(goals) OVER () AS total_goals, (goals * 1.0 / SUM(goals) OVER ()) * 100 AS percentage_of_total FROM (
	SELECT CASE 
				WHEN shot_place = 3 THEN 'Bottom left'
				WHEN shot_place = 4 THEN 'Bottom right'
				WHEN shot_place = 5 THEN 'Center'
				WHEN shot_place = 13 THEN 'Top left'
				WHEN shot_place = 12 THEN 'Top right'
				END AS shot_place, COUNT(*) AS goals
			FROM events$ WHERE shot_place <> 'NA' AND is_goal = 1
				GROUP BY shot_place) t 
				ORDER BY goals DESC;

-- Double check the total goals by counting all events where is_goal is 1 (true)
SELECT COUNT(*) FROM events$ WHERE is_goal = 1;

-- View the distribution of shot_place frequencies to see if the total amount of goals tallied made sense given the
-- disagreement between the previous two statements of the total goals scored, the issue seems to be where
-- a goal was scored and the shot_place was NA
SELECT shot_place, COUNT(*) AS frequency FROM events$ WHERE is_goal = 1 GROUP BY shot_place;

-- Based on the text description of the events, it is evident that the cases where shot_place was NA and a goal
-- was marked as scored was either an own goal or scored in the high centre of the goal
SELECT "text" FROM events$ WHERE is_goal = 1 AND shot_place = 'NA';

-- View the  total events where a goal was scored and was an own goal
SELECT COUNT(*) AS 'Own goal' FROM events$ WHERE is_goal = 1 AND shot_place = 'NA' AND "text" LIKE '%Own Goal%';

-- View the total events where a goal was scored and the shot was in the high centre
SELECT COUNT(*) AS 'Top center' FROM events$ WHERE is_goal = 1 AND shot_place = 'NA' AND "text" LIKE '%high centre of the goal%';

-- The total between own goal and high centre goals is 1671, 5 off from the total of NA shot_place goals
-- lets find the remaining cases which seem to be a mix of shot_places that were not marked correctly
SELECT "text" FROM events$ WHERE NOT("text" LIKE '%Own Goal%' OR "text" LIKE '%high centre of the goal%') AND shot_place = 'NA' AND is_goal = 1;

-- Make sure that the rows that will be edited to insert the 'Top center' shot_place category are correct
SELECT * FROM events$ WHERE is_goal = 1 AND shot_place = 'NA' AND "text" LIKE '%high centre of the goal%';

-- Update the rows to have the correct shot_place of 'Top center' where a goal took place and the text described the goal as 'high centre of the goal'
UPDATE events$ SET shot_place = 11 WHERE is_goal = 1 AND shot_place = 'NA' AND "text" LIKE '%high centre of the goal%';
UPDATE events$ SET shot_place = 3 WHERE is_goal = 1 AND shot_place = 'NA' AND "text" LIKE '%bottom left corner%';
UPDATE events$ SET shot_place = 4 WHERE is_goal = 1 AND shot_place = 'NA' AND "text" LIKE '%bottom right corner%';
UPDATE events$ SET shot_place = 5 WHERE is_goal = 1 AND shot_place = 'NA' AND "text" LIKE '%centre of the goal%';
UPDATE events$ SET shot_place = 13 WHERE is_goal = 1 AND shot_place = 'NA' AND "text" LIKE '%top left corner%';

-- Now with the updated dataset adding the shot_place of 'Top center', the total amount of goals used is now more accurate not accounting
-- own goals which are difficult to categorize with a shot placement based on text. Now each show_place with have its corresponding number of goals and percentage of total
SELECT *, SUM(goals) OVER () AS total_goals, (goals * 1.0 / SUM(goals) OVER ()) * 100 AS percentage_of_total FROM (
	SELECT CASE 
				WHEN shot_place = 3 THEN 'Bottom left'
				WHEN shot_place = 4 THEN 'Bottom right'
				WHEN shot_place = 5 THEN 'Center'
				WHEN shot_place = 11 THEN 'Top center'
				WHEN shot_place = 13 THEN 'Top left'
				WHEN shot_place = 12 THEN 'Top right'
				END AS shot_place, COUNT(*) AS goals
			FROM events$ WHERE shot_place <> 'NA' AND is_goal = 1
				GROUP BY shot_place) t 
	ORDER BY goals DESC;

-- View the total amount of goals for each distinct shot_place
SELECT shot_place, COUNT(*) AS goals FROM events$ WHERE is_goal = 1 GROUP BY shot_place;

-- View the total amount of no_goals for each distinct shot_place contained in the previous query, only including the ones
-- that were on target
SELECT shot_place, COUNT(*) AS no_goal FROM events$ WHERE is_goal = 0 AND shot_place <> 'NA' AND shot_place IN (3,4,5,11,13,12) GROUP BY shot_place;

-- Using joins, join both previous queries based on shot_place to create a table showcasing each shot_place
-- and their goals and no_goals along with their shot conversion percentage
SELECT CASE 
			WHEN f1.shot_place = 3 THEN 'Bottom left'
			WHEN f1.shot_place = 4 THEN 'Bottom right'
			WHEN f1.shot_place = 5 THEN 'Center'
			WHEN f1.shot_place = 11 THEN 'Top center'
			WHEN f1.shot_place = 13 THEN 'Top left'
			WHEN f1.shot_place = 12 THEN 'Top right'
		END AS shot_place,
		f1.goals, f2.no_goals, (f1.goals * 1.0 / f2.no_goals * 1.0) * 100 AS 'shot_conversion_pct' FROM (
		SELECT shot_place, COUNT(*) AS goals FROM events$ WHERE is_goal = 1 GROUP BY shot_place
	) f1 INNER JOIN (
		SELECT shot_place, COUNT(*) AS no_goals FROM events$ WHERE is_goal = 0 AND shot_place <> 'NA' AND shot_place IN (3,4,5,11,13,12) GROUP BY shot_place
	) f2 ON f1.shot_place = f2.shot_place
ORDER BY shot_conversion_pct DESC;

-- For each team, count the assist events that occurred at each possible location on a football pitch
-- by grouping based on the event team and location
SELECT event_team AS team, 
	CASE
		WHEN "location" = 1 THEN 'Attacking half'
		WHEN "location" = 2 THEN 'Defensive half'
		WHEN "location" = 3 THEN 'Centre of the box'
		WHEN "location" = 4 THEN 'Left wing'
		WHEN "location" = 5 THEN 'Right wing'
		WHEN "location" = 6 THEN 'Difficult angle and long range'
		WHEN "location" = 7 THEN 'Difficult angle on the left'
		WHEN "location" = 8 THEN 'Difficult angle on the right'
		WHEN "location" = 9 THEN 'Left side of the box'
		WHEN "location" = 10 THEN 'Left side of the six yard box'
		WHEN "location" = 11 THEN 'Right side of the box'
		WHEN "location" = 12 THEN 'Right side of the six yard box'
		WHEN "location" = 13 THEN 'Very close range'
		WHEN "location" = 14 THEN 'Penalty spot'
		WHEN "location" = 15 THEN 'Outside the box'
		WHEN "location" = 16 THEN 'Long range'
		WHEN "location" = 17 THEN 'More than 35 yards'
		WHEN "location" = 18 THEN 'More than 40 yards'
	END AS 'location', COUNT(*) AS frequency FROM events$ WHERE (assist_method <> 0 OR "location" <> 19) AND "location" <> 'NA' GROUP BY event_team, "location" ORDER BY event_team ASC, frequency DESC;

-- For each team, count number of goals scored for each shot location possible assuming that the player scored
-- grouping based on event team and shot_place
SELECT event_team AS team, CASE 
				WHEN shot_place = 3 THEN 'Bottom left'
				WHEN shot_place = 4 THEN 'Bottom right'
				WHEN shot_place = 5 THEN 'Center'
				WHEN shot_place = 11 THEN 'Top center'
				WHEN shot_place = 13 THEN 'Top left'
				WHEN shot_place = 12 THEN 'Top right'
			END AS shot_place, COUNT(*) AS frequency FROM events$ WHERE is_goal = 1 AND shot_place <> 'NA' AND shot_place IN (3,4,5,11,13,12) GROUP BY event_team, shot_place ORDER BY event_team ASC, frequency DESC;

SELECT event_team AS team, "time", COUNT(*) AS frequency FROM events$ WHERE is_goal = 1 AND shot_place <> 'NA' AND shot_place IN (3,4,5,11,13,12) GROUP BY event_team, "time" ORDER BY event_team ASC, "time" ASC;

SELECT opponent AS team, "time", COUNT(*) AS frequency FROM events$ WHERE is_goal = 1 AND shot_place <> 'NA' AND shot_place IN (3,4,5,11,13,12) GROUP BY opponent, "time" ORDER BY opponent ASC, "time" ASC;

SELECT opponent AS team, 
	CASE
		WHEN "location" = 1 THEN 'Attacking half'
		WHEN "location" = 2 THEN 'Defensive half'
		WHEN "location" = 3 THEN 'Centre of the box'
		WHEN "location" = 4 THEN 'Left wing'
		WHEN "location" = 5 THEN 'Right wing'
		WHEN "location" = 6 THEN 'Difficult angle and long range'
		WHEN "location" = 7 THEN 'Difficult angle on the left'
		WHEN "location" = 8 THEN 'Difficult angle on the right'
		WHEN "location" = 9 THEN 'Left side of the box'
		WHEN "location" = 10 THEN 'Left side of the six yard box'
		WHEN "location" = 11 THEN 'Right side of the box'
		WHEN "location" = 12 THEN 'Right side of the six yard box'
		WHEN "location" = 13 THEN 'Very close range'
		WHEN "location" = 14 THEN 'Penalty spot'
		WHEN "location" = 15 THEN 'Outside the box'
		WHEN "location" = 16 THEN 'Long range'
		WHEN "location" = 17 THEN 'More than 35 yards'
		WHEN "location" = 18 THEN 'More than 40 yards'
	END AS 'location', COUNT(*) AS frequency FROM events$ WHERE (assist_method <> 0 OR "location" <> 19) AND "location" <> 'NA' GROUP BY opponent, "location" ORDER BY opponent ASC, frequency DESC;