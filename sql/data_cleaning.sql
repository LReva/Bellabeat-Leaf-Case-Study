-- creating a unified table for two months of daily activity data
CREATE OR REPLACE TABLE wellnessdata-01.fitabase_clean.dailyActivity_all AS
SELECT *, 
  EXTRACT(DAYOFWEEK FROM all_activity.ActivityDate) AS week_day,
  CASE
    WHEN EXTRACT(DAYOFWEEK FROM all_activity.ActivityDate) IN (1,7) THEN TRUE
    ELSE FALSE
  END AS is_weekend
 FROM (
  SELECT 
    *,
    '2016-04-12_to_2016-05-12' AS dataset_window,
    DATE_DIFF(DATE(ActivityDate), DATE '2016-04-12', DAY) + 1 AS window_day_index
  FROM `wellnessdata-01.fitabase.dailyActivity`
  UNION ALL
  SELECT 
    *,
    '2016-03-12_to_2016-04-11' AS dataset_window,
    DATE_DIFF(DATE(ActivityDate), DATE '2016-03-12', DAY) + 1 AS window_day_index
  FROM `wellnessdata-01.fitabase.dailyActivity_31216_41116`) AS all_activity
WHERE window_day_index <= 31 AND window_day_index > 0;

-- creating a unified table for two months of daily weight data
CREATE OR REPLACE TABLE `wellnessdata-01.fitabase_clean.weightLogInfo_all` AS
WITH unioned AS (
  SELECT
    *,
    '2016-04-12_to_2016-05-12' AS dataset_window
  FROM `wellnessdata-01.fitabase.weightLogInfo`

  UNION ALL

  SELECT
    *,
    '2016-03-12_to_2016-04-11' AS dataset_window
  FROM `wellnessdata-01.fitabase.weightLogInfo_31216_41116`
),
parsed AS (
  SELECT
    SAFE_CAST(Id AS INT64) AS Id,
    SAFE.PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', Date) AS log_ts,
    SAFE_CAST(WeightKg AS FLOAT64) AS weight_kg,
    SAFE_CAST(BMI AS FLOAT64) AS bmi,
    SAFE_CAST(IsManualReport AS BOOL) AS is_manual_report,
    SAFE_CAST(LogId AS INT64) AS log_id,
    dataset_window
  FROM unioned
)
SELECT *,
  EXTRACT(DAYOFWEEK FROM all_activity.log_date) AS week_day,
  CASE
    WHEN EXTRACT(DAYOFWEEK FROM all_activity.log_date) IN (1,7) THEN TRUE
    ELSE FALSE
  END AS is_weekend
FROM (
  SELECT
    Id,
    DATE(log_ts) AS log_date,
    TIME(log_ts) AS log_time,
    weight_kg,
    bmi,
    is_manual_report,
    log_id,
    dataset_window,
    CASE
      WHEN dataset_window = '2016-03-12_to_2016-04-11'
        THEN DATE_DIFF(DATE(log_ts), DATE '2016-03-12', DAY) + 1
      WHEN dataset_window = '2016-04-12_to_2016-05-12'
        THEN DATE_DIFF(DATE(log_ts), DATE '2016-04-12', DAY) + 1
    END AS window_day_index
  FROM parsed
  WHERE Id IS NOT NULL
    AND log_ts IS NOT NULL) AS all_activity
WHERE window_day_index <= 31 AND window_day_index > 0;

-- creating a unified table for two months of hourly intensities data
CREATE OR REPLACE TABLE `wellnessdata-01.fitabase_clean.hourlyIntensities_all` AS
WITH unioned AS (
  SELECT
    *,
    '2016-04-12_to_2016-05-12' AS dataset_window
  FROM `wellnessdata-01.fitabase.hourlyIntensities`

  UNION ALL

  SELECT
    *,
    '2016-03-12_to_2016-04-11' AS dataset_window
  FROM `wellnessdata-01.fitabase.hourlyIntensities_31216_41116`
),
parsed AS (
  SELECT
    SAFE_CAST(Id AS INT64) AS Id,
    SAFE.PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', ActivityHour) AS log_ts,
    SAFE_CAST(TotalIntensity AS FLOAT64) AS total_intensity,
    SAFE_CAST(AverageIntensity AS FLOAT64) AS average_intensity,
    dataset_window
  FROM unioned
)
SELECT *, 
  EXTRACT(DAYOFWEEK FROM all_activity.log_date) AS week_day,
  CASE
    WHEN EXTRACT(DAYOFWEEK FROM all_activity.log_date) IN (1,7) THEN TRUE
    ELSE FALSE
  END AS is_weekend
FROM (
  SELECT
    Id,
    DATE(log_ts) AS log_date,
    TIME(log_ts) AS log_time,
    total_intensity,
    average_intensity,
    dataset_window,
    CASE
      WHEN dataset_window = '2016-03-12_to_2016-04-11'
        THEN DATE_DIFF(DATE(log_ts), DATE '2016-03-12', DAY) + 1
      WHEN dataset_window = '2016-04-12_to_2016-05-12'
        THEN DATE_DIFF(DATE(log_ts), DATE '2016-04-12', DAY) + 1
    END AS window_day_index
  FROM parsed
  WHERE Id IS NOT NULL
    AND log_ts IS NOT NULL) AS all_activity
WHERE window_day_index <= 31 AND window_day_index > 0;

-- creating a unified table for two months of hourly calories data
CREATE OR REPLACE TABLE `wellnessdata-01.fitabase_clean.hourlyCalories_all` AS
WITH unioned AS (
  SELECT
    *,
    '2016-04-12_to_2016-05-12' AS dataset_window
  FROM `wellnessdata-01.fitabase.hourlyCalories`

  UNION ALL

  SELECT
    *,
    '2016-03-12_to_2016-04-11' AS dataset_window
  FROM `wellnessdata-01.fitabase.hourlyCalories_31216_41116`
),
parsed AS (
  SELECT
    SAFE_CAST(Id AS INT64) AS Id,
    SAFE.PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', ActivityHour) AS log_ts,
    SAFE_CAST(Calories AS FLOAT64) AS calories,
    dataset_window
  FROM unioned
)
SELECT *, 
  EXTRACT(DAYOFWEEK FROM all_activity.log_date) AS week_day,
  CASE
    WHEN EXTRACT(DAYOFWEEK FROM all_activity.log_date) IN (1,7) THEN TRUE
    ELSE FALSE
  END AS is_weekend
FROM 
  (SELECT
    Id,
    DATE(log_ts) AS log_date,
    TIME(log_ts) AS log_time,
    calories,
    dataset_window,
    CASE
      WHEN dataset_window = '2016-03-12_to_2016-04-11'
        THEN DATE_DIFF(DATE(log_ts), DATE '2016-03-12', DAY) + 1
      WHEN dataset_window = '2016-04-12_to_2016-05-12'
        THEN DATE_DIFF(DATE(log_ts), DATE '2016-04-12', DAY) + 1
    END AS window_day_index
  FROM parsed
  WHERE Id IS NOT NULL
    AND log_ts IS NOT NULL) AS all_activity
WHERE window_day_index <= 31 AND window_day_index > 0;

-- creating a unified table for two months of hourly steps data
CREATE OR REPLACE TABLE `wellnessdata-01.fitabase_clean.hourlySteps_all` AS
WITH unioned AS (
  SELECT
    *,
    '2016-04-12_to_2016-05-12' AS dataset_window
  FROM `wellnessdata-01.fitabase.hourlySteps`

  UNION ALL

  SELECT
    *,
    '2016-03-12_to_2016-04-11' AS dataset_window
  FROM `wellnessdata-01.fitabase.hourlySteps_31216_41116`
),
parsed AS (
  SELECT
    SAFE_CAST(Id AS INT64) AS Id,
    SAFE.PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', ActivityHour) AS log_ts,
    SAFE_CAST(StepTotal AS FLOAT64) AS total_steps,
    dataset_window
  FROM unioned
)
SELECT *, 
  EXTRACT(DAYOFWEEK FROM all_activity.log_date) AS week_day,
  CASE
    WHEN EXTRACT(DAYOFWEEK FROM all_activity.log_date) IN (1,7) THEN TRUE
    ELSE FALSE
  END AS is_weekend
FROM (
  SELECT
    Id,
    DATE(log_ts) AS log_date,
    TIME(log_ts) AS log_time,
    total_steps,
    dataset_window,
    CASE
      WHEN dataset_window = '2016-03-12_to_2016-04-11'
        THEN DATE_DIFF(DATE(log_ts), DATE '2016-03-12', DAY) + 1
      WHEN dataset_window = '2016-04-12_to_2016-05-12'
        THEN DATE_DIFF(DATE(log_ts), DATE '2016-04-12', DAY) + 1
    END AS window_day_index
  FROM parsed
  WHERE Id IS NOT NULL
    AND log_ts IS NOT NULL) AS all_activity
WHERE window_day_index <= 31 AND window_day_index > 0;

-- creating a table for sleep day data
CREATE OR REPLACE TABLE `wellnessdata-01.fitabase_clean.sleepDay` AS
WITH cleaned AS (SELECT
  SAFE_CAST(Id AS INT64) AS Id,
  SAFE.PARSE_TIMESTAMP('%m/%d/%Y %I:%M:%S %p', SleepDay) AS log_ts,
  SAFE_CAST(TotalSleepRecords AS FLOAT64) AS total_sleep_records,
  SAFE_CAST(TotalMinutesAsleep AS FLOAT64) AS total_sleep_minutes,
  SAFE_CAST (TotalTimeInBed AS FLOAT64) AS total_time_in_bed,
  '2016-04-12_to_2016-05-12' AS dataset_window
  FROM `wellnessdata-01.fitabase.sleepDay`)
SELECT DISTINCT *
FROM (SELECT Id,
  DATE(log_ts) AS log_date,
  TIME(log_ts) AS log_time,  
  total_sleep_records,
  total_sleep_minutes,
  total_time_in_bed,
  total_sleep_minutes / total_time_in_bed AS sleep_efficiency,
  EXTRACT(DAYOFWEEK FROM log_ts) AS week_day,
  CASE
    WHEN EXTRACT(DAYOFWEEK FROM log_ts) IN (1,7) THEN TRUE
    ELSE FALSE
  END AS is_weekend
FROM cleaned
WHERE Id IS NOT NULL AND log_ts IS NOT NULL);
