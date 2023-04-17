map_ui <- function(id){
  ns <- NS(id)
  
  fluidPage(
    
    leaflet::leafletOutput(
      outputId = ns('main_map'),
      width = '100%',
      height = '90vh'
    ) %>% withSpinner(type = 4, color = 'red'),
    
    hr(),
    
    div(
      align = 'center',
      
      actionButton(
        inputId = ns('update_map'),
        label = 'Atualizar Mapa'
      )
    )
    
  )
  
}

map_server <- function(input, output, session){
  
  ns <- session$ns
  
  # # # # Render # # # #
  output$main_map <- renderLeaflet({
    
    query <- "
      SELECT 
      	pc.id_posto AS id,
      	pc.nome_posto AS name,
      	pc.endereco_completo AS address,
      	pc.latitude AS lat,
      	pc.longitude AS lng,
      	SUM(c.quantidade_kg) AS qtd
      FROM
      	public.postos_coleta pc
      LEFT JOIN
        public.compostagens c
      ON 
        pc.id_posto = c.posto_fk 
      WHERE
        c.foi_recolhido = false
      GROUP BY 
        id;"
    
    dataset <- pool::dbGetQuery(con, query) %>% 
      dplyr::mutate(qtd = ifelse(is.na(qtd), 0, qtd))
    
    
    leaflet() %>% 
      
      addTiles() %>%
      
      setView(lng = -45.89630216400873, lat = -23.19709799312104, zoom = 12) %>% 
      
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
                                  '</br><b>Quantidade de Resíduos à recolher: </b>', qtd, ' kg',
                                  '</br></br><b>Clique para mais detalhes!</b>') %>% lapply(htmltools::HTML),
                 labelOptions = labelOptions(textsize = "14px"),
                 group = 'markers',
                 layerId = ~ id,
                 clusterOptions = leaflet::markerClusterOptions())
    
  })
  
  
  # # # # Dataset # # # #
  dataset <- reactive({
    
    input$update_map
    
    query <- "
      SELECT 
      	pc.id_posto AS id,
      	pc.nome_posto AS name,
      	pc.endereco_completo AS address,
      	pc.latitude AS lat,
      	pc.longitude AS lng,
      	SUM(c.quantidade_kg) AS qtd
      FROM
      	public.postos_coleta pc
      LEFT JOIN
        public.compostagens c
      ON 
        pc.id_posto = c.posto_fk
      WHERE 
        c.foi_recolhido = false
      GROUP BY 
        id;"
    
    dataset <- pool::dbGetQuery(con, query) %>% 
      dplyr::mutate(qtd = ifelse(is.na(qtd), 0, qtd))
    
    dataset
    
  })
  
  
  # # # # Threads # # # #
  observe({
    
    leafletProxy('main_map') %>% 
      
      clearGroup('markers') %>% 
      
      addMarkers(data = dataset(),
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
                                  '</br><b>Quantidade de Resíduos à recolher: </b>', qtd, ' kg',
                                  '</br></br><b>Clique para mais detalhes!</b>') %>% lapply(htmltools::HTML),
                 labelOptions = labelOptions(textsize = "14px"),
                 group = 'markers',
                 layerId = ~ id,
                 clusterOptions = leaflet::markerClusterOptions())
    
    
  })
  
  observeEvent(input$main_map_marker_click, {
    
    id <- input$main_map_marker_click$id

    entity <- dataset() %>% dplyr::filter(id == !!id)

    all_compost_query <- "
     select
      c.id_compostagem AS id,
    	c.quantidade_kg,
    	c.publicado_em,
    	c.publicado_por
    from
    	public.compostagens c
    where
      c.foi_recolhido = false
      AND c.publicado_por <> '_default'
    	AND c.posto_fk = ?fk;
    "

    all_compost_query <- pool::sqlInterpolate(con, all_compost_query, fk = id)

    all_compost_dataset <<- pool::dbGetQuery(con, all_compost_query)

    output$compost_table <- renderDT({
      
      shiny::validate(
        shiny::need(nrow(all_compost_dataset) > 0, 
                    'Não existe resíduos para coleta neste endereço.')
      )

      all_compost_dataset %>%

        datatable(
          rownames = FALSE,
          options = list(searching = FALSE,
                         paging = FALSE,
                         info = FALSE,
                         stripeClasses = FALSE,
                         scrollX = TRUE,
                         ordering = FALSE,
                         scrollY = "250px")
        )

    })

    
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
            
            DT::dataTableOutput(ns('compost_table')),
            
            br(), br(),
            
            div(
              align = 'center',
              actionButton(
                inputId = ns('btn_remove'),
                label = 'Recolher Selecionados'
              )
            )
            
          )
        )
        
       
        )
      )
    
  })
  
  
  # # # Get Composts
  observeEvent(input$btn_remove, {
    
    .rows <- input$compost_table_rows_selected %>% shiny::isolate()
    
    rows_to_update <- all_compost_dataset[.rows, ]
    
    query <- "UPDATE public.compostagens 
      SET foi_recolhido = true, recolhido_em = NOW()
      WHERE id_compostagem = ?id;"
    
    lapply(rows_to_update$id, function(id) {
      update_query <- pool::sqlInterpolate(con, query, id = id)
      pool::dbGetQuery(con, update_query)
    })
    
    removeModal()
    
    shinyjs::click(id = 'update_map')
    
  })
}
