# Discover Aarhus using Shiny App
# Authors: Louise Brix Pilegaard Hansen (202006093) and Rikke Uldbæk (202007501)
# Date: 7th of June 2023


######################### Load packages ###########################
 pacman::p_load(shiny, # R shiny functions
        leaflet, # map package
        waiter, # waiting screen package
        tidyverse, #data wrangling
        dplyr, # data wrangling
        readxl, # read data
        fontawesome # specify icons in logos
        )


######################### Load data ###########################
df <- read_csv("./data/DiscoverAarhusData.csv")


################### Predefining variables #####################
# predefined logos with colors for markers
logos <- awesomeIconList(
  "Beach" = makeAwesomeIcon(
    text= fa("umbrella-beach"),
    markerColor = "beige",
    iconColor = "#f5f5f7",
    library = "fa"
  ),
  "Church" = makeAwesomeIcon(
    text = fa("church"),
    markerColor = "white",
    iconColor = "#111112",
    library = "fa"
  ),
  "Cinema" = makeAwesomeIcon(
    icon = "film",
    markerColor = "red",
    iconColor = "#f5f5f7",
    library = "fa"
  ),
  "Entertainment" = makeAwesomeIcon(
    text= fa("icons"),
    markerColor = "orange",
    iconColor = "#f5f5f7",
    library = "fa"
  ),
  "Marina" = makeAwesomeIcon(
    icon = "anchor",
    markerColor = "darkblue",
    iconColor = "#f5f5f7",
    library = "fa"
  ),
  "Museum" = makeAwesomeIcon(
    text = fa("building-columns"),
    markerColor = "purple",
    iconColor = "#f5f5f7",
    library = "fa"
  ),
  "Park" = makeAwesomeIcon(
    text = fa("cloud-sun"),
    markerColor = "lightgreen",
    iconColor = "#f5f5f7",
    library = "fa"
  ),
  "Sport and fitness" = makeAwesomeIcon(
    text = fa("person-running"),
    markerColor = "lightblue",
    iconColor = "#f5f5f7",
    library = "fa"
  ),
  "Theater" = makeAwesomeIcon(
    text= fa("masks-theater"),
    markerColor = "darkpurple",
    iconColor = "#f5f5f7",
    library = "fa"
  ),
  "Venue" = makeAwesomeIcon(
    icon = "music",
    markerColor = "black",
    iconColor = "#f5f5f7",
    library = "fa"
  ),
  "Library" = makeAwesomeIcon(
    text = fa("book"),
    markerColor = "lightgray",
    iconColor = "#111112",
    library = "fa"
  ),
  "Forest" = makeAwesomeIcon(
    text = fa("tree"),
    markerColor = "darkgreen",
    iconColor = "#f5f5f7",
    library = "fa"
  ),
  "Nature facilities" = makeAwesomeIcon(
    text = fa("campground"),
    markerColor = "lightred",
    iconColor = "#f5f5f7",
    library = "fa"
  ),
  "Playground" = makeAwesomeIcon( 
    text = fa("puzzle-piece"),
    markerColor = "pink",
    iconColor = "#f5f5f7",
    library = "fa"
  ),
   "Other" = makeAwesomeIcon( 
    icon = "compass",
    markerColor = "gray",
    iconColor = "#f5f5f7",
    library = "fa"
  )
)
 


# Text for waiting screen
text_for_waiting_screen <- data.frame(text= c("Let's discover Aarhus!",  "Are you ready?")) 

# Define spinner and text for waiting screen
waiting_screen <- tagList(
  spin_loaders(21), # define spinner
  h3(text_for_waiting_screen$text[1], style = "color:#FFFFFF;font-weight: 50;font-family: 'Helvetica Neue', Helvetica;font-size: 30px;"),
  h3(text_for_waiting_screen$text[2], style = "color:#FFFFFF;font-weight: 50;font-family: 'Helvetica Neue', Helvetica;font-size: 30px;"),
)



#################### UI and server function ####################
# Define UI for application that draws a histogram
ui <- fluidPage(
  
  # Initialize waiter
  useWaiter(),


    # Application title
    titlePanel("DiscoverAarhus"),

    # Sidebar
    sidebarLayout(
        sidebarPanel(
          
          
          # Text input
          helpText(h4("Welcome to the DiscoverAarhus app!"),
         "This app will help you explore fun activities in Aarhus.",
         "Please use the filters to find your next activity."),
            
            # select input age group
            selectInput("age_group",
                        "Select age group:",
                        choices = c(unique(df$group), unique(df$all_group)),
                        selected = unique(df$all_group)),
            
            # select input for indoor or outdoor activity
            selectInput("indoor_outdoor",
                        "Select indoor or outdoor activity:",
                        choices = c(unique(df$indoor_outdoor), unique(df$all_in_out)),
                        selected = unique(df$all_in_out)),
            
            # select input for activity category
            selectInput("activity_category",
                        "Select activity category:",
                        choices = c(unique(df$type), unique(df$all_type)),
                        selected =unique(df$all_type))
            
        ),

        
  # Main panel - map output      
   mainPanel(
        # create map using leaflet
           leafletOutput(outputId = 'map'))
  
    )
)





# Define server logic displaying the leaflet map appropriately 
server <- function(input, output, session) {
    
    
# Waiting screen
  waiter_show(html = waiting_screen,
              image = "https://media.cnn.com/api/v1/images/stellar/prod/190410133420-01-aarhus-denmark.jpg?q=x_0,y_0,h_2772,w_4926,c_fill/h_720,w_1280/f_webp")
    Sys.sleep(8) # display waiting screen for 8 seconds
    waiter_hide()
    

### ----------- reactive function for age group ----------- ### 
  AGE_GROUP_and_INSIDE_OUTSIDE <- reactive({
    filter(df, group == input$age_group | all_group == input$age_group)
  })

  observeEvent(AGE_GROUP_and_INSIDE_OUTSIDE(), {
    choices <- c(unique(AGE_GROUP_and_INSIDE_OUTSIDE()$indoor_outdoor),  unique(AGE_GROUP_and_INSIDE_OUTSIDE()$all_in_out)) #define new select options based on filter
    updateSelectInput(session, inputId = "indoor_outdoor", choices = choices, selected = unique(df$all_in_out))  # update select input widget
  })
  
  
### ----------- reactive function for indoor/outdoor  ----------- ### 
  INSIDE_OUTSIDE_and_ACTIVITY_CATEGORY <- reactive({
    req(input$indoor_outdoor)
    filter(AGE_GROUP_and_INSIDE_OUTSIDE(), indoor_outdoor == input$indoor_outdoor | all_in_out== input$indoor_outdoor)
  })
  observeEvent(INSIDE_OUTSIDE_and_ACTIVITY_CATEGORY(), {
    choices <- c(sort(unique(INSIDE_OUTSIDE_and_ACTIVITY_CATEGORY()$type)),  unique(INSIDE_OUTSIDE_and_ACTIVITY_CATEGORY()$all_type)) #define new select options based on filter
    updateSelectInput(session, inputId = "activity_category", choices = choices, selected = unique(df$all_type)) # update select input widget
  })
  
### ----------- reactive function for activity category ----------- ### 
 ACTIVITY_CATEGORY_end <- reactive({
     req(input$activity_category)
     filter(INSIDE_OUTSIDE_and_ACTIVITY_CATEGORY(), type == input$activity_category | all_type == input$activity_category) 
   })
 
 

 
# Leaflet map    
  output$map <- renderLeaflet({
    leaflet(ACTIVITY_CATEGORY_end()) %>%
      addTiles() %>%
      setView(lng = 10.2131012, lat = 56.1557451, zoom = 13) %>%
      addAwesomeMarkers(lat = ~latitude, lng = ~longitude, icon= ~ logos[ACTIVITY_CATEGORY_end()$type],
                        popup= paste(paste("<h4>", ACTIVITY_CATEGORY_end()$name, "</h4>"),
                                   paste("<strong>",ACTIVITY_CATEGORY_end()$type, "</strong>"), "<br>",
                                   paste("<em>",ACTIVITY_CATEGORY_end()$description, "</em>"))
                        )
    
  })
}


# Run the application 
shinyApp(ui = ui, server = server)


