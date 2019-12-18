#' ---
#' title: "European species ranges"
#' author: "RS-eco"
#' ---

filedir <- "/media/matt/Data/Documents/Wissenschaft/Data/"

library(sf)
library(fasterize)

#' ### Rasterize IUCN species shapefiles

#' IUCN data was downloaded from: https://www.iucnredlist.org/resources/spatial-data-download, by running the following code:

if(!dir.exists("ODONATA")) {
  download.file("http://spatial-data.s3.amazonaws.com/groups/FW_ODONATA.zip", 
                destfile = paste0(filedir, "/IUCN/FW_ODONATA.zip")) # <-- 594.3 MB
  unzip(paste0(filedir, "/IUCN/FW_ODONATA.zip"), exdir = paste0(filedir, "/IUCN"))
  unlink(paste0(filedir, "/IUCN/FW_ODONATA.zip"))
}

#' You have one shapefile for a group of animals, consisting of individual polygons for each species with different information (presence, origin, seasonal). You can specify the resolution in degrees, here we use 0.11°.

#+ rasterize_odonata, eval=F
dsn <- paste0(filedir, "/IUCN/FW_ODONATA.shp")
sp_ind_shp <- sf::st_read(dsn=dsn)
extent <- raster::extent(c(-44.25, 65.31, 22.09, 72.69))
sp_ind_eur <- sf::st_crop(sp_ind_shp, extent)
rm(sp_ind_shp); gc()

resolution <- 0.11
crs="+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
r <- raster::raster(ext=extent, resolution=resolution, crs=crs)
r_high <- raster::disaggregate(r, fact=10)
r_high

dat_ec <- raster::stack("/media/matt/Data/Documents/Wissenschaft/Data/EURO_CORDEX/EUR/bioclim_ICHEC-EC-EARTH_rcp26_r12i1p1_SMHI-RCA4_v1-SMHI-DBS45-MESAN-1989-2010_mon_2071-2099.nc")
dat_ec <- dat_ec[[1]]
plot(dat_ec)

#x <- 29 # Aeshna caerulea
dat <- lapply(1:nrow(sp_ind_eur), function(x){
  r_poly <- fasterize::fasterize(sp_ind_eur[x,], r_high, background=NA)
  r_poly <- raster::aggregate(r_poly, fact=10, fun=sum)
  r_poly <- raster::resample(r_poly, dat_ec)
  r_poly <- as.data.frame(raster::rasterToPoints(r_poly))
  colnames(r_poly) <- c("x", "y", "perc_present")
  r_poly$binomial <- sp_ind_eur$binomial[x]
  r_poly$presence <- sp_ind_eur$presence[x]
  r_poly$origin <- sp_ind_eur$origin[x]
  r_poly$seasonal <- sp_ind_eur$seasonal[x]
  return(r_poly); gc()
})
dat <- dplyr::bind_rows(dat)
readr::write_csv(dat, "/home/matt/Desktop/Odonata_IUCN_EUR_0.11deg.csv.xz")

odonata_dist_eur <- read.csv("/home/matt/Desktop/Odonata_IUCN_EUR_0.11deg.csv.xz")
save(odonata_dist_eur, file="data/odonata_dist_eur.rda", compress="xz")

#' ### Rasterize BirdLife species shapefiles

#+ rasterize_birdlife, eval=FALSE
dsn <- paste0(filedir, "/BirdLife_2018")
files <- list.files(dsn, pattern=".shp", full.names=T)
extent <- raster::extent(c(-44.25, 65.31, 22.09, 72.69))
resolution <- 0.11
crs="+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"
r <- raster::raster(ext=extent, resolution=resolution, crs=crs)
r_high <- raster::disaggregate(r, fact=10)
r_high

dat_ec <- raster::stack("/media/matt/Data/Documents/Wissenschaft/Data/EURO_CORDEX/EUR/bioclim_ICHEC-EC-EARTH_rcp26_r12i1p1_SMHI-RCA4_v1-SMHI-DBS45-MESAN-1989-2010_mon_2071-2099.nc")
dat_ec <- dat_ec[[1]]

#options(show.error.messages = FALSE)
options(try.outFile = stdout())
#x <- files[298]
lapply(files, function(x){
  if(!file.exists(paste0("/home/matt/Desktop/aves/", sub(".shp", ".csv", basename(x))))){
    print(x)
    dat <- sf::st_read(x)
    try(dat <- sf::st_crop(dat, extent)) # Crop data and skip in case file has holes
    if(nrow(dat) > 0){
      pol_df <- lapply(1:nrow(dat), function(y){
        r_poly <- fasterize::fasterize(dat[y,], r_high, background=NA)
        try(r_poly <- raster::aggregate(r_poly, fact=10, fun=sum))
        try(r_poly <- raster::resample(r_poly, dat_ec))
        try(r_poly <- as.data.frame(raster::rasterToPoints(r_poly)))
        try(colnames(r_poly) <- c("x", "y", "perc_present"))
        try(r_poly$binomial <- dat$SCINAME[y])
        try(r_poly$presence <- dat$PRESENC[y])
        try(r_poly$origin <- dat$ORIGIN[y])
        try(r_poly$seasonal <- dat$SEASONA[y])
        if(nrow(r_poly)>0){return(r_poly)} else{return(NULL)}
      }); rm(dat); gc()
      pol_df <- Filter(Negate(is.null), pol_df)
      pol_df <- dplyr::bind_rows(pol_df)
      if(nrow(pol_df) > 0){
        readr::write_csv(pol_df, paste0("/home/matt/Desktop/aves/", sub(".shp", ".csv", basename(x))))
      }
    }
  }
}); gc()
files <- list.files("/home/matt/Desktop/aves/", full.names=T)
sp_ind_shp <- lapply(files, read.csv)
sp_ind_shp <- dplyr::bind_rows(sp_ind_shp)
vroom::vroom_write(sp_ind_shp, "/home/matt/Desktop/Aves_BirdLife_EUR_0.11deg.csv.xz", delim=",")
#file.remove(files)
#dir.remove("/home/matt/Desktop/aves")

ter_birds_dist_eur <- read.csv("/home/matt/Desktop/Aves_BirdLife_EUR_0.11deg.csv.xz")
save(ter_birds_dist_eur, file="data/ter_birds_dist_eur.rda", compress="xz")
