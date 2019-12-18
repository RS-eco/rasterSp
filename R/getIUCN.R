#' Download IUCN range maps for a given taxa or group
#' 
#' This function automatically downloads IUCN range maps of a given taxa or group
#' to a specified location.
#' 
#' @param taxa character, Name of taxa to download
#' @param group chracter, Name of subgroup, in case you are interested in a subset of species
#' @param user E-mail address you used to login at the IUCN Website
#' @param password Password you used to login at the IUCN Website
#' @param path Path to download location
#' @return location of data files
#' @examples
#' \dontrun{
#' getIUCN(taxa="Reptiles", group="Chameleons")
#' 
#' getIUCN(group="Chameleons")
#' }
#' @export
getIUCN <- function(taxa, group, user, password, path=getwd()){
  if(taxa == "Birds"){
    print("Please check ouf the getBirdLife function or 
          have a look at BirdLife International (http://www.birdlife.org/)")
  } else if(taxa == "Marine Groups"){
    if(group %in% c("Cone Snails", "Corals", "Lobsters",
                    "Mangroves", "Sea Cucumbers", "Seagrasses")){
      #download.file()
    } else{
      print("Please select one of the following groups: 
            Cone Snails, Corals, Lobsters, Mangroves, Sea Cucumbers, Seagrasses")
    }
  } else if(group %in% c("Marine Mammals", "Terrestrial Mammals",
                         "Tailless Amphibians", "Tailed Amphibians",
                         "Caecilian Amphibians", "Sea Snakes", "Chameleons",
                         "Crocodiles", "Angelfish", "Bonefishes and Tarpons",
                         "Butterflyfish", "Combtooth Blennies", "Damselfish",
                         "Groupers", "Hagfish", "Pufferfish", "Sea Bream and Porgies",
                         "Surgeonfish, Tangs and Unicornfish", "Wrasse", "Tunas and Billfishes")){
    #download.file()
  } else if(group %in% c("Fish", "Mollusc", "Plants", "Odonata", "Shrimps", "Crabs", "Crayfish")){
    if(is.na(taxa)){
      print("Please provide onf of the two taxa: Freshwater Polygon Groups or Freshwater HydroBASIN Tables")
    } else if (taxa == "Freshwater Polygon Groups"){
      #download.file()
    } else if (taxa == "Freshwater HydroBASIN Tables"){
      #download.file()
    }
  } else if(is.na(group)){
    if(taxa %in% c("Mammals", "Amphibians", "Reptiles", 
                   "Chondrichthyes", "Marine Fish", 
                   "Freshwater Polygon Groups", "Freshwater HydroBASIN Tables")){
      #download.file("http://www.iucnredlist.org/technical-documents/spatial-data") 
    }
  } else{
    print("Please provide a valid taxa or group!")
  }
}