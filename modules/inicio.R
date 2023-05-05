inicio_ui <- function(id){
  ns <- NS(id)
  
  message("building resume ...")
  
  knitr::knit2html(
    input = "www/html/inicio.Rmd",
    output = "www/html/inicio.html",
    quiet = TRUE
  )
  
  message("done!")
  
  tagList(
    tags$iframe(
      src = "html/inicio.html",
      width = '100%', height = "800px",
      frameborder = 0, scrolling = "no"
    )
  )
}