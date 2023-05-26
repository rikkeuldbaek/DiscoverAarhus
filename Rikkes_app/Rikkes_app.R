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
setwd("~/Library/Mobile Documents/com~apple~CloudDocs/Cognitive Science/6th_semester/spatial_analytics/DiscoverAarhus")
df <- read_excel("./data/cult_activities_aarhus.xls")
df$latitude <- as.numeric(df$latitude)
df$longitude <- as.numeric(df$longitude)



# Define UI for application that draws a histogram
ui <- fluidPage(

    # Application title
    titlePanel("Discover Aarhus"),

    # Sidebar
    sidebarLayout(
        sidebarPanel(
            
            #select input age group
            selectInput("age_group",
                        "Select age group:",
                        choices = c(unique(df$group), unique(df$all_group)),
                        selected = unique(df$all_group)),
            
            #select input for indoor or outdoor activity
            selectInput("inside_outside",
                        "Select indoor or outdoor activity:",
                        choices = c(unique(df$inside_outside), unique(df$all_in_out)),
                        selected = unique(df$all_in_out)),
            
            #select input for activity category
            selectInput("activity_category",
                        "Select activity category:",
                        choices = c(unique(df$type), unique(df$all_type)),
                        selected =unique(df$all_type))
            
        ), #sidebar panel end

   mainPanel(
        # create map using leaflet
           leafletOutput(outputId = 'map'))
  
    ) #sidebar layoyt end
) #fluid page end





# Define server logic required to draw a histogram
server <- function(input, output, session) {

  AGE_GROUP_and_INSIDE_OUTSIDE <- reactive({
    filter(df, group == input$age_group | all_group == input$age_group)
  })

  observeEvent(AGE_GROUP_and_INSIDE_OUTSIDE(), {
    choices <- c(unique(AGE_GROUP_and_INSIDE_OUTSIDE()$inside_outside),  unique(AGE_GROUP_and_INSIDE_OUTSIDE()$all_in_out))
    updateSelectInput(session, inputId = "inside_outside", choices = choices) 
  })
  
  
  
  INSIDE_OUTSIDE_and_ACTIVITY_CATEGORY <- reactive({
    req(input$inside_outside)
    filter(AGE_GROUP_and_INSIDE_OUTSIDE(), inside_outside == input$inside_outside | all_in_out== input$inside_outside)
  })
  observeEvent(INSIDE_OUTSIDE_and_ACTIVITY_CATEGORY(), {
    choices <- c(unique(INSIDE_OUTSIDE_and_ACTIVITY_CATEGORY()$type),  unique(INSIDE_OUTSIDE_and_ACTIVITY_CATEGORY()$all_type))
    updateSelectInput(session, inputId = "activity_category", choices = choices)
  })
  
 ACTIVITY_CATEGORY_end <- reactive({
     req(input$activity_category)
     filter(INSIDE_OUTSIDE_and_ACTIVITY_CATEGORY(), type == input$activity_category | all_type == input$activity_category)
   })
 
#   observeEvent(ACTIVITY_CATEGORY_end(), {
#     choices <- c(unique(ACTIVITY_CATEGORY_end()$type), unique(ACTIVITY_CATEGORY_end()$all_type))
#     updateSelectInput(session, inputId = "activity_category", choices = choices)
#   })


    
    
    
  output$map <- renderLeaflet({
    leaflet(ACTIVITY_CATEGORY_end()) %>%
      addTiles() %>%
      setView(lng = 10.2131012, lat = 56.1557451, zoom = 13) %>%
      addMarkers(lat = ~latitude, lng = ~longitude, label = ~placename)
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

