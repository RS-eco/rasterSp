#' ---
#' title: "Individual species data"
#' author: "RS-eco"
#' ---

library(sf)

filedir <- "/home/matt/Documents/"
birdfiles <- list.files(paste0(filedir, "/BirdLife_2018/"), pattern=".shp", full.names=TRUE)

sturnus_vulgaris <- st_read(birdfiles[grepl(birdfiles, pattern="Sturnus_vulgaris")]) # European starling
threskiornis_aethiopicus <- st_read(birdfiles[grepl(birdfiles, pattern="Threskiornis_aethiopicus")]) #Sacred ibis
passer_domesticus <- st_read(birdfiles[grepl(birdfiles, pattern="Passer_domesticus")]) # House sparrow

colnames(sturnus_vulgaris)[5:7] <- c("PRESENCE", "ORIGIN", "SEASONAL")
colnames(threskiornis_aethiopicus)[5:7] <- c("PRESENCE", "ORIGIN", "SEASONAL")
colnames(passer_domesticus)[5:7] <- c("PRESENCE", "ORIGIN", "SEASONAL")

sf::st_write(sturnus_vulgaris, "inst/extdata/sturnus_vulgaris.shp", append=F)
sf::st_write(threskiornis_aethiopicus, "inst/extdata/threskiornis_aethiopicus.shp", append=F)
sf::st_write(passer_domesticus, "inst/extdata/passer_domesticus.shp", append=F)

#save(sturnus_vulgaris, file="data/sturnus_vulgaris.rda", compress="xz")
#save(threskiornis_aethiopicus, file="data/threskiornis_aethiopicus.rda", compress="xz")
#save(passer_domesticus, file="data/passer_domesticus.rda", compress="xz")
