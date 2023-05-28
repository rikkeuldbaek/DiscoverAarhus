# Discover Aarhus using Shiny App
# Authors: Louise Brix Pilegaard Hansen and Rikke Uldbæk (202007501)
# Date: 7th of June 2023


######################### Load packages ###########################
pacman::p_load(shiny, # R shiny functions
       leaflet, # 
       waiter, # waiting screen package
       sf, # 
       dplyr, #
       shinybusy, # 
       RColorBrewer, # predefined colour palette
       readxl # read data
       )

######################### Load data ###########################
setwd("~/Library/Mobile Documents/com~apple~CloudDocs/Cognitive Science/6th_semester/spatial_analytics/DiscoverAarhus")
df <- read_excel("./data/cult_activities_aarhus.xls")
df$latitude <- as.numeric(df$latitude)
df$longitude <- as.numeric(df$longitude)




# Dataframe containing fun facts
text_for_waiting_screen <- data.frame(text= c("Let's discover Aarhus!",  "Are you ready?")) 

# Specifying details of waiting screen
waiting_screen <- tagList(
  spin_loaders(21), # define spinner
  h3(sample(text_for_waiting_screen$text[1], 1), style = "color:#FFFFFF;font-weight: 100;font-family: 'Helvetica Neue', Helvetica;font-size: 27px;"),
  h3(sample(text_for_waiting_screen$text[2], 1), style = "color:#FFFFFF;font-weight: 100;font-family: 'Helvetica Neue', Helvetica;font-size: 27px;"),

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
    
    
#
# Waiting screen
  waiter_show(html = waiting_screen, color = "#CC33FF")
    Sys.sleep(5) # spin for 2 seconds
    waiter_hide()
    
 # call the waiter function (RIKKES TAKE)
  #w <- Waiter$new()
  #w$show() #show waiter
  #Sys.sleep(2) # spin for 2 seconds
  #w$hide() # hide when waiter is done
  

    

### ----------- reactive function for age group ----------- ### 
  AGE_GROUP_and_INSIDE_OUTSIDE <- reactive({
    filter(df, group == input$age_group | all_group == input$age_group)
  })

  observeEvent(AGE_GROUP_and_INSIDE_OUTSIDE(), {
    choices <- c(unique(AGE_GROUP_and_INSIDE_OUTSIDE()$inside_outside),  unique(AGE_GROUP_and_INSIDE_OUTSIDE()$all_in_out))
    updateSelectInput(session, inputId = "inside_outside", choices = choices, selected = unique(df$all_in_out)) 
  })
  
  
### ----------- reactive function for indoor/outdoor  ----------- ### 
  INSIDE_OUTSIDE_and_ACTIVITY_CATEGORY <- reactive({
    req(input$inside_outside)
    filter(AGE_GROUP_and_INSIDE_OUTSIDE(), inside_outside == input$inside_outside | all_in_out== input$inside_outside)
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
                        color = brewer.pal(n = 6, name = "Dark2"),
                       radius = 7,
                       fillOpacity=0.8,
                       popup = paste0(" ", ACTIVITY_CATEGORY_end()$placename,  "<br>",#vil gerne have med FED h2()
                                     " ", ACTIVITY_CATEGORY_end()$type,  "<br>",
                                  "  ", ACTIVITY_CATEGORY_end()$description, "<br>")) 
  })
}

# Run the application 
shinyApp(ui = ui, server = server)

