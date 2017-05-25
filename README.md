# Network-Hub-Disruption-Probabilities

## Research Description
When designing hub networks, it is important to consider how well these networks are able to function when one or more hubs are disrupted. There is currently a need for efficient algorithms to design transportation networks to account for multiple hub failures. The work presented in this repository is focused on creating data sets reliable hub network optimization algorithms. First is a "realistic instance" network based off of US metropolitan areas. After estimating distances, flows, and disruption probabilities for this realistic instance, I developed a framework to generate different theoretical networks to test the algorithms. The work completed in this repository was funded by Dr. Hector Vergara at Oregon State University as part of his research group. 

#### Realistic Instance 
The Reliable Hub Network script assigns selects hub locations, and computes a distance and flow matrix for each hub. Selected hub locations are based on the highest metropolitan areas in the US. Flow data is aggregated from the Freight Analysis Framework version 4 (FAF4), which summarizes the amount of goods transported within and between US metropolitan area as well as other countries. 

Using the designated hub locations, disruption probabilities are estimated based on severe weather event data from the NOAA. The research focuses on finding both marginal disruption probabilities for each hub, along with joint probability distributions between hubs.

#### Generating Theoretical Networks
The project also includes python scripts to generate a theoretical network to test the optimization algorithms based off of user specified parameters. This framework is intended to provide an efficient and flexible way to create data sets for future research initiatives. 
