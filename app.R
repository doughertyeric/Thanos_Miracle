library(shiny)
library(tidyverse)
library(sf)

#towns <- read_csv('Towns_Population_2016_Prep.csv')

towns <- read_csv('Towns_Population_2016.csv') %>%
  filter(PLACE != 0) %>%
  filter(PLACE != 99990) %>%
  filter(POPESTIMATE2016 != 0)
towns$lon <- NA
towns$lat <- NA

ui <- fluidPage(
  sliderInput(inputId = 'depart.prob',
              label = 'Departure Probability',
              value = 0.5, min = 0.01, max = 0.99),
  actionButton("rerun", "Re-run Simulation"),
  plotOutput(outputId = 'map')
)

server <- function(input, output) {
  
  all_zeros <- eventReactive(input$rerun, {
    departure.sim <- function(depart.prob) {
      zero_departures <- c()
      z=1
      for (i in 1:nrow(towns)) {
        all_draws <- rbinom(n=1, size=towns$POPESTIMATE2016[i], p=depart.prob)
        if (sum(all_draws) == 0) {
          zero_departures[z] <- i
          z = z + 1
        }
      }
      
      all_zeros <- data.frame(matrix(0,length(zero_departures),5))
      colnames(all_zeros) <- c('Town', 'State', 'Population', 'lon', 'lat')
      for (j in 1:length(zero_departures)) {
        row.id <- zero_departures[j]
        all_zeros[j,] <- towns[row.id, c('NAME', 'STNAME', 'POPESTIMATE2016', 'lon', 'lat')]
      }
      all_zeros <- all_zeros[order(all_zeros$Population, decreasing=TRUE),]
      
      return(all_zeros)
    }
    
    departure.sim(input$depart.prob)
  })
  
  output$map <- renderPlot({
    all_zeros <- all_zeros()
    ggplot(data=all_zeros) + geom_histogram(aes(x=Population), binwidth=1)
  })
}

shinyApp(ui = ui, server = server)
