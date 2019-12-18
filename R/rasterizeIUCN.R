#' Rasterize Species Data from Shapefile
#'
#' Rasterize shapefile of multiple polygons to 
#' individual global rasters with a specific resolution
#' 
#' @param dsn Path to one shapefile with multiple polygons or a list of files
#' @param id \code{character} Character specifying the id column
#' @param method \code{character} Default is all, which means both lines and areas of the polygons will be rasterized, 
#' unless sf and fasterize are installed then only the polygons are rasterized.
#' @param resolution \code{integer} Resolution in degrees
#' @param save \code{logical} Should individual output be stored. Path to output folder can be specified under path 
#' @param extent \code{extent} Extent of area that we are interested in.
#' @param split \code{character} default is NA
#' @param name_split \code{integer} Specifies which splits to use, default is c(1,2).
#' @param seasonal \code{integer} 1 = Resident, 2 = Breeding Season, 3 = Non-breeding Season, 4 = Passage, 5 =	Seasonal occurence uncertain.
#' @param origin \code{integer} 1 = Native, 2 =	Reintroduced, 3 =	Introduced, 4 =	Vagrant, 5 = Origin Uncertain.
#' @param presence \code{integer} 1 =	Extant, 2 = Probably Extant, 3 = Possibly Extant, 4 = Possibly Extinct, 5 = Extinct (post 1500), 6 = Presence Uncertain.
#' @param getCover \code{logical} Calculate the percentage covered by a polygon rather than the presence of a species
#' @param df \code{logical} Store the output as data.frame or not. If df=FALSE output will be stored as .tif files.
#' @param crs \code{character} Define the output projection of your data.
#' @param path \code{character} Path where individual output files are going to be stored.
#' @return list of raster layers for each \code{id} with the given area \code{shapefile}
#' @examples
#' \dontrun{
#' rasterizeIUCN()
#' }
#' @export 
rasterizeIUCN <- function(dsn=paste0(getwd(), "IUCN/AMPHIBIANS.shp"), id="binomial", 
                          method="all", resolution=0.5, save=TRUE,
                          extent=c(-180,180,-90,90), split=NA, name_split=c(1,2),
                          seasonal=NA, origin=NA, presence=NA, getCover=F, df=F,
                          crs="+proj=longlat +datum=WGS84 +ellps=WGS84 +towgs84=0,0,0",
                          path=getwd()){
  if(!dir.exists(path)){dir.create(path)}
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
    if(requireNamespace("sf") == TRUE){
      species_file <- sf::st_read(dsn=dsn)
      if(is.na(sf::st_crs(species_file))){
        sf::st_crs(species_file) <- sf::st_crs(crs)
      } else if(sf::st_crs(species_file) != sf::st_crs(crs)){
        species_file <- sf::st_transform(species_file, sf::st_crs(crs))
      }
      
      # Define file name according to list of species
      species_name <- sapply(levels(unlist(dplyr::select(as.data.frame(species_file), id))), FUN=function(x){
        paste0(strsplit(as.character(x), split=" ")[[1]][name_split], collapse="_")
      })
      
    } else{
      # Read shapefile
      species_file <- rgdal::readOGR(dsn=dsn, layer=rgdal::ogrListLayers(dsn)[1])
      
      # Make sure shapefile is in correct projection
      if(is.na(sp::proj4string(species_file))){
        sp::proj4string(species_file) <- crs
      } else if(sp::proj4string(species_file) != crs){
        species_file <- sp::spTransform(species_file, sp::CRS(crs))
      }
      
      # Define file name according to list of species
      species_name <- sapply(levels(species_file@data[,c(id)]), FUN=function(x){
        paste0(strsplit(as.character(x), split=" ")[[1]][name_split], collapse="_")
      })
    }
  }
  
  # If split is specificed, only select a portion of the species_names
  if(unique(!is.na(split))){species_name <- species_name[split]}
  
  # Check which files are already there 
  available_names <- sapply(list.files(path), FUN=function(x) strsplit(as.character(x), split=".tif")[[1]][1])
  
  # and find which species names are still missing
  n <- which(species_name %in% available_names == FALSE); rm(available_names)
  
  # Create empty global raster with right resolution and projection
  extent <- raster::extent(extent)
  #crs <- sp::CRS(crs)
  r <- raster::raster(ext=extent, resolution=resolution, crs=crs)
  
  # Increase resolution if getCover=T
  if(getCover==TRUE){
    r <- raster::disaggregate(r, fact=10)
  }
  
  #lapply(n, function(n){
  #  raster::writeRaster(r, filename=paste0(path, species_name[n], "_", 
  #                                 resolution, ".tif"), 
  #              format="GTiff", overwrite=TRUE)
  #})
  
  
  # Load packages for cluster
  #parallel::clusterEvalQ(cl, sapply(c('raster', 'gdalUtils',"rgdal"), require, char=TRUE))
  
  if(requireNamespace("sf") == TRUE & requireNamespace("fasterize") == TRUE){
    # Calculate the number of cores available and use 2 cores
    no_cores <- 2
    # Initiate cluster
    cl <- parallel::makeCluster(no_cores)
    parallel::clusterEvalQ(cl, sapply(c("raster", "rgdal", "sf", "fasterize"), require, char=TRUE))
  } else{
    # Calculate the number of cores available and use 50% of available cores
    no_cores <- ceiling(0.5*parallel::detectCores())
    
    # Initiate cluster
    cl <- parallel::makeCluster(no_cores)
    parallel::clusterEvalQ(cl, sapply(c("raster", "rgdal", "sp"), require, char=TRUE))
  } 
  
  # Load variables
  if(length(dsn) > 1){
    parallel::clusterExport(cl, list("n", "species_name", "path", "crs", "getCover",
                                     "resolution", "dsn", "r", "seasonal", "origin", 
                                     "method", "presence", "save"), envir=environment())
  } else{
    parallel::clusterExport(cl, list("n", "species_name", "path", "species_file", "getCover",
                                     "resolution", "dsn", "r", "seasonal", "origin", 
                                     "id", "method", "presence", "save"), envir=environment())
  }
  
  # Convert species distribution to a raster with appropriate resolution
  r_sp <- parallel::parLapply(cl, n, function(n){
    # Rasterize shapefile of species
    if(length(dsn) > 1){
      if(requireNamespace("sf") == TRUE){
        sp_ind_shp <- sf::st_read(dsn=dsn[n])
        if(is.na(sf::st_crs(sp_ind_shp))){
          sf::st_crs(sp_ind_shp) <- sf::st_crs(crs)
        } else if(sf::st_crs(sp_ind_shp) != sf::st_crs(crs)){
          sp_ind_shp <- sf::st_transform(sp_ind_shp, sf::st_crs(crs))
        }
        
        # Extract only shapefiles with certain parameters
        if(!anyNA(seasonal)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$SEASONAL %in% seasonal,]}
        if(!anyNA(origin)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$ORIGIN %in% origin,]}
        if(!anyNA(presence)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$PRESENCE %in% presence,]}
      } else{
        
        # Get shapefile of species
        sp_ind_shp <- rgdal::readOGR(dsn=dsn[n], layer=rgdal::ogrListLayers(dsn[n])[1])
        
        # Make sure shapefile is in correct projection
        if(is.na(sp::proj4string(sp_ind_shp))){
          sp::proj4string(sp_ind_shp) <- crs
        } else{
          sp_ind_shp <- sp::spTransform(sp_ind_shp, crs)
        }
        
        # Extract only shapefiles with certain parameters
        if(!anyNA(seasonal)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$SEASONAL %in% seasonal,]}
        if(!anyNA(origin)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$ORIGIN %in% origin,]}
        if(!anyNA(presence)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$PRESENCE %in% presence,]}
      }
    } else{
      if(requireNamespace("sf") == TRUE){
        # Extract list of species
        species_list <- levels(unlist(dplyr::select(as.data.frame(species_file), id)))
        
        # Select only polygons of one species
        sp_ind_shp <- species_file[as.data.frame(species_file)[,c(id)] == species_list[n],]
        
        # Extract only shapefiles with certain parameters
        if(!anyNA(seasonal)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$seasonal %in% seasonal,]}
        if(!anyNA(origin)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$origin %in% origin,]}
        if(!anyNA(presence)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$presence %in% presence,]}
        
      } else{
        # Extract list of species
        species_list <- levels(species_file@data[,c(id)])
        
        # Select only polygons of one species
        sp_ind_shp <- species_file[species_file@data[,c(id)] == species_list[n],]
        
        # Extract only shapefiles with certain parameters
        if(!anyNA(seasonal)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$seasonal %in% seasonal,]}
        if(!anyNA(origin)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$origin %in% origin,]}
        if(!anyNA(presence)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$presence %in% presence,]}
      }
    }
    if(length(sp_ind_shp)!=0){
      if(requireNamespace("sf") == TRUE & requireNamespace("fasterize") == TRUE){
        if(nrow(sp_ind_shp) > 1){
          r_poly <- lapply(1:nrow(sp_ind_shp), function(x){fasterize::fasterize(sp_ind_shp[x,], r, background=NA)})
          if(df==FALSE){
           r_poly <- do.call(raster::merge, r_poly)
          }
        } else if(nrow(sp_ind_shp) == 1){
          r_poly <- fasterize::fasterize(sp_ind_shp, r, background=NA)
        }
        if(getCover==TRUE){
          try(r_poly <- raster::aggregate(r_poly, fact=10, fun=sum))
        }
        if(df==TRUE){
          if(class(r_poly)=="list"){
            dat <- lapply(1:length(r_poly), function(x){
              dat <- as.data.frame(raster::rasterToPoints(r_poly[[x]]))
              colnames(dat) <- c("x", "y", "present")
              try(dat$binomial <- sp_ind_shp$binomial[x])
              try(dat$presence <- sp_ind_shp$presence[x])
              try(dat$origin <- sp_ind_shp$origin[x])
              try(dat$seasonal <- sp_ind_shp$seasonal[x])
              try(dat$binomial <- sp_ind_shp$BINOMIAL[x])
              try(dat$presence <- sp_ind_shp$PRESENCE[x])
              try(dat$origin <- sp_ind_shp$ORIGIN[x])
              try(dat$seasonal <- sp_ind_shp$SEASONAL[x])
              return(dat)
            })
            dat <- dplyr::bind_rows(dat)
          } else{
            try(dat <- as.data.frame(raster::rasterToPoints(r_poly)))
            colnames(dat) <- c("x", "y", "present")
            try(dat$binomial <- sp_ind_shp$binomial)
            try(dat$presence <- sp_ind_shp$presence)
            try(dat$origin <- sp_ind_shp$origin)
            try(dat$seasonal <- sp_ind_shp$seasonal)
            try(dat$binomial <- sp_ind_shp$BINOMIAL)
            try(dat$presence <- sp_ind_shp$PRESENCE)
            try(dat$origin <- sp_ind_shp$ORIGIN)
            try(dat$seasonal <- sp_ind_shp$SEASONAL)
          }
          try(readr::write_csv(dat, path=paste0(path, species_name[n], "_", round(resolution,digits=3), ".csv.xz")))
        } else{
          try(raster::writeRaster(r_poly, filename=paste0(path, species_name[n], "_", round(resolution,digits=3), ".tif"), 
                                  format="GTiff", overwrite=TRUE))
        }
      } else if(method == "all"){
        line <- as(sp_ind_shp, "SpatialLines")
        r_line <- raster::rasterize(line, r, field=1, background=NA, na.rm=TRUE)
        r_poly <- raster::rasterize(sp_ind_shp, r, field=1, background=NA, na.rm=TRUE)
        if(save == FALSE){
          r <- raster::merge(r_line, r_poly)
        } else{
          if(df==FALSE){
            r <- raster::merge(r_line, r_poly, 
                               filename=paste0(path, species_name[n], 
                                               "_", round(resolution,digits=3), ".tif"), 
                               format="GTiff", overwrite=TRUE)
          } else{
            r <- raster::merge(r_line, r_poly)
            dat <- as.data.frame(raster::rasterToPoints(r))
            readr::write_csv(dat, path=paste0(path, species_name[n], "_", round(resolution,digits=3), ".csv.xz"))
          }
        }
      } else{
        if(df==FALSE){r <- raster::rasterize(sp_ind_shp, r, field=1, background=NA, na.rm=TRUE,
                               filename=paste0(path, species_name[n], "_", 
                                               round(resolution,digits=3), ".tif"), 
                               format="GTiff", overwrite=TRUE, datatype="INT2U", options="COMPRESS=LZW")
        #gdalUtils::gdal_rasterize(src_datasource=sp_ind_shp, 
        #               dst_filename=paste0(path, species_name[n], "_", 
        #                                   resolution, ".tif"), b=1, a=1, 
        #               verbose=F, output_Raster=T)
        } else{
          dat <- as.data.frame(raster::rasterToPoints(r))
          readr::write_csv(dat, path=paste0(path, species_name[n], "_", round(resolution,digits=3), ".csv.xz"))
        }
      }
    }
    return(r)
  })
  # Close the cluster
  parallel::stopCluster(cl)
  
  # Add the 2nd methodology for rasterizing SPDFs!
  # Implement gdal-rasterize, some of it already there in comments, but needs testing!
}
