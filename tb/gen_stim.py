#%%

import numpy as np

peSize = 1024
nTestCycles = 50

# Create random integer array between [0,2^4) of shape (50,peSize)
acts = np.random.randint(0,2**4,(50,peSize))
np.savetxt('acts.csv',acts,fmt='%i')
acts

#%%
outs = acts + 1
outs

np.savetxt('out_ref.csv',outs,fmt='%i')

#%%