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
    head(mtcars, 5)
  })
  
}
