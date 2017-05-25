import numpy as np
import random

def rep_ids(N, H, reps):

    # Initialize replication matrix
    combos = np.zeros((N, int(reps)))
    
    for i in range(reps):
        # Randomly sample indexes that could be assigned as hubs for replication
        foo = random.sample(range(N), H)
        if i == 0:
            ids = foo
        else:
            ids = np.row_stack((ids, foo))

            # Check that replication is unique
            test=True
            while test:
                test = False
                ids.sort()
                for k in range(i-1):
                    if all(ids[k] == ids[i]):
                        # If not unique, select new random sample
                        test = True
                        ids[i] = random.sample(range(N), H)

    # Store binary indicators for potential hub indexes for replication
    for i in range(reps):
        for j in range(N):
            if j in ids[i]:
                combos[j,i] = 1
            else:
                combos[j,i] = 0         
        
    return combos



