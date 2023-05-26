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
df$Latitude <- as.numeric(df$Latitude)
df$Longitude <- as.numeric(df$Longitude)



ui <- fluidPage(
  
  # 1st widget (agegroup)
  selectInput(
    inputId = "age_group",
    label = "Select age group",
    choices = c("both children and adults","only children", "only adults", "show all"),
    selected = "show all"
  ),
  
  #conditional panel for CHILDREN (if children, create checkbox)
  conditionalPanel(
    condition = "input.age_group == 'show all'",
    selectInput(
      inputId = "inside_outside_all",
      label = "Inside or Outside",
      choices = c("inside", "outside", "all"),
      selected = "all",
      multiple = FALSE
    )
  ),
  
  #conditional panel for ADULTS (if adults, create checkbox)
  conditionalPanel(
    condition = "input.age_group == 'only adults'",
    selectInput(
      inputId = "inside_outside_adults",
      label = "Inside or Outside",
      choices = c("inside", "outside", "all"),
      selected = "all",
      multiple = FALSE
    )
  ),
  
  #conditional panel for CHILDREN (if all, create checkbox)
  conditionalPanel(
    condition = "input.age_group == 'only children'",
    selectInput(
      inputId = "inside_outside_children",
      label = "Inside or Outside",
      choices = c("inside", "outside", "all"),
      selected = "all",
      multiple = FALSE
    )
  ),
  
  #conditional panel for both (if both, create checkbox)
  conditionalPanel(
    condition = "input.age_group == 'both children and adults'",
    selectInput(
      inputId = "inside_outside_both",
      label = "Inside or Outside",
      choices = c("inside", "outside", "all"),
      selected = "all",
      multiple = FALSE
    )
  ), #conditional panels end
  
  
  #conditional panel for ACTIVITY CATEGORY
  #conditionalPanel(
    #condition = "input.inside_outside_both == 'inside' || input.inside_outside_both == 'outside' || input.inside_outside_both == 'all' || input.inside_outside_all == 'inside' || input.inside_outside_all == 'outside' || input.inside_outside_all == 'all'",
    #condition =  "input.inside_outside_both == 'inside'",
    selectInput(
      inputId = "activity_category",
      label = "Activity Category",
      choices = c(unique(df$Type), unique(df$Type_all)),
      selected = "all"
    ),
    
  #),

  
  mainPanel(
        # create map using leaflet
           leafletOutput(outputId = 'map')
        )
  
)#FLUID PAGE END



server <- function(input, output) {
  
  filtered_data <- reactive({  
    
    #filter function per age group
    if (input$age_group == 'both children and adults') {
     df <- df[df$group == input$age_group, ] #filter "both children and adults"
    } else if (input$age_group == 'only adults'){
      df <- df[df$group == input$age_group, ] #filter "only adults"
    } else if (input$age_group == 'only children'){
      df <-df[df$group == input$age_group, ] #filter "only children "
    } else if (input$age_group == 'show all'){
      df <- df[df$group_all == input$age_group, ] #filter "show all"
    }

    # #filter function per age group and inside/outside
    if (input$age_group == 'both children and adults' & !is.null(input$inside_outside_both)) { # inside_outside_both conditional widget
      df<- df[df$inside_outside == input$inside_outside_both | df$in_out_all == input$inside_outside_both, ] # filter inside/outside/all
    }else if (input$age_group == 'show all' & !is.null(input$inside_outside_all)) { # inside_outside_all conditional widget
      df<- df[df$inside_outside == input$inside_outside_all | df$in_out_all == input$inside_outside_all, ]  # filter inside/outside/all
    }else if (input$age_group == 'only adults' & !is.null(input$inside_outside_adults)) { # inside_outside_adults conditional widget
      df<- df[df$inside_outside == input$inside_outside_adults | df$in_out_all == input$inside_outside_adults, ] # filter inside/outside/all
    }else if (input$age_group == 'only children' & !is.null(input$inside_outside_children)) { # inside_outside_children conditional widget
      df<- df[df$inside_outside == input$inside_outside_children | df$in_out_all == input$inside_outside_children, ] # filter inside/outside/all
    }
    
    #filter function for activity category
    if (input$inside_outside_both == 'inside' | input$inside_outside_both ==  "outside" |  input$inside_outside_both == "all" & !is.null(input$activity_category)) { # inside_outside_both conditional widget
      df<- df[df$Type == input$activity_category| df$Type_all == input$activity_category, ] 
    }
    #filter function for activity category
    if (input$inside_outside_all == 'inside' | input$inside_outside_all == "outside" | input$inside_outside_all == "all" & !is.null(input$activity_category)) { # inside_outside_bo conditional widget
      df<- df[df$Type == input$activity_category| df$Type_all == input$activity_category, ] 
    }
    #filter function for activity category
    if (input$inside_outside_children == 'inside' | input$inside_outside_children == "outside" | input$inside_outside_children == "all" & !is.null(input$activity_category)) { # inside_outside_both conditional widget
      df<- df[df$Type == input$activity_category| df$Type_all == input$activity_category, ] 
    }
    #filter function for activity category
    if (input$inside_outside_adults == 'inside' |input$inside_outside_adults ==  "outside" | input$inside_outside_adults == "all" & !is.null(input$activity_category)) { # inside_outside_both conditional widget
      df<- df[df$Type == input$activity_category| df$Type_all == input$activity_category, ] 
    }
    
    
    ##########WORKS men vil bare gerne have at den kun displayer de categorier der er tilgængelige givet conditions:
    # fx "both children and adults" + "inside" = "museum" og "bylivshus" og "all" (som er begge), men de andre 
    # kategorier er som valgmuligheder stadig
    


    #return
    df
    
    
    })#end eventReactive function
  
  #update activity category
  observeEvent(filtered_data(){
    choices <- c(unique(filtered_data()$Type), unique(filtered_data()$Type_all))
    print(choices)
    updateSelectInput(inputId = "activity_category", choices = choices) 
  })
    
      
  
  
   
  # Render the map with markers for the cultural activities
  output$map <- renderLeaflet({
    leaflet(filtered_data()) %>%
      addTiles() %>%
      setView(lng = 10.2131012, lat = 56.1557451, zoom = 13) %>%
      addMarkers(lat = ~Latitude, lng = ~Longitude, label = ~Placename)
  })
  
  
}


# Run the app
shinyApp(ui, server)

