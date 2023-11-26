##%#########################################################################%##
#                                                                             #
#                             Data science Tutorial?                          #
#                               Zoja Manček Páli                              #
#                                                                             #
##%#########################################################################%##
#Making maps with google maps

#WD
setwd("~/") #erases previously set WDs
setwd("Personal repo - zmancekpali/Data Science Tutorial") #sets a new one
getwd() #check that it's worked

#Libraries
library(ggmap)
library(gridExtra)
library(tidyverse)

#Set up the google maps connection
ggmap::register_google(key = "AIzaSyDnersipSvcXuK4tCDbr8NOpa-qsrYf9pc", 
                       write = TRUE) #register your own Google API Key here
#Data wrangling
coords <- read.csv("traits_analysis.csv") %>% 
  select("type", "code", "latin_name", "long", "lat") %>%  #select the longitude, latitude, invasion type and species code
  mutate(type = recode(type, "Alien" = "Alien species",
                       "Invasive" = "Invasive species", 
                       "Naturalised" = "Naturalised species", 
                       "Native" = "Native species")) %>%  #recode the invasion type names
  distinct(long, lat, .keep_all = TRUE) #remove multiple rows (avoids overplotting)

(edinburgh <- map <- get_googlemap("edinburgh", zoom = 16))
rbge <- c(left = -3.2140, bottom = 55.9627, right = -3.2025, top = 55.9682) #set the map view window accordingly; I want to view the Botanics
edi_map_terrain <- get_map(rbge, maptype='terrain', source="google", zoom=16) #specify what kind of map you want
terrain_map <- ggmap(edi_map_terrain)

edi_map_roadmap <- get_map(rbge, maptype='roadmap', source="google", zoom=16) #specify what kind of map you want
roadmap <- ggmap(edi_map_roadmap)

edi_map_satellite <- get_map(rbge, maptype='satellite', source="google", zoom=16) #specify what kind of map you want
satellite_map <- ggmap(edi_map_satellite)

edi_map_hybrid <- get_map(rbge, maptype='hybrid', source="google", zoom=16) #specify what kind of map you want
hybrid_map <- ggmap(edi_map_hybrid)

maps_grid <- grid.arrange(terrain_map, roadmap, satellite_map, hybrid_map, ncol = 2) #maybe annotate these?


#the final map
(map_with_names <- ggmap(edi_map_satellite) +
    geom_point(data = coords, aes(x = long, y = lat, color = type, shape = type), 
               size = 3) +
    scale_color_manual(values = c("#5EA8D9", "#CD6090", "#698B69", "#EEC900"),
                       name = "Invasion type") +
    scale_shape_manual(values = c(16, 17, 18, 15), name = "Invasion type") +
    xlab("Longitude") +
    ylab("Latitude") +
    theme(legend.position = c(0.85, 0.87),
          legend.key = element_rect(fill = "floralwhite"),
          legend.background = element_rect(fill = "floralwhite")) +
    ggrepel::geom_label_repel(data = coords, aes(x = long, y = lat, label = latin_name),
                              max.overlaps = 200, box.padding = 0.5, point.padding = 0.1, 
                              segment.color = "floralwhite", size = 3, fontface = "italic"))


(map_with_codes <- ggmap(edi_map_satellite) +
    geom_point(data = coords, aes(x = long, y = lat, color = type, shape = type), 
               size = 3) +
    scale_color_manual(values = c("#5EA8D9", "#CD6090", "#698B69", "#EEC900"),
                       name = "Invasion type") +
    scale_shape_manual(values = c(16, 17, 18, 15), name = "Invasion type") +
    xlab("Longitude") +
    ylab("Latitude") +
    theme(legend.position = c(0.85, 0.87),
          legend.key = element_rect(fill = "floralwhite"),
          legend.background = element_rect(fill = "floralwhite")) +
    ggrepel::geom_label_repel(data = coords, aes(x = long, y = lat, label = code),
                              max.overlaps = 200, box.padding = 0.5, 
                              point.padding = 0.1, segment.color = "floralwhite", 
                              size = 3, fontface = "italic"))


#Coding club stuff: ----
#Libraries
library(rgdal)  # readOGR() spTransform()
library(raster)  # intersect()
library(ggsn)  # north2() scalebar()
library(rworldmap)  # getMap()

