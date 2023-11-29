##%#########################################################################%##
#                                                                             #
#                            Data Science Tutorial                            #
#                               Zoja Manček Páli                              #
#                                                                             #
##%#########################################################################%##
#Making maps with google maps

#WD
setwd("~/") #erases previously set WDs
setwd("Tutorial DS") #sets a new one
getwd() #check that it's worked

#Libraries
library(ggmap)
library(gridExtra)
library(rmarkdown)
library(tidyverse)

#Set up the google maps connection
ggmap::register_google(key = "AIzaSyDnersipSvcXuK4tCDbr8NOpa-qsrYf9pc", 
                       write = TRUE) #register your own Google API Key here

#Data
leaves <- read.csv("Data/traits_analysis.csv")
bugs <- read.csv("Data/bugs.csv")

#Data import and wrangling
leaves <- leaves %>% 
  select("type", "code", "latin_name", "long", "lat") %>%  #select the relevant columns
  mutate(type = recode(type, "Alien" = "Alien species",
                       "Invasive" = "Invasive species", 
                       "Naturalised" = "Naturalised species", 
                       "Native" = "Native species")) %>%  #recode the invasion type names
  distinct(long, lat, .keep_all = TRUE) #remove multiple rows (avoids overplotting)

bugs <- bugs %>% 
  select("site", "transect", "long", "lat", "quad", "Id") %>%  #select the relevant columns
  distinct(long, lat, .keep_all = TRUE) #remove multiple rows (avoids overplotting)


#Edinburgh maps ----
(edinburgh <- get_googlemap("edinburgh", zoom = 16))
rbge <- c(left = -3.2140, bottom = 55.9627, right = -3.2025, top = 55.9682) #set the map view window accordingly; I want to view the Botanics
edi_map_terrain <- get_map(rbge, maptype ='terrain', source="google", zoom=16) #specify what kind of map you want
(terrain_map <- ggmap(edi_map_terrain) +
    xlab("Longitude") +
    ylab("Latitude\n") +
    annotate("text", x = -3.214, y = 55.968, colour = "black", label = "a)", size = 4.5, 
             fontface = "bold"))

edi_map_roadmap <- get_map(rbge, maptype ='roadmap', source = "google", zoom = 16) #specify what kind of map you want
(roadmap <- ggmap(edi_map_roadmap) +
  xlab("Longitude") +
  ylab("Latitude\n"))
  
edi_map_satellite <- get_map(rbge, maptype ='satellite', source = "google", zoom = 16) #specify what kind of map you want
(satellite_map <- ggmap(edi_map_satellite) +
    xlab("Longitude") +
    ylab("Latitude\n"))

edi_map_hybrid <- get_map(rbge, maptype = 'hybrid', source = "google", zoom = 16) #specify what kind of map you want
(hybrid_map <- ggmap(edi_map_hybrid) +
    xlab("Longitude") +
    ylab("Latitude\n"))

(maps_grid <- grid.arrange(terrain_map, roadmap, satellite_map, hybrid_map, ncol = 2)) #maybe annotate these?
ggsave("map_types_option.jpg", maps_grid, path = "Plots", units = "cm", 
       width = 30, height = 20)

#the final map
(rbge_simple_map <- ggmap(edi_map_satellite) +
    geom_point(data = leaves, aes(x = long, y = lat, color = type, shape = type), 
               size = 3))
ggsave("rbge_initial_map.jpg", rbge_simple_map, path = "Plots", units = "cm", 
       width = 30, height = 20)

(rbge_map_with_names <- ggmap(edi_map_satellite) +
    geom_point(data = leaves, aes(x = long, y = lat, color = type, shape = type), 
               size = 3) +
    scale_color_manual(values = c("#5EA8D9", "#CD6090", "#2CB82E", "#EEC900"),
                       name = "Invasion type") +
    scale_shape_manual(values = c(16, 17, 18, 15), name = "Invasion type") +
    xlab("Longitude") +
    ylab("Latitude") +
    theme(legend.position = c(0.85, 0.87),
          legend.key = element_rect(fill = "floralwhite"),
          legend.background = element_rect(fill = "floralwhite")) +
    ggrepel::geom_label_repel(data = leaves, aes(x = long, y = lat, label = latin_name),
                              max.overlaps = 200, box.padding = 0.5, point.padding = 0.1, 
                              segment.color = "floralwhite", size = 3, fontface = "italic"))
ggsave("rbge_map_with_names.jpg", rbge_map_with_names, path = "Plots", units = "cm", 
       width = 30, height = 20)

(map_with_codes <- ggmap(edi_map_satellite) +
    geom_point(data = leaves, aes(x = long, y = lat, color = type, shape = type), 
               size = 3) +
    scale_color_manual(values = c("#5EA8D9", "#CD6090", "#698B69", "#EEC900"),
                       name = "Invasion type") +
    scale_shape_manual(values = c(16, 17, 18, 15), name = "Invasion type") +
    xlab("Longitude") +
    ylab("Latitude") +
    theme(legend.position = c(0.85, 0.87),
          legend.key = element_rect(fill = "floralwhite"),
          legend.background = element_rect(fill = "floralwhite")) +
    ggrepel::geom_label_repel(data = leaves, aes(x = long, y = lat, label = code),
                              max.overlaps = 200, box.padding = 0.5, 
                              point.padding = 0.1, segment.color = "floralwhite", 
                              size = 3, fontface = "italic"))
ggsave("map_with_codes.jpg", map_with_codes, path = "Plots", units = "cm", 
       width = 30, height = 20)


#Transect maps ----
(badaguish <- map <- get_googlemap("Badaguish", zoom = 16))
badaguish_sites <- c(left = -3.730, bottom = 57.174, right = -3.70, top = 57.20) #set the map view window accordingly

(badaguish_sattelite <- get_map(badaguish_sites, maptype = 'satellite', source = "google", 
                               zoom = 14))

(transect_simple_map <- ggmap(badaguish_sattelite) +
  geom_point(data = bugs, aes(x = long, y = lat, color = as.factor(site)), 
             size = 3) +
  scale_color_manual(values = c("#5EA8D9", "#CD6090", "#2CB82E", "#EEC900"),
                     name = "Site")) #as you can see, the sites are quite far apart (so this is still a good figure)
#but lets make individual maps for each site, so we can see the environment of each transect
ggsave("transect_simple.png", transect_simple_map, path = "Plots", units = "cm",
       width = 30, height = 20)

#Site 1
site1_coords <- bugs %>% filter(site == "1")
site1 <- c(left = -3.730, bottom = 57.185, right = -3.745, top = 57.198) #set the map view window accordingly
(site1_sattelite <- get_map(site1, maptype = 'satellite', source = "google", 
                                zoom = 17))
(site1_map <- ggmap(site1_sattelite) +
    geom_point(data = site1_coords, aes(x = long, y = lat, color = as.factor(transect)), size = 2) +
    geom_line(data = site1_coords, aes(x = long, y = lat, color = as.factor(transect)),
              linewidth = 1) +
    annotate("text", x = -3.735, y = 57.193, label = "Site 1", color = "white", 
             fontface = "bold") +
    scale_color_manual(values = c("A" = "#5EA8D9", "B" = "#5EA8D9")) +
    labs(color = "Transects"))
ggsave("site1.png", site1_map, path = "Plots", units = "cm",
       width = 30, height = 20)


#Site 2
site2_coords <- bugs %>% filter(site == "2")
site2 <- c(left = -3.728, bottom = 57.184, right = -3.724, top = 57.1867) #set the map view window accordingly
(site2_sattelite <- get_map(site2, maptype = 'satellite', source = "google", 
                            zoom = 17))
(site2_map <- ggmap(site2_sattelite) +
    geom_point(data = site2_coords, aes(x = long, y = lat, color = as.factor(transect)), 
               size = 2) +
    geom_line(data = site2_coords, aes(x = long, y = lat, color = as.factor(transect)),
              linewidth = 1) +
    annotate("text", x = -3.7235, y = 57.187, label = "Site 2", color = "white", 
             fontface = "bold") +
    scale_color_manual(values = c("A" = "#CD6090", "B" = "#CD6090")) +
    labs(color = "Transects"))
ggsave("site2.png", site2_map, path = "Plots", units = "cm",
       width = 30, height = 20)


#Site 3
site3_coords <- bugs %>% filter(site == "3")
site3 <- c(left = -3.72, bottom = 57.175, right = -3.70, top = 57.18) #set the map view window accordingly
(site3_sattelite <- get_map(site3, maptype = 'satellite', source = "google", 
                            zoom = 17))
(site3_map <- ggmap(site3_sattelite) +
    geom_point(data = site3_coords, aes(x = long, y = lat, color = as.factor(transect)), 
               size = 2) +
    geom_line(data = site3_coords, aes(x = long, y = lat, color = as.factor(transect)),
              linewidth = 1) +
    annotate("text", x = -3.7075, y = 57.179, label = "Site 3", color = "white", 
             fontface = "bold") +
    scale_color_manual(values = c("A" = "#2CB82E", "B" = "#2CB82E")) +
    labs(color = "Transects"))
ggsave("site3.png", site3_map, path = "Plots", units = "cm",
       width = 30, height = 20)


#Site 3
site4_coords <- bugs %>% filter(site == "4")
site4 <- c(left = -3.71, bottom = 57.174, right = -3.70, top = 57.177) #set the map view window accordingly
(site4_sattelite <- get_map(site4, maptype = 'satellite', source = "google", 
                            zoom = 17))
(site4_map <- ggmap(site4_sattelite) +
    geom_point(data = site4_coords, aes(x = long, y = lat, color = as.factor(transect)), 
               size = 2) +
    geom_line(data = site4_coords, aes(x = long, y = lat, color = as.factor(transect)),
              linewidth = 1) +
    annotate("text", x = -3.7025, y = 57.177, label = "Site 4", color = "white", 
             fontface = "bold") +
    scale_color_manual(values = c("A" = "#EEC900", "B" = "#EEC900")) +
    labs(color = "Transects"))
ggsave("site4.png", site4_map, path = "Plots", units = "cm",
       width = 30, height = 20)

(sites_grid <- grid.arrange(site1_map, site2_map, site3_map, site4_map, ncol = 4))
ggsave("sites_grid.png", sites_grid, path = "Plots", units = "cm", 
       width = 50, height = 10)


