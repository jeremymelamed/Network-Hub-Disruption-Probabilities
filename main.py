import os
import numpy as np
import datetime
from generate_network import generate_network


# Read parameters from txt file
path = os.getcwd() 
with open(path + '\Params.txt', 'r') as f:
    Params = []
    for line in f:
        Params.append(line)

# Store parameter values. Ask user if parameters are correct.
L = float(Params[0][(Params[0].index('=')+1):len(Params[0])])
W = float(Params[1][(Params[1].index('=')+1):len(Params[1])])
N = int(Params[2][(Params[2].index('=')+1):len(Params[2])])
H = int(Params[3][(Params[3].index('=')+1):len(Params[3])])
reps = int(Params[4][(Params[4].index('=')+1):len(Params[4])])
h_cost_min=float(Params[5][(Params[5].index('=')+1):len(Params[5])])
h_cost_max=float(Params[6][(Params[6].index('=')+1):len(Params[6])])
p_min=float(Params[7][(Params[7].index('=')+1):len(Params[7])])
p_max=float(Params[8][(Params[8].index('=')+1):len(Params[8])])
link_dens=float(Params[9][(Params[9].index('=')+1):len(Params[9])])
num_loads=float(Params[10][(Params[10].index('=')+1):len(Params[10])])
load_min=int(Params[11][(Params[11].index('=')+1):len(Params[11])])
load_max=int(Params[12][(Params[12].index('=')+1):len(Params[12])])
num_clust=int(Params[13][(Params[13].index('=')+1):len(Params[13])])
clust_rad=float(Params[14][(Params[14].index('=')+1):len(Params[14])])
clust_node_perc=float(Params[15][(Params[15].index('=')+1):len(Params[15])])


# Create nodes, links, and loads for network
nodes, links, loads = generate_network(L, W, N, H, reps, num_clust, clust_rad, clust_node_perc,
                                h_cost_min, h_cost_max, p_min, p_max, link_dens,
                                num_loads, load_min, load_max)

        
### Write files in new folder
curr_path = path.replace("\\", "\\\\")
dt = datetime.datetime.now()
new_path = curr_path + "\\\\" + "Nodes" + str(N) + "_Hubs" + str(H) + '_' + str(dt.strftime("%m.%d.%Y %H.%M"))
os.makedirs(new_path)

os.chdir(new_path)
np.savetxt('nodes.txt', nodes, fmt='%1.3f', delimiter=',', newline='\r\n')
np.savetxt('links.txt', links, fmt='%1.3f', delimiter=',', newline='\r\n')
np.savetxt('loads.txt', loads, fmt='%1.3f', delimiter=',', newline='\r\n')

### Create network visualization
import matplotlib.pyplot as plt
import networkx as nx
from collections import defaultdict

# Create array of link tuples
edges = zip(list(links[:,1]), list(links[:,2]))
edges = list(edges)

# Create node location dictionary
locs = defaultdict(list)
for x in range(N):
    locs[x+1].append((nodes[x,2],nodes[x,3]))
locs=dict(locs)

G=nx.Graph()
G.add_edges_from(list(edges))
fix_nodes = locs.keys()
pos = nx.spring_layout(G, pos=locs, fixed=fix_nodes, iterations=0)
plt.axis([-10, L+10, -10, W+10])
fig = nx.draw_networkx(G, pos, with_labels=False, node_size=75, node_color = 'b', alpha=.5)
plt.savefig(new_path + '\\network_plot.png')
plt.show(fig)






