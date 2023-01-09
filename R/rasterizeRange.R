#' Rasterize Species Data from Shapefile
#'
#' Rasterize shapefile of multiple polygons to 
#' individual global rasters with a specific resolution
#' 
#' @param dsn Path to one shapefile with multiple polygons or a list of files
#' @param id \code{character} Character specifying the id column
#' @param touches \code{logical} If TRUE, all cells touched by lines or polygons are affected, 
#' not just those on the line render path, or whose center point is within the polygon. 
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
#' r_amphibians <- rasterizeRange(dsn=paste0(getwd(), "/IUCN/AMPHIBIANS.shp"), id="binomial", 
#' resolution=0.5, seasonal=c(1,2), origin=1, presence=c(1,2), path=getwd())
#' }
#' @export 
rasterizeRange <- function(dsn=paste0(getwd(), "/IUCN/AMPHIBIANS.shp"), 
                          id="binomial", resolution=0.5, save=TRUE, touches=TRUE, 
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
      colnames(species_file) <- tolower(colnames(species_file))
      id <- tolower(id)
      if(!any(colnames(species_file) %in% id)){
        print("Please specify a correct id column.")
      }
      if(is.na(sf::st_crs(species_file))){
        sf::st_crs(species_file) <- sf::st_crs(crs)
      } else if(sf::st_crs(species_file) != sf::st_crs(crs)){
        species_file <- sf::st_transform(species_file, sf::st_crs(crs))
      }
      
      # Define file name according to list of species
      species_name <- sapply(unique(unlist(dplyr::select(as.data.frame(species_file), 
                                                         tidyselect::all_of(id)))), FUN=function(x){
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
  available_names <- sapply(list.files(path), FUN=function(x){
    strsplit(as.character(x), split=paste0("_", round(resolution,digits=3), ".tif"))[[1]][1]
  })
  
  # and find which species names are still missing
  n_all <- which(species_name %in% available_names == FALSE); rm(available_names)
  
  # Create empty global raster with right resolution and projection
  if(requireNamespace("terra") == TRUE){
    extent <- terra::ext(extent)
    r <- terra::rast(ext=extent, resolution=resolution, crs=crs)
    # Increase resolution if getCover=T
    if(getCover==TRUE){
      r <- terra::disagg(r, fact=10)
    }
  } else if(requireNamespace("raster") == TRUE){
    extent <- raster::extent(extent)
    r <- raster::raster(x=extent, resolution=resolution, crs=crs)
    # Increase resolution if getCover=T
    if(getCover==TRUE){
      r <- raster::disaggregate(r, fact=10)
    }
  } else{
    print("Please install either the terra or the raster R package.")
  }
  
  # Convert species distribution to a raster with appropriate resolution
  r_sp <- lapply(n_all, function(n){
    # Rasterize shapefile of species
    if(length(dsn) > 1){
      if(requireNamespace("sf") == TRUE){
        sp_ind_shp <- sf::st_read(dsn=dsn[n])
        colnames(sp_ind_shp) <- tolower(colnames(sp_ind_shp))
        id <- tolower(id)
        if(is.na(sf::st_crs(sp_ind_shp))){
          sf::st_crs(sp_ind_shp) <- sf::st_crs(crs)
        } else if(sf::st_crs(sp_ind_shp) != sf::st_crs(crs)){
          sp_ind_shp <- sf::st_transform(sp_ind_shp, sf::st_crs(crs))
        }
      } else{
        # Get shapefile of species
        sp_ind_shp <- rgdal::readOGR(dsn=dsn[n], layer=rgdal::ogrListLayers(dsn[n])[1])
        
        # Make sure shapefile is in correct projection
        if(is.na(sp::proj4string(sp_ind_shp))){
          sp::proj4string(sp_ind_shp) <- crs
        } else{
          sp_ind_shp <- sp::spTransform(sp_ind_shp, crs)
        }
      } 
    } else{
      if(requireNamespace("sf") == TRUE){
        # Extract list of species
        species_list <- unique(unlist(dplyr::select(as.data.frame(species_file), 
                                                    tidyselect::all_of(id))))
        
        # Select only polygons of one species
        sp_ind_shp <- species_file[as.data.frame(species_file)[,c(id)] == species_list[n],]
      } else{
        # Extract list of species
        species_list <- levels(species_file@data[,c(id)])
        
        # Select only polygons of one species
        sp_ind_shp <- species_file[species_file@data[,c(id)] == species_list[n],]
      } 
    }
    # Extract only shapefiles with certain parameters
    if(!anyNA(seasonal)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$seasonal %in% seasonal,]}
    if(!anyNA(origin)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$origin %in% origin,]}
    if(!anyNA(presence)){sp_ind_shp <- sp_ind_shp[sp_ind_shp$presence %in% presence,]}
    
    if(nrow(sp_ind_shp)!=0){
      if(touches == TRUE){
        if(requireNamespace("terra") == TRUE){
          r_poly <- terra::rasterize(terra::vect(sp_ind_shp), r, touches=T, background=NA)
          if(getCover==TRUE){
            r_poly <- terra::aggregate(r_poly, fact=10, fun="sum", na.rm=T)
          }
        } else if(requireNamespace("raster") == TRUE){
          line <- as(as(sp_ind_shp, "Spatial"), "SpatialLines")
          r_line <- raster::rasterize(line, r, field=1, background=NA, na.rm=TRUE)
          r_poly <- raster::rasterize(sp_ind_shp, r, field=1, background=NA, na.rm=TRUE)
          r_poly <- raster::merge(r_line, r_poly)
          if(getCover==TRUE){
            r_poly <- terra::aggregate(r_poly, fact=10, fun="sum", na.rm=T)
          }
        } else{
          print("Please install one of the following two R packages: terra or raster.")
        }
      } else{
        if(requireNamespace("terra") == TRUE){
          r_poly <- terra::rasterize(terra::vect(sp_ind_shp), r, touches=F, background=NA)
          if(getCover==TRUE){
            r_poly <- terra::aggregate(r_poly, fact=10, fun="sum", na.rm=T)
          }
        } else if(requireNamespace("raster") == TRUE){
          r_poly <- raster::rasterize(sp_ind_shp, raster::raster(r), field=1, background=NA, na.rm=TRUE)
          # Increase resolution if getCover=T
          if(getCover==TRUE){
            r_poly <- raster::aggregate(r_poly, fact=10, fun="sum", na.rm=T)
          }
        } else{
          print("Please install one of the following two R packages: terra or raster.")
        }
      }
      if(df==FALSE){
        if(save == TRUE){
          if(requireNamespace("terra") == TRUE){
            if(nrow(as.data.frame(r_poly))>0){
              try(terra::writeRaster(r_poly, filename=paste0(path, species_name[n], "_", 
                                                             round(resolution,digits=3), ".tif"), 
                                     filetype="GTiff", overwrite=TRUE))
            }
          } else if(requireNamespace("raster") == TRUE){
            if(nrow(as.data.frame(raster::rasterToPoints(r_poly)))>0){
              try(raster::writeRaster(r_poly, filename=paste0(path, species_name[n], "_", 
                                                              round(resolution,digits=3), ".tif"), 
                                      format="GTiff", overwrite=TRUE))
            }
          }
        }
      } else{
        if(requireNamespace("terra") == TRUE){
          r_poly <- as.data.frame(r_poly,xy=T)
        } else if(requireNamespace("raster") == TRUE){
          r_poly <- as.data.frame(raster::rasterToPoints(r_poly))
        }
        colnames(r_poly) <- c("x", "y", "presence")
        r_poly$species <- species_name[n]
        if(save == TRUE){
          readr::write_csv(r_poly, path=paste0(path, species_name[n], "_", 
                                               round(resolution,digits=3), ".csv.xz"))
        }
      }
      return(r_poly)
    }
  })
  if(length(species_name) < 50){
    if(df==FALSE){
      if(requireNamespace("terra") == TRUE){
        r_sp <- terra::rast(r_sp)
      } else{
        r_sp <- raster::stack(r_sp)
      }
      names(r_sp) <- species_name
    } else{
      r_sp <- dplyr::bind_rows(r_sp)
    }
    return(r_sp)
  }
}
