#################################################################
# RELIABLE NETWORK DESIGN UNDER MULTIPLE HUB FAILURES
# Hub Network Distance and Flow Matrix Preparation
# Jeremy Melamed
# January, 2017
#################################################################

# ---------------------------- Hub Selection ----------------------------------
library(ggplot2)
library(maps)

# Set working directory
setwd('C:\\Users\\Jeremy\\OneDrive\\Research\\Vergara\\Data')

# Read data
world_cities <- read.csv('world_cities.csv', colClasses = c(rep('character',2), rep('numeric', 3), rep('character', 3), 'character'))
faf_meta <- read.csv('FAF4_Metadata.csv', colClasses = c('numeric', rep('character', 4), 'numeric', 'numeric'))

# Subset largest us cities
us_cities <- subset(world_cities, world_cities$country == 'United States of America')
major_cities <- subset(us_cities, us_cities$pop > 500000)

### Consolodate duplicate metro area codes
# Boston = 251, 331, 441
# Chicago = 171, 181
# Cincinatti = 211, 391
# Kansas City 201, 291
# New York = 92, 341, 363, 423
# Philadelphia = 101, 342, 421
# Portland = 411, 532
# St. Louis = 172, 292
# Washington DC = 111, 242, 513
duplicates <- c(331, 441, 181, 391, 291, 341, 363, 423, 342, 421, 532, 292, 242, 513)
faf_new <- data.frame()

for (i in 1:nrow(faf_meta)) {
        if (faf_meta$Code[i] %in% duplicates) {
                # Do nothing
        } else {
                faf_new <- rbind(faf_new, faf_meta[i, ])
        }
}

# Assign hubs from FAF flow data city and metro locations using major cities
hubs <- data.frame()

for (i in 1:nrow(major_cities)) {
        city <- major_cities$city[i]
        
        for (j in 1:nrow(faf_new)) {
                if (substr(faf_new$FAF.Region[j], 1, nchar(city)) == city) {
                        hubs <- rbind(hubs, faf_new[j, ])
                }
        }
}

# Visualization of hubs
ggplot() + geom_polygon(data = map_data('state'), aes(x=long, y=lat, group = group), colour = 'white') +
        geom_point(data = hubs, aes(x=Longitude, y=Latitude), color='coral1', size = 3, show.legend = FALSE) +
        ggtitle('US Hubs Locations')

# write.csv(hubs, 'hubs.csv')

# ---------------------------- Hub Distances ----------------------------------
library(geosphere)

# Distance matrix in km
hub_distances <- round(distm(cbind(hubs$Longitude, hubs$Latitude), cbind(hubs$Longitude, hubs$Latitude)) / 1000, 2)

# Add column names for cities, and row of city names for reference
colnames(hub_distances) <- hubs$FAF.Region
hub_distances <- cbind(as.character(hubs$FAF.Region), hub_distances)

# write.csv(hub_distances, 'distance_matrix.csv')

# ---------------------------- Flow Matrix ------------------------------------
# Read freight data
faf <- read.csv('FAF4_Reduced.CSV') # reduced subset of original faf data
state_codes <- read.csv('state_codes.csv', colClasses = c('numeric', 'character'))

# Remove coal
faf_nocoal <- subset(faf, faf$sctg2 != 15)

# Flow data empty matrix
flows <- matrix(nrow = nrow(hubs), ncol = nrow(hubs))

# Consolodate metro area codes
boston = c(251, 331, 441)
chic = c(171, 181)
cinci = c(211, 391)
kc = c(201, 291)
ny = c(92, 341, 363, 423)
phila = c(101, 342, 421)
portland = c(411, 532)
sl = c(172, 292)
dc = c(111, 242, 513)

# Sum of flow data between metro areas
for (i in 1:nrow(hubs)) {
        for (j in 1:nrow(hubs)) {
                
                # Remove intercity flows
                if (i == j) {
                        flows[i,j] <- 0
                } else {
                      
                        # Determine from and to city/metro areas
                        x <- hubs$Code[i]
                        y <- hubs$Code[j]
                        
                        # Take into account consolidated metros
                        if (x == 251) {
                                x <- boston
                        } else if (x == 171) {
                                x <- chic
                        } else if (x == 211) {
                                x <- cinci
                        } else if (x == 201) {
                                x <- kc
                        } else if (x == 92) {
                                x <- ny
                        } else if (x == 101) {
                                x <- phila
                        } else if (x ==411) {
                                x <- portland
                        } else if (x == 172) {
                                x <- sl 
                        } else if (x == 111) {
                                x <- dc
                        }
                        
                        if (y == 251) {
                                y <- boston
                        } else if (y == 171) {
                                y <- chic
                        } else if (y == 211) {
                                y <- cinci
                        } else if (y == 201) {
                                y <- kc
                        } else if (y == 92) {
                                y <- ny
                        } else if (y == 101) {
                                y <- phila
                        } else if (y == 411) {
                                y <- portland
                        } else if (y == 172) {
                                y <- sl 
                        } else if (y == 111) {
                                y <- dc
                        }
                        
                        # Subset of data with corresponding from-to cities
                        temp <- subset(faf, faf$dms_orig %in% x & faf$dms_dest %in% y)
                
                        # Sum flow data in for relationship
                        flows[i,j] <- sum(temp$tons_2012)
                }
        }
}

colnames(flows) <- as.character(hubs$FAF.Region)
flows <- cbind(as.character(hubs$FAF.Region), flows)

# write.csv(flows, 'flows_matrix.csv')







