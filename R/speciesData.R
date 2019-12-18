#' Create dataframe of species presence from multiple raster files
#'
#' Read raster files of multiple species and
#' extract only the coordinates, where individuals are present
#' 
#' @param species_names List with species names
#' @param path Path to location of raster files
#' @param filename Specify filename of output
#' @param ... Additional arguments:
#' na: String used for missing values. Defaults to NA. Missing values will never be quoted; strings with the same value as na will always be quoted.
#' append: If FALSE, will overwrite existing file. If TRUE, will append to existing file. In both cases, if file does not exist a new file is created.
#' col_names:	Write columns names at the top of the file?
#' @return raster layer with species richness of files provided 
#' @examples
#' \dontrun{
#' speciesData()
#' }
#' @export
speciesData <- function(species_names=NA, path=getwd(), filename=NA, ...){
  if(unique(!is.na(filename))){
    if(file.exists(filename)){
      df_species <- readr::read_csv(filename)
    }
  }
  if(!exists("df_species")){
    # Turn species names into correct format
    species_names <- sub(species_names, pattern = " ", replacement="\\_")
    
    # Get the files 
    available_files <- list.files(path)
    available_names <- sapply(available_files, FUN=function(x){
      paste0(strsplit(as.character(x), split="_")[[1]][1:2], collapse="_")
    })
    res <- strsplit(sub(".tif","", available_files[[1]]), split="_")[[1]][3]
    rm(available_files)
    head(available_names)
    
    # Subset filenames by overlap with species names
    # to extract only bird, amphibian or terrestrial mammal files
    if(!anyNA(species_names)){
      species_names <- species_names[species_names %in% available_names]; rm(available_names)
    } else {
      species_names <- available_names; rm(available_names)
    }
    
    # Calculate the number of cores available and use 75% of available cores
    no_cores <- ceiling(0.75*parallel::detectCores())
    
    # Initiate cluster
    cl <- parallel::makeCluster(no_cores)
    
    # Load variables
    parallel::clusterExport(cl, "path",envir=environment())
    parallel::clusterExport(cl, "res", envir=environment())
    
    # Load packages for cluster
    parallel::clusterEvalQ(cl, library(raster))
    
    df_species <- parallel::parLapply(cl, species_names, function(x){
      # Read individual species raster file
      r_species <- raster::raster(paste0(path, "/", x, "_", res, ".tif"))
      
      # Turn raster file into a dataframe
      df_species <- as.data.frame(raster::rasterToPoints(r_species))
      
      # Remove presence column
      df_species <- df_species[,c("x", "y")]

      # Add column with species name
      df_species$species <- paste(strsplit(x, "_")[[1]][1:2], collapse=" ")
      
      return(df_species)
    })
    # Close the cluster
    parallel::stopCluster(cl)
    
    # Merge df_species list to one data frame
    df_species <- data.table::rbindlist(df_species)
    
    # Save dataframe to file
    if(unique(!is.na(filename))){
      readr::write_csv(df_species, path=filename, ...)
    }
  }
  return(df_species)
}
