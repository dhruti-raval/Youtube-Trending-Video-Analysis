-- =========================================
-- YOUTUBE TRENDING VIDEO ANALYSIS (INDIA)
-- =========================================

-- 1. QUICK DATA PREVIEW
-- View first 10 rows to understand dataset structure
SELECT TOP 10 *
FROM India_youtube;

-- Check table structure (columns, datatypes)
EXEC sp_help India_youtube;

-- =========================================
-- 2. BASIC DATA CLEANING
-- =========================================

-- Count total dislikes (checking data presence)
SELECT COUNT(dislikes) 
FROM India_youtube;

-- Find maximum dislikes value
SELECT MAX(dislikes) 
FROM India_youtube;

-- Drop dislikes column (assuming it's unnecessary for analysis)
ALTER TABLE India_youtube
DROP COLUMN dislikes;

-- =========================================
-- 3. DATETIME TRANSFORMATION
-- =========================================

-- Add new column for proper datetime format
ALTER TABLE India_youtube
ADD publish_datetime DATETIME;

-- Convert publish_time (string) to DATETIME
UPDATE India_youtube
SET publish_datetime = TRY_CAST(publish_time AS DATETIME);

-- Fix formatting issues (ISO format like 'T' and 'Z')
UPDATE India_youtube
SET publish_datetime = TRY_CAST(
    REPLACE(REPLACE(publish_time, 'T', ' '), 'Z', '') 
AS DATETIME);

-- Check if conversion worked
SELECT publish_time, publish_datetime
FROM India_youtube;

-- Check NULL values in datetime column
SELECT publish_datetime
FROM India_youtube
WHERE publish_datetime IS NULL;

-- Count valid vs total rows
SELECT COUNT(*) AS total_rows,
       COUNT(publish_datetime) AS valid_dates
FROM India_youtube;

-- =========================================
-- 4. ENGAGEMENT ANALYSIS
-- =========================================

-- Top videos by engagement rate
-- Engagement = (likes + comments) / views
SELECT TOP 10
    title,
    views,
    likes,
    comments,
    (likes + comments) * 1.0 / NULLIF(views, 0) AS engagement_rate
FROM India_youtube
WHERE views > 10000
ORDER BY engagement_rate DESC;

-- Average engagement per category
SELECT 
    category_id,
    AVG((likes + comments) * 1.0 / NULLIF(views, 0)) AS avg_engagement
FROM India_youtube
WHERE views > 10000
GROUP BY category_id  
ORDER BY avg_engagement DESC;

-- =========================================
-- 5. CATEGORY MAPPING (NUMERIC -> NAME)
-- =========================================

-- Create mapping table
CREATE TABLE category_mapping (
    category_id INT PRIMARY KEY,
    category_name VARCHAR(100)
);

-- Insert category values
INSERT INTO category_mapping VALUES
(1,  'Film & Animation'),
(2,  'Autos & Vehicles'),
(10, 'Music'),
(15, 'Pets & Animals'),
(17, 'Sports'),
(18, 'Short Movies'),
(19, 'Travel & Events'),
(20, 'Gaming'),
(21, 'Videoblogging'),
(22, 'People & Blogs'),
(23, 'Comedy'),
(24, 'Entertainment'),
(25, 'News & Politics'),
(26, 'Howto & Style'),
(27, 'Education'),
(28, 'Science & Technology'),
(29, 'Nonprofits & Activism'),
(30, 'Movies'),
(31, 'Anime/Animation'),
(32, 'Action/Adventure'),
(33, 'Classics'),
(34, 'Comedy'),
(35, 'Documentary'),
(36, 'Drama'),
(37, 'Family'),
(38, 'Foreign'),
(39, 'Horror'),
(40, 'Sci-Fi/Fantasy'),
(41, 'Thriller'),
(42, 'Shorts'),
(43, 'Shows'),
(44, 'Trailers');

-- View mapping table
SELECT * 
FROM category_mapping;

-- =========================================
-- 6. CATEGORY PERFORMANCE ANALYSIS
-- =========================================

-- Join both tables to get readable category names
SELECT 
    c.category_name, 
    AVG((I.likes + I.comments) * 1.0 / NULLIF(I.views, 0)) AS avg_engagement
FROM India_youtube I
JOIN category_mapping c 
    ON I.category_id = c.category_id 
WHERE I.views > 1000
GROUP BY c.category_name
ORDER BY avg_engagement DESC;

-- =========================================
-- 7. CHANNEL PERFORMANCE ANALYSIS
-- =========================================

-- Rank videos within each channel by views
SELECT 
    channel_title, 
    title, 
    views, 
    RANK() OVER (
        PARTITION BY channel_title 
        ORDER BY views DESC
    ) AS rank_in_channel
FROM India_youtube;

-- =========================================
-- 8. TREND REPETITION ANALYSIS
-- =========================================

-- Find videos that trend multiple times
SELECT 
    title,
    COUNT(*) AS trending_count
FROM India_youtube
GROUP BY title
ORDER BY trending_count DESC;

-- =========================================
-- 9. BEST PUBLISH TIME ANALYSIS
-- =========================================

-- Analyze which hour gives highest average views
SELECT 
    DATEPART(HOUR, publish_datetime) AS publish_hour,
    AVG(CAST(views AS BIGINT)) AS avg_views
FROM India_youtube
WHERE publish_datetime IS NOT NULL
GROUP BY DATEPART(HOUR, publish_datetime)
ORDER BY avg_views DESC;

-- =========================================
-- END OF PROJECT
-- =========================================
