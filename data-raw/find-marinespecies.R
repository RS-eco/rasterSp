#We can find bird species which occur in the ocean, by:
  
# Read bird data
load("data/ter_birds_dist.rda")

# Read land outline
data(outline, package="ggmap2")

# Convert bird data to a spatial object
sp::coordinates(ter_birds_dist) <- ~x+y

# Make sure both files have the same projection
proj4string(ter_birds_dist) <- raster::crs(outline)

# Use over to subset bird_data which is on land
ter_birds <- ter_birds_dist %over% outline

#Now, we rasterize our data to plot and select a region, which still contains seabirds

library(raster)
coordinates(ter_birds_dist) <- ~x+y
proj4string(ter_birds_dist) <- crs.wgs84
gridded(ter_birds_dist) <- TRUE
r_ter_bird_data <- raster(ter_birds_dist)

# Select region which still contains seabirds
plot(r_ter_bird_data)
select(r_ter_bird_data)

# Manually select this region to get seabird names
marine_birds <- ter_birds_dist[ter_birds_dist$x < 1.5 & 
                               ter_birds_dist$x > -25 & 
                               ter_birds_dist$y > -47 & 
                               ter_birds_dist$y < -41,]
unique(marine_birds$species)
