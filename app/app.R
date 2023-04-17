



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


# Load the data of cultural activities in Aarhus 
data <- read_excel("./data/cult_activities_aarhus.xls")
data$Latitude <- as.numeric(data$Latitude)
data$Longitude <- as.numeric(data$Longitude)

# Define UI for application
ui <- fluidPage(

    # Application title
    titlePanel("Cultural Activities in Aarhus"),

    # Sidebar with a slider input for number of bins 
    sidebarLayout(
        
        # Sidebar Panel
        sidebarPanel(
            
            #fluid row for all filters
            fluidRow(
                #slider input 
                wellPanel(sliderInput("distance", #input name
                                           label = h4("Distance in meters"),
                                           min = 100,
                                           max = 7000,
                                           value = 500) #default start distance
                
            )),
            
            #select box for age group
                wellPanel(selectInput("age_group_select", #input name
                                      label = h4("Age group"),
                                      choices = list( "all" = "all",
                                                        "children" = "children",
                                                        "students" = "students",
                                                        "adults" = "adults"),
                                      selected = 1
            )),
            
            #select box for activity category
                wellPanel(selectInput("activity_category_select", #input name
                                      label= h4("Activity category"),
                                      choices = list(unique(data$Type) = unique(data$Type)),
                                      selected = 1
                                      ))
            
                
            # ADD ANOTHER WIDGET (husk intet komma efter sidste widget(som ovenståend))
            
            ), #fluid row parenthesis
        
        
            
        
        
        # Create main panel
        mainPanel(
        # create map using leaflet
           leafletOutput(outputId = 'map')
        )
    )
)



# Define server logic required to draw the map (contain the code used)
server <- function(input, output) {
    
    
    # Align CRS
    #data_sf<- st_as_sf(data, coords = c("longitude", "latitude"),crs = 4326)
    #data <- st_transform(data_sf, "+proj=utm +zone=42N +datum=WGS84 +units=km")
    
    map_df = reactive({

      data %>%
        count(Type, name = 'titles') %>%
        #left_join(coordinates_list, by = 'coverage_city')%>%
        filter(!is.na(data$Longitude) & !is.na(data$Latitude)) %>% # remove NA's
        st_as_sf(coords = c('lng', 'lat')) %>%
        st_set_crs(4326)
        #nb_sf <- st_as_sf(nb, coords = c("longitude", "latitude"), crs = 4326)
        #nb_crs <- st_transform(nb_sf, crs = 25832)

    })
    
    ########### MAPS MUST BE SAME CRS!!!!!!!!
    
    
    # Construct palette from type of activity
    pal <- colorFactor(unique(data$col_type), unique(data$Type)) 
    

    # The map!
    output$map = renderLeaflet({ #output$map betyder: vis kortet (map er defineret i ui.)
        #map displayed (den her kan ændres som man lyster)
          leaflet(data %>% 
                     dplyr::filter(group == input$age_group_select)) %>% # filters age group
            addTiles() %>%
            setView(lng = 10.2131012, lat = 56.1557451, zoom = 12) %>%  # start location on map
            addCircles(lat = ~Latitude, lng = ~Longitude, #VIL GERNE HAVE MARKERS !
                       label = ~Placename, 
                       color = ~pal(Type), # determines color based on type of activity
                       fillOpacity=0.4,
                       popup = paste0("Placename: ", data$Placename,  "<br>",#vil gerne have med FED h2()
                                      "Type: ", data$Type,  "<br>",
                                      "Description: ", data$Description, "<br>"))
        ##########PROBLEM!!!! den viser descriptions baseret på hvilket filter du har brugt!!!!!!!!!
        #så hvis du vælger børn så er det børne description i alle points
        
            #addMarkers(lat = ~Latitude, lng = ~Longitude,
            #           popup = paste0("Placename: ", Placename,  "<br>",
            #                          "Type: ", Type,
            #                         "Description: ", Description, "<br>"))
            #addMarkers(lng = data$Longitude, 
            # lat = data$Latitude,
            # popup = data$Description)

    })
    


}

# Run the application 
shinyApp(ui,server)

