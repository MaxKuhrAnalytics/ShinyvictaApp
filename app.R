# Loading shiny library
library(shiny)


# Set Source for necessary functions
source("ShinyvictaFunctions.R")


# Importing video analytics
data = read_csv("sinvicta_videos_2021_2025.csv") %>%
  mutate(
    year_month = floor_date(published_at, "month"), # creates column id-ing videos by year and month only
    duration_min = round(as.numeric(duration(duration, "seconds")) / 60, 0), # converts duration to raw minute count
    duration_type = case_when( # categorizes videos based on length
      duration_min <= 5 ~ "brief",
      duration_min > 5 & duration_min <= 25 ~ "short",
      duration_min > 25 & duration_min <= 48 ~ "typical",
      duration_min > 48 & duration_min <= 70 ~ "long",
      duration_min > 70 ~ "very long"
    ),
    engagement = round((like_count + comment_count) / view_count * 100, 3), # calculates engagement statistics
    short_title = str_trunc(title, 50, "right") # truncates titles to 50 characters
  )

# Filtering out unique tags
unique_tags = unique(unlist(strsplit(data$tags, ","))) # grabs unique tags
pattern = "[!:#-?]|Ep\\. " # common characters of video title tags, which are redundant
unique_tags = unique_tags[!grepl(pattern, unique_tags) & !is.na(unique_tags)] # grep according to the pattern

# Define metrics
metrics = c("views", "likes", "comments", "engagement") # defining metrics to plot and table





##### Shiny Code Starts Here #####

# Shiny UI
ui = sidebarLayout(
  # Sidebar Panel (shared across all tabs)
  sidebarPanel(
    h3("Shinyvicta - Sinvicta Channel Analytics"), # App Title
    helpText("Best viewed in a full window!"),
    br(), # Blank Line Break for formatting
    
    # Publication Date Slider
    sliderInput(
      "date_range", # object name
      "Publication Date Range:", # Title
      min = min(data$year_month), # Earliest date
      max = max(data$year_month), # Latest date
      value = c(min(data$year_month), max(data$year_month)), # set range of time
      timeFormat = "%b %Y" #Month Year format
    ),
    helpText("NOTE: Tables with a wider date range will take longer to load."),
    
    # Video Duration Group Checkbox
    checkboxGroupInput(
      "duration_type",
      "Video Duration:",
      choices = c("Brief (<= 5 Min)" = "brief", "Short (5-25 min)" = "short", # selection tied to object name
                  "Typical (25-48 min)" = "typical",
                  "Long (48-70 min)" = "long", "Very Long (70+ min)" = "very long"),
      selected = c("brief", "short", "typical", "long", "very long") # everything is pre-selected
    ),
    helpText("Relative video length.")
  ),
  
  # Main Panel with Navbar
  mainPanel(
    navbarPage(
      "", # Blank, as the app name is in the side bar
      
      # Trends Tab
      tabPanel(
        "Trends",
        fluidRow( # First row of plots
          column(6, plotOutput("plot_views", height = "300px")),
          column(6, plotOutput("plot_likes", height = "300px"))
        ),
        fluidRow( # Second Row
          column(6, plotOutput("plot_comments", height = "300px")),
          column(6, plotOutput("plot_engagement", height = "300px"))
        )
      ),
      
      # Top 5 Videos Tab
      tabPanel(
        "Top 5 Videos",
        fluidRow( # One of top of the other, as side by side looks bad and is hard to read.
          column(12, h4("Top 5 Videos by Views"), DTOutput("table_videos_views")),
          column(12, h4("Top 5 Videos by Likes"), DTOutput("table_videos_likes")),
          column(12, h4("Top 5 Videos by Comments"), DTOutput("table_videos_comments")),
          column(12, h4("Top 5 Videos by Engagement"), DTOutput("table_videos_engagement"))
        )
      ),
      
      # Top 5 Tags Tab
      tabPanel(
        "Top 5 Tags",
        fluidRow( # See above
          column(12, h4("Top 5 Tags by Views"), DTOutput("table_tags_views")),
          column(12, h4("Top 5 Tags by Likes"), DTOutput("table_tags_likes")),
          column(12, h4("Top 5 Tags by Comments"), DTOutput("table_tags_comments")),
          column(12, h4("Top 5 Tags by Engagement"), DTOutput("table_tags_engagement"))
        )
      ),
      
      # Average Metrics Tab
      tabPanel(
        "Average Metrics",
        fluidRow( # See 'Top 5 Videos'
          column(12, h4("Average Views in Timeframe"), DTOutput("table_avg_views")),
          column(12, h4("Average Likes in Timeframe"), DTOutput("table_avg_likes")),
          column(12, h4("Average Comments in Timeframe"), DTOutput("table_avg_comments")),
          column(12, h4("Average Engagement in Timeframe"), DTOutput("table_avg_engagement"))
        )
      ),
      
      # About Tab
      tabPanel(
        "About",
        h3("About Shinyvicta"), # Title
        # Regular text
        p("'Shinyvicta' is an R Shiny app that explores and visualizes analytics data 
          taken from the current 'Repentance'-era of the Sinvicta YouTube gaming channel
          spanning March 31st 2021 to June 30th 2025."),
        p("The app helps creators, fans, and analyists understand channel performance
          by tracking trends in views, likes, comments, and engagement (the ratio 
          of total likes and comments over total views, representing how much of the audience engaged with the video), identifying top-performing
          videos and tags, and summarizing average metrics over user-specified time periods
          and video lengths."),
        p("More information about the data collected can be viewed in the Data tab."),
        h3("How to Use"),
        p("User Input:"),
        tags$ul(
          tags$li("Publication Date Range - Filters videos for a range of time by month and year."), # indent
          tags$li("Video Duration - Filters videos based on category of relative length.")
        ),
        p("Tabs:"),
        tags$ul(
          tags$li("Trends - Line plots with trend line. Plots total Views, Likes 
                  and Comments over time to measure growth, as well as average 
                  engagement over time to measure audience engagement."),
          tags$li("Top 5 Videos - Table of top 5 videos including Title, publication date, length type, and raw count or percentage for specific metric."),
          tags$li("Top 5 Tags - Table of top 5 tags by average, including the average."),
          tags$li("Average Metrics - Average overall metrics for selected timeframe.")
        ),
        h3("DISCLAIMER"),
        p("All counts for individual videos are taken as a total count from the time of the latest update. They are not reflective of the counts over time."),
        p("Data is taken from the public YouTube API. It is not comprehensive, nor does it track important data such as demographics or time watched per view."),
        br(),
        p("Most recent data update: July 21, 2025")
      ),
      
      # Data Tab
      tabPanel(
        "Data",
        h3("About Shinyvicta Data"),
        p("The data frame for the Shinyvicta app was collected using the public Youtube
          Data API v3 using Python scripts and libraries, drawn from the 'Sinvicta' 
          YouTube gaming channel's current 'modern' era of content spanning March  
          31st 2021 to June 30th 2025."),
        p("Data Columns:"),
        tags$ul(
          tags$li("video_id (chr) = Gives raw YouTube video ID. Generally not helpful to users."),
          tags$li("title (chr) = Video title as seen on YouTube."),
          tags$li("published_at (date) = Date of publication, format: Year-Month-Day (yyyy-mm-dd)."),
          tags$li("view_count (dbl) = Number of unique views associated to specific video."),
          tags$li("like_count (dbl) = Number of likes associated to specific video."),
          tags$li("comment_count (dbl) = Number of comments associated to specific video."),
          tags$li("tags (chr) = Tags associated with video as one comma-delineated string."),
          tags$li("category_id (dbl) = Youtube category IDs. 20 = 'Gaming', 10 = 'Music'."),
          tags$li("duration (chr) = Video duration in ISO 8601 format (PT1H1M8S = 1h 1m 8s).")
        ),
        p("Derived Columns:"),
        tags$ul(
          tags$li("engagement (dbl) = Ratio of engagment to views: Likes + Comments
                  / Views * 100 = % Audience Engagement for that Video"),
          tags$li("duration_min (date) = duration of video converted into minutes."),
          tags$li("duration_type (chr) = categories based on relative length (see sidebar). 
                  Groups were determined by examining the distribution of videos according to duration_min."),
          tags$li("year_month (date) = groups publication date by Month and Year.")
        )
      )
    )
  )
)




# Server
server = function(input, output) {
  # Reactive filtering
  filtered_data = reactive({
    data %>%
      filter(
        year_month >= input$date_range[1], #Slider
        year_month <= input$date_range[2], #Slider
        duration_type %in% input$duration_type #Duration checkbox
      )
  }) %>% debounce(500) # Doesn't compute until 0.5 sec after slider stops
  
  # Compute tables once for all metrics
  tables = reactive({
    lapply(metrics, function(metric) {
      table_metric(filtered_data(), metric, unique_tags)
    }) %>% setNames(metrics)
  })
  
  # Render plots
  lapply(metrics, function(metric) {
    output[[paste0("plot_", metric)]] = renderPlot({ #plots given metric name
      plot_metric(filtered_data(), metric)
    })
  })
  
  # Render tables
  lapply(metrics, function(metric) {
    output[[paste0("table_videos_", metric)]] = renderDT({
      datatable(
        tables()[[metric]]$videos,
        options = list(pageLength = 5, searching = FALSE, lengthChange = FALSE)
      )
    })
    output[[paste0("table_tags_", metric)]] = renderDT({
      datatable(
        tables()[[metric]]$tags,
        options = list(pageLength = 5, searching = FALSE, lengthChange = FALSE)
      )
    })
    output[[paste0("table_avg_", metric)]] = renderDT({
      datatable(
        tables()[[metric]]$average,
        options = list(pageLength = 1, searching = FALSE, lengthChange = FALSE,
                       paging = FALSE, info = FALSE)
      )
    })
  })
}

# Run app
shinyApp(ui, server)