source("logic.R")

library(shiny)
library(leaflet)

data <- fread("parsed/ships.csv")

ui <- fluidPage(
  titlePanel("Longest distance observation"),
  sidebarLayout(
    sidebarPanel(
      selectizeInput(inputId="ship_type", 
                label = "Vessel type:", 
                choices = unique(data$SHIP_TYPE),
                options = list(placeholder = 'Please select',
                                onInitialize = I('function() { this.setValue(""); }'))
            ),

      selectizeInput(inputId="ship_id",
                label = "Vessel name:", 
                choices = list("None" = NA),
                options = list(placeholder = 'Please select type first')
            ),
    ),

    mainPanel(
      leafletOutput("map"),
      br(),
      textOutput("info")
    )
  )
)

server <- function(input, output, session) {
    observation <- reactive( {
        get_observation_by_id(data,input$ship_id)}
    )

    output$info <- renderText({
        paste("The vessel ", 
              observation()$ship_name,
              " sailed ",
              observation()$distance, "m",
              " in ", observation()$tbm, "s") 
    })

    observeEvent(input$ship_type, {
        updateSelectInput(session = session,
                        inputId="ship_id",
                        choices=get_ships_by_type(data, input$ship_type))
    })
    output$map <- renderLeaflet({
        leaflet() %>%
        addProviderTiles(providers$Stamen.TonerLite,
              options = providerTileOptions(noWrap = TRUE)
        ) %>%
        addMarkers(data = observation()$positions, label=c("start","end"))
    })
}
options(shiny.port = 8000, display.mode = "showcase")
shinyApp(ui = ui, server = server)