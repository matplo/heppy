#!/usr/bin/env python
'''
This is a simple script to read a PU14 file and return a dataframe of four-vectors per event.
To use it, you should:

import pu14_reader
pu14_reader.read_file(file, n_particles, n_events)

where file is a path to a PU14 file, and n_particles is the background multiplicity in the PU14 file
containing n_events.

The PU14 file expects a particular format 
(https://twiki.cern.ch/twiki/bin/view/JetQuenchingTools/PU14Samples)
(located on GSI cluster at /lustre/emmi/emmi05/thermal)
'''

import pandas
import numpy as np

def pu14_reader():

  file = '/lustre/emmi/emmi05/thermal/Mult1700/ThermalEventsMult1700PtAv0.90_0.pu14'
  read_file(file, 1700)
  
def read_file(file, n_particles, n_events=10000):

  # Read all lines from the text file into a dataframe (taking only relevant columns)
  df = pandas.read_table(file, delim_whitespace=True, names=('px', 'py', 'pz', 'm', 'pid', 'label'), usecols=[0,1,2,3], comment="#", header=0)

  # Split dataframe into an array of dataframes, one per event
  df_array = np.array_split(df, n_events)

  # Iterate through each dataframe and drop the commented lines
  for i, df in enumerate(df_array):
    if i == n_events-1:
      df.drop(df.tail(1).index,inplace=True)
    else:
      df.drop(df.tail(2).index,inplace=True)

  return df_array
      
#---------------------------------------------------------------------------------------------------
if __name__ == '__main__':
  pu14_reader()
                                            
