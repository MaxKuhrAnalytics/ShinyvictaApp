# Loading libraries
library(tidyverse)
library(lubridate)
library(shiny)
library(DT)

# Plotting function for Metrics
plot_metric = function(data, metric) {
  metric_col = switch(metric,
                      "views" = "view_count",
                      "likes" = "like_count",
                      "comments" = "comment_count",
                      "engagement" = "engagement")
  y_label = switch(metric,
                   "views" = "Total Views (Thousands)",
                   "likes" = "Total Likes (Thousands)",
                   "comments" = "Total Comments (Thousands)",
                   "engagement" = "Average Engagement Rate (%)")
  
  plot_data = if (metric == "engagement") {
    data %>%
      group_by(year_month) %>%
      summarise(total = mean(.data[[metric_col]], na.rm = TRUE)) %>%
      ungroup()
  } else {
    data %>%
      group_by(year_month) %>%
      summarise(total = sum(.data[[metric_col]], na.rm = TRUE)) %>%
      ungroup()
  }
  
  p = ggplot(plot_data, aes(x = year_month, y = total)) +
    geom_line(color = "red", size = 1) +
    geom_point(color = "blue", size = 2) +
    geom_smooth(color = alpha("green", 0.7), size = 2, se = FALSE) +
    labs(title = paste(y_label, "Over Time"),
         x = "Publication Month",
         y = y_label) +
    scale_x_date(date_breaks = "4 months", date_labels = "(%m-%y)") +
    theme_minimal()
  
  # Format non-engagement counts to thousands 
  if (metric != "engagement") {
    p = p + scale_y_continuous(labels = function(x) x / 1000)
  }
  
  return(p)
}

# Table function for a single metric
table_metric = function(data, metric, unique_tags) {
  metric_col = switch(metric,
                      "views" = "view_count",
                      "likes" = "like_count",
                      "comments" = "comment_count",
                      "engagement" = "engagement")
  metric_label = switch(metric,
                        "views" = "Views",
                        "likes" = "Likes",
                        "comments" = "Comments",
                        "engagement" = "Engagement (%)")
  
  # Top 5 videos
  top_videos = data %>%
    select(short_title, published_at, duration_type, !!sym(metric_col)) %>%
    arrange(desc(.data[[metric_col]])) %>%
    slice_head(n = 5) %>%
    rename(Title = short_title, `Publication Date` = published_at, 
           `Duration Type` = duration_type, !!metric_label := !!sym(metric_col))
  
  # Top 5 tags by average metric value
  tag_metrics = map_dfr(unique_tags, function(tag) {
    data %>%
      filter(str_detect(tags, fixed(tag, ignore_case = TRUE))) %>%
      summarise(avg_metric = mean(.data[[metric_col]], na.rm = TRUE)) %>%
      mutate(Tag = tag)
  }) %>%
    arrange(desc(avg_metric)) %>%
    slice_head(n = 5) %>%
    mutate(avg_metric = round(avg_metric, 2)) %>%
    rename(!!paste0("Avg ", metric_label) := avg_metric)
  
  # Average metric
  avg_metric = data %>%
    summarise(avg = round(mean(.data[[metric_col]], na.rm = TRUE), 2)) %>%
    pull(avg)
  
  list(
    videos = top_videos,
    tags = tag_metrics,
    average = data.frame(Metric = paste("Average", metric_label), Value = avg_metric)
  )
}