library(data.table)

get_observation_by_id <- function(data, ship_id) {
   observations <- subset(data, SHIP_ID == ship_id)
   o <-head(observations, 1)

   return (list(
       "positions" = data.frame("lat" = c(o$LAT0, o$LAT), "lng" =  c(o$LON0, o$LON)),
       "ship_name" = o$SHIP_NAME,
       "distance" = format(o$DISTANCE),
       "tbm" = o$TBM
       ))
}

get_ships_by_type <- function(data, type) {
   ships <- subset(data, SHIP_TYPE == type, select=c("SHIP_NAME", "SHIP_ID"))
   ships <-unique(ships)
   options <- as.list(ships$SHIP_ID)
   names(options) <- ships$SHIP_NAME
   options <- options[order(names(options))]
   return (options)
}
