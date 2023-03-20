edit_entity <- function(new_entity){
  
  .geocoded_address <- geocode(new_entity$address)
  
  .query <- "
    UPDATE collector.compost AS c
    SET post_date = NOW(),
        address = ?value_address,
        full_address = ?value_full_address,
      	latitude = ?value_latitude,
      	longitude = ?value_longitude,
      	post_by = ?value_post_by,
      	weight_kg = ?value_weight
    WHERE c.compost_id = ?id;"
  
  .query <- pool::sqlInterpolate(con, 
                                 .query, 
                                 value_address = .geocoded_address$address,
                                 value_full_address = .geocoded_address$full_address,
                                 value_latitude = .geocoded_address$lat,
                                 value_longitude = .geocoded_address$lng,
                                 value_post_by = entity$post_by,
                                 value_weight = entity$weight,
                                 id = new_entity$id)
  
  pool::dbGetQuery(con, .query)
  
  message('Edit entity on database!')
  
}