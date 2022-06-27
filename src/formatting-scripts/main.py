import os
import os.path
from glob import glob
from os.path import isdir

import numpy as np
import OpenEphys


# Read a .continuous or .events file and save it as a .npy file
def continuousToNPY(pathToFile):
    rawData = OpenEphys.load(f'{pathToFile}')  # returns a dict with data, timestamps, etc.

    dataType = '.events'  # Change to .continuous/.events accordingly
    pathToSave = pathToFile.replace(dataType, '')


    # Each part of the data must be saved as a numpy array so that it can be read into Julia
    if dataType == '.continuous':
        timestamps = np.array(rawData['timestamps'])
        data = np.array(rawData['data'])
        recordingNumber = np.array(rawData['recordingNumber'])
        np.savez(f'formatted-lfp/{pathToSave}', timestamps=timestamps, data=data, recordingNumber=recordingNumber)
    else:
        #data = []
        #for key in rawData.keys():
        #    data.append(rawData[key])
        #data = np.array(data)
        np.savez(f'formatted-lfp/{pathToSave}', rawData)



# Convert all files of the type .continuous or .events in a given directory
def read_all_files(pathToFile):
    file_names = glob(f'{pathToFile}/*.events')  # Change to .continuous/.events accordingly
    os.makedirs(f'formatted-lfp/{pathToFile}', exist_ok=True)
    for filename in file_names:
        continuousToNPY(filename)


# Recurse through all directories to find the paths containing data
def recursePaths(directory):
    paths = list(filter(isdir, glob(f'{directory}/*')))
    if len(paths) == 0:
        print(directory)
        read_all_files(directory)
    else:
        for path in paths:
            recursePaths(path)

experimentPath = 'Exp 1'
recursePaths(experimentPath)  # Supply the starting point for the recursion