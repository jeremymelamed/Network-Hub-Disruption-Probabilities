######################################################################
# RELIABLE NETWORK DESIGN UNDER MULTIPLE HUB FAILURES
# Hub Distruption Probabilities
# Jeremy Melamed
# January, 2017
#################################################################

# -------------------------------- Disruption Probabilities -------------------------------------
library(ggplot2)
library(geosphere)

# Set working directory
setwd('C:\\Users\\Jeremy\\OneDrive\\Research\\Vergara\\Data')

# Import data
storm_events <- read.csv('NOAA Storm Events\\storm_events_2010.csv')
storm_locs <- read.csv('NOAA Storm Events\\storm_locs_2010.csv')
hubs <- read.csv('hubs.csv', colClasses = c('character', 'numeric', rep('character', 4), rep('numeric', 2)))

# Change data types 
storm_events$STATE <- as.character(storm_events$STATE)
storm_events$EVENT_TYPE <- as.character(storm_events$EVENT_TYPE)
storm_events$CZ_NAME <- as.character(storm_events$CZ_NAME)
storm_events$BEGIN_DATE_TIME <- as.character(storm_events$BEGIN_DATE_TIME)
storm_events$END_DATE_TIME <-as.character(storm_events$END_DATE_TIME)


# Keep only event types that likely would have disrupted a network hub
severe_events <- subset(storm_events, storm_events$EVENT_TYPE %in% c('Blizzard', 'Heavy Snow', 'Hurricane', 'Ice Storm', 'Tornado', 
                                                                    'Tropical Storm', 'Winter Storm', 'Winter Weather'))

# The data set includes multiple recordings of the same event. 
severe_events_locs <- subset(storm_locs, storm_locs$EVENT_ID %in% severe_events$EVENT_ID & 
                                     storm_locs$EPISODE_ID %in% severe_events$EPISODE_ID)

# Initialize empty matrix
disruptions <- character()

# Test loop to determine whether hub was disrupted by an event
for (i in 1:nrow(severe_events_locs)) {
      for (j in 1:nrow(hubs)) {
              # Compute distance between event and hub
              event_dist <- distHaversine(c(hubs$Longitude[j], hubs$Latitude[j]), 
                                          c(severe_events_locs$LONGITUDE[i], severe_events_locs$LATITUDE[i])) * 0.000621371
              
              # Check if within range
              if (event_dist < 25) {
                      
                      # Lookup information for storm_events table
                      event_id <- severe_events_locs$EVENT_ID[i]
                      epi_id <- severe_events_locs$EPISODE_ID[i]
                      event <- subset(storm_events, storm_events$EPISODE_ID == epi_id & storm_events$EVENT_ID == event_id)[c(7,8,9, 13, 16, 18, 20)]
                      
                      # Copy row from storm_events table with hub name
                      disruptions <- rbind(disruptions, c(hubs$FAF.Region[j], event))
              }
              
      }
}


















