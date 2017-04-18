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

# -------------------------------- Read and Initialize Data -------------------------------------
# Import data
setwd('C:\\Users\\melam\\OneDrive\\Research\\Network-Hub-Disruption-Probabilities\\Data')
storm_events <- rbind(read.csv('NOAA Storm Events\\storm_events_2010.csv'),
                      read.csv('NOAA Storm Events\\storm_events_2011.csv'),
                      read.csv('NOAA Storm Events\\storm_events_2012.csv'),
                      read.csv('NOAA Storm Events\\storm_events_2013.csv'),
                      read.csv('NOAA Storm Events\\storm_events_2014.csv'),
                      read.csv('NOAA Storm Events\\storm_events_2015.csv'),
                      read.csv('NOAA Storm Events\\storm_events_2016.csv'))
storm_locs <- rbind(read.csv('NOAA Storm Events\\storm_locs_2010.csv'),
                    read.csv('NOAA Storm Events\\storm_locs_2011.csv'),
                    read.csv('NOAA Storm Events\\storm_locs_2012.csv'),
                    read.csv('NOAA Storm Events\\storm_locs_2013.csv'),
                    read.csv('NOAA Storm Events\\storm_locs_2014.csv'),
                    read.csv('NOAA Storm Events\\storm_locs_2015.csv'),
                    read.csv('NOAA Storm Events\\storm_locs_2016.csv'))
hubs_locs <- read.csv('hubs_counties.csv', colClasses = c('numeric', rep('character', 3), rep('numeric', 2)))

# Change data types 
storm_events$STATE <- as.character(storm_events$STATE)
storm_events$EVENT_TYPE <- as.character(storm_events$EVENT_TYPE)
storm_events$CZ_NAME <- as.character(storm_events$CZ_NAME)


# ------------------------------- Subset of events which impact hub network ----------------------
# Only include events deemed to be significant causes of network disruption.
types <- c('Blizzard', 'Flash Flood', 'Flood', 'Heavy Snow', 'Hurricane', 'Ice Storm', 'Tornado', 'Winter Weather')

# Subset storm events data set to only include events which impact counties where hubs are located, 
# and are one of the severe event types of interest.
disrupt_events <- subset(storm_events[ , 1:16], storm_events$CZ_NAME %in% hubs_locs$County & 
                                 storm_events$EVENT_TYPE %in% types)

# Remove events which are associated in counties of the same name in a different state
foo <- numeric()

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
                foo <- c(foo, i)
        }
}
# Remove events which correspond to an incorrect county
disrupt_events <- disrupt_events[-c(foo), ]

# Determine length of disrupting event
duration <- disrupt_events$END_DAY - disrupt_events$BEGIN_DAY
disrupt_events$duration <- duration

# Check if any events span two months. 
which(disrupt_events$BEGIN_YEARMONTH != disrupt_events$END_YEARMONTH) # none found

# Summary of disruption event types
foo <- disrupt_events[!duplicated(disrupt_events[7]),]
x <- barplot(table(foo$EVENT_TYPE), axisnames = F)
labs <- names(table(foo$EVENT_TYPE))
text(cex=1, x=(x -.25), y=-80, labs, xpd=TRUE, srt=45)

# ------------------------------- Identify disrupting events --------------------------------
# Data frame for event occurences
disruptions <- matrix(nrow = 0, ncol = 4)
colnames(disruptions) <- c('year', 'month', 'day', 'hubs_disrupted')

# # function to determine next day, month, yr
# month_len <- function(m) {
#         switch(m, 
#                '01' = 31,
#                '02' = 28,
#                '03' = 31,
#                '04' = 30,
#                '05' = 31,
#                '06' = 30,
#                '07' = 31,
#                '08' = 31,
#                '09' = 30,
#                '10' = 31,
#                '11' = 30,
#                '12' = 31
#                )
# }

# Sort columns in data frame before processing
disrupt_events <- disrupt_events[order(disrupt_events[,1], disrupt_events[,2]), ]

# Add disruption indicators to matrix 
for (i in 1:nrow(disrupt_events)) {
     
        # Date of row event
        yr <- substr(disrupt_events$BEGIN_YEARMONTH[i], 1, 4)
        mo <- substr(disrupt_events$BEGIN_YEARMONTH[i], 5, 7)
        day <- disrupt_events$BEGIN_DAY[i]
        
        # Check to see if disruptions have already been entered for date
        foo <- which(disruptions[ , 1] == yr & disruptions[ , 2] == mo & disruptions[ , 3] == day)
        
        if (length(foo) == 0) {
                # Other disruption events that occured on same date
                x <- which(substr(disrupt_events$BEGIN_YEARMONTH, 1, 4) == yr &
                           substr(disrupt_events$BEGIN_YEARMONTH, 5, 7) == mo &
                                  disrupt_events$BEGIN_DAY == day)
                
                # Counties and hubs disrupted on yr/mo/day
                cs <- unique(disrupt_events$CZ_NAME[x]) 
                hs <- which(hubs_locs$County %in% cs)
                
                # Enter ID for hubs disrupted on date
                disruptions <- rbind(disruptions, c(yr, mo, day, paste(c('-', hs, '-'), collapse = '-')))
        }

        # Add events for subsequent days if duration > 0
        if (disrupt_events$duration[i] > 0) {
                
               dur <- disrupt_events$duration[i]
                
               for (j in 1:dur) {
               
                      day = day + 1
               
                      # Check to see if disruptions have already been entered for next date
                      foo <- which(disruptions[ , 1] == yr & disruptions[ , 2] == mo & disruptions[ , 3] == day)
                      
                      # If no events entered for date
                      if (length(foo) == 0) {
               
                              # Other disruption events that occured on same date
                              x <- which(substr(disrupt_events$BEGIN_YEARMONTH, 1, 4) == yr &
                                                 substr(disrupt_events$BEGIN_YEARMONTH, 5, 7) == mo &
                                                 disrupt_events$BEGIN_DAY == day)
               
                              # Counties and hubs disrupted on yr/mo/day
                              cs <- unique(disrupt_events$CZ_NAME[x])
                              hs <- which(hubs_locs$County %in% cs)
                              # Hub with extended disruption
                              h <- which(hubs_locs$County == disrupt_events$CZ_NAME[i])
                              
                              # Enter ID for hubs disrupted on date
                              disruptions <- rbind(disruptions, c(yr, mo, day, paste(c('-', hs, '-', h, '-'), collapse = '-')))
                              
                      # If other events have already been entered for the date append hub list.
                      } else {
                              # Date index in disruptions matrix
                              x <- which(disruptions[,1] == yr & disruptions[,2] == mo & disruptions[,3] == day)
                              # Hub index
                              h <- which(hubs_locs$County == disrupt_events$CZ_NAME[i])
               
                              # Append hub to list.
                              disruptions[x, 4] <- paste(disruptions[x, 4], '-', h, '-', sep = '', collapse = '-')
                      }
               
               }
                
        }
} 

# write.csv(disruptions, 'disruptions_new.csv')

# ------------------------------- Hub disruption probabilities -----------------------------
# Marginal disruption probabilities
marg <- function(h_id) {
        foo <- paste('-', h_id, '-', sep = '')
        # Number of days hub_id is disrupted
        n <- length(grep(foo, disruptions[ , 4]))
}

# Joint disruption probabilities
joint <- function(h1, h2) {
        foo <- paste('-', h1, '-', sep = '')
        bar <- paste('-', h2, '-', sep = '')
        # Events causing disruptions at respective hubs
        dis1 <- grep(foo, disruptions[ , 4])
        dis2 <- grep(bar, disruptions[ , 4])
        # Number of days with concurrent disruptions
        n <- length(intersect(dis1, dis2))
}

# Marginal and joint probability matrix for hub network
disrupt_probs <- matrix(nrow = nrow(hubs_locs), ncol = nrow(hubs_locs)) 
ndays <- 365 * 7

for (i in 1:nrow(disrupt_probs)) {
        for (j in 1:i) {
                if (i == j) {
                        # Marginal prob
                        disrupt_probs[i, j] <- round(marg(i) / ndays, 4)
                } else {
                        # Joint prob
                        disrupt_probs[i, j] <- round(joint(i, j) / ndays, 4)
                }
                        
        }
}

colnames(disrupt_probs) <- hubs_locs$Hub


# ------------------------------- Results Summary --------------------------
library(ggplot2)
library(maps)

# Add column of marginal probabilities to hubs df
hubs_locs$disrupt_prob <- diag(disrupt_probs)

# Visualization of hubs with probabilites
require(gridExtra)
p1 <- ggplot() + geom_polygon(data = map_data('state'), aes(x=long, y=lat, group = group), colour = 'white') +
     geom_point(data = hubs_locs, aes(x=Longitude, y=Latitude), color='coral1', size = 3, show.legend = FALSE) +
     ggtitle('US Hubs Locations') + theme(plot.title = element_text(hjust = 0.5))

p2 <- ggplot() + geom_polygon(data = map_data('state'), aes(x=long, y=lat, group = group), colour = 'white') +
          geom_point(data = hubs_locs, aes(x=Longitude, y=Latitude), color='coral1', size = 100 * hubs_locs$disrupt_prob, show.legend = FALSE) +
          ggtitle('US Hubs Locations') + theme(plot.title = element_text(hjust = 0.5))

grid.arrange(p1, p2, ncol=2)


