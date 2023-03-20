open_connection <- function(){
  
  con <- pool::dbPool(
    RPostgreSQL::PostgreSQL(),
    user     = Sys.getenv("GIS_USER"), 
    password = Sys.getenv("GIS_PWD"), 
    dbname   = "postgres", 
    host     = "localhost")
  
  if(!pool::dbIsValid(con))
    stop('Não foi possível estabelecer a conexão com o banco de dados.')
  
  message("Conectado ao Banco de dados!")
  
  return(con)
}

close_connection <- function(){
  pool::poolClose(con)
  message('Desconectado do Banco de dados.')
}

con <- open_connection()
