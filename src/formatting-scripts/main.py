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
        channel = np.array(rawData['channel'])
        timestamps = np.array(rawData['timestamps'])
        eventType = np.array(rawData['eventType'])
        eventId = np.array(rawData['eventId'])
        nodeId = np.array(rawData['nodeId'])
        recordingNumber = np.array(rawData['recordingNumber'])
        sampleNum = np.array(rawData['sampleNum'])

        np.savez(f'formatted-lfp/{pathToSave}', channel=channel, timestamps=timestamps, eventType=eventType,
                 nodeId=nodeId, recordingNumber=recordingNumber, eventId=eventId, sampleNumber=sampleNum)



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

experimentPath = 'Exp 3'
recursePaths(experimentPath)  # Supply the starting point for the recursion