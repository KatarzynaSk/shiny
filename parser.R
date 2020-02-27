library(data.table)
library(geosphere)

DATETIME_FORMAT = "%Y-%m-%d %H:%M:%OS"

get_time_diff <- function(date1, date2) {
   return (difftime(date2,date1))
}

DT <- fread("data/ships.csv",
      select = c("LON", "LAT", "ship_type","SHIPNAME", "SHIP_ID","DATETIME","DESTINATION"))
setnames(DT, "ship_type", "SHIP_TYPE")
setnames(DT, "SHIPNAME", "SHIP_NAME")

# set previous values of LON and LAT
DT[ , LON0 := ifelse(shift(SHIP_ID) == SHIP_ID, shift(LON), NA)]
DT[ , LAT0 := ifelse(shift(SHIP_ID) == SHIP_ID, shift(LAT), NA)]

# parse datetime
DT[, DATETIME := as.POSIXct(DATETIME, format = DATETIME_FORMAT)]

# calculate time between measurements and filter out not consecutive observations 
DT[ , TBM := ifelse(shift(SHIP_ID) == SHIP_ID, get_time_diff(shift(DATETIME),DATETIME), NA)]
DT <- DT[TBM > 20 & TBM < 125]
DT[ , DISTANCE := geosphere::distCosine(cbind(LON,LAT), cbind(LON0,LAT0))]

# calculate distance divided by TBM and find max value per SHIP_ID
DT[, DISTANCE_PER_TBM := DISTANCE/TBM]
DT[, MAX_DISTANCE_PER_TBM := max(DISTANCE_PER_TBM), by=SHIP_ID]

# from records with MAX_DISTANCE_PER_TBM choose most recent one
DT <- DT[DISTANCE_PER_TBM == MAX_DISTANCE_PER_TBM]
result <- DT[, .SD[which.max(DATETIME)], by=SHIP_ID]

fwrite(result, "parsed/ships.csv")