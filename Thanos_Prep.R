library(tidyverse)
library(ggmap)
library(shiny)

towns <- read_csv('Towns_Population_2016.csv') %>%
  filter(PLACE != 0) %>%
  filter(PLACE != 99990) %>%
  filter(POPESTIMATE2016 != 0)
towns$lon <- NA
towns$lat <- NA

# Create a name to use for searching the Google Maps API
name_list <- c()
for (i in 1:nrow(towns)) {
  name <- towns$NAME[i]
  name <- gsub(x=name, pattern=' city', '', ignore.case=FALSE)
  name <- gsub(x=name, pattern=' town', '', ignore.case=FALSE)
  name_list[i] <- paste0(name, ", ", towns$STNAME[i])
}

# Use the geocode command to return the coordinates of each town
for (i in 1:length(name_list)) {
  temp.coords <- geocode(name_list[i], force=TRUE, override_limit=TRUE)
  towns$lon[i] <- temp.coords$lon
  towns$lat[i] <- temp.coords$lat
}


################################################



print(max(all_zeros$Population))

all_zeros <- st_as_sf(all_zeros, coords=4:5, crs=4326)
max_zero <- all_zeros[1,]

ggplot() + geom_sf(data=all_zeros, aes(size=Population, fill=1))
