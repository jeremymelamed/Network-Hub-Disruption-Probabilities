import os
import numpy as np
from create_network import create_nodes
from create_links import create_links

# Read parameters from txt file
path = os.getcwd() 
with open(path + '\Params.txt', 'r') as f:
    Params = []
    for line in f:
        Params.append(line)

# Print parameters. Ask user if parameters are correct.
L = float(Params[0][(Params[0].index('=')+1):len(Params[0])])
W = float(Params[1][(Params[1].index('=')+1):len(Params[1])])
N = int(Params[2][(Params[2].index('=')+1):len(Params[2])])
H = int(Params[3][(Params[3].index('=')+1):len(Params[3])])
h_cost_min=float(Params[4][(Params[4].index('=')+1):len(Params[4])])
h_cost_max=float(Params[5][(Params[5].index('=')+1):len(Params[5])])

# Get nodes, links, and loads data
nodes = create_nodes(L,W,N,H,h_cost_min,h_cost_max)
links = create_links(N,nodes[:,0],nodes[:,1],nodes[:,2])

print(nodes)
print("")
print(links)

# Write files in new folder
curr_path = path.replace("\\", "\\\\")
new_path = curr_path + "\\\\" + "Nodes" + str(N) + "_Hubs" + str(H)
if not os.path.isdir(new_path):
    os.makedirs(new_path)
else:
    print('Instance already exists.')
# Add text files
os.chdir(new_path)
np.savetxt('nodes.txt', nodes, delimiter=',')
np.savetxt('links.txt', links, delimiter=',')
