map_ui <- function(id){
  ns <- NS(id)
  
  fluidPage(
    
    leaflet::leafletOutput(
      outputId = ns('main_map'),
      width = '100%',
      height = '90vh'
    ) %>% withSpinner(type = 4, color = 'red')
    
  )
  
}

map_server <- function(input, output, session){
  
  ns <- session$ns
  
  dataset <- data.frame(
    lat = c(-23.05034156974224,
            -23.01937860955801,
            -23.23508040975259),
    lng = c(-45.60461799853394,
            -45.582645341792244,
            -45.89840288397144),
    name = c('Via Vale Garden Shopping',
             'Taubaté Shopping',
             'Shopping Jardim Oriente'),
    address = c('Av. Dom Pedro I, 7181 - Res. Estoril, Taubaté - SP, 12091-000',
                'Av. Charles Schnneider, 1700 - Vila Costa, Taubaté - SP, 12040-900',
                'R. Andorra, 500 - Jardim America, São José dos Campos - SP, 12235-050')
  )
  
  
  
  output$main_map <- renderLeaflet({
    
    leaflet() %>% 
      
      addTiles() %>%
      
      setView(lng = -45.50709, lat = -23.05067, zoom = 11) %>% 
      
      setMaxBounds(lng1 = 39.02344, 
                   lat1 = 28.92163, 
                   lng2 = -163.125, 
                   lat2 = -59.88894) %>% 
      
      leaflet.extras::addFullscreenControl() %>% 
      
      addMarkers(data = dataset,
                 lat = ~ lat,
                 lng = ~ lng,
                 icon = leaflet::makeIcon(iconUrl = 'www/assets/recycle.svg',
                                          iconWidth = 25,
                                          iconHeight = 43,
                                          iconAnchorX = 22, 
                                          iconAnchorY = 38,
                                          shadowUrl = "www/assets/marker-shadow.png"),
                 label = ~ paste0('<b>', name, '</b>',
                                  '</br>', address,
                                  '</br></br><b>Clique para mais detalhes!</b>') %>% lapply(htmltools::HTML),
                 labelOptions = labelOptions(textsize = "14px"),
                 group = 'markers',
                 layerId = ~ name,
                 clusterOptions = leaflet::markerClusterOptions())
    
  })
  
  
  
  observeEvent(input$main_map_marker_click, {
    
    id <- input$main_map_marker_click$id
    
    entity <- dataset %>% 
      dplyr::filter(name == id)
    
    showModal(
      modalDialog(
        title = 'Ponto de Coleta',
        size = 'l',
        fade = TRUE,
        easyClose = TRUE,
        footer = modalButton(label = "", icon = icon("fas fa-times")),
        
        fluidPage(
          
          div(
            align = 'center',
            
            img(
              src = 'https://cdn-icons-png.flaticon.com/512/892/892930.png',
              height = '70px',
              width = '70px'
            ),
            
            br(), br(),
            
            h3(entity$name),
            tags$i(entity$address),
            
            
            br(), br(),
            
            htmltools::HTML('<b>Publicado em 14/03/2023</b>')
            
          )
        )
      )
    )
    
  })
  
}
