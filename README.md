# ShinyvictaApp

## About Shinyvicta

'Shinyvicta' is an R Shiny app that explores and visualizes analytics data taken from the current 'Repentance'-era of the Sinvicta YouTube gaming channel spanning March 31st 2021 to June 30th 2025.

The app helps creators, fans, and analyists understand channel performance by tracking trends in views, likes, comments, and engagement (the ratio of total likes and comments over total views, representing how much of the audience engaged with the video), identifying top-performing videos and tags, and summarizing average metrics over user-specified time periods and video lengths.

More information about the data collected can be viewed in the Data tab.

## How to Use

User Input:

    Publication Date Range - Filters videos for a range of time by month and year.
    Video Duration - Filters videos based on category of relative length.

Tabs:

    Trends - Line plots with trend line. Plots total Views, Likes and Comments over time to measure growth, as well as average engagement over time to measure audience engagement.
    Top 5 Videos - Table of top 5 videos including Title, publication date, length type, and raw count or percentage for specific metric.
    Top 5 Tags - Table of top 5 tags by average, including the average.
    Average Metrics - Average overall metrics for selected timeframe.

DISCLAIMER

All counts for individual videos are taken as a total count from the time of the latest update. They are not reflective of the counts over time.

Data is taken from the public YouTube API. It is not comprehensive, nor does it track important data such as demographics or time watched per view.

Most recent data update: July 21, 2025

## 
About Shinyvicta Data

The data frame for the Shinyvicta app was collected using the public Youtube Data API v3 using Python scripts and libraries, drawn from the 'Sinvicta' YouTube gaming channel's current 'modern' era of content spanning March 31st 2021 to June 30th 2025.

Data Columns:

    video_id (chr) = Gives raw YouTube video ID. Generally not helpful to users.
    title (chr) = Video title as seen on YouTube.
    published_at (date) = Date of publication, format: Year-Month-Day (yyyy-mm-dd).
    view_count (dbl) = Number of unique views associated to specific video.
    like_count (dbl) = Number of likes associated to specific video.
    comment_count (dbl) = Number of comments associated to specific video.
    tags (chr) = Tags associated with video as one comma-delineated string.
    category_id (dbl) = Youtube category IDs. 20 = 'Gaming', 10 = 'Music'.
    duration (chr) = Video duration in ISO 8601 format (PT1H1M8S = 1h 1m 8s).

Derived Columns:

    engagement (dbl) = Ratio of engagment to views: Likes + Comments / Views * 100 = % Audience Engagement for that Video
    duration_min (date) = duration of video converted into minutes.
    duration_type (chr) = categories based on relative length (see sidebar). Groups were determined by examining the distribution of videos according to duration_min.
    year_month (date) = groups publication date by Month and Year.


