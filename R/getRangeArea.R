#' Obtain range area from species shapefiles
#'
#' Rasterize shapefile of multiple polygons to 
#' individual global rasters with a specific resolution
#' 
#' @param dsn Path to one shapefile with multiple polygons or a list of files
#' @param id \code{character} Character specifying the id column
#' @param seasonal \code{integer} ...
#' @param origin \code{integer}
#' @param presence \code{integer}
#' @param crs \code{character}
#' @param name_split \code{integer} Specifies which splits to use, default is c(1,2).
#' @return \code{data.frame} with the range area of each species
#' @examples
#' \dontrun{
#' rasterizeIUCN()
#' }
#' @export 
getRangeArea<- function(dsn=paste0(getwd(), "IUCN/AMPHIBIANS.shp"), id="binomial", 
                        seasonal=NA, origin=NA, presence=NA, name_split=c(1,2),
                        crs="+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0"){
  # Add dplyr
  requireNamespace("dplyr")
  
  # Need to read shape file beforehand
  # IUCN Data was downloaded from: http://www.iucnredlist.org/technical-documents/spatial-data
  # Bird data comes from Christian, obtained from BirdLife International
  
  # Check if data is one shapefile or a list of shapefiles
  if(length(dsn) > 1){
    # Get species_names from list of files
    species_name <- sapply(dsn, FUN=function(x)
      paste0(strsplit(as.character(basename(x)), split="[_.]")[[1]][name_split], collapse="_")
    )
  } else {
    # Read shapefile
    species_file <- sf::st_read(dsn=dsn, 
                                layer=sf::st_layers(dsn)[1]$name)
    
    # Make sure shapefile is in correct projection
    if(is.na(sf::st_crs(species_file)$proj4string)){
      sf::st_crs(species_file)$proj4string <- crs
    } else if(sf::st_crs(species_file)$proj4string != crs){
      species_file <- sf::st_transform(species_file, crs)
    }
    
    # Extract list of species
    species_list <- species_file %>% dplyr::select(dplyr::matches(id))
    sf::st_geometry(species_list) <- NULL
    species_list <- levels(species_list[[1]])
    
    # Define file name according to species
    species_name <- sapply(species_list, FUN=function(x) 
      paste0(strsplit(as.character(x), split=" ")[[1]][name_split], collapse="_")
    )
    rm(species_list)
  }
  
  # Convert species distribution to a raster with appropriate resolution
  if(length(dsn) > 1){
    # Calculate the number of cores available and use 75% of available cores
    no_cores <- ceiling(0.75*parallel::detectCores())
    
    # Initiate cluster
    cl <- parallel::makeCluster(no_cores)
    
    # Load packages for cluster
    parallel::clusterEvalQ(cl, sapply(c("sf", "dplyr"), require, char=TRUE))
    parallel::clusterExport(cl, list("species_name", "crs", 
                                     "dsn", "seasonal", "origin", 
                                     "presence"), envir=environment())
    
    n <- 1:length(species_name)
    r_sp <- parallel::parLapply(cl, n, function(n){
      # Get shapefile of species
      sp_ind_shp <-sf::st_read(dsn=dsn[n], layer=sf::st_layers(dsn[n])[[1]])
      
      # Make sure shapefile is in correct projection
      if(is.na(sf::st_crs(sp_ind_shp))){
        sf::st_crs(sp_ind_shp) <- crs
      } else{
        sp_ind_shp <- sf::st_transform(sp_ind_shp, crs)
      }
      
      # Extract only shapefiles with certain parameters
      if(!anyNA(seasonal)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$SEASONAL %in% seasonal,]}
      if(!anyNA(origin)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$ORIGIN %in% origin,]}
      if(!anyNA(presence)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$PRESENCE %in% presence,]}
      if(length(sp_ind_shp)==0){r <- NULL} else{
        # Calculate area of each species
        area <- sf::st_area(sp_ind_shp)
        r <- data.frame(species_name=sp_ind_shp$SCINAME, area=area)
      }
      return(r)
    })
    # Close the cluster
    parallel::stopCluster(cl)
    do.call("rbind", r_sp)
  } else{
    # Extract only shapefiles with certain parameters
    if(!anyNA(seasonal)){sp_ind_shp <- species_file[species_file$seasonal %in% seasonal,]}
    if(!anyNA(origin)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$origin %in% origin,]}
    if(!anyNA(presence)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$presence %in% presence,]}
    if(length(sp_ind_shp)==0){} else{
      # Calculate area of each species
      area <- sf::st_area(sp_ind_shp)
      data.frame(species_name=sp_ind_shp$binomial, area=area)
    }
  }
}
