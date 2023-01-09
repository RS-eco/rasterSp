## Rasterize species data

### Get species information

filedir <- "/home/matt/Documents/"

# IUCN data can be directly downloaded from:
#download.file("http://spatial-data.s3.amazonaws.com/groups/REPTILES.zip", 
#               destfile=paste0(filedir, "/IUCN/REPTILES.zip"))
#' We access the species shapefile, extract the species infomation and save it to a csv file.

library(dplyr); library(magrittr)

# Read amphibians
amphibians <-  sf::read_sf(dsn=paste0(filedir, "/IUCN/AMPHIBIANS.shp"))
amphibians %<>% as.data.frame() %>% select(-geometry) %>% 
  group_by(binomial, presence, origin, seasonal, kingdom_na, 
           phylum_nam, class_name, order_name, family_nam) %>% 
  summarise_at("shape_Area", sum)
save(amphibians, file="data/amphibians.rda", compress="xz")

# Read odonata data
odonata <- sf::read_sf(dsn=paste0(filedir, "/IUCN/FW_ODONATA_v6.2/FW_ODONATA.shp"))
odonata %<>% as.data.frame() %>% select(-geometry) %>% 
  group_by(binomial, presence, origin, seasonal, kingdom, phylum, class, order_, family) %>% 
  summarise_at("SHAPE_Area", sum)
save(odonata, file="data/odonata.rda", compress="xz")

# Read terrestrial mammals
ter_mammals <- sf::read_sf(dsn=paste0(filedir, "/IUCN/TERRESTRIAL_MAMMALS.shp"))
ter_mammals %<>% as.data.frame() %>% select(-geometry) %>% 
  group_by(binomial, presence, origin, seasonal, kingdom_na, 
           phylum_nam, class_name, order_name, family_nam) %>% 
  summarise_at("shape_Area", sum)

# Remove the polar bear (Ursus maritimus) 
# as it is causing the marine regions in the Arctic to show up 
# with a species richness of 1
ter_mammals %<>% filter(binomial != "Ursus maritimus")

# Save ter_mammals file
save(ter_mammals, file="data/ter_mammals.rda", compress="xz")

# Read reptiles
reptiles <- sf::read_sf(dsn=paste0(filedir, "/IUCN/REPTILES.shp"))
reptiles %<>% as.data.frame() %>% select(-geometry) %>% 
  group_by(binomial, presence, origin, seasonal, kingdom, phylum,
           class, order_, family) %>% summarise_at("SHAPE_Area", sum)
# Save reptiles file
save(reptiles, file="data/reptiles.rda", compress="xz")

# Read reptiles
reptiles1 <- sf::read_sf(dsn=paste0(filedir, "/IUCN/REPTILES_v6.3/REPTILES_PART1.shp"))
reptiles1 %<>% as.data.frame() %>% select(-geometry) %>% 
  group_by(sci_name, presence, origin, seasonal, kingdom, phylum,
           class, order_, family) %>% summarise_at("SHAPE_Area", sum)
reptiles2 <- sf::read_sf(dsn=paste0(filedir, "/IUCN/REPTILES_v6.3/REPTILES_PART2.shp"))
reptiles2 %<>% as.data.frame() %>% select(-geometry) %>% 
  group_by(sci_name, presence, origin, seasonal, kingdom, phylum,
           class, order_, family) %>% summarise_at("SHAPE_Area", sum)
reptiles_v6.3 <- bind_rows(reptiles1, reptiles2)
# Save reptiles file
save(reptiles_v6.3, file="data/reptiles_v6.3.rda", compress="xz")

#' The BirdLife data is missing information on the taxonomy of the species.
#' But, BirdLife provides a checklist for each version of their data product 
#' (http://datazone.birdlife.org/species/taxonomy).

#**Note:** I am not sure if the data currently used is Version 7 or older, 
#* but here we use checklist v7.

#Read bird data
birds <- lapply(list.files(paste0(filedir, "/BirdLife"), 
                           pattern=".shp", full.names=TRUE), FUN=function(x){
                             data <- sf::st_read(x)
                             area <- sf::st_area(data)
                             data %<>% as.data.frame() %>% 
                               select(c("SISID", "SCINAME", "PRESENCE", "ORIGIN", "SEASONAL"))
                             data$area <- area
                             return(data)
                           })
birds <- dplyr::bind_rows(birds)

# Download BirdLife checklist and read into R
temp <- tempfile(fileext = ".zip")
download.file("http://datazone.birdlife.org/userfiles/file/Species/Taxonomy/BirdLife_Checklist_Version_70.zip", temp, method = "auto", quiet = TRUE, mode="wb")
folder <- unzip(temp, exdir = ".")
unlink(temp)
birdtaxa <- readxl::read_xlsx("./Checklist v7 July14/BirdLife_Checklist_Version_7.xlsx", skip=1)
colnames(birdtaxa)[13] <- "SISRecID"
birdtaxa$SISRecID <- as.factor(birdtaxa$SISRecID)
file.remove(folder)

# Join checklist with bird data
birdtaxa$SISRecID <- as.numeric(birdtaxa$SISRecID)
birds <- dplyr::left_join(birds, birdtaxa, by=c("SCINAME" = "Scientific name"))
colnames(birds)

# Create unique list of species
birds <- birds %>% select(SCINAME, PRESENCE, ORIGIN, SEASONAL, Order, "Family name", area,
                          "2014 IUCN Red List category") %>% distinct()
colnames(birds) <- c("SCINAME", "PRESENCE", "ORIGIN", "SEASONAL", "Order", "Family.name", "area", "code")

##########

## Remove seabirds from birds file

# Load seabird names to remove
data(seabird_species)
# See the data-raw file (find-marinespecies.R) for a way of identifying sea bird species names.

# Change species names to correct format
seabird_species$species <- gsub(seabird_species$species, pattern = "\\_", replacement=" ")

# Remove seabird names from bird info file
ter_birds <- birds[!birds$SCINAME %in% seabird_species$species,]

# Save species information to file
save(ter_birds, file="data/ter_birds.rda", compress="xz")

# GARD reptile data was downloaded from: https://datadryad.org/resource/doi:10.5061/dryad.83s7k

# When using this data, please cite the original publication:

# Roll U, Feldman A, Novosolov M, Allison A, Bauer AM, Bernard R, Böhm M, Castro-Herrera F, Chirio L, Collen B, Colli GR, Dabool L, Das I, Doan TM, Grismer LL, Hoogmoed M, Itescu Y, Kraus F, LeBreton M, Lewin A, Martins M, Maza E, Meirte D, Nagy ZT, de C. Nogueira C, Pauwels OSG, Pincheira-Donoso D, Powney GD, Sindaco R, Tallowin OJS, Torres-Carvajal O, Trape J, Vidan E, Uetz P, Wagner P, Wang Y, Orme CDL, Grenyer R, Meiri S (2017) The global distribution of tetrapods reveals a need for targeted reptile conservation. Nature Ecology & Evolution 1(11): 1677–1682. https://doi.org/10.1038/s41559-017-0332-2

# Additionally, please cite the Dryad data package:

# Meiri S, Roll U, Grenyer R, Feldman A, Novosolov M, Bauer AM (2017) 
# Data from: The global distribution of tetrapods reveals a need for targeted reptile conservation. 
# Dryad Digital Repository. https://doi.org/10.5061/dryad.83s7k 

# Read reptiles
gard_reptiles <- sf::read_sf(dsn=paste0(filedir, "/GARD1.1_dissolved_ranges/modeled_reptiles.shp"))

# No need to subset data
gard_reptiles %<>% as.data.frame() %>% select(-geometry) 
#%>% group_by(Binomial) %>% summarise_at("Area", sum)

# Save reptiles file
save(gard_reptiles, file="data/gard_reptiles.rda", compress="xz")

### Save terrestrial species data to csv file

#' First we need to rasterize the shapefiles, using the rasterizeRange function, see the README.Rmd for how this is done.

#' **Note:** The speciesData function is internally using 75 % of the number of cores for parallel computing.

source("R/speciesData.R")
data(amphibians)
speciesData(species_names=unique(amphibians$binomial), 
            path=paste0(filedir, "/SpeciesData/"), 
            filename="data/amphibians_dist.csv.xz")

data(odonata)
speciesData(species_names=unique(odonata$binomial), 
            path=paste0(filedir, "SpeciesData/"), 
            filename="data/odonata_dist.csv.xz")

data(ter_mammals)
speciesData(species_names=unique(ter_mammals$binomial), path=paste0(filedir, "/SpeciesData/"), 
            filename="data/ter_mammals_dist.csv.xz")

data(reptiles)
speciesData(species_names=unique(reptiles$binomial), path=paste0(filedir, "/SpeciesData/"), 
            filename="data/reptiles_dist.csv.xz")

data(reptiles_v6.3)
speciesData(species_names=unique(reptiles_v6.3$sci_name), path=paste0(filedir, "/ReptileData_v6.3/"), 
            filename="data/reptiles_v6.3_dist.csv.xz")

data(gard_reptiles)
speciesData(species_names=unique(gard_reptiles$Binomial), path=paste0(filedir, "/GARD_SpeciesData/"), 
            filename="data/gard_reptiles_dist.csv.xz")

data(ter_birds)
speciesData(species_names=unique(ter_birds$SCINAME), path=paste0(filedir, "/SpeciesData/"), 
            filename="data/ter_birds_dist.csv.xz")

# <!--Note: There are 10423 shapefiles, 10315 tif files and ... that are considered by %in%.-->

# Save dist files to .rda and deleted .csv.xz
amphibians_dist <- read.csv("data/amphibians_dist.csv.xz")
odonata_dist <- read.csv("data/odonata_dist.csv.xz")
ter_mammals_dist <- read.csv("data/ter_mammals_dist.csv.xz")
ter_birds_dist <- read.csv("data/ter_birds_dist.csv.xz")
gard_reptiles_dist <- read.csv("data/gard_reptiles_dist.csv.xz")
reptiles_dist <- read.csv("data/reptiles_dist.csv.xz")
reptiles_v6.3_dist <- read.csv("data/reptiles_v6.3_dist.csv.xz")

save(amphibians_dist, file="data/amphibians_dist.rda", compress="xz")
save(odonata_dist, file="data/odonata_dist.rda", compress="xz")
save(ter_mammals_dist, file="data/ter_mammals_dist.rda", compress="xz")
save(ter_birds_dist, file="data/ter_birds_dist.rda", compress="xz")
save(gard_reptiles_dist, file="data/gard_reptiles_dist.rda", compress="xz")
save(reptiles_dist, file="data/reptiles_dist.rda", compress="xz")
save(reptiles_v6.3_dist, file="data/reptiles_v6.3_dist.rda", compress="xz")
file.remove("data/amphibians_dist.csv.xz", "data/odonata_dist.csv.xz", "data/ter_mammals_dist.csv.xz", 
            "data/ter_birds_dist.csv.xz", "data/gard_reptiles_dist.csv.xz", "data/reptiles_dist.csv.xz",
            "data/reptiles_v6.3_dist.csv.xz")

# Extract data of non-modelled species

load("data/amphibians_dist.rda")
load("data/odonata_dist.rda")
load("data/ter_mammals_dist.rda")
load("data/ter_birds_dist.rda")
load("data/gard_reptiles_dist.rda")
load("data/reptiles_dist.rda")
load("data/reptiles_v6.3_dist.rda")

# Create group column
amphibians_dist$group <- "Amphibians"
odonata_dist$group <- "Odonata"
ter_mammals_dist$group <- "Mammals"
ter_birds_dist$group <- "Birds"
reptiles_dist$group <- "Reptiles"
reptiles_v6.3_dist$group <- "Reptiles"
gard_reptiles_dist$group <- "GARD Reptiles"

# Create presence column
amphibians_dist$presence <- 1 
odonata_dist$presence <- 1 
ter_mammals_dist$presence <- 1
ter_birds_dist$presence <- 1
reptiles_dist$presence <- 1
reptiles_v6.3_dist$presence <- 1
gard_reptiles_dist$presence <- 1

# Number of records per species
count_sp_amphibian <- amphibians_dist %>% 
  group_by(species, group) %>% 
  summarise(sum = sum(presence))

count_sp_odonata <- odonata_dist %>% 
  group_by(species, group) %>% 
  summarise(sum = sum(presence))

count_sp_ter_mammal <- ter_mammals_dist %>% 
  group_by(species, group) %>% 
  summarise(sum = sum(presence))

count_sp_ter_bird <- ter_birds_dist %>% 
  group_by(species, group) %>% 
  summarise(sum = sum(presence))

count_sp_reptiles <- reptiles_dist %>% 
  group_by(species, group) %>% 
  summarise(sum = sum(presence))

count_sp_reptiles_v6.3 <- reptiles_v6.3_dist %>% 
  group_by(species, group) %>% 
  summarise(sum = sum(presence))

count_sp_gard_reptiles <- gard_reptiles_dist %>% 
  group_by(species, group) %>% 
  summarise(sum = sum(presence))

# Combine counts per species into one dataframe
species_presences_alltaxa <- rbind(count_sp_amphibian, count_sp_odonata, count_sp_ter_bird, 
                                   count_sp_ter_mammal, count_sp_reptiles, count_sp_reptiles_v6.3, 
                                   count_sp_gard_reptiles)
rm(count_sp_amphibian, count_sp_odonata, count_sp_ter_mammal, count_sp_ter_bird, 
   count_sp_reptiles, count_sp_reptiles_v6.3, count_sp_gard_reptiles)

species_presences_smallrange <- species_presences_alltaxa %>% 
  filter(sum < 10)

amphibians_dist_smallrange <- amphibians_dist %>% 
  filter(species %in% species_presences_smallrange$species)
odonata_dist_smallrange <- odonata_dist %>% 
  filter(species %in% species_presences_smallrange$species)
ter_mammals_dist_smallrange <- ter_mammals_dist %>% 
  filter(species %in% species_presences_smallrange$species)
ter_birds_dist_smallrange <- ter_birds_dist %>% 
  filter(species %in% species_presences_smallrange$species)
reptiles_dist_smallrange <- reptiles_dist %>% 
  filter(species %in% species_presences_smallrange$species)
reptiles_v6.3_dist_smallrange <- reptiles_v6.3_dist %>% 
  filter(species %in% species_presences_smallrange$species)
gard_reptiles_dist_smallrange <- gard_reptiles_dist %>% 
  filter(species %in% species_presences_smallrange$species)

# Save to file
save(amphibians_dist_smallrange, file="data/amphibians_dist_smallrange.rda", compress="xz")
save(odonata_dist_smallrange, file="data/odonata_dist_smallrange.rda", compress="xz")
save(ter_mammals_dist_smallrange, file="data/ter_mammals_dist_smallrange.rda", compress="xz")
save(ter_birds_dist_smallrange, file="data/ter_birds_dist_smallrange.rda", compress="xz")
save(reptiles_dist_smallrange, file="data/reptiles_dist_smallrange.rda", compress="xz")
save(reptiles_v6.3_dist_smallrange, file="data/reptiles_v6.3_dist_smallrange.rda", compress="xz")
save(gard_reptiles_dist_smallrange, file="data/gard_reptiles_dist_smallrange.rda", compress="xz")

## Create dataframe of species range areas and select smallest 15%
source("R/getRangeArea.R")
range_amphibians <- getRangeArea(dsn=paste0(filedir, "/IUCN/AMPHIBIANS.shp"), 
                                 seasonal=c(1,2), origin=1, presence=c(1,2), make_valid=T)
amphibians_endemic <- range_amphibians %>% filter(area <= quantile(range_amphibians$area, probs=0.15, type=7))
save(amphibians_endemic, file="data/amphibians_endemic.rda", compress="xz")

range_odonata <- getRangeArea(dsn=paste0(filedir, "/IUCN/FW_ODONATA_v6.2/FW_ODONATA.shp"), 
                              seasonal=c(1,2), origin=1, presence=c(1,2), make_valid=T)
odonata_endemic <- range_odonata %>% filter(area <= quantile(range_odonata$area, probs=0.15, type=7))
save(odonata_endemic, file="data/odonata_endemic.rda", compress="xz"); invisible(gc())

range_mammals <- getRangeArea(dsn=paste0(filedir, "/IUCN/TERRESTRIAL_MAMMALS.shp"), 
                              seasonal=c(1,2), origin=1, presence=c(1,2), make_valid=T)
ter_mammals_endemic <- range_mammals %>% filter(area <= quantile(range_mammals$area, probs=0.15))
save(ter_mammals_endemic, file="data/ter_mammals_endemic.rda", compress="xz")

range_birds <- getRangeArea(dsn=list.files(paste0(filedir, "/BirdLife/"), pattern=".shp", full.names=TRUE), 
                            id="SCINAME", seasonal=c(1,2), origin=1, presence=c(1,2), make_valid=T)
ter_birds_endemic <- range_birds %>% filter(area <= quantile(range_birds$area, probs=0.15))
save(ter_birds_endemic, file="data/ter_birds_endemic.rda", compress="xz"); gc()

range_reptiles <- getRangeArea(dsn=paste0(filedir, "/IUCN/REPTILES.shp"), 
                                seasonal=c(1,2), origin=1, presence=c(1,2), make_valid=F); gc()
reptiles_endemic <- range_reptiles %>% filter(area <= quantile(range_reptiles$area, probs=0.15)); rm(range_reptiles); invisible(gc())
save(reptiles_endemic, file="data/reptiles_endemic.rda", compress="xz"); gc()

range_reptiles_v6.3_1 <- getRangeArea(dsn=paste0(filedir, "/IUCN/REPTILES_v6.3/REPTILES_PART1.shp"), 
                                      id="sci_name", seasonal=c(1,2), origin=1, presence=c(1,2), make_valid=F); gc()
range_reptiles_v6.3_2 <- getRangeArea(dsn=paste0(filedir, "/IUCN/REPTILES_v6.3/REPTILES_PART2.shp"), 
                                      id="sci_name", seasonal=c(1,2), origin=1, presence=c(1,2), make_valid=F); gc()
range_reptiles_v6.3 <- bind_rows(range_reptiles_v6.3_1, range_reptiles_v6.3_2); rm(range_reptiles_v6.3_1, range_reptiles_v6.3_2); gc()
reptiles_v6.3_endemic <- range_reptiles_v6.3 %>% filter(area <= quantile(range_reptiles_v6.3$area, probs=0.15)) %>% data.frame()
save(reptiles_v6.3_endemic, file="data/reptiles_v6.3_endemic.rda", compress="xz"); gc()

range_gard_reptiles <- getRangeArea(dsn=paste0(filedir, "/GARD1.1_dissolved_ranges/modeled_reptiles.shp"), id="Binomial", make_valid=T)
gard_reptiles_endemic <- range_gard_reptiles %>% 
  filter(area <= quantile(range_gard_reptiles$area, probs=0.15)) %>% data.frame()
save(gard_reptiles_endemic, file="data/gard_reptiles_endemic.rda", compress="xz"); gc()

# Create dataframe of threatened species (amphibian and mammal files come from ...,
# bird data is included in the BirdLife checklist files).

#Get information on threat
load("data/threat_status_mammals.rda")
load("data/threat_status_amphibians.rda")
load("data/ter_birds.rda")

ter_birds <- ter_birds %>% select(SCINAME, code) %>% unique()

# IUCN Categories
#EX = Extinct, EW = Extinct in the Wild, CR = Critically Endangered, EN = Endangered, VU = Vulnerable
#NT = Near Threatened, LC = Least Concern, DD = Data deficient, NE = Not evaluated

# Extract distribution of threatened species
amphibians_threatened <- amphibians_dist %>% 
  filter(species %in% threat_status_amphibians$binomial[threat_status_amphibians$code %in% c("EN", "CR", "VU")])
ter_mammals_threatened <- ter_mammals_dist %>% 
  filter(species %in% threat_status_mammals$binomial[threat_status_mammals$code %in% c("EN", "CR", "VU")])
ter_birds_threatened <- ter_birds_dist %>% 
  filter(species %in% ter_birds$SCINAME[ter_birds$code %in% c("EN", "CR", "VU")])
save(amphibians_threatened, file="data/amphibians_threatened.rda", compress="xz")
save(ter_mammals_threatened, file="data/ter_mammals_threatened.rda", compress="xz")
save(ter_birds_threatened, file="data/ter_birds_threatened.rda", compress="xz")
