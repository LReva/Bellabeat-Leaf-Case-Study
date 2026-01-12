 -- count sleep records for each user
CREATE OR REPLACE TABLE `wellnessdata-01.fitabase_marts.flag_sleep` AS
SELECT
  Id,
  dataset_window,
  TRUE AS has_sleep_log,
  COUNT(*) AS sleep_rows
FROM `wellnessdata-01.fitabase_clean.sleepDay`
GROUP BY 1,2;

-- count weight records for each user
CREATE OR REPLACE TABLE `wellnessdata-01.fitabase_marts.flag_weight` AS
SELECT
  Id,
  dataset_window,
  TRUE AS has_weight_log,
  COUNT(*) AS weight_rows
FROM `wellnessdata-01.fitabase_clean.weightLogInfo_all`
GROUP BY 1,2;

-- create a summary of days with activity, sleep and weight for each user
CREATE OR REPLACE TABLE `wellnessdata-01.fitabase_marts.user_summary_leaf` AS
WITH base AS (
  SELECT
    Id,
    dataset_window,
    COUNT(*) AS days_with_activity,
    AVG(TotalSteps) AS avg_steps,
    AVG(TotalDistance) AS avg_distance,
    AVG(Calories) AS avg_calories,
    STDDEV_SAMP(TotalSteps) AS step_variability,
    AVG(SedentaryMinutes) AS avg_sedentary_minutes
  FROM `wellnessdata-01.fitabase_clean.dailyActivity_all`
  GROUP BY 1,2
)
SELECT
  b.*,
  SAFE_DIVIDE(days_with_activity,31) AS active_days_pct,
  COALESCE(s.has_sleep_log, FALSE) AS has_sleep_log,
  COALESCE(w.has_weight_log, FALSE) AS has_weight_log,
  COALESCE(s.sleep_rows, 0) AS sleep_rows,
  COALESCE(w.weight_rows, 0) AS weight_rows
FROM base b
LEFT JOIN `wellnessdata-01.fitabase_marts.flag_sleep` s
  ON b.Id = s.Id AND b.dataset_window = s.dataset_window
LEFT JOIN `wellnessdata-01.fitabase_marts.flag_weight` w
  ON b.Id = w.Id AND b.dataset_window = w.dataset_window;

-- create daily activity + sleep table
CREATE OR REPLACE TABLE `wellnessdata-01.fitabase_marts.daily_leaf` AS
WITH base AS (
  SELECT 
    Id,
    ActivityDate AS log_date,
    TotalSteps AS total_steps,
    TotalDistance AS total_distance,
    TrackerDistance AS tracker_distance,
    VeryActiveDistance AS very_active_distance,
    ModeratelyActiveDistance AS moderately_active_distance, 
    LightActiveDistance AS light_active_distance,
    SedentaryActiveDistance AS sedentary_active_distance,
    VeryActiveMinutes AS very_active_minutes,
    FairlyActiveMinutes AS fairly_active_minutes,
    LightlyActiveMinutes AS lightly_active_minutes,
    SedentaryMinutes AS sedentary_minutes,
    Calories AS calories,
    dataset_window,
    is_weekend,
    week_day,
    window_day_index
  FROM `wellnessdata-01.fitabase_clean.dailyActivity_all`
),

sleep_dedup AS (
  SELECT
    Id,
    log_date,
    dataset_window,
    total_sleep_minutes AS minutes_asleep,
    total_time_in_bed AS time_in_bed,
    ROW_NUMBER() OVER (
      PARTITION BY Id, log_date, dataset_window
      ORDER BY total_sleep_minutes DESC, total_time_in_bed DESC
    ) AS rn
  FROM `wellnessdata-01.fitabase_clean.sleepDay`
),

weight_dedup AS (
  SELECT
    Id,
    log_date,
    log_time,
    dataset_window,
    weight_kg,
    ROW_NUMBER() OVER (
      PARTITION BY Id, log_date, dataset_window
      ORDER BY log_time DESC
) AS rw 
FROM `wellnessdata-01.fitabase_clean.weightLogInfo_all`
)

SELECT
  b.*,
  s.minutes_asleep,
  s.time_in_bed,
  SAFE_DIVIDE(s.minutes_asleep, s.time_in_bed) AS sleep_efficiency,
  COALESCE(s.rn = 1, FALSE) AS has_sleep_log_for_day,
  COALESCE(w.rw = 1, FALSE) AS has_weight_log_for_day,
  w.weight_kg

FROM base b
LEFT JOIN sleep_dedup s
  ON b.Id = s.Id
 AND b.log_date = s.log_date
 AND b.dataset_window = s.dataset_window
 AND s.rn = 1
 LEFT JOIN weight_dedup w
  ON b.Id = w.Id
 AND b.log_date = w.log_date
 AND b.dataset_window = w.dataset_window
 AND w.rw = 1;

--  hourly steps + intensities
CREATE OR REPLACE TABLE `wellnessdata-01.fitabase_marts.hourly_leaf` AS
WITH base AS (
  SELECT *
  FROM `wellnessdata-01.fitabase_clean.hourlySteps_all`
)

SELECT 
  b.Id,
  b.log_date,
  b.log_time,
  b.total_steps,
  i.average_intensity,
  i.total_intensity,
  c.calories,
  b.dataset_window,
  b.is_weekend,
  b.week_day,
  b.window_day_index
  FROM base b
  LEFT JOIN `wellnessdata-01.fitabase_clean.hourlyIntensities_all` i
    ON b.Id = i.Id
  AND b.log_date = i.log_date
  AND b.log_time = i.log_time
  AND b.dataset_window = i.dataset_window
  LEFT JOIN `wellnessdata-01.fitabase_clean.hourlyCalories_all` c
    ON b.Id = c.Id
  AND b.log_date = c.log_date
  AND b.log_time = c.log_time
  AND b.dataset_window = c.dataset_window;

  -- average summary
CREATE OR REPLACE TABLE `wellnessdata-01.fitabase_marts.window_compaisson` AS
WITH base AS (
  SELECT *
  FROM `wellnessdata-01.fitabase_marts.daily_leaf`
)
SELECT
 dataset_window,
 week_day,
 AVG(total_steps) AS avg_total_steps,
 AVG(total_distance) AS avg_total_distance,
 AVG(tracker_distance) AS avg_tracker_distance,
 AVG(very_active_distance) AS avg_very_active_distance,
 AVG(moderately_active_distance) AS avg_moderately_active,
 AVG(light_active_distance) AS avg_light_active,
 AVG(sedentary_active_distance) AS avg_sedentary_active,
 AVG(very_active_minutes) AS avg_very_active_minutes,
 AVG(fairly_active_minutes) AS avg_fairly_active_minutes,
 AVG(lightly_active_minutes) AS avg_lightly_active_minutes,
 AVG(sedentary_minutes) AS avg_sedentary_minutes,
 AVG(calories) AS avg_calories,
 COUNT(*) AS total_days
FROM base
GROUP BY 1,2
ORDER BY 1,2;

