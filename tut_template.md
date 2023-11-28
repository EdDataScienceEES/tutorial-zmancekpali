![Image credit: Google Maps](https://cdn.arstechnica.net/wp-content/uploads/2023/09/Google-Maps-640x361.jpg)


________________
<left>## Visualising spatial data with ggplot and Google Maps

#### Tutorial Aims

#### <a href="#section1"> 1. The first section</a>

#### <a href="#section2"> 2. The second section</a>

#### <a href="#section3"> 3. The third section</a>


_________________
Visualising data in space is an important component of ecological and environmental analysis.
Knowing exactly where the sampling took place, and within what environments, is essential to appropriate interpretation of the trends - this is where __Google Maps__ comes in. Using Google Maps satellite images as an aid in the plots can help us contextualise our studies within their environments. 

This tutorial explores two common examples of ecological spatial visualisation - plotting sample objects (e.g. individual trees) and study locations (e.g. sampling transects). We will use a combination of Google Maps and ggplot2 to create visually appealing and informative graphs. You can get all of the resources for this tutorial from [this repository](https://github.com/EdDataScienceEES/tutorial-zmancekpali). Clone and download the repo as a zip file, then unzip it. 

<a name="section1"></a>

### 1. The set up:

The begin, set up your working directory in your script and load the necessary libraries:
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

The data we are working with come from two of my projects: a field course and my dissertation. The leaves dataset is my dissertation dataset (I collected a variety of leaf trait data to compare the differences between naturalised, native, and invasive tree species in Scotland). The bugs dataset is from the 4th year field course I attended this summer during which we collected insect and plant diversity data along different transects across forest edges. Both datasets contain a wide array of data, but for the purpose of this tutorial, we are mostly interested in the location data (the longitude and latitude columns) and the descriptors (e.g. the tree species or the transect ID). 

To complete the setup, import the two datasets like so: 
```r
leaves <- read.csv("Data/traits_analysis.csv")
bugs <- read.csv("Data/bugs.csv")
```


### Plotting locations of individual samples

To plot where exactly each tree within our trees dataset is located, we need to clean up the data a bit first. The last command in this tidying chunk removes repeat longitude/latitude values (as I had multiple samples from the same trees; it makes for cleaner maps): 
```r
leaves <- leaves %>% 
  select("type", "code", "latin_name", "long", "lat") %>%  #select the relevant columns
  mutate(type = recode(type, "Alien" = "Alien species",
                       "Invasive" = "Invasive species", 
                       "Naturalised" = "Naturalised species", 
                       "Native" = "Native species")) %>%  #recode the invasion type names
  distinct(long, lat, .keep_all = TRUE) #remove multiple rows (avoids overplotting)

```

We also need to let RStudio know where exactly we want to plot the data; in this case, all the samples were from the Royal Botanic Gardens Edinburgh, so we let R know that we want to plot Edinburgh and set the exact centre of the map to RBGE: 
```r
(edinburgh <- map <- get_googlemap("edinburgh", zoom = 16))
rbge <- c(left = -3.2140, bottom = 55.9627, right = -3.2025, top = 55.9682) #set the map view window accordingly; we want to view the RBGE
```


Now that we have a map of RBGE, we can select which type of map is best for our purposes from: terrain, roadmap, sattelite, or hybrid. To select which one you think is best, you can plot them all and select one: 

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


Now that we have the connection to Google Maps, the data, and the maps set up, we can finally plot the individual trees. To start, let's simply plot a dot for each tree:
```
(initial_simple_map <- ggmap(edi_map_satellite) +
    geom_point(data = leaves, aes(x = long, y = lat, color = type, shape = type), 
               size = 3))
```
![initial map](https://github.com/EdDataScienceEES/tutorial-zmancekpali/blob/master/Plots/initial_map1.jpg)

But we can make this look a lot more informative by adding the species names to each dot as a label:
```
(map_with_names <- ggmap(edi_map_satellite) +
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
    ggrepel::geom_label_repel(data = leaves, aes(x = long, y = lat, label = latin_name),
                              max.overlaps = 200, box.padding = 0.5, point.padding = 0.1, 
                              segment.color = "floralwhite", size = 3, fontface = "italic"))
```
![labelled](https://github.com/EdDataScienceEES/tutorial-zmancekpali/blob/master/Plots/map_with_names.jpg)


We can also plot the species abbreviation code I used to make the map a bit less cluttered with text (however, this would not really be usable in formal academic reports without a legend explaining each abbreviation). Still, for the purpose of this tutorial, we can see it looks much cleaner:
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
                              size = 3, fontface = "italic"))
```
![with codes instead](https://github.com/EdDataScienceEES/tutorial-zmancekpali/blob/master/Plots/map_with_codes.jpg)


### Plotting locations of transects
For the second section, we can plot transect sites (a very common sampling method in ecology and environmental sciences). To do that, we will set the centre of the map to Badaguish, Scotland, as that's where the study sites were located. Set up your script like so:

```r

```

And finally, plot the data:

```r
ggplot(data = xy_fil, aes(x = x_dat, y = y_dat)) +  # Select the data to use
	geom_point() +  # Draw scatter points
	geom_smooth(method = "loess")  # Draw a loess curve
```

At this point it would be a good idea to include an image of what the plot is meant to look like so students can check they've done it right. Replace `IMAGE_NAME.png` with your own image file:

<center> <img src="{{ site.baseurl }}/IMAGE_NAME.png" alt="Img" style="width: 800px;"/> </center>

<a name="section1"></a>

## 3. The third section

More text, code and images.

This is the end of the tutorial. Summarise what the student has learned, possibly even with a list of learning outcomes. In this tutorial we learned:

##### - how to generate fake bivariate data
##### - how to create a scatterplot in ggplot2
##### - some of the different plot methods in ggplot2

We can also provide some useful links, include a contact form and a way to send feedback.

For more on `ggplot2`, read the official <a href="https://www.rstudio.com/wp-content/uploads/2015/03/ggplot2-cheatsheet.pdf" target="_blank">ggplot2 cheatsheet</a>.

Everything below this is footer material - text and links that appears at the end of all of your tutorials.

<hr>
<hr>

#### Check out our <a href="https://ourcodingclub.github.io/links/" target="_blank">Useful links</a> page where you can find loads of guides and cheatsheets.

#### If you have any questions about completing this tutorial, please contact us on ourcodingclub@gmail.com

#### <a href="INSERT_SURVEY_LINK" target="_blank">We would love to hear your feedback on the tutorial, whether you did it in the classroom or online!</a>

<ul class="social-icons">
	<li>
		<h3>
			<a href="https://twitter.com/our_codingclub" target="_blank">&nbsp;Follow our coding adventures on Twitter! <i class="fa fa-twitter"></i></a>
		</h3>
	</li>
</ul>

_____
### References:
Google Maps (2023). Google Maps Logo. Available at: https://www.google.com/maps/@55.9503053,-3.1918862,14z?entry=ttu.
