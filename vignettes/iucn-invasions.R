## ----setup, include = FALSE---------------------------------------------------
knitr::opts_chunk$set(
  collapse = TRUE,
  comment = "#>"
)

## -----------------------------------------------------------------------------
library(rasterSp)
sturnus_vulgaris <- sf::st_read(system.file("extdata", "sturnus_vulgaris.shp", package = "rasterSp"))
passer_domesticus <-  sf::st_read(system.file("extdata", "passer_domesticus.shp", package = "rasterSp"))
threskiornis_aethiopicus <-  sf::st_read(system.file("extdata", "threskiornis_aethiopicus.shp", 
                                                    package = "rasterSp"))

## ---- fig.show='hold'---------------------------------------------------------
library(sf); library(dplyr)
sturnus_vulgaris %>% st_geometry() %>% plot(main="European starling")
sturnus_vulgaris %>% filter(ORIGIN==1) %>% st_geometry() %>% plot(add=T, col="blue")
sturnus_vulgaris %>% filter(ORIGIN==3) %>% st_geometry() %>% plot(add=T, col="blue")
passer_domesticus %>% st_geometry() %>% plot(main="House sparrow")
passer_domesticus %>% filter(ORIGIN==1) %>% st_geometry() %>% plot(add=T, col="blue")
passer_domesticus %>% filter(ORIGIN==3) %>% st_geometry() %>% plot(add=T, col="red")

## ---- fig.show='hold'---------------------------------------------------------
threskiornis_aethiopicus %>% filter(ORIGIN==1) %>% 
  st_geometry() %>% plot(col="blue", main="Sacred ibis (native)")
threskiornis_aethiopicus %>% filter(ORIGIN==3) %>% 
  st_geometry() %>% plot(col="red", main="Sacred ibis (introduced)")

