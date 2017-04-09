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

library(Hmisc)

# -------------------------------- Read and Initialize Data -------------------------------------
# Import data
setwd('C:\\Users\\Jeremy\\OneDrive\\Research\\Network-Hub-Disruption-Probabilities\\Data')
storm_events <- read.csv('NOAA Storm Events\\storm_events_2010.csv')
storm_locs <- read.csv('NOAA Storm Events\\storm_locs_2010.csv')
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

# Summary of disruption event types
foo <- disrupt_events[!duplicated(disrupt_events[7]),]
table(foo$EVENT_TYPE)


# ------------------------------- Identify disrupting events --------------------------------
# Data frame for event occurences
disruptions <- matrix(nrow = 0, ncol = 4)
colnames(disruptions) <- c('year', 'month', 'day', 'hubs_disrupted')

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
}


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
ndays <- 365

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







