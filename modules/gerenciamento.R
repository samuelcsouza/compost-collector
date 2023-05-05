gerenciamento_ui <- function(id){
  ns <- NS(id)
  
  fluidRow(
    # Recolhimento
    {
      box(
        title = 'Recolhimento',
        width = 12,
        status = 'primary',
        solidHeader = TRUE,
        collapsible = TRUE,
        collapsed = FALSE,
        
        fluidPage(
          
          h4('Quantidade de resíduos já coletados'),
          DT::dataTableOutput(ns('list_collection_garbage')) %>% withSpinner(type = 4, color = 'red'),
          
          br(),
          
          fluidRow(
            align = 'right',
            
            downloadButton(
              outputId = ns('garbage_download'),
              label = 'Download',
            ) ,
            
            actionButton(
              inputId = ns('garbage_update'),
              label = 'Atualizar Dados',
              icon = icon('refresh')
            ),
            
            actionButton(
              inputId = ns('garbage_delete'),
              label = 'Limpar Dados',
              icon = icon('broom')
            )
            
          )
        )
      )
    },
    
    # Postos de Coleta
    {
      box(
        title = 'Pontos de Coleta',
        width = 12,
        status = 'primary',
        solidHeader = TRUE,
        collapsible = TRUE,
        collapsed = TRUE,
        
        fluidPage(
          h4('Pontos de coletas já cadastrados'),
          DT::dataTableOutput(ns('list_collection_points')) %>% withSpinner(type = 4, color = 'red'),
          
          br(),
          
          box(
            title = 'Cadastrar novo Ponto de Coleta',
            width = 12,
            status = 'success',
            solidHeader = TRUE,
            collapsible = TRUE,
            collapsed = TRUE,
            
            fluidPage(
              textInput(
                inputId = ns('point_address'),
                label = 'Endereço',
                width = '95%',
                value = NULL
              ) %>% column(width = 8),
              
              textInput(
                inputId = ns('point_name'),
                label = 'Nome do Ponto de Coleta',
                width = '95%',
                value = NULL
              ) %>% column(width = 4),
            ),
            
            footer = div(
              align = 'center',
              actionButton(
                inputId = ns('new_point'),
                label = 'Adicionar'
              )
            )
            
          ),
          
          br(),
          
          box(
            title = 'Editar um ponto já existente',
            width = 12,
            status = 'warning',
            solidHeader = TRUE,
            collapsible = TRUE,
            collapsed = TRUE,
            
            fluidPage(
              textInput(
                inputId = ns('edit_point_id'),
                label = 'ID',
                width = '95%',
                value = NULL
              ) %>% column(width = 2),
              
              textInput(
                inputId = ns('edit_point_address'),
                label = 'Endereço',
                width = '95%',
                value = NULL
              ) %>% column(width = 6),
              
              textInput(
                inputId = ns('edit_point_name'),
                label = 'Nome do Ponto de Coleta',
                width = '95%',
                value = NULL
              ) %>% column(width = 4)
            ),
            
            footer = div(
              align = 'center',
              actionButton(
                inputId = ns('edit_point'),
                label = 'Editar'
              )
            )
            
          ),
          
          br(),
          
          box(
            title = 'Excluir um ponto de coleta',
            width = 12,
            status = 'danger',
            solidHeader = TRUE,
            collapsible = TRUE,
            collapsed = TRUE,
            
            
            fluidPage(
              numericInput(
                inputId = ns('delete_point_id'),
                label = 'ID',
                width = '95%',
                value = NULL
              ) %>% column(width = 2)
            ),
            
            footer = div(
              align = 'center',
              actionButton(
                inputId = ns('delete_point'),
                label = 'Excluir'
              )
            )
            
          )
        )
      )
    }
    
  )
}

gerenciamento_server <- function(input, output, session){
  ns <- session$ns
  
  #### Postos de Coleta ####
  
  output$list_collection_points <- renderDataTable({
    
    input$new_point
    input$edit_point
    input$delete_point
    
    query <- "
      SELECT
        id_posto AS Identificador,
        nome_posto AS nome,
        endereco_completo AS endereço
      FROM
        public.postos_coleta
      ORDER BY id_posto ASC
      LIMIT 5;
    "
    
    dataset <- pool::dbGetQuery(con, query)
    
    datatable(
      dataset,
      colnames = names(dataset) %>% stringr::str_to_title(),
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
  
  # # # # Add # # # #
  observeEvent(input$new_point, {
    
    address <- shiny::isolate(input$point_address) %>% stringr::str_to_title()
    point_name <- shiny::isolate(input$point_name)
    
    coords <- tryCatch(
      geocode(address),
      error = function(e){
        showModal(
          modalDialog(
            title = 'Erro!',
            size = 's',
            p('Endereço não encontrado! ', address)
          )
        )
        shiny::validate("")
      }
    )
    
    query <- "
      INSERT INTO public.postos_coleta(
        endereco_completo,
        nome_posto,
        latitude,
        longitude
      ) VALUES (
        ?address, ?name, ?lat, ?lng
      );
    "
    
    query <- pool::sqlInterpolate(con, 
                                  query, 
                                  address = address, 
                                  name = point_name,
                                  lat = coords$lat[1],
                                  lng = coords$lon[1])
    
    pool::dbGetQuery(con, query)
    
    clear_text('point_address')
    clear_text('point_name')
    
    showModal(
      modalDialog(
        title = 'Sucesso!',
        size = 's',
        p('Ponto de coleta inserido com sucesso!')
      )
    )
    
  })
  
  # # # # Edit # # # #
  observeEvent(input$edit_point, {
    
    id          <- shiny::isolate(input$edit_point_id)
    address     <- shiny::isolate(input$edit_point_address) %>% stringr::str_to_title()
    point_name  <- shiny::isolate(input$edit_point_name)
    
    coords <- tryCatch(
      geocode(address),
      error = function(e){
        showModal(
          modalDialog(
            title = 'Erro!',
            size = 's',
            p('Endereço não encontrado! ', address)
          )
        )
        shiny::validate("")
      }
    )
    
    query <- "
      UPDATE
        public.postos_coleta
      SET
        endereco_completo = ?address,
        latitude = ?lat,
        longitude = ?lng,
        nome_posto = ?name,
        atualizado_em = NOW()
      WHERE
        public.postos_coleta.id_posto = ?id;
    "
    
    query <- pool::sqlInterpolate(con,
                                  query,
                                  id = id,
                                  address = address,
                                  name = point_name,
                                  lat = coords$lat[1],
                                  lng = coords$lon[1])
    
    pool::dbGetQuery(con, query)
    
    clear_text('edit_point_address')
    clear_text('edit_point_name')
    clear_text('edit_point_id')
    
    showModal(
      modalDialog(
        title = 'Sucesso!',
        size = 's',
        p('Ponto de coleta alterado com sucesso!')
      )
    )
    
  })
  
  # # # # Delete # # # #
  observeEvent(input$delete_point, {
    
    id <- shiny::isolate(input$delete_point_id)
    
    query <- "
      DELETE FROM 
        public.postos_coleta
      WHERE
        public.postos_coleta.id_posto = ?id;
    "
    
    query <- pool::sqlInterpolate(con,
                                  query,
                                  id = id)
    
    pool::dbGetQuery(con, query)
    
    clear_text('delete_point_id')
    
    showModal(
      modalDialog(
        title = 'Sucesso!',
        size = 's',
        p('Ponto de coleta excluído com sucesso!')
      )
    )
    
  })
  
  
  #### Resíduos ####
  
  # Table
  output$list_collection_garbage <- renderDataTable({
    
    input$garbage_update
      
      query <- "
      select 
      	publicado_por as \"Nome\",
      	 sum(quantidade_kg) as \"Quantidade Coletada (Kg)\"
      from
      	public.residuos
      where
      	foi_recolhido = true
      	AND publicado_por <> '_default'
      group by
      	publicado_por;"
      
      dataset <- pool::dbGetQuery(con, query)
      
      datatable(
        dataset,
        rownames = FALSE,
        options = list(searching = FALSE,
                       paging = FALSE,
                       info = FALSE,
                       stripeClasses = FALSE,
                       scrollX = TRUE,
                       ordering = FALSE,
                       scrollY = "250px",
                       columnDefs = list(list(className = 'dt-center',
                                              targets = "_all")))
      )
      
    
  })
  
  collection_garbage <- reactive({
    
    input$garbage_update
    
    query <- "
      select 
      	publicado_por as \"Nome\",
      	 sum(quantidade_kg) as \"Quantidade Coletada (Kg)\"
      from
      	public.residuos
      where
      	foi_recolhido = true
      	AND publicado_por <> '_default'
      group by
      	publicado_por;"
    
    dataset <- pool::dbGetQuery(con, query)
    
    dataset
    
  })
  
  observeEvent(input$garbage_delete, {
    
    query <- "DELETE FROM public.residuos WHERE foi_recolhido = true"
    
    pool::dbGetQuery(con, query)
    
    shinyjs::click('garbage_update')
    
    showModal(
      modalDialog(
        title = 'Sucesso!',
        size = 's',
        p('Dados excluidos do banco de dados!')
      )
    )
    
  })
  
  output$garbage_download <- {
    downloadHandler(
      filename = function(){
        fname <- paste0(Sys.Date(), '_download.xlsx')
      },
      content = function(fname){
        writexl::write_xlsx(collection_garbage(), fname)
      }
    )
  }
  
}
