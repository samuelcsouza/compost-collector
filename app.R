suppressMessages({
  library(shiny)
  library(shinydashboard)
  library(dplyr)
  library(leaflet)
  library(leaflet.extras)
})

sapply(
  list.files(path = "modules/", full.names = TRUE, recursive = TRUE),
  source
)

sapply(
  list.files(path = "functions/", full.names = TRUE, recursive = TRUE),
  source
)


sidebar <- dashboardSidebar(
  
  sidebarMenu(
    
    menuItem(
      text    = "Início",
      tabName = "home",    
      icon    = icon("home")
    ),
    
    menuItem(
      text    = "Mapa",
      tabName = "mapa",    
      icon    = icon("fas fa-map-marked-alt")
    ),
    
    menuItem(
      text    = "Estatísticas",
      tabName = "dados",    
      icon    = icon("chart-line")
    )
    
  )
)

body <- dashboardBody(
  tabItems(
    
    tabItem(tabName = "home", fluidPage('home')),
    tabItem(tabName = "mapa", fluidPage('mapa')),
    tabItem(tabName = "dados", fluidPage('dados'))
    
  )
)

ui <- dashboardPage(
  title = "PI - UNIVESP",
  dashboardHeader(title = tags$a(tags$img(src = '/assets/univesp.png', 
                                          width = "75%", style = "margin-bottom: 10px;"))), 
  sidebar, 
  body,
  skin = 'black'
)

server <- function(input, output, session) {
  
  
}

shinyApp(ui, server)
