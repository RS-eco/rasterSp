#' Calculate species richness of species presence raster stack
#'
#' Read raster files of multiple species to calculate the species richness
#' With special implementation for calculating the species richness of many species
#' 
#' @param species_names List with species names
#' @param path Path to location of raster files
#' @param filename Specify filename of output
#' @param ... Additional arguments for saving raster file
#' @return raster layer with species richness of files provided 
#' @examples
#' \dontrun{
#' calcSR()
#' }
#' @export
calcSR <- function(species_names=NA, path=getwd(), filename=NA, ...){
  if(!is.na(filename)){
    if(file.exists(filename)){
      r_species <- raster::raster(filename)
    }
  } else if(!exists("r_species")){
    # Check which files are already there 
    available_files <- list.files(path)
   
    # which filenames and species names overlap
    if(!anyNA(species_names)){
      available_names <- sapply(available_files, FUN=function(x){
        paste(strsplit(as.character(x), split="_")[[1]][1],strsplit(as.character(x), split="_")[[1]][2])})
      available_files <- available_files[which(available_names %in% species_names)]
      rm(available_names)
    }
    
    r_species <- raster::raster(paste0(path, available_files[1]))
    for(i in 2:length(available_files)){
      r_species <- raster::stack(r_species, raster::raster(paste0(path, available_files[i])))
      r_species <- raster::calc(r_species, sum, na.rm=TRUE)
    }
    # Set all 0s to NA
    r_species[raster::getValues(r_species) == 0] <- NA
    
    # Save r_species to file
    if(!is.na(filename)){
      raster::writeRaster(r_species, filename=filename, ...)
    }
  }
  return(r_species)
}
