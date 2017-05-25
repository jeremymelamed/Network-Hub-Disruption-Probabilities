import numpy as np
import pandas as pd
import random
import os
import math
from math import sqrt
from combination import rep_ids

np.set_printoptions(suppress=True)

# Create matrix with node ids, location, cost, and replications
def generate_network(L, W, N, H, reps, num_clust, clust_rad, clust_node_perc,
                     h_cost_min, h_cost_max, p_min, p_max, link_density):
    
    # Check to see if clusters are desired. If so, store centroids.
    if num_clust != 0:
        centroids = np.zeros((1, 2))
        
        for i in range(num_clust):
            new_centroid = [round(np.random.uniform(clust_rad, L-clust_rad), 3),
                            round(np.random.uniform(clust_rad, W-clust_rad), 3)]
            if i == 0:
                centroids[0] = new_centroid
            else:
                centroids = np.row_stack((centroids, new_centroid))
    
    # In each iteration, generate a new node and connect it to the existing network to ensure connectivity.
    for i in range(N):

        # Unclustered Case. Generate nodes uniformly.
        if num_clust == 0:
            # Set all cluster ids to zero for unclustered case
            clust_id = 0
            if i == 0:
                # Initialize nodes matrix
                nodes = [i+1, clust_id, round(np.random.uniform(0, L), 3), round(np.random.uniform(0, W), 3),
                            round(np.random.uniform(h_cost_min, h_cost_max), 3), round(np.random.uniform(p_min, p_max), 3)]
            else:
                # Create additional nodes 
                new_node = [i+1, clust_id, round(np.random.uniform(0, L), 3), round(np.random.uniform(0, W), 3),
                            round(np.random.uniform(h_cost_min, h_cost_max), 3), round(np.random.uniform(p_min, p_max), 3)]
                nodes = np.row_stack((nodes, new_node))

            # Create Links
            if i == 1:
                # Initialize links matrix with link between first two nodes. 
                dist = sqrt((nodes[0,1] - nodes[1,1])**2 + (nodes[0,2] - nodes[1,2])**2)
                links = [i, 1, 2, dist]
                new_link = [i+1, 2, 1, dist]
                links = np.row_stack((links, new_link))
            elif i > 1:
                # Connect to most recent node in unclustered case to avoid overlinking to first nodes
                orig = nodes[i-1,0]
                dest = nodes[i,0] 
                dist = sqrt((nodes[i,2] - nodes[i-1,2])**2 + (nodes[i,3] - nodes[i-1,3])**2)
                # Add link going in both directions to ensure connectivity
                index = len(links) + 1
                link1 = [index, orig, dest, dist]
                link2 = [index+1, dest, orig, dist]
                links = np.row_stack((links, link1, link2))
                
        # Clustered Case. Generate proportion of nodes to be within assigned number of clusters.
        else:
            clust_nodes = round(clust_node_perc*N) / num_clust
            if i == 0:
                # Set first node to be in cluster 1
                clust_id = 1
                theta = random.uniform(0, 2*math.pi)
                x_cord = centroids[clust_id-1,0] + clust_rad*math.cos(theta)
                y_cord = centroids[clust_id-1,1] + clust_rad*math.sin(theta)
                nodes = [i+1, clust_id, x_cord, y_cord, round(random.uniform(h_cost_min, h_cost_max), 3),
                         round(random.uniform(p_min, p_max), 3)]

            elif math.ceil(i/clust_nodes) <= num_clust:
                # Determine which cluster to assign node to.
                clust_id = math.ceil(i/clust_nodes)
                
                theta = random.uniform(0, 2*math.pi)
                x_cord = centroids[clust_id-1,0] + clust_rad*math.cos(theta)
                y_cord = centroids[clust_id-1,1] + clust_rad*math.sin(theta)
                new_node = [i+1, clust_id, x_cord, y_cord, round(random.uniform(h_cost_min, h_cost_max), 3),
                         round(random.uniform(p_min, p_max), 3)]
                nodes = np.row_stack((nodes, new_node))

            else:
                # Assign addition nodes not associated with cluster
                clust_id = 0
                
                theta = random.uniform(0, 2*math.pi)
                x_cord = random.uniform(0, L)
                y_cord = random.uniform(0, W)
                new_node = [i+1, clust_id, x_cord, y_cord, round(random.uniform(h_cost_min, h_cost_max), 3),
                         round(random.uniform(p_min, p_max), 3)]
                nodes = np.row_stack((nodes, new_node))

            # Create Links
            if i == 1:
                # Initialize links matrix with link between first two nodes. 
                dist = sqrt((nodes[0,2] - nodes[1,2])**2 + (nodes[0,3] - nodes[1,3])**2)
                links = [i, 1, 2, dist]
                new_link = [i+1, 2, 1, dist]
                links = np.row_stack((links, new_link))
                
            elif i > 1:
                # Connect to most recent node in unclustered case to avoid overlinking to first nodes
                orig = nodes[i-1,0]
                dest = nodes[i,0] 
                dist = sqrt((nodes[i,2] - nodes[i-1,2])**2 + (nodes[i,3] - nodes[i-1,3])**2)
                # Add link going in both directions to ensure connectivity
                index = len(links) + 1
                link1 = [index, orig, dest, dist]
                link2 = [index+1, dest, orig, dist]
                links = np.row_stack((links, link1, link2))
                
    # Add links to network until desired density is achieved    
    while True:
        curr_density = len(links) / (N*(N-1))
        if curr_density < link_density:
            # Create data frame to find all rows where origin is equal to value
            links = pd.DataFrame(links, columns=['id', 'origin', 'destination', 'distance'])
            orig = np.random.randint(1, len(nodes)+1)
            existing_links = links.loc[links['origin'] == orig]
            # If node origin is not connected to all destinations, add link to new destination
            if len(existing_links) < N-1:
                existing_dest = existing_links.destination.unique()
                existing_dest = np.append(np.array(existing_dest), orig)
                potential_new_dest = [x for x in range(1, len(nodes)+1) if x not in existing_dest]
                new_dest = np.random.choice(potential_new_dest, 1)

                dist = sqrt((nodes[orig-1,1] - nodes[new_dest-1,1])**2 + (nodes[orig-1,2] - nodes[new_dest-1,2])**2)
                
                new_link = [len(links) + 2, orig, new_dest, dist]
                links = np.row_stack((links, new_link))
        else:
            break      

    # Add replication identifier columns to nodes network
    reps = rep_ids(N, H, reps)
    nodes = np.column_stack((nodes, reps))

    return nodes, links

nodes, links = generate_network(L=100, W=100, N=30, H=4, reps=5, num_clust=5, clust_rad=30,
                         clust_node_perc=.3, h_cost_min=1, h_cost_max=2,
                         p_min=.1, p_max=.2, link_density = .1)

print(nodes)
print(links)



# Create network visualization
import matplotlib.pyplot as plt
import networkx as nx
from collections import defaultdict

# Create array of link tuples
##edges = zip(list(links[:,1]), list(links[:,2]))
##edges = list(edges)
##
### Create node location dictionary
##locs = defaultdict(list)
##for x in range(30):
##    locs[x+1].append((nodes[x,2],nodes[x,3]))
##
##locs=dict(locs)
##print(locs)
##
##
##G=nx.Graph()
##G.add_edges_from(list(edges))
##fix_nodes = locs.keys()
##pos = nx.spring_layout(G, pos=locs, fixed=fix_nodes)
##nx.draw_networkx(G, pos)
##plt.show()




