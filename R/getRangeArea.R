#' Obtain range area from species shapefiles
#'
#' Rasterize shapefile of multiple polygons to 
#' individual global rasters with a specific resolution
#' 
#' @param dsn Path to one shapefile with multiple polygons or a list of files
#' @param id \code{character} Character specifying the id column
#' @param name_split \code{integer} Specifies which splits to use, default is c(1,2).
#' @param no_species \code{} Range 
#' @param seasonal \code{integer} ...
#' @param origin \code{integer}
#' @param presence \code{integer}
#' @param make_valid \code{logical} Default to FALSE. If TRUE polygons are tried to be made valid using sf::st_make_valid()
#' @param crs \code{character}
#' @return \code{data.frame} with the range area of each species
#' @examples
#' \dontrun{
#' getRangeArea()
#' }
#' @export 
getRangeArea<- function(dsn=paste0(getwd(), "IUCN/AMPHIBIANS.shp"), 
                        id="binomial", name_split=c(1,2), no_species=NA, 
                        seasonal=NA, origin=NA, presence=NA, make_valid=F,
                        crs="+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"){
  # Add dplyr
  requireNamespace("dplyr")
  
  # Need to read shape file beforehand
  # IUCN Data was downloaded from: http://www.iucnredlist.org/technical-documents/spatial-data
  # Bird data comes from Christian, obtained from BirdLife International
  
  # Check if data is one shapefile or a list of shapefiles
  
  # Convert species distribution to a raster with appropriate resolution
  if(length(dsn) > 1){
    # Get species_names from list of files
    species_name <- sapply(dsn, FUN=function(x)
      paste0(strsplit(as.character(basename(x)), split="[_.]")[[1]][name_split], collapse="_")
    )
    
    # Calculate the number of cores available and use 75% of available cores
    no_cores <- ceiling(0.75*parallel::detectCores())
    
    # Initiate cluster
    cl <- parallel::makeCluster(no_cores)
    
    # Load packages for cluster
    parallel::clusterEvalQ(cl, sapply(c("sf", "dplyr"), require, char=TRUE))
    parallel::clusterExport(cl, list("species_name", "crs", 
                                     "dsn", "seasonal", "origin", 
                                     "presence"), envir=environment())
    
    if(any(is.na(no_species))){
      n <- 1:length(species_name)
    } else{
      n <- seq(no_species[1], no_species[2], by=1)
    }
    
    r_sp <- parallel::parLapply(cl, n, function(n){
      # Get shapefile of species
      sp_ind_shp <-sf::st_read(dsn=dsn[n], layer=sf::st_layers(dsn[n])[[1]])
      
      # Make sure shapefile is in correct projection
      if(is.na(sf::st_crs(sp_ind_shp))){
        sf::st_crs(sp_ind_shp) <- crs
      } else{
        sp_ind_shp <- sf::st_transform(sp_ind_shp, crs)
      }
      
      # Remove polygons with invalid geometry 
      if(make_valid==TRUE){sp_ind_shp <- sf::st_make_valid(sp_ind_shp)}
      #table(sf::st_is_valid(sp_ind_shp))
      sp_ind_shp <- sp_ind_shp[sf::st_is_valid(sp_ind_shp),]
      sp_ind_shp <- sp_ind_shp %>% dplyr::select(tidyselect::any_of(c(id, "SEASONAL", "ORIGIN", "PRESENCE", "geometry"))); invisible(gc())
      
      # Extract only shapefiles with certain parameters
      if(!anyNA(seasonal)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$SEASONAL %in% seasonal,]}
      if(!anyNA(origin)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$ORIGIN %in% origin,]}
      if(!anyNA(presence)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$PRESENCE %in% presence,]}; invisible(gc())
      if(length(sp_ind_shp)==0){r <- NULL} else{
        # Calculate area of each species
        area <- sf::st_area(sp_ind_shp)
        r <- data.frame(species_name=data.frame(sp_ind_shp)[,c(id)], area=area); rm(sp_ind_shp); invisible(gc())
      }
      return(r)
    })
    # Close the cluster
    parallel::stopCluster(cl)
    do.call("rbind", r_sp)
  } else{
    # Read shapefile
    species_file <- sf::st_read(dsn=dsn, layer=sf::st_layers(dsn)[1]$name)
    
    if(any(is.na(no_species))){} else{
      species_names <- unique(data.frame(species_file)[,c(id)])
      if(length(species_names) > no_species[2]){
        no_species[2] <- length(species_names)
      }
      species_names <- species_names[seq(no_species[1], no_species[2], by=1)]
      species_file$id <- data.frame(species_file)[,c(id)]
      species_file <- species_file[species_file$id %in% species_names,]
    }
    
    # Make sure shapefile is in correct projection
    if(is.na(sf::st_crs(species_file)$proj4string)){
      sf::st_crs(species_file)$proj4string <- crs
    } else if(sf::st_crs(species_file)$proj4string != crs){
      species_file <- sf::st_transform(species_file, crs)
    }
    
    # Remove polygons with invalid geometry 
    ## sf_use_s2(FALSE)
    if(make_valid==TRUE){sp_ind_shp <- sf::st_make_valid(sp_ind_shp)}
    #table(sf::st_is_valid(species_file))
    species_file <- species_file[sf::st_is_valid(species_file),]
    species_file <- species_file %>% dplyr::select(tidyselect::any_of(c(id, "seasonal", "origin", "presence", "geometry"))); invisible(gc())
    
    # Extract only shapefiles with certain parameters
    if(!anyNA(seasonal)){species_file <- species_file[species_file$seasonal %in% seasonal,]}
    if(!anyNA(origin)){species_file <- species_file[species_file$origin %in% origin,]}
    if(!anyNA(presence)){species_file <- species_file[species_file$presence %in% presence,]}; invisible(gc())
    if(length(species_file)==0){} else{
      # Calculate area of each species
      area <- sf::st_area(species_file)
      r <- data.frame(species_name=data.frame(species_file)[,c(id)], area=area); rm(species_file); invisible(gc())
    }
    r
  }
}
