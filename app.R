library(shiny)
library(tidyverse)
library(sf)
library(maps)
library(DT)

towns <- read_csv('Cities_Population_2016.csv') %>%
  filter(Population != 0)

# towns <- read_csv('Towns_Population_2016.csv') %>%
#   filter(PLACE != 0) %>%
#   filter(PLACE != 99990) %>%
#   filter(POPESTIMATE2016 != 0)
# towns$lon <- NA
# towns$lat <- NA

ui <- fluidPage(
  headerPanel('Finding Miracle in Thanos\'s America'),
  helpText('[SPOILER ALERT!!]
            \n
            In Avengers: Infinity War, Thanos succeeds in collecting all six of the 
            Infinity gems, giving him the power to eliminate half of all life in the
            Universe with a snap of his fingers. The final scene of the movie is not 
            entirely unlike the beginning of the HBO series The Leftovers, in which 2% 
            of the population mysteriously disappears, resulting in vehicle collisions 
            and other accidents when drivers suddenly \'depart\' from the driver\'s seat. 
            In a subsequent season of The Leftovers, it is revealed that Jarden, Texas (site 
            of the fictional Miracle National Park) was the location in America with the largest 
            popualtion that experienced zero departures (none of its 9,261 residents departed).
            \n \n
            The goal of this Shiny App is to explore where in America we might place Miracle
            National Park following the snap of Thanos\'s fingers. Of course, the elimination
            of 50% of the population is much more severe than a loss of only 2%, so we would 
            expect for the town\'s population to be substantially less than the 9,261 in Jarden
            (already an exceptional outlier, as you can see by setting the slider to 0.02),
            but just how big of a town might we expect to see experience no departures?
            \n \n
            A simple simulation is carried out in which each of the towns recorded in the 2016 
            census are simulated independently, and each individual within the town is selected 
            to remain or depart. Once a single individual from a town departs, it no longer qualifies
            for Miracle National Park. At the end of the simulation, the towns with the largest populations
            that experienced zero departures are returned.'),
  sliderInput(inputId = 'depart.prob',
              label = 'Departure Probability',
              value = 0.5, min = 0.01, max = 0.50),
  actionButton("rerun", "Re-run Simulation"),
  plotOutput(outputId = 'map'),
  DT::dataTableOutput(outputId = 'table')
)

server <- function(input, output) {
  
  all_zero_func <- eventReactive(input$rerun, {
    departure.sim <- function(depart.prob) {
      zero_departures <- c()
      z=1
      for (i in 1:nrow(towns)) {
        all_draws <- rbinom(n=1, size=towns$Population[i], p=depart.prob)
        if (sum(all_draws) == 0) {
          zero_departures[z] <- i
          z = z + 1
        }
      }
      
      while (length(zero_departures) < 1) {
        zero_departures <- c()
        z=1
        for (i in 1:nrow(towns)) {
          all_draws <- rbinom(n=1, size=towns$Population[i], p=depart.prob)
          if (sum(all_draws) == 0) {
            zero_departures[z] <- i
            z = z + 1
          }
        }
      }
      
      all_zeros <- data.frame(matrix(0,length(zero_departures),4))
      colnames(all_zeros) <- c('Name', 'Population', 'Longitude', 'Latitude')
      for (j in 1:length(zero_departures)) {
        row.id <- zero_departures[j]
        all_zeros[j,] <- towns[row.id, c('Name', 'Population', 'Longitude', 'Latitude')]
      }
      all_zeros <- all_zeros[order(all_zeros$Population, decreasing=TRUE),]
      
      return(all_zeros)
    }
    
    departure.sim(input$depart.prob)
  }, ignoreNULL = FALSE)
  
  output$map <- renderPlot({
    all_zeros_sf <- st_as_sf(all_zero_func(), coords=3:4, crs=4326)
    all_states <- map_data("state")
    ggplot() + 
      geom_polygon(data=all_states, aes(x=long, y = lat, group = group, fill=1, color=as.factor(1))) +
      scale_color_manual(values='black') +
      geom_sf(data=all_zeros_sf, aes(stroke = (Population * (4/max(Population))))) +
      theme(legend.position="none")
  })
  
  output$table <- DT::renderDataTable({
    data.frame(all_zero_func())
  })
  
}

shinyApp(ui = ui, server = server)
