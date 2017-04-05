######################################################################
# RELIABLE NETWORK DESIGN UNDER MULTIPLE HUB FAILURES
#
# This script calculates joint disruption probabilities for hubs in 
# midwest states due to Tornadoes. The data used for this research
# comes from NOAA severe weather storm events database. 
#
# These probabilities are used as a realistic instance to test
# reliable reliable hub network optimization algorithms.
#
# Author: Jeremy Melamed
# Date Updated: April, 2017
#################################################################

# -------------------------------- Disruption Probabilities -------------------------------------
library(ggplot2)
library(geosphere)

### Import data
setwd('C:\\Users\\Jeremy\\OneDrive\\Research\\Network-Hub-Disruption-Probabilities\\Data')
storm_events <- read.csv('NOAA Storm Events\\storm_events_2010.csv')
storm_locs <- read.csv('NOAA Storm Events\\storm_locs_2010.csv')
hubs_locs <- read.csv('hubs_counties.csv', colClasses = c(rep('character', 3), rep('numeric', 2)))

# Summary of disruption event types
foo <- storm_events[!duplicated(storm_events[7]),]
summary(foo$EVENT_TYPE)

### Change data types 
storm_events$STATE <- as.character(storm_events$STATE)
storm_events$EVENT_TYPE <- as.character(storm_events$EVENT_TYPE)
storm_events$CZ_NAME <- as.character(storm_events$CZ_NAME)

# Only include events deemed to be significant causes of network disruption.
types <- c('Blizzard', 'Flash Flood', 'Flood', 'Heavy Snow', 'Hurricane', 'Ice Storm', 'Tornado', 'Winter Weather')

# Subset storm events data set to only include events which impact counties where hubs are located, 
# and are one of the severe event types of interest.
disrupt_events <- subset(storm_events, storm_events$CZ_NAME %in% hubs_locs$County & 
                                 storm_events$EVENT_TYPE %in% types)

# Remove events which are associated in counties of the same name in a different state
for (i in 1:nrow(disrupt_events)) {
        # Storm event county and state
        event_county <- disrupt_events$CZ_NAME[i]
        event_state <- disrupt_events$STATE[i]
        # Correct state associated with the hub a county
        s <- hubs_locs$State[which(hubs_locs$County == event_county)]
        
        # Remove disruption event rows with incorrect state
        if (event_state == s) {
                # Keep event
        } else {
                disrupt_events <- disrupt_events[-c(i), ]
        }
}


# Initialize empty matrix
disruptions <- matrix(nrow = 0, ncol = ncol(tornado_events) + 1)

# Determine whether hub was disrupted by an event
for (i in 1:nrow(tornado_events)) {
      for (j in 1:nrow(hubs)) {
              
              # Compute distance between event and hub
              event_dist <- distHaversine(c(hubs$Longitude[j], hubs$Latitude[j]), 
                                          c(tornado_events$BEGIN_LON[i], tornado_events$BEGIN_LAT[i])) * 0.000621371
              
              # Check if within disruption range (r = 25 mi)
              if (event_dist < 50) {
                      
                      # Lookup information for storm_events table
                      # event_id <- severe_events_locs$EVENT_ID[i]
                      # epi_id <- severe_events_locs$EPISODE_ID[i]
                      # event <- subset(storm_events, storm_events$EPISODE_ID == epi_id & storm_events$EVENT_ID == event_id)[c(7,8,9, 13, 16, 18, 20)]
                      
                      # Copy row from storm_events table with hub name
                      disruptions <- rbind(disruptions, c(hubs$FAF.Region[j], tornado_events[i, ]))
              }
              
      }
}

disruptions <- as.matrix(disruptions)






### Event durations
# test <- storm_events
# test$BEGIN_DATE_TIME <- as.POSIXct(as.character(storm_events$BEGIN_DATE_TIME), '%d-%b-%y %H:%M:%S', tz = 'GMT')
# test$END_DATE_TIME <- as.POSIXct(as.character(storm_events$END_DATE_TIME), '%d-%b-%y %H:%M:%S', tz = 'GMT')
# test$DURATION <- test$END_DATE_TIME - test$BEGIN_DATE_TIME
test$DAY_DIFF <- test$END_DAY - test$BEGIN_DAY
boxplot(test$DAY_DIFF, main = 'Event Duration Boxplot')









