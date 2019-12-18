#' R Package to rasterize and summarise IUCN range maps
#'
#' @name rasterSp package
#' @aliases rasterSppackage
#' @docType package
#' @title R Package to rasterize and summarise IUCN range maps
#' @author RS-eco
#'
#' @import methods grDevices raster rgdal parallel grid tidyselect
#' @importFrom stats var
#' @importFrom data.table rbindlist
#' @importFrom dplyr left_join %>%
#' @references https://www.iucnredlist.org/resources/spatial-data-download; 
#' http://datazone.birdlife.org/species/spcdistPOS; 
#' https://datadryad.org/resource/doi:10.5061/dryad.83s7k
#' @keywords package
#'
NULL
#'
#' @docType data
#' @name amphibians
#' @title Latin names of Amphibian Species
#' @description Latin names of Amphibian Species
#' @details This dataset contains all Latin Names of Amphibians 
#' that were derived from the IUCN database.
#' @format A \code{data.frame} with 6618 observations and 10 variables.
#' 
NULL
#'
#' @docType data
#' @name amphibians_dist
#' @title Distribution of amphibians at 0.5 degree spatial resolution
#' @description Data with x,y coordinates for each amphibian species (present in 0.5 degree grid cells)
#' @details This dataset contains the distribution of all amphibian species (on a 0.5 degree grid)
#' according to the IUCN range maps.
#' @format A \code{data.frame} with 792695 observations and 3 variables.
NULL
#'
#' @docType data
#' @name amphibians_dist_smallrange
#' @title Distribution of small ranging amphibians
#' @description Data with x,y coordinates for each amphibian species that has less than 10 occurrences (present in 0.5 degree grid cells)
#' @details This dataset contains the distribution of all amphibian species that have a small range (less than 10 occurrences on a 0.5 degree grid)
#' according to the IUCN range maps.
#' @format A \code{data.frame} with 10463 observations and 5 variables.
NULL
#'
#' @docType data
#' @name amphibians_endemic
#' @title Names of endemic amphibian Species
#' @description Data with endemic amphibian species names and their range area
#' @details This dataset contains the name and range area of all endemic amphibian species. 
#' Species are classified as endemic if their range area is smaller or equal to the range area of the smallest ranging 15% of all species
#' @format A \code{data.frame} with 2700 observations and 2 variables.
NULL
#'
#' @docType data
#' @name amphibians_threatened
#' @title Distribution of threatened amphibian species
#' @description Data with x,y coordinates for each amphibian species that is Critically Endangered, Endangered or Vulnerable
#' @details This dataset contains the distribution of all amphibian species that are 
#' Critically Endangered, Endangered or Vulnerable according to the IUCN threat status.
#' @format A \code{data.frame} with 229425 observations and 5 variables.
NULL
#'
#' @docType data
#' @name gard_reptiles
#' @title Latin names of Reptile Species
#' @description Latin names of Reptile Species
#' @details This dataset contains all Latin Names of Reptiles
#' that were derived from GARD ranges.
#' @format A \code{data.frame} with 10064 observations and 8 variables.
NULL
#'
#' @docType data
#' @name gard_reptiles_dist
#' @title Distribution of reptiles at 0.5 degree spatial resolution
#' @description Data with x,y coordinates for each reptile species (present in 0.5 degree grid cells)
#' @details This dataset contains the distribution of all reptile species (on a 0.5 degree grid)
#' according to the GARD ranges.
#' @format A \code{data.frame} with 1001518 observations and 3 variables.
NULL
#'
#' @docType data
#' @name gard_reptiles_dist_smallrange
#' @title Distribution of small ranging reptiles
#' @description Data with x,y coordinates for each reptile species that has less than 10 occurrences (present in 0.5 degree grid cells)
#' @details This dataset contains the distribution of all reptile species that have a small range (less than 10 occurrences on a 0.5 degree grid)
#' according to the GARD range maps.
#' @format A \code{data.frame} with 15960 observations and 5 variables.
NULL
#'
#' @docType data
#' @name gard_reptiles_endemic
#' @title Names of endemic reptile species
#' @description Data with endemic GARD reptile species names and their range area
#' @details This dataset contains the name and range area of all endemic reptile species. 
#' Species are classified as endemic if their range area is smaller or equal to the range area of the smallest ranging 15% of all species.
#' @format A \code{data.frame} with 0 observations and 1 variables.
NULL
#'
#' @docType data
#' @name odonata_dist_eur
#' @title Distribution of Odonata species at 0.11 degree spatial resolution for Europe
#' @description Data with x,y coordinates for each Odonata species (present in 0.11 degree grid cells) in Europe
#' @details This dataset contains the distribution of all Odonata species (on a 0.11 degree grid) in Europe
#' according to the IUCN ranges.
#' @format A \code{data.frame} with 2334175 observations and 7 variables.
NULL
#'
#' @docType data
#' @name reptiles
#' @title Latin names of Reptile Species
#' @description Latin names of Reptile Species
#' @details This dataset contains all Latin Names of Reptiles
#' that were derived from the IUCN database.
#' @format A \code{data.frame} with 7066 observations and 10 variables.
NULL
#'
#' @docType data
#' @name reptiles_dist
#' @title Distribution of reptiles at 0.5 degree spatial resolution
#' @description Data with x,y coordinates for each reptile species (present in 0.5 degree grid cells)
#' @details This dataset contains the distribution of all reptile species (on a 0.5 degree grid)
#' according to the IUCN ranges.
#' @format A \code{data.frame} with 1224860 observations and 3 variables.
NULL
#'
#' @docType data
#' @name reptiles_dist_smallrange
#' @title Distribution of small ranging reptiles
#' @description Data with x,y coordinates for each reptile species that has less than 10 occurrences (present in 0.5 degree grid cells)
#' @details This dataset contains the distribution of all reptile species that have a small range (less than 10 occurrences on a 0.5 degree grid)
#' according to the IUCN range maps.
#' @format A \code{data.frame} with 11158 observations and 5 variables.
NULL
#'
#' @docType data
#' @name reptiles_endemic
#' @title Names of endemic reptile species
#' @description Data with endemic IUCN reptile species names and their range area
#' @details This dataset contains the name and range area of all endemic reptile species. 
#' Species are classified as endemic if their range area is smaller or equal to the range area of the smallest ranging 15% of all species.
#' @format A \code{data.frame} with 1344 observations and 2 variables.
NULL
#'
#' @docType data
#' @name seabird_species
#' @title Latin names of all sea bird species
#' @description Latin names of all bird species that occur in the ocean
#' @details This dataset contains all Latin Names of Birds that have part or all of their range within the sea.
#' @format A \code{data.frame} with 358 observations and 1 variable.
NULL
#'
#' @docType data
#' @name ter_birds
#' @title Latin names of Bird Species
#' @description Latin names of Bird Species
#' @details This dataset contains all Latin Names of Birds
#' that were derived from the Bird Life Database.
#' @format A \code{data.frame} with 17835 observations and 8 variable.
NULL
#'
#' @docType data
#' @name ter_birds_dist
#' @title Distribution of terrestrial birds at 0.5 degree spatial resolution
#' @description Data with x,y coordinates for each terrestrial bird species (present in 0.5 degree grid cells)
#' @details This dataset contains the distribution of all terrestrial bird species (on a 0.5 degree grid)
#' according to the IUCN range maps.
#' @format A \code{data.frame} with 10108394 observations and 3 variables.
NULL
#'
#' @docType data
#' @name ter_birds_dist_eur
#' @title Distribution of terrestrial birds at 0.11 degree spatial resolution for Europe
#' @description Data with x,y coordinates for each terrestrial bird species (present in 0.11 degree grid cells)
#' @details This dataset contains the distribution of all terrestrial bird species (on a 0.11 degree grid) for Europe
#' according to the IUCN range maps.
#' @format A \code{data.frame} with 10108394 observations and 3 variables.
NULL
#'
#' @docType data
#' @name ter_birds_dist_smallrange
#' @title Distribution of small ranging bird species
#' @description Data with x,y coordinates for each bird species that has less than 10 occurrences (present in 0.5 degree grid cells)
#' @details This dataset contains the distribution of all bird species that have a small range (less than 10 occurrences on a 0.5 degree grid)
#' according to the range maps derived from the Bird Life Database.
#' @format A \code{data.frame} with 3878 observations and 5 variables.
NULL
#'
#' @docType data
#' @name ter_birds_endemic
#' @title Names of endemic bird Species
#' @description Data with endemic terrestrial bird species names and their range area
#' @details This dataset contains the name and range area of all endemic terrestrial bird species. 
#' Species are classified as endemic if their range area is smaller or equal to the range area of the smallest ranging 15% of all species.
#' @format A \code{data.frame} with 1956 observations and 2 variables.
NULL
#'
#' @docType data
#' @name ter_birds_threatened
#' @title Distribution of threatened bird species
#' @description Data with x,y coordinates for each bird species that is Critically Endangered, Endangered or Vulnerable
#' @details This dataset contains the distribution of all bird species that are 
#' Critically Endangered, Endangered or Vulnerable according to the IUCN threat status.
#' @format A \code{data.frame} with 204060 observations and 5 variables.
NULL
#'
#' @docType data
#' @name ter_mammals
#' @title Latin names of Terrestrial Mammal Species
#' @description Latin names of Terrestrial Mammal Species
#' @details This dataset contains all Latin Names of Terrestrial Mammals 
#' that were derived from the IUCN database.
#' @format A \code{data.frame} with 6067 observations and 10 variables.
NULL
#'
#' @docType data
#' @name ter_mammals_dist
#' @title Distribution of terrestrial mammals at 0.5 degree spatial resolution
#' @description Data with x,y coordinates for each terrestrial mammal species (present in 0.5 degree grid cells)
#' @details This dataset contains the distribution of all terrestrial mammal species (on a 0.5 degree grid)
#' according to the IUCN range maps.
#' @format A \code{data.frame} with 3396275 observations and 3 variables.
NULL
#'
#' @docType data
#' @name ter_mammals_dist_smallrange
#' @title Distribution of small ranging mammal species
#' @description Data with x,y coordinates for each mammal species that has less than 10 occurrences (present in 0.5 degree grid cells)
#' @details This dataset contains the distribution of all mammal species that have a small range (less than 10 occurrences on a 0.5 degree grid)
#' according to the IUCN range maps.
#' @format A \code{data.frame} with 3898 observations and 5 variables.
NULL
#'
#' @docType data
#' @name ter_mammals_endemic
#' @title Names of endemic mammal Species
#' @description Data with endemic mammal species names and their range area
#' @details This dataset contains the name and range area of all endemic terrestrial mammal species. 
#' Species are classified as endemic if their range area is smaller or equal to the range area of the smallest ranging 15% of all species.
#' @format A \code{data.frame} with 4852 observations and 2 variables.
NULL
#'
#' @docType data
#' @name ter_mammals_threatened
#' @title Distribution of threatened mammal species
#' @description Data with x,y coordinates for each mammal species that is Critically Endangered, Endangered or Vulnerable
#' @details This dataset contains the distribution of all mammal species that are 
#' Critically Endangered, Endangered or Vulnerable according to the IUCN threat status.
#' @format A \code{data.frame} with 169656 observations and 5 variables.
NULL
#'
#' @docType data
#' @name threat_status_amphibians
#' @title IUCN threat status for each amphibian species of the IUCN range map data
#' @description Data with the species information of each amphibian and its current IUCN threat status
#' @details This dataset contains the name of every amphibian species present in the IUCN range map data 
#' and their current IUCN threat status
#' @format A \code{data.frame} with 6997 observations and 10 variables.
NULL
#'
#' @docType data
#' @name threat_status_mammals
#' @title IUCN threat status for each mammal species of the IUCN range map data
#' @description Data with the species information of each mammal and its current IUCN threat status
#' @details This dataset contains the name of every mammal species present in the IUCN range map data 
#' and their current IUCN threat status
#' @format A \code{data.frame} with 5472 observations and 10 variables.
NULL