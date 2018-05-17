library(tidyverse)
library(ggmap)
library(shiny)

towns <- read_csv('Towns_Population_2016.csv') %>%
  filter(PLACE != 0) %>%
  filter(PLACE != 99990) %>%
  filter(POPESTIMATE2016 != 0)
#towns$lon <- NA
#towns$lat <- NA

# Create a name to use for searching the Google Maps API
name_list <- c()
for (i in 1:nrow(towns)) {
  name <- towns$NAME[i]
  name <- gsub(x=name, pattern=' city', '', ignore.case=FALSE)
  name <- gsub(x=name, pattern=' town', '', ignore.case=FALSE)
  name_list[i] <- paste0(name, ", ", towns$STNAME[i])
}
towns$name <- name_list

cities <- read_csv('city_coords.csv')
name_list2 <- c()
for (i in 1:nrow(cities)) {
  name <- cities$city[i]
  name_list2[i] <- paste0(name, ", ", cities$state_name[i])
}
cities$name <- name_list2

city_pops <- inner_join(cities, towns)

city_pops <- city_pops %>%
  mutate(Name = name,
         Longitude = lng,
         Latitude = lat,
         Population = population) %>%
  dplyr::select(Name, Longitude, Latitude, Population)
city_pops <- city_pops[!duplicated(city_pops$Name),]

# Use the geocode command to return the coordinates of each town
for (i in 1:2500) {
  temp.coords <- geocode(name_list[i], force=TRUE, override_limit=TRUE)
  towns$lon[i] <- temp.coords$lon
  towns$lat[i] <- temp.coords$lat
}

write.csv(towns, 'Towns_Population_2016_Prep.csv')
