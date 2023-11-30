![Image credit: Google Maps](https://cdn.arstechnica.net/wp-content/uploads/2023/09/Google-Maps-640x361.jpg)


________________
# Visualising spatial data with ggplot and Google Maps

#### Tutorial Aims and Background:
The general aim of this tutorial is to learn how to use geographical location data and plot it using ggplot and Google Maps. The tutorial is aimed at someone who has some experience with using ggplot for data visualisation and the tidyverse for data manipulation. The three main aims of this tutorial are to learn how to plot different ecological geographical data on a Google Maps underlay. We will specifically work with two examples:

1. [Plotting individual sample units]()
2. [Plotting sampling locations](). 

Visualising data in space is an important component of ecological and environmental analysis; knowing exactly where the sampling took place, and within what environments, is essential to appropriate interpretation of the trends - this is where __Google Maps__ comes in. Using Google Maps satellite images as an aid in the plots can help us contextualise our studies within their environments. 

This tutorial explores two common examples of ecological spatial visualisation - plotting sample objects (e.g. individual trees) and study locations (e.g. sampling transects). We will use a combination of Google Maps and ggplot2 to create visually appealing and informative graphs. You can get all of the resources for this tutorial from [this repository](https://github.com/EdDataScienceEES/tutorial-zmancekpali). Clone and download the repo as a zip file, then unzip it.

The data we are working with come from two of my projects: a field course and my dissertation. The leaves dataset is my dissertation dataset (I collected a variety of leaf trait data to compare the differences between naturalised, native, and invasive tree species in Scotland). The bugs dataset is from the 4th year field course I attended this summer during which we collected insect diversity data from pitfall traps along different transects across forest edges. Both datasets contain a wide array of data, but for the purpose of this tutorial, we are mostly interested in the location data (the longitude and latitude columns) and the descriptors (e.g. the tree species or the transect ID). 

---------
## Setting up for the tutorial

To begin, set up your working directory in your script and load the necessary libraries:
```r
#WD
setwd("~/") #erases any previously set WDs
setwd("Path to your directory") #sets a new one
getwd() #use this command to check that it's worked

#Libraries
library(ggmap)
library(gridExtra)
library(tidyverse)
```

To be able to work through this tutorial, we need to enable a connection between RStudio and Google Maps - and we can do that using an API key (application programming interface; basically allows a connection of an app and the identification of a user on that app). To create your own API key, follow these steps: 

1. Go to the [Credentials page of the Google Maps Platform](https://console.cloud.google.com/projectselector2/google/maps-apis/credentials?utm_source=Docs_CreateAPIKey&utm_content=Docs_maps-backend) and select "Create project". 
2. Pick a name for it, and ignore the organisation ('No organisation' is fine for the purposes of this tutorial). 
3. Press "Create" and copy the API key it provides you (e.g. mine is  AIzaSyDnersipSvcXuK4tCDbr8NOpa-qsrYf9pc), and add it into your script like so:
```r
ggmap::register_google(key = "your key here", write = TRUE) #register your own Google API Key here
```
If you can't get your key to work for any reason, feel free to use mine to complete the tutorial.

To complete the setup, import the two datasets like so: 
```r
leaves <- read.csv("Data/traits_analysis.csv")
bugs <- read.csv("Data/bugs.csv")
```

---------
## Plotting locations of individual samples:

To plot where exactly each tree within our trees dataset is located, we need to clean up the data a bit first. The last command in this tidying chunk removes repeat longitude/latitude values (as I had multiple samples from the same trees; it makes for cleaner maps): 
```r
leaves <- leaves %>% 
  select("type", "code", "latin_name", "long", "lat") %>%  #select the relevant columns
  mutate(type = recode(type, "Alien" = "Alien species",
                       "Invasive" = "Invasive species", 
                       "Naturalised" = "Naturalised species", 
                       "Native" = "Native species")) %>%  #recode the invasion type names to be capitalised
  distinct(long, lat, .keep_all = TRUE) #remove multiple rows (avoids overplotting)
```

We also need to let RStudio know where exactly we want to plot the data; in this case, all the samples were from the Royal Botanic Gardens Edinburgh (RBGE), so we let R know that we want to plot Edinburgh and set the exact centre of the map to RBGE: 
```r
(edinburgh <- map <- get_googlemap("edinburgh", zoom = 16))
rbge <- c(left = -3.2140, bottom = 55.9627, right = -3.2025, top = 55.9682) #set the map view window accordingly
```

Now that we have a map of RBGE, we can select which type of map is best for our purposes from: terrain, roadmap, sattelite, or hybrid. To select which one you think is best, you can plot them all and select a specific one: 
```r
edi_map_terrain <- get_map(rbge, maptype='terrain', source="google", zoom=16) #specify what kind of map you want
(terrain_map <- ggmap(edi_map_terrain) +
    xlab("Longitude") +
    ylab("Latitude\n") +
    annotate("text", x = -3.214, y = 55.968, colour = "black", label = "a)", size = 4.5, 
             fontface = "bold"))

edi_map_roadmap <- get_map(rbge, maptype='roadmap', source="google", zoom=16) 
(roadmap <- ggmap(edi_map_roadmap) +
  xlab("Longitude") +
  ylab("Latitude\n"))
  
edi_map_satellite <- get_map(rbge, maptype='satellite', source="google", zoom=16) 
(satellite_map <- ggmap(edi_map_satellite) +
    xlab("Longitude") +
    ylab("Latitude\n"))

edi_map_hybrid <- get_map(rbge, maptype='hybrid', source="google", zoom=16)
(hybrid_map <- ggmap(edi_map_hybrid) +
    xlab("Longitude") +
    ylab("Latitude\n"))
```

Here you can see them all side by side; for this study, I would most likely select satellite (bottom left) as it has the most realistic picture of the environment from which I collected my samples and is not cluttered with irrelevant text:
![map options](https://github.com/EdDataScienceEES/tutorial-zmancekpali/blob/master/Plots/map_types_option.jpg)


Now that we have the connection to Google Maps, the data, and the maps set up, we can plot the sampled trees. To start, let's simply plot a dot for each tree:
```
(initial_simple_map <- ggmap(edi_map_satellite) +
    geom_point(data = leaves, aes(x = long, y = lat, color = type, shape = type), 
               size = 3))
```
![initial map](https://github.com/EdDataScienceEES/tutorial-zmancekpali/blob/master/Plots/initial_map1.jpg)

We can make this map more informative by adding the species names to each dot as a label:
```
(map_with_names <- ggmap(edi_map_satellite) +
    geom_point(data = leaves, aes(x = long, y = lat, color = type, shape = type), 
               size = 3) +
    scale_color_manual(values = c("#5EA8D9", "#CD6090", "#698B69", "#EEC900"),
                       name = "Invasion type") +
    scale_shape_manual(values = c(16, 17, 18, 15), name = "Invasion type") +
    xlab("Longitude") +
    ylab("Latitude") +
    theme(legend.position = c(0.85, 0.87), #defines the position of the legend
          legend.key = element_rect(fill = "floralwhite"),
          legend.background = element_rect(fill = "floralwhite")) + #this adds a box under the legend with these colour specifications
    ggrepel::geom_label_repel(data = leaves, aes(x = long, y = lat, label = latin_name),
                              max.overlaps = 200, box.padding = 0.5, point.padding = 0.1, 
                              segment.color = "floralwhite", size = 3, fontface = "italic") + #this adds a label to each individual dot
    annotation_north_arrow(location = "tl", which_north = "true", 
                           style = north_arrow_fancy_orienteering (text_col = 'floralwhite',
                                                                   line_col = 'floralwhite',
                                                                   fill = 'floralwhite'))) #adds a north arrow onto the plot
```
![labelled](https://github.com/EdDataScienceEES/tutorial-zmancekpali/blob/master/Plots/rbge_map_with_names.jpg)

You can now see a much more informative plot that tells you the exact location of each tree and the species, however, it looks a bit cluttered. For the purposes of this tutorial, we can plot the species abbreviation code instead of the full Latin names to make the map a bit less cluttered with text (however, this would not really be usable in formal academic reports without a legend explaining each abbreviation). Still, we can see it looks much cleaner:
```
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
                              size = 3, fontface = "italic") +
    annotation_north_arrow(location = "tl", which_north = "true", 
                           style = north_arrow_fancy_orienteering (text_col = 'floralwhite',
                                                                   line_col = 'floralwhite',
                                                                   fill = 'floralwhite'))) #adds a north arrow onto the plot
```
![with codes instead](https://github.com/EdDataScienceEES/tutorial-zmancekpali/blob/master/Plots/map_with_codes.jpg)

---------
## Plotting locations of transects:
For the second section, we can plot transect sites (a very common sampling method in ecology and environmental sciences). To do that, we will set the centre of the map to Badaguish, Scotland, as that's where the study sites were located. Set up your script like so and create a simple plot of the data:

```r
(badaguish <- map <- get_googlemap("Badaguish", zoom = 16))
badaguish_sites <- c(left = -3.730, bottom = 57.174, right = -3.70, top = 57.20)

(badaguish_sattelite <- get_map(badaguish_sites, maptype = 'satellite', source = "google", zoom = 14))

(transect_simple_map <- ggmap(badaguish_sattelite) +
  geom_point(data = bugs, aes(x = long, y = lat, color = as.factor(site)), 
             size = 3) +
  scale_color_manual(values = c("#5EA8D9", "#CD6090", "#2CB82E", "#EEC900"),
                     name = "Site")) 
```

![transect figure](https://github.com/EdDataScienceEES/tutorial-zmancekpali/blob/master/Plots/transect_simple.png)

We can now see the exact location of each of our transects and the sampling points along them. However, you want your figures to be more detailed if you wanted to use them for a report, so let's instead plot a more detailed map for each site and make a grid of them (this way, we can see the exact habitat of our sampling sites). This next chunk of code filters out each of the four sites and plots them individually initially, and then arranges them in a grid using the ```grid.arrange()``` function. 

```r
#Site 1
site1_coords <- bugs %>% filter(site == "1")
site1 <- c(left = -3.730, bottom = 57.185, right = -3.745, top = 57.198) #set the map view window accordingly
(site1_sattelite <- get_map(site1, maptype = 'satellite', source = "google", 
                                zoom = 17))
(site1_map <- ggmap(site1_sattelite) +
    geom_point(data = site1_coords, aes(x = long, y = lat, color = as.factor(transect)), size = 2) + #this line plots the dot for each sampling site (in this case, each pitfall trap)
    geom_line(data = site1_coords, aes(x = long, y = lat, color = as.factor(transect)),
              linewidth = 1) + #this plots a line between the pitfall traps at each transect (using as.factor(transect) allows R to distinguish between each transect and connect the dots that way, instead of connecting them all as it would if you omit this part of the call)
    scale_color_manual(values = c("A" = "#5EA8D9", "B" = "#5EA8D9")) + #specify the colours of the transects
    labs(color = "Transects (Site 1)") + #legend title
    xlab("Longitude") +
    ylab("Latitude") +
    theme(legend.position = c(0.85, 0.9), #changes the position of the legend
          legend.key = element_rect(fill = "floralwhite"), #adds a rectange under the legend
          legend.background = element_rect(fill = "floralwhite")) +
    annotation_north_arrow(location = "tl", which_north = "true", 
                           style = north_arrow_fancy_orienteering (text_col = 'floralwhite',
                                                                   line_col = 'floralwhite',
                                                                   fill = 'floralwhite'))) #adds a north arrow onto the plot

ggsave("site1.png", site1_map, path = "Plots", units = "cm", width = 30, height = 20) #you can save each of your plots like so if you wish.


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
    scale_color_manual(values = c("A" = "#CD6090", "B" = "#CD6090")) +
    labs(color = "Transects (Site 2)") +
    xlab("Longitude") +
    ylab("Latitude") +
    theme(legend.position = c(0.85, 0.9),
          legend.key = element_rect(fill = "floralwhite"),
          legend.background = element_rect(fill = "floralwhite")) +
    annotation_north_arrow(location = "tl", which_north = "true", 
                           style = north_arrow_fancy_orienteering (text_col = 'floralwhite',
                                                                   line_col = 'floralwhite',
                                                                   fill = 'floralwhite')))

ggsave("site2.png", site2_map, path = "Plots", units = "cm", width = 30, height = 20)


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
    scale_color_manual(values = c("A" = "#2CB82E", "B" = "#2CB82E")) +
    labs(color = "Transects (Site 3)") +
    xlab("Longitude") +
    ylab("Latitude") +
    theme(legend.position = c(0.85, 0.90),
          legend.key = element_rect(fill = "floralwhite"),
          legend.background = element_rect(fill = "floralwhite")) +
    annotation_north_arrow(location = "tl", which_north = "true", 
                           style = north_arrow_fancy_orienteering (text_col = 'floralwhite',
                                                                   line_col = 'floralwhite',
                                                                   fill = 'floralwhite')))
ggsave("site3.png", site3_map, path = "Plots", units = "cm", width = 30, height = 20)


#Site 4
site4_coords <- bugs %>% filter(site == "4")
site4 <- c(left = -3.71, bottom = 57.174, right = -3.70, top = 57.177) #set the map view window accordingly
(site4_sattelite <- get_map(site4, maptype = 'satellite', source = "google", 
                            zoom = 17))
(site4_map <- ggmap(site4_sattelite) +
    geom_point(data = site4_coords, aes(x = long, y = lat, color = as.factor(transect)), 
               size = 2) +
    geom_line(data = site4_coords, aes(x = long, y = lat, color = as.factor(transect)),
              linewidth = 1) +
    scale_color_manual(values = c("A" = "#EEC900", "B" = "#EEC900")) +
    labs(color = "Transects (Site 4)") +
    xlab("Longitude") +
    ylab("Latitude") +
    theme(legend.position = c(0.85, 0.9),
          legend.key = element_rect(fill = "floralwhite"),
          legend.background = element_rect(fill = "floralwhite")) +
    annotation_north_arrow(location = "tl", which_north = "true", 
                           style = north_arrow_fancy_orienteering (text_col = 'floralwhite',
                                                                   line_col = 'floralwhite',
                                                                   fill = 'floralwhite')))

ggsave("site4.png", site4_map, path = "Plots", units = "cm", width = 30, height = 20)
```

![site1](https://github.com/EdDataScienceEES/tutorial-zmancekpali/blob/master/Plots/site1.png)
![site2](https://github.com/EdDataScienceEES/tutorial-zmancekpali/blob/master/Plots/site2.png)
![site3](https://github.com/EdDataScienceEES/tutorial-zmancekpali/blob/master/Plots/site3.png)
![site4](https://github.com/EdDataScienceEES/tutorial-zmancekpali/blob/master/Plots/site4.png)


You can now see each individual sample site much more zoomed in, and if you wish, you can even arrange a grid of all four plots and save it:

```r
#Grid
(sites_grid <- grid.arrange(site1_map, site2_map, site3_map, site4_map, ncol = 4))
ggsave("sites_grid.png", sites_grid, path = "Plots", units = "cm", width = 70, height = 30)
```

![grid](https://github.com/EdDataScienceEES/tutorial-zmancekpali/blob/master/Plots/sites_grid.png)


## Finished!!

In this tutorial we learned: how to plot data onto an underlay of Google Maps with ggplot2 for two distinct and common ecological sampling methods

#### If you have any questions about completing this tutorial, please contact us on s2095338@gmail.com (Zoja Manček Páli)

_____
## References:
Google Maps (2023). Google Maps Logo. Available at: https://www.google.com/maps/@55.9503053,-3.1918862,14z?entry=ttu.
