import numpy as np
from math import sqrt

# Create matrix with link ids, origin, destination, and distance
def create_links(N, h_ids, x, y):
    # Generate distance matrix
    DM = np.zeros((N,N))
    for i in range(N):
        for j in range(N):
            DM[i][j]=sqrt((x[i]-x[j])**2+(y[i]-y[j])**2)   

    # Creat links matrix
    density = 1
    
    link_ids = []
    for i in range(N*(N-1)):
        link_ids.append(i+1)

    orig = []
    dest = []
    dist = []
    for i in range(N):
        for j in range(N):
            if i != j:
                orig.append(i+1)
                dest.append(j+1)
                dist.append(DM[i,j])
    
    links = np.column_stack((link_ids, orig, dest, dist))
    return links
