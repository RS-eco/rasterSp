#' Rasterize Species Data
#' 
#' Rasterize SpatialPointsDataFrame or SpatialPolygonsDataFrame to 
#' individual global raster with a specific resolution
#' 
#' @param dsn Path to one shapefile with multiple polygons or a list of files
#' @return list of raster layers for each \code{id} with the given area \code{shapefile}
#' @examples
#' \dontrun{
#' rasterizeSp()
#' }
#' @export 
rasterizeSp <- function(dsn){
  if(class(dsn) == "SpatialPointsDataFrame"){
    
  } else if(class(dsn) == "SpatialPolygonDataFrame"){
    
  }
}
