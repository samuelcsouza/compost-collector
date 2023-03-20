#' Cria uma entidade no banco de dados.
#' Colunas necessárias: 
#'  - `address`: Endereço completo
#'  - `post_by`: Nome da pessoa
#'  - `weight`: Quantidade (Kg)

create_entity <- function(entity) {
  
  .geocoded_address <- geocode(entity$address)
  
  .query <- "
    INSERT INTO collector.compost(
      address,
      full_address,
    	latitude,
    	longitude,
    	post_by,
    	weight_kg
    ) VALUES (
      ?value_address,
      ?value_full_address,
      ?value_latitude,
      ?value_longitude,
      ?value_post_by,
      ?value_weight
    );"
  
  .query <- pool::sqlInterpolate(con, 
                                 .query, 
                                 value_address = .geocoded_address$address,
                                 value_full_address = .geocoded_address$full_address,
                                 value_latitude = .geocoded_address$lat,
                                 value_longitude = .geocoded_address$lng,
                                 value_post_by = entity$post_by,
                                 value_weight = entity$weight)
  
  pool::dbGetQuery(con, .query)
  
  message('Save into database!')
  
}
