geocode <- function(address){
  return(
    nominatimlite::geo_lite(address, limit = 1) %>% 
      dplyr::rename(full_address = address, address = query)
  )
}