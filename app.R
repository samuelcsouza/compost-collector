suppressMessages({
  library(shiny)
  library(shinydashboard)
  library(shinycssloaders)
  library(shinyjs)
  library(dplyr)
  library(leaflet)
  library(leaflet.extras)
  library(htmltools)
  library(DT)
  library(plotly)
  library(stringr)
  library(pool)
  library(RPostgreSQL)
  library(nominatimlite)
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
  
  shinyjs::useShinyjs(),
  
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
      text    = "Gerenciamento",
      tabName = "gerenciamento",    
      icon    = icon('gears', verify_fa = FALSE)
    )
    
  )
)

body <- dashboardBody(
  tabItems(
    
    tabItem(tabName = "home", inicio_ui('home')),
    tabItem(tabName = "mapa", map_ui('mapa')),
    tabItem(tabName = 'gerenciamento', gerenciamento_ui('gerenciamento'))
    
  )
)

ui <- dashboardPage(
  title = "PI - UNIVESP",
  dashboardHeader(title = tags$a(tags$img(src = 'https://lh4.googleusercontent.com/dZUO6fz4YHh3TD4DzAy-vqNw46KdnnXny5RriKj4LKn6C_rXdJwFl2PRgYJriZhIn7HWst4SCnIU6mAmo9ep7GdZd_f022xo3o_ewwcei94acA1lBbXNH00aG_GcmoIwlQ=w8188', 
                                          width = "95%", style = "margin-bottom: 10px;"))), 
  sidebar, 
  body,
  skin = 'black'
)

server <- function(input, output, session) {
  
  callModule(map_server, 'mapa')
  callModule(gerenciamento_server, 'gerenciamento')
  
}

shiny::onStop(close_connection)

shinyApp(ui, server)
