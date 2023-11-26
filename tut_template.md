<center>![Image credit: Google Maps](https://cdn.arstechnica.net/wp-content/uploads/2023/09/Google-Maps-640x361.jpg) <center>


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

```
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

1. Go to the [Credentials page of the Google Maps Platform](https://console.cloud.google.com/projectselector2/google/maps-apis/credentials?utm_source=Docs_CreateAPIKey&utm_content=Docs_maps-backend) and select "Create project". Pick a name for it, and ignore the organisation ('No organisation' is fine for the purposes of this tutorial). Press "Create" and copy the API key it provides you (e.g. AIzaSyDnersipSvcXuK4tCDbr8NOpa-qsrYf9pc), and add it into your script like so:
```
ggmap::register_google(key = "your key here", write = TRUE) #register your own Google API Key here
```


At the beginning of your tutorial you can ask people to open `RStudio`, create a new script by clicking on `File/ New File/ R Script` set the working directory and load some packages, for example `ggplot2` and `dplyr`. You can surround package names, functions, actions ("File/ New...") and small chunks of code with backticks, which defines them as inline code blocks and makes them stand out among the text, e.g. `ggplot2`.

When you have a larger chunk of code, you can paste the whole code in the `Markdown` document and add three backticks on the line before the code chunks starts and on the line after the code chunks ends. After the three backticks that go before your code chunk starts, you can specify in which language the code is written, in our case `R`.

To find the backticks on your keyboard, look towards the top left corner on a Windows computer, perhaps just above `Tab` and before the number one key. On a Mac, look around the left `Shift` key. You can also just copy the backticks from below.

```r
# Set the working directory
setwd("your_filepath")

# Load packages
library(ggplot2)
library(dplyr)
```

<a name="section2"></a>

## 2. The second section

You can add more text and code, e.g.

```r
# Create fake data
x_dat <- rnorm(n = 100, mean = 5, sd = 2)  # x data
y_dat <- rnorm(n = 100, mean = 10, sd = 0.2)  # y data
xy <- data.frame(x_dat, y_dat)  # combine into data frame
```

Here you can add some more text if you wish.

```r
xy_fil <- xy %>%  # Create object with the contents of `xy`
	filter(x_dat < 7.5)  # Keep rows where `x_dat` is less than 7.5
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
