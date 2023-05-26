pacman::p_load(shiny, # R shiny functions
       leaflet, # 
       sf, # 
       dplyr, #
       shinydashboard, #
       shinybusy, # 
       waiter, # 
       ggplot2, #
       ggthemes, # 
       RColorBrewer, #
       readxl # read data
       )

# Load data
#setwd("~/Library/Mobile Documents/com~apple~CloudDocs/Cognitive Science/6th_semester/spatial_analytics/DiscoverAarhus")
data <- read_excel("./data/cult_activities_aarhus.xls")
data$Latitude <- as.numeric(data$Latitude)
data$Longitude <- as.numeric(data$Longitude)


# Define UI
ui <- fluidPage(
    
    # Application title
    titlePanel("Cultural Activities in Aarhus"),
  
  # Add leaflet map
  leafletOutput("map"),
  
  # Add filter widgets
  selectInput("age_group", "Age group", choices = c("all", "children", "adults")),
  selectInput("category", "Activity category", choices = c("all","museum", "venue", "playground", "bylivshus")),
  selectInput("inside_outside", "Inside or Outside", choices = c("both", "inside", "outside"))
)

######### fluid page END

# Define server
server <- function(input, output) {
  
  # Create leaflet map
  output$map <- renderLeaflet({
    leaflet(data) %>%
      addTiles() %>%
      addMarkers(lat = ~Latitude, lng = ~Longitude,
        popup = paste( "Age group: ", data$group, "<br>",
                      "Category: ", data$Type)
      )
  })
  
  # Filter data based on user selections
  filtered_data <- reactive({
    data %>%
      filter(
        if (input$age_group != "all") data$group == input$age_group else TRUE,
        #if (input$category != "all") data$Type == input$category else TRUE,
        if (input$inside_outside != "both") data$inside_outside== input$inside_outside else TRUE
      )
  })
  
  
  
  # Construct colour palette from type of activity
  #load dataframe with unique color for each type of actvity
  pal <- colorFactor(unique(data$col_type), unique(data$Type)) 
  
  # Update map with filtered data
  observe({
    leafletProxy("map", data = filtered_data()) %>%
      clearMarkers() %>%
      addMarkers(lat = ~Latitude, lng = ~Longitude, #VIL GERNE HAVE MARKERS !
                 label = ~Placename,
                 popup = paste0("Placename: ", data$Placename,  "<br>",#vil gerne have med FED h2()
                                      "Type: ", data$Type,  "<br>",
                                      "Description: ", data$Description, "<br>")
      )
  })
  
}

#####PROBLEM: når man vælger BØRN og museums så crasher appen (for der findes ingen museer kun til børn)

# Run the app
shinyApp(ui, server)

