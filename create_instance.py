import numpy as np
import os

# Ask user for parameters
nodes = int(input("Enter the number of total nodes in the network: "))
print('')
while True:
    try:
        x_max, y_max = map(float, input("Enter dimensions for the network (width then height separated by space): ").split())
        break
    except ValueError:
        print("Invalid Entry. Make sure two values entered are separated by a space.")
print('')

# x_max = float(input("Enter value for length of rectangular"))
# y_max = 7

# Initiate nodes in
x_cords = np.random.uniform(low=0, high=x_max, size=nodes)
y_cords = np.random.uniform(low=0, high=y_max, size=nodes)

node_locs = np.column_stack((list(range(1, nodes+1)), x_cords, y_cords))

print(node_locs)
print('')

# Create new folder
curr_path = os.getcwd().replace("\\", "\\\\")
new_path = curr_path + '\\\\' + 'nodes-' + str(nodes)
if not os.path.isdir(new_path):
    os.makedirs(new_path)
else:
    print('Instance already exists.')
# Add text files
os.chdir(new_path)
np.savetxt('nodes.txt', node_locs)


# Ask user if finished
foo = str(input('Enter "done" to exit program or "continue" to create a new instance: '))
if foo == "done":
    print('complete')
else:
    print('restart')
