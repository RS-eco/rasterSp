## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
filedir <- "/media/matt/Data/Documents/Wissenschaft/Data/"
birdfiles <- list.files(paste0(filedir, "/BirdLife_2018/"), pattern=".shp", full.names=TRUE)
library(rgdal)
bird1 <- readOGR(birdfiles[grepl(birdfiles, pattern="Sturnus_vulgaris")]) # European starling
bird2 <- readOGR(birdfiles[grepl(birdfiles, pattern="Threskiornis_aethiopicus")]) #Sacred ibis
bird3 <- readOGR(birdfiles[grepl(birdfiles, pattern="Passer_domesticus")]) # House sparrow

## ---- fig.show='hold'---------------------------------------------------------
plot(bird1, main="European starling")
plot(bird1[bird1@data$ORIGIN==1,], add=T, col="blue")
plot(bird1[bird1@data$ORIGIN==3,], add=T, col="red")
plot(bird3, main="House sparrow")
plot(bird3[bird3@data$ORIGIN==1,], add=T, col="blue")
plot(bird3[bird3@data$ORIGIN==3,], add=T, col="red")

## ---- fig.show='hold'---------------------------------------------------------
plot(bird2[bird2@data$ORIGIN==1,], col="blue", main="Sacred ibis (native)")
plot(bird2[bird2@data$ORIGIN==3,], col="red", main="Sacred ibis (introduced)")

