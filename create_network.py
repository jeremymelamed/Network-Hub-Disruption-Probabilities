import os
from math import sqrt
import random
import numpy as np
from combination import Combination

# Create matrix with node ids, location, cost, and combinations
def create_nodes(L,W,N,H,h_cost_min, h_cost_max):    
    n_ind = []
    for i in range(N):
        n_ind.append(i+1)
    x = []
    for i in range(N):
        x.append(random.random()*L)
    y = []
    for i in range(N):
        y.append(random.random()*W)
    h_cost = []
    for i in range(N):
        h_cost.append(random.uniform(h_cost_min, h_cost_max))

    ### Create nodes file
    ##temp = Combination(N,H)
    ##combos = np.zeros((N, int(temp.combination())))
    ##
    ##for i in range(int(temp.combination())):
    ##    temp = Combination(N,H,i)
    ##    print(temp.column_ids())
    
    nodes = np.column_stack((n_ind, x, y, h_cost))

    return nodes














        

