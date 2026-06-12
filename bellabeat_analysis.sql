-- ============================================================
--   BELLABEAT FITNESS DATA ANALYSIS
--   Case Study: How Can a Wellness Technology Company Play It Smart?
--   Tool: MySQL Workbench
-- ============================================================

USE bellabeat;

-- ============================================================
-- SECTION 1: DATA EXPLORATION
-- Get a high-level overview of the dataset
-- ============================================================

-- 1.1 Total users and overall averages
SELECT 
  COUNT(DISTINCT Id)                    AS total_users,
  ROUND(AVG(TotalSteps), 0)             AS avg_daily_steps,
  ROUND(AVG(Calories), 0)              AS avg_daily_calories,
  ROUND(AVG(SedentaryMinutes), 0)      AS avg_sedentary_minutes,
  ROUND(AVG(VeryActiveMinutes), 0)     AS avg_very_active_minutes,
  ROUND(AVG(LightlyActiveMinutes), 0)  AS avg_lightly_active_minutes,
  ROUND(AVG(FairlyActiveMinutes), 0)   AS avg_fairly_active_minutes
FROM dailyactivity_cleaned;

-- 1.2 Date range of the dataset
SELECT 
  MIN(ActivityDate) AS start_date,
  MAX(ActivityDate) AS end_date,
  DATEDIFF(MAX(ActivityDate), MIN(ActivityDate)) AS total_days
FROM dailyactivity_cleaned;

-- 1.3 How many days did each user track?
SELECT 
  Id,
  COUNT(*) AS days_tracked
FROM dailyactivity_cleaned
GROUP BY Id
ORDER BY days_tracked DESC;


-- ============================================================
-- SECTION 2: USER ACTIVITY CLASSIFICATION
-- Segment users by how active they are
-- ============================================================

-- 2.1 Classify each user by average daily steps
SELECT 
  Id,
  ROUND(AVG(TotalSteps), 0) AS avg_steps,
  ROUND(AVG(Calories), 0)   AS avg_calories,
  CASE 
    WHEN AVG(TotalSteps) < 5000                    THEN 'Sedentary'
    WHEN AVG(TotalSteps) BETWEEN 5000 AND 7499     THEN 'Lightly Active'
    WHEN AVG(TotalSteps) BETWEEN 7500 AND 9999     THEN 'Fairly Active'
    WHEN AVG(TotalSteps) >= 10000                  THEN 'Very Active'
  END AS activity_level
FROM dailyactivity_cleaned
GROUP BY Id
ORDER BY avg_steps DESC;

-- 2.2 Count of users per activity level
SELECT 
  activity_level,
  COUNT(*) AS user_count
FROM (
  SELECT 
    Id,
    CASE 
      WHEN AVG(TotalSteps) < 5000                    THEN 'Sedentary'
      WHEN AVG(TotalSteps) BETWEEN 5000 AND 7499     THEN 'Lightly Active'
      WHEN AVG(TotalSteps) BETWEEN 7500 AND 9999     THEN 'Fairly Active'
      WHEN AVG(TotalSteps) >= 10000                  THEN 'Very Active'
    END AS activity_level
  FROM dailyactivity_cleaned
  GROUP BY Id
) AS user_levels
GROUP BY activity_level
ORDER BY user_count DESC;

-- 2.3 Full activity breakdown per user
SELECT 
  Id,
  ROUND(AVG(TotalSteps), 0)            AS avg_steps,
  ROUND(AVG(Calories), 0)             AS avg_calories,
  ROUND(AVG(SedentaryMinutes), 0)     AS avg_sedentary_mins,
  ROUND(AVG(LightlyActiveMinutes), 0) AS avg_lightly_active_mins,
  ROUND(AVG(FairlyActiveMinutes), 0)  AS avg_fairly_active_mins,
  ROUND(AVG(VeryActiveMinutes), 0)    AS avg_very_active_mins
FROM dailyactivity_cleaned
GROUP BY Id
ORDER BY avg_steps DESC;


-- ============================================================
-- SECTION 3: STEPS & CALORIES RELATIONSHIP
-- Do more steps = more calories burned?
-- ============================================================

-- 3.1 Daily steps vs calories for every user
SELECT 
  Id,
  ActivityDate,
  TotalSteps,
  Calories
FROM dailyactivity_cleaned
ORDER BY Id, ActivityDate;

-- 3.2 Average steps vs average calories per user
SELECT 
  Id,
  ROUND(AVG(TotalSteps), 0) AS avg_steps,
  ROUND(AVG(Calories), 0)   AS avg_calories
FROM dailyactivity_cleaned
GROUP BY Id
ORDER BY avg_steps DESC;

-- 3.3 Days where users hit 10,000+ steps (healthy benchmark)
SELECT 
  Id,
  COUNT(*) AS days_above_10k_steps
FROM dailyactivity_cleaned
WHERE TotalSteps >= 10000
GROUP BY Id
ORDER BY days_above_10k_steps DESC;


-- ============================================================
-- SECTION 4: SEDENTARY BEHAVIOUR ANALYSIS
-- How much time are users spending inactive?
-- ============================================================

-- 4.1 Average sedentary hours per user
SELECT 
  Id,
  ROUND(AVG(SedentaryMinutes) / 60, 1) AS avg_sedentary_hours,
  ROUND(AVG(VeryActiveMinutes), 0)      AS avg_very_active_mins,
  ROUND(AVG(LightlyActiveMinutes), 0)   AS avg_lightly_active_mins
FROM dailyactivity_cleaned
GROUP BY Id
ORDER BY avg_sedentary_hours DESC;

-- 4.2 Overall: how is the average day split across activity types?
SELECT 
  ROUND(AVG(SedentaryMinutes), 0)     AS avg_sedentary_mins,
  ROUND(AVG(LightlyActiveMinutes), 0) AS avg_lightly_active_mins,
  ROUND(AVG(FairlyActiveMinutes), 0)  AS avg_fairly_active_mins,
  ROUND(AVG(VeryActiveMinutes), 0)    AS avg_very_active_mins,
  ROUND(AVG(SedentaryMinutes) / 
    (AVG(SedentaryMinutes) + AVG(LightlyActiveMinutes) + 
     AVG(FairlyActiveMinutes) + AVG(VeryActiveMinutes)) * 100, 1) AS sedentary_pct
FROM dailyactivity_cleaned;


-- ============================================================
-- SECTION 5: TIME OF DAY ANALYSIS
-- When are users most active during the day?
-- ============================================================

-- 5.1 Average steps by hour of day
SELECT 
  HOUR(ActivityHour)            AS hour_of_day,
  ROUND(AVG(StepTotal), 0)      AS avg_steps
FROM hourlysteps_cleaned
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- 5.2 Most active hours (top 5)
SELECT 
  HOUR(ActivityHour)            AS hour_of_day,
  ROUND(AVG(StepTotal), 0)      AS avg_steps
FROM hourlysteps_cleaned
GROUP BY hour_of_day
ORDER BY avg_steps DESC
LIMIT 5;

-- 5.3 Average calories burned by hour of day
SELECT 
  HOUR(ActivityHour)            AS hour_of_day,
  ROUND(AVG(Calories), 2)       AS avg_calories
FROM hourlycalories_cleaned
GROUP BY hour_of_day
ORDER BY hour_of_day;

-- 5.4 Average intensity by hour of day
SELECT 
  HOUR(ActivityHour)                AS hour_of_day,
  ROUND(AVG(TotalIntensity), 2)     AS avg_intensity
FROM hourlyintensities_cleaned
GROUP BY hour_of_day
ORDER BY avg_intensity DESC;


-- ============================================================
-- SECTION 6: DAY OF WEEK ANALYSIS
-- Which days of the week are most active?
-- ============================================================

-- 6.1 Average steps by day of week
SELECT 
  DAYNAME(ActivityDate)         AS day_of_week,
  DAYOFWEEK(ActivityDate)       AS day_num,
  ROUND(AVG(TotalSteps), 0)     AS avg_steps,
  ROUND(AVG(Calories), 0)       AS avg_calories
FROM dailyactivity_cleaned
GROUP BY day_of_week, day_num
ORDER BY day_num;

-- 6.2 Most active day overall
SELECT 
  DAYNAME(ActivityDate)         AS day_of_week,
  ROUND(AVG(TotalSteps), 0)     AS avg_steps
FROM dailyactivity_cleaned
GROUP BY day_of_week
ORDER BY avg_steps DESC
LIMIT 1;


-- ============================================================
-- SECTION 7: SLEEP ANALYSIS
-- How much and how well are users sleeping?
-- ============================================================

-- 7.1 Total sleep minutes per user per day
-- (value = 1 means asleep, 2 = restless, 3 = awake)
SELECT 
  Id,
  DATE(date)                                        AS sleep_date,
  COUNT(*)                                          AS total_sleep_records,
  SUM(CASE WHEN value = 1 THEN 1 ELSE 0 END)        AS minutes_asleep,
  SUM(CASE WHEN value = 2 THEN 1 ELSE 0 END)        AS minutes_restless,
  SUM(CASE WHEN value = 3 THEN 1 ELSE 0 END)        AS minutes_awake,
  ROUND(SUM(CASE WHEN value = 1 THEN 1 ELSE 0 END) / 60, 1) AS hours_asleep
FROM minutesleep_cleaned
GROUP BY Id, sleep_date
ORDER BY Id, sleep_date;

-- 7.2 Average sleep per user
SELECT 
  Id,
  ROUND(AVG(minutes_asleep) / 60, 1)    AS avg_hours_asleep,
  ROUND(AVG(minutes_restless), 0)        AS avg_mins_restless,
  CASE
    WHEN AVG(minutes_asleep) / 60 >= 7  THEN 'Healthy Sleep'
    WHEN AVG(minutes_asleep) / 60 >= 6  THEN 'Slightly Under'
    ELSE 'Sleep Deprived'
  END AS sleep_quality
FROM (
  SELECT 
    Id,
    DATE(date) AS sleep_date,
    SUM(CASE WHEN value = 1 THEN 1 ELSE 0 END) AS minutes_asleep,
    SUM(CASE WHEN value = 2 THEN 1 ELSE 0 END) AS minutes_restless
  FROM minutesleep_cleaned
  GROUP BY Id, sleep_date
) AS daily_sleep
GROUP BY Id
ORDER BY avg_hours_asleep DESC;

-- 7.3 Overall average sleep across all users
SELECT 
  ROUND(AVG(minutes_asleep) / 60, 1) AS overall_avg_hours_asleep
FROM (
  SELECT 
    Id,
    DATE(date)                                              AS sleep_date,
    SUM(CASE WHEN value = 1 THEN 1 ELSE 0 END)             AS minutes_asleep
  FROM minutesleep_cleaned
  GROUP BY Id, sleep_date
) AS daily_sleep;


-- ============================================================
-- SECTION 8: COMBINED INSIGHTS
-- Merge activity + sleep for full picture
-- ============================================================

-- 8.1 Activity level vs sleep quality per user
SELECT 
  a.Id,
  ROUND(AVG(a.TotalSteps), 0)           AS avg_steps,
  ROUND(AVG(a.Calories), 0)            AS avg_calories,
  ROUND(AVG(a.SedentaryMinutes), 0)    AS avg_sedentary_mins,
  ROUND(AVG(s.minutes_asleep) / 60, 1) AS avg_hours_asleep,
  CASE 
    WHEN AVG(a.TotalSteps) < 5000                THEN 'Sedentary'
    WHEN AVG(a.TotalSteps) BETWEEN 5000 AND 7499 THEN 'Lightly Active'
    WHEN AVG(a.TotalSteps) BETWEEN 7500 AND 9999 THEN 'Fairly Active'
    WHEN AVG(a.TotalSteps) >= 10000              THEN 'Very Active'
  END AS activity_level
FROM dailyactivity_cleaned a
LEFT JOIN (
  SELECT 
    Id,
    DATE(date)                                          AS sleep_date,
    SUM(CASE WHEN value = 1 THEN 1 ELSE 0 END)         AS minutes_asleep
  FROM minutesleep_cleaned
  GROUP BY Id, sleep_date
) s ON a.Id = s.Id AND a.ActivityDate = s.sleep_date
GROUP BY a.Id
ORDER BY avg_steps DESC;
