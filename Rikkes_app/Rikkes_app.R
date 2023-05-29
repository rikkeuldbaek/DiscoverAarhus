# Discover Aarhus using Shiny App
# Authors: Louise Brix Pilegaard Hansen and Rikke Uldbæk (202007501)
# Date: 7th of June 2023


######################### Load packages ###########################
pacman::p_load(shiny, # R shiny functions
       leaflet, # 
       waiter, # waiting screen package
       sf, # 
       tidyverse,
       dplyr, #
       shinybusy, # 
       RColorBrewer, # predefined colour palette
       readxl, # read data
       colourvalues # colour coding activities
       )

######################### Load data ###########################
setwd("~/Library/Mobile Documents/com~apple~CloudDocs/Cognitive Science/6th_semester/spatial_analytics/DiscoverAarhus")
#df <- read_excel("./data/cult_activities_aarhus.xls")
df <- read_excel("./data/DiscoverAarhus.xlsx")
df$latitude <- as.numeric(df$latitude)
df$longitude <- as.numeric(df$longitude)


df$col <- colour_values(df$type, palette = "rainbow_hcl")



# df <- df %>% 
#   mutate(color = case_when(str_detect(type, "Park/Garden") ~ "green",
#                            str_detect(type, "museum") ~ "red",
#                            TRUE ~ "a default"))


# Dataframe containing fun facts
text_for_waiting_screen <- data.frame(text= c("Let's discover Aarhus!",  "Are you ready?")) 

# Specifying details of waiting screen
waiting_screen <- tagList(
  spin_loaders(21), # define spinner
  h3(text_for_waiting_screen$text[1], style = "color:#FFFFFF;font-weight: 50;font-family: 'Helvetica Neue', Helvetica;font-size: 40px;"),
  h3(text_for_waiting_screen$text[2], style = "color:#FFFFFF;font-weight: 50;font-family: 'Helvetica Neue', Helvetica;font-size: 40px;"),

)


#COOOOOL SPINNERS!!!!
#https://shiny.john-coene.com/waiter/


#################### UI and server function ####################
# Define UI for application that draws a histogram
ui <- fluidPage(
    
  useWaiter(), #insert picture of aarhus #    "#99CCFF"


    # Application title
    titlePanel("Discover Aarhus"),

    # Sidebar
    sidebarLayout(
        sidebarPanel(
          
          
          # Text input
          helpText(h4("Welcome to the DiscoverAarhus app!"),
         "This app will help you find fun activities in Aarhus.",
         "Please use the filters to find your next fun activity."),
            
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
            
        ), #sidebar panel end

   mainPanel(
        # create map using leaflet
           leafletOutput(outputId = 'map'))
  
    ) #sidebar layoyt end
) #fluid page end




# Define server logic displaying the leaflet map appropriately 
server <- function(input, output, session) {
    
    
#
# Waiting screen
  waiter_show(html = waiting_screen, color = "#CC33FF")
    Sys.sleep(1) # display waiting screen for 8 seconds
    waiter_hide()
    

### ----------- reactive function for age group ----------- ### 
  AGE_GROUP_and_INSIDE_OUTSIDE <- reactive({
    filter(df, group == input$age_group | all_group == input$age_group)
  })

  observeEvent(AGE_GROUP_and_INSIDE_OUTSIDE(), {
    choices <- c(unique(AGE_GROUP_and_INSIDE_OUTSIDE()$indoor_outdoor),  unique(AGE_GROUP_and_INSIDE_OUTSIDE()$all_in_out))
    updateSelectInput(session, inputId = "indoor_outdoor", choices = choices, selected = unique(df$all_in_out)) 
  })
  
  
### ----------- reactive function for indoor/outdoor  ----------- ### 
  INSIDE_OUTSIDE_and_ACTIVITY_CATEGORY <- reactive({
    req(input$indoor_outdoor)
    filter(AGE_GROUP_and_INSIDE_OUTSIDE(), indoor_outdoor == input$indoor_outdoor | all_in_out== input$indoor_outdoor)
  })
  observeEvent(INSIDE_OUTSIDE_and_ACTIVITY_CATEGORY(), {
    choices <- c(unique(INSIDE_OUTSIDE_and_ACTIVITY_CATEGORY()$type),  unique(INSIDE_OUTSIDE_and_ACTIVITY_CATEGORY()$all_type))
    updateSelectInput(session, inputId = "activity_category", choices = choices, selected = unique(df$all_type))
  })
  
### ----------- reactive function for activity category ----------- ### 
 ACTIVITY_CATEGORY_end <- reactive({
     req(input$activity_category)
     filter(INSIDE_OUTSIDE_and_ACTIVITY_CATEGORY(), type == input$activity_category | all_type == input$activity_category)
   })
 
 

# Construct palette from type of activity
    #pal <- colorFactor(unique(data$col_type), unique(data$Type))  #DET HER SKAL IMPLEMENTERES NÅR VI HAR ALT DATA
    
 

 
# Leaflet map    
  output$map <- renderLeaflet({
    leaflet(ACTIVITY_CATEGORY_end()) %>%
      addTiles() %>%
      setView(lng = 10.2131012, lat = 56.1557451, zoom = 13) %>%
          addCircleMarkers(lat = ~latitude, lng = ~longitude,
                           #color = ~pal(Type), # determines color based on type of activity
                        color = df$col, #does the trick with unique colour coding (palettes are ugly)
                        #color =brewer.pal(length(unique(df$type)), name = "Dark2"),
                       radius = 7,
                       fillOpacity=0.8,
                       popup = paste0(" ", ACTIVITY_CATEGORY_end()$name,  "<br>",#vil gerne have med FED h2()
                                     " ", ACTIVITY_CATEGORY_end()$type,  "<br>",
                                  "  ", ACTIVITY_CATEGORY_end()$description, "<br>")) 
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

