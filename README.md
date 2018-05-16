# Thanos Miracle

[SPOILER ALERT!!]

In Avengers: Infinity War, Thanos succeeds in collecting all six of the Infinity gems, giving him the power to eliminate half of all life in the Universe with a snap of his fingers. The final scene of the movie is not entirely unlike the beginning of the HBO series The Leftovers, in which 2% of the population mysteriously disappears, resulting in vehicles collisions and other accidents when drivers suddenly 'depart' from the driver's seat. In a subsequent season of The Leftovers, it is revealed that Jarden, Texas (site of Miracle National Park) was the location in America with the largest popualtion that experienced zero departures (none of its 9,261 residents departed).

The goal of this Shiny App is to explore where in America we might place Miracle National Park following the snap of Thanos's fingers. Of course, the elimination of 50% of the population is much more severe than a loss of only 2%, so we would expect for the town's population to be substantially less than the 9,261 in Jarden, but just how big of a town might we expect to see experience no departures?

A simple simulation is carried out in which each of the towns recorded in the 2010 census are simulated independently, and each individual within the town is selected to remain or depart. Once a single individual from a town departs, it no longer qualifies for Miracle National Park. At the end of the simulation, the town with the largest population that experienced zero departures, if there are any, is returned.
