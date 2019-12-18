#' Convert point data to gridded data
#'
#' Turn a dataframe or SpatiaPointsDataFrame into a RasterLayer or RasterStack 
#' with a certain resolution and certain extent.
#'
#' @param data SpatialPointsDataFrame or dataframe
#' @param long \code{character} specifying name of Longitude column.
#' @param lat \code{character} specifying name of Latitude column.
#' @param res Desired resolution for ridded output data
#' @param tres Desired temporal resolution
#' @param ... Additional arguments for rasterize function.
#' @param crop logical. Crop raster by bounding box of SpatialPoints, default is FALSE.
#' @param crs projection of input data, if data is not a SpatialPointsDataFrame
#' @return rasterstack with data
#' @examples
#' data(meuse, package="sp")
#' library(ggplot2)
#' ggplot(aes(x = x, y = y, color = zinc), data = meuse) + 
#' geom_point() + theme(legend.position=c(0.85,0.2))
#' 
#' gr_meuse <- rasterizePoints(data=meuse, res=100, crs=sp::CRS("+init=epsg:28992"))
#' library(raster)
#' ggplot(aes(x = x, y = y, fill = cadmium), data = data.frame(rasterToPoints(gr_meuse))) + 
#' geom_raster()
#' 
#' # If long and lat are not called x,y, 
#' # you have to specify their columnNames 
#' # in the rasterizePoints function accordingly
#' meuse_longlat <- meuse
#' colnames(meuse_longlat)[c(1,2)] <- c("Longitude", "Latitude")
#' 
#' gr_meuse <- rasterizePoints(data=meuse_longlat, long="Longitude", lat="Latitude", 
#'                             res=100, crs=sp::CRS("+init=epsg:28992"))
#' ggplot(aes(x = x, y = y, fill = lead), data = data.frame(rasterToPoints(gr_meuse))) + 
#' geom_raster()
#' 
#' @export
rasterizePoints <- function(data, long=NA, lat=NA, res=0.5, tres=NA, ..., crop=T,
                            crs=sp::CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0")){
  # Turn data into correct format
  if(class(data) == "data.frame"){
    if(!is.na(long) | !is.na(lat)){
      if(long != "x" & long != "y"){
        data$x <- data[,long]
        data$y <- data[,lat]
      }
    } else{
      data$x <- data[,tidyselect::vars_select(colnames(data), tidyselect::one_of(c("decimallongitude", "LONGITUDE", "decimalLongitude", "Longitude", "long", "Long", "x")))]
      data$y <- data[,tidyselect::vars_select(colnames(data), tidyselect::one_of(c("decimallatitude", "LATITUDE", "decimaLatitude", "Latitude", "lat", "Lat", "y")))]
    }
    sp::coordinates(data) <- ~x+y
    sp::proj4string(data) <- crs
    if(!is.na(long) | !is.na(lat)){
      if(long != "x" & long != "y"){
        data@data <- dplyr::select(data@data, -tidyselect::one_of(long, lat))
      }
    } else{
      data@data <- dplyr::select(data@data, -tidyselect::one_of(c("decimallongitude", "LONGITUDE", "decimalLongitude", "Longitude", "long", "Long")))
      data@data <- dplyr::select(data@data, -tidyselect::one_of(c("decimallatitude", "LATITUDE", "decimaLatitude", "Latitude", "lat", "Lat")))
    }
  }
  if(crop == TRUE){
    # Create extent object
    extent <- raster::extent(as.vector(t(sp::bbox(data))))
    r <- raster::raster(x=extent, res=res, crs=crs)
  } else{
    r <- raster::raster(xmn=-180, xmx=180, ymn=-90, ymx=90, res=res, 
                        crs=sp::CRS("+proj=longlat +datum=WGS84 +no_defs +ellps=WGS84 +towgs84=0,0,0"))
    r <- projectExtent(r, crs)
  }
  
  # Create empty raster
  r_data <- lapply(colnames(data@data), function(z){
    tryCatch(raster::rasterize(x=data, y=r, res=res, field=z), error=function(e) NULL)
  })
  names(r_data) <- colnames(data@data)
  r_data <- Filter(Negate(is.null), r_data)
  r_data <- raster::stack(r_data)
  return(r_data)
}