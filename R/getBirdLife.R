#' Download range maps of birds from BirdLife International
#' 
#' This function automatically downloads the BirdLife International
#' range maps for the world's bird species, 
#' given that an existing user name and password are provided.
#' 
#' @param user E-mail address you used to login at the IUCN Website
#' @param password Password you used to login at the IUCN Website
#' @param path Path to download location
#' @return location of data files
#' @examples
#' getBirdLife()
#' @export
getBirdLife <- function(user=NA, password=NA, path=getwd()){
 if(!is.na(user) & !is.na(password)){
   #download.file()
 } else{
   print("No username and/or password was provided.") 
 }
}
