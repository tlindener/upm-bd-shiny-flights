# base libraries
library(dplyr)
library(leaflet)
library(maps)
library(maptools)
library(ggmap)
library(ggplot2)
library(reshape2)
# load initial dataset

airport_connections <- read.csv2("airports_connection_matrix.csv")

airport_connections$airport_origin <-
  as.factor(airport_connections$airport_origin)
airport_names <- levels(airport_connections$airport_origin)
us_map = leaflet(width = 1280, height = 800) %>%
  setView(lng = -95.72,
          lat = 37.13,
          zoom = 4) %>%
  addProviderTiles("NASAGIBS.ViirsEarthAtNight2012",
                   options = providerTileOptions(opacity = 1))
xlim <- c(-171.738281, -50.601563)
ylim <- c(12.039321, 71.856229)
base_map = map(
  "world",
  col = "#f2f2f2",
  fill = TRUE,
  bg = "white",
  lwd = 0.05,
  xlim = xlim,
  ylim = ylim
)


weather_delays <- read.csv("weather_delays.csv")
airport_atlanta <- readRDS("airport_atlanta.rds")
airport_atlanta_prediction_columns <- c("DayofMonth","DayOfWeek","FlightNum","DepTime","CRSDepTime","ArrTime","CRSArrTime","UniqueCarrier"     ,
                                        "TailNum"        ,"Dest"        ,"Distance","TaxiOut"         ,"airport_dest" ,"Date"       ,"Min.TemperatureC"   ,"Min.Humidity"    ,    "Max.Sea.Level.PressurehPa",
                                        "Min.Sea.Level.PressurehPa","Max.VisibilityKm"   ,    "Max.Wind.SpeedKm.h","Max.Gust.SpeedKm.h","CloudCover","Events","WindDirDegrees")


airport_atlanta_columns <-
  c("DepTime","CRSDepTime","ArrTime","CRSArrTime","UniqueCarrier"     ,
    "TailNum"        ,"DepDelay","Dest"        ,"Distance","TaxiOut"         ,"airport_dest" ,"Date"       ,"Min.TemperatureC"   ,"Min.Humidity"    ,    "Max.Sea.Level.PressurehPa",
    "Min.Sea.Level.PressurehPa","Max.VisibilityKm"   ,    "Max.Wind.SpeedKm.h","Max.Gust.SpeedKm.h","CloudCover","Events","WindDirDegrees")
aggregateATL <- read.csv("aggregateATL.csv")
aggregateORD <- read.csv("aggregateORD.csv")
aggregateLAX <- read.csv("aggregateLAX.csv")
aggregateDFW <- read.csv("aggregateDFW.csv")
aggregateDEN <- read.csv("aggregateDEN.csv")
airports_names_top5 <-
  c(
    "All",
    "William B Hartsfield-Atlanta Intl",
    "Chicago O'Hare International",
    "Dallas-Fort Worth International",
    "Los Angeles International",
    "Denver Intl"
  )
timemed <- read.csv("tsmed.csv")
timeavg <- read.csv("tsavg.csv")
geodata <- read.csv("geodata.csv")
airports <- readRDS("airports.rds")
delay_max <- round(range(airports$arr_delay_avg)[2])
delay_min <- round(range(airports$arr_delay_avg)[1])

flight_max <- range(airports$num_flights)[2]
flight_min <- range(airports$num_flights)[1]
