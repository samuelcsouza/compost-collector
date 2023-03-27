gerenciamento_ui <- function(id){
  ns <- NS(id)
  
  fluidRow(
    
    box(
      title = 'Pontos de Coleta',
      width = 12,
      status = 'primary',
      solidHeader = TRUE,
      collapsible = TRUE,
      collapsed = FALSE,
      
      fluidPage(
        h4('Pontos de coletas já cadastrados'),
        DT::dataTableOutput(ns('list_collection_points')) %>% withSpinner(type = 4, color = 'red'),
        
        br(),
        
        box(
          title = 'Cadastrar novo Ponto de Coleta',
          width = 12,
          status = 'primary',
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
          status = 'primary',
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
          status = 'primary',
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
              inputId = ns('edit_point'),
              label = 'Excluir'
            )
          )
          
        )
      )
    )
    
  )
}

gerenciamento_server <- function(input, output, session){
  ns <- session$ns
  
  output$list_collection_points <- renderDataTable({
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
  
}
