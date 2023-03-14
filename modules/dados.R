data_ui <- function(id){
  ns <- NS(id)
  
  fluidRow(
    uiOutput(ns('ui_info_box')),
    
    br(),
    
    uiOutput(ns('ui_table_chart')),
    
    br(),
    
    uiOutput(ns('ui_2nd_chart'))
  )
  
}

data_server <- function(input, output, session){
  ns <- session$ns
  
  dataset <- data.frame(
    collected = c(TRUE, FALSE, FALSE),
    last_update = c('22/01/2023',
                    '14/03/2023',
                    '11/04/2023'),
    name = c('Via Vale Garden Shopping',
             'Taubaté Shopping',
             'Shopping Jardim Oriente'),
    address = c('Av. Dom Pedro I, 7181 - Res. Estoril, Taubaté - SP, 12091-000',
                'Av. Charles Schnneider, 1700 - Vila Costa, Taubaté - SP, 12040-900',
                'R. Andorra, 500 - Jardim America, São José dos Campos - SP, 12235-050')
  )
  
  # - - - - - info box ----
  
  output$ui_info_box <- renderUI({
    
    fluidRow(
      infoBox(title = 'Total',
              subtitle = 'Pontos Mapeados',
              value = 537,
              icon  = icon('map-marker'),
              color = 'green', 
              width = 11, 
              fill  = FALSE) %>% column(width = 4),
      
      infoBox(title = 'A Coletar',
              subtitle = 'Pontos a serem visitados',
              value = 150,
              icon  = icon('truck'),
              color = 'green', 
              width = 11, 
              fill  = FALSE) %>% column(width = 4),
      
      infoBox(title = 'Coletados', 
              subtitle = 'Pontos já visitados',
              value = 489,
              icon  = icon('check'),
              color = 'green', 
              width = 11, 
              fill  = FALSE) %>% column(width = 4)
    )
    
  })
  
  
  # Table & charts ----
  
  output$ui_table_chart <- renderUI({
    
    output$table_status <- renderTable({
      dataset %>% 
        select(-address)
      
    })
    
    output$chart_status <- plotly::renderPlotly({
      
      dataset %>% 
        dplyr::group_by(collected) %>% 
        dplyr::summarise(n = n()) %>% 
        dplyr::mutate(collected = ifelse(collected, 'Já coletado', 'A coletar')) %>% 
        
        plot_ly(labels = ~ collected,
                values = ~ n,
                type = 'pie',
                textinfo='label+percent',
                insidetextorientation='radial') %>% 
        
        plotly::layout(
          title = 'Coletas - Visão Geral',
          xaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE),
          yaxis = list(showgrid = FALSE, zeroline = FALSE, showticklabels = FALSE)
        )
      
    })
    
    fluidPage(
      column(
        width = 4,
        
        box(
          title = 'Tabela',
          width = 12,
          status = 'primary',
          solidHeader = TRUE,
          
          tableOutput(ns('table_status'))
        )
      ),
      
      column(
        width = 8,
        
        box(
          title = 'Overview',
          width = 12,
          status = 'primary',
          solidHeader = TRUE,
          
          plotly::plotlyOutput(ns('chart_status'))
        )
      )
    )
    
  })
  
  output$ui_2nd_chart <- renderUI({
    
    output$chart_2nd <- renderPlotly({
      
      chart_dataset <- data.frame(
        x = c('Janeiro',
              'Fevereiro',
              'Março',
              'Abril',
              'Maio',
              'Junho',
              'Julho',
              'Agosto',
              'Setembro',
              'Outubro',
              'Novembro',
              'Dezembro'),
        y = abs(rnorm(12) * 100)
      )
      
      plot_ly(data = chart_dataset) %>% 
        
        add_trace(x = ~ x,
                  y = ~ y,
                  hovertemplate = '<b>%{x}</b><br>%{y:.0f} Pontos Coletados<extra></extra>',
                  type = 'bar') %>% 
        
          layout(title = "Pontos Coletados",
                 xaxis = list(title = ""),
                 yaxis = list(title = "", hoverformat = '.2f'))
      
    })
    
    
    box(
      title = 'Pontos coletados',
      width = 12,
      status = 'primary',
      solidHeader = TRUE,
      
      plotlyOutput(ns('chart_2nd'))
    )
    
  })
  
}