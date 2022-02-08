import os
import random
import numpy as np
import UtilityFunctions

from scipy.stats import truncnorm
batch_number = 10
VALIDATION_RATIO = 0.2
index = np.arange(batch_number)
np.random.shuffle(index)
slice_var = int(VALIDATION_RATIO * len(index))
valid_index = index[:slice_var]
train_index = index[slice_var:]
print(valid_index)
print(train_index)
