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



ui <- fluidPage(
  
  # 1st widget (agegroup)
  selectInput(
    inputId = "age_group",
    label = "Select age group",
    choices = c("both children and adults","only children", "only adults", "Show all"),
    selected = "Show all"
  ),
  
  #conditional panel for CHILDREN (if children, create checkbox)
  conditionalPanel(
    condition = "input.age_group == 'Show all'",
    selectInput(
      inputId = "inside_outside_all",
      label = "Inside or Outside",
      choices = c("inside", "outside", "Show all"),
      selected = "Show all",
      multiple = FALSE
    )
  ),
  
  #conditional panel for ADULTS (if adults, create checkbox)
  conditionalPanel(
    condition = "input.age_group == 'only adults'",
    selectInput(
      inputId = "inside_outside_adults",
      label = "Inside or Outside",
      choices = c("inside", "outside", "Show all"),
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
      choices = c("inside", "outside", "Show all"),
      selected = "Show all",
      multiple = FALSE
    )
  ),
  
  #conditional panel for both (if both, create checkbox)
  conditionalPanel(
    condition = "input.age_group == 'both children and adults'",
    selectInput(
      inputId = "inside_outside_both",
      label = "Inside or Outside",
      choices = c("inside", "outside", "Show all"),
      selected = "Show all",
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
      choices = c(unique(df$type), unique(df$all)),
      selected = "Show all"
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
    } else if (input$age_group == 'Show all'){
      df <- df[df$all == input$age_group, ] #filter "Show all"
    }

    # #filter function per age group and inside/outside
    if (input$age_group == 'both children and adults' & !is.null(input$inside_outside_both)) { # inside_outside_both conditional widget
      df<- df[df$inside_outside == input$inside_outside_both | df$all == input$inside_outside_both, ] # filter inside/outside/all
    }else if (input$age_group == 'Show all' & !is.null(input$inside_outside_all)) { # inside_outside_all conditional widget
      df<- df[df$inside_outside == input$inside_outside_all | df$all == input$inside_outside_all, ]  # filter inside/outside/all
    }else if (input$age_group == 'only adults' & !is.null(input$inside_outside_adults)) { # inside_outside_adults conditional widget
      df<- df[df$inside_outside == input$inside_outside_adults | df$all == input$inside_outside_adults, ] # filter inside/outside/all
    }else if (input$age_group == 'only children' & !is.null(input$inside_outside_children)) { # inside_outside_children conditional widget
      df<- df[df$inside_outside == input$inside_outside_children | df$all == input$inside_outside_children, ] # filter inside/outside/all
    }
    
    #filter function for activity category
    if (input$inside_outside_both == 'inside' || input$inside_outside_both ==  "outside" ||  input$inside_outside_both == "Show all" & !is.null(input$activity_category)) { # inside_outside_both conditional widget
      df<- df[df$type == input$activity_category| df$all == input$activity_category, ] 
    } #filter function for activity category
    if (input$inside_outside_all == 'inside' || input$inside_outside_all == "outside" || input$inside_outside_all == "Show all" & !is.null(input$activity_category)) { # inside_outside_bo conditional widget
      df<- df[df$type == input$activity_category| df$all == input$activity_category, ] 
    } #filter function for activity category
    if (input$inside_outside_children == 'inside' || input$inside_outside_children == "outside" || input$inside_outside_children == "Show all" & !is.null(input$activity_category)) { # inside_outside_both conditional widget
      df<- df[df$type == input$activity_category| df$all == input$activity_category, ] 
    }#filter function for activity category
    if (input$inside_outside_adults == 'inside' || input$inside_outside_adults ==  "outside" || input$inside_outside_adults == "Show all" & !is.null(input$activity_category)) { # inside_outside_both conditional widget
      df<- df[df$type == input$activity_category| df$all == input$activity_category, ] 
    }
    
    
    ##########WORKS men vil bare gerne have at den kun displayer de categorier der er tilgængelige givet conditions:
    # fx "both children and adults" + "inside" = "museum" og "bylivshus" og "all" (som er begge), men de andre 
    # kategorier er som valgmuligheder stadig
    


    #return
    df
    
    
    })#end eventReactive function
  
  #update activity category
  #observeEvent(filtered_data(){
  #  choices <- c(unique(filtered_data()$type), unique(filtered_data()$all))
  #  print(choices)
  #  updateSelectInput(inputId = "activity_category", choices = choices) 
  #})
  
  #new reactive function using 
  new_filtered_data <- reactive({
    req(input$activity_category)
    filter(filtered_data(), new_filtered_data()$type == input$activity_category)
  })
  
  #observe
  observeEvent(new_filtered_data(), {
    choices <- unique(new_filtered_data()$type)
    updateSelectInput(inputId = "activity_category", choices = choices)
  })
    
      
  
  
   
  # Render the map with markers for the cultural activities
  output$map <- renderLeaflet({
    leaflet(new_filtered_data()) %>%
      addTiles() %>%
      setView(lng = 10.2131012, lat = 56.1557451, zoom = 13) %>%
      addMarkers(lat = ~latitude, lng = ~longitude, label = ~placename)
  })
  
  
}


# Run the app
shinyApp(ui, server)

