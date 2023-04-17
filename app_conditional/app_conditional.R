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
data <- read_excel("./data/cult_activities_aarhus.xls")
data$Latitude <- as.numeric(data$Latitude)
data$Longitude <- as.numeric(data$Longitude)
ls.str(data)


# Define UI
ui <- fluidPage(
  
  # Add leaflet map
  leafletOutput("map"),
  
  # Add filter widgets
  selectInput("age_group", "Age group", choices = c("all", "children", "adults")),
  selectInput("category", "Activity category", choices = c("museum", "venue", "playground", "bylivshus"))
  
)

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
        if (input$age_group != "All") data$group == input$age_group else TRUE,
        if (input$category != "All") data$Type == input$category else TRUE
      )
  })
  
  # Update map with filtered data
  observe({
    leafletProxy("map", data = filtered_data()) %>%
      clearMarkers() %>%
      addMarkers(lat = ~Latitude, lng = ~Longitude,
        popup = paste("Age group: ", data$group, "<br>",
                      "Category: ", data$Type)
      )
  })
  
}

# Run the app
shinyApp(ui, server)
