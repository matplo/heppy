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
  
def read_file(file, n_particles, n_events=10000, n_events_max=10000):

  # Read all lines from the text file into a dataframe (taking only relevant columns)
  #col_types = {'px': np.float64, 'py': np.float64, 'pz':np.float64, 'm': np.float64}
  col_names = ['px', 'py', 'pz', 'm', 'pid', 'label']
  df = pandas.read_table(file, delim_whitespace=True, names=col_names, usecols=[0,1,2,3], comment="#", header=0)
  #dtype=col_types
  
  # Split dataframe into an array of dataframes, one per event
  df_array = None
  if n_events_max < n_events:
    df_array = np.array_split(df, n_events)[:n_events_max]
  else:
    df_array = np.array_split(df, n_events)

  print('Taking {} of {} events from PU14'.format(n_events_max, n_events))
  
  # Iterate through each dataframe and drop the commented lines
  for i, df in enumerate(df_array):
    df.reset_index(inplace=True, drop=True)
    if i == (n_events-1):
      df.drop(df.tail(1).index,inplace=True)
    else:
      df.drop(df.tail(2).index,inplace=True)

  # The px column is wrong type, so cast it (could do this cleaner way...)
  # (Note: to_numeric doesn't exist until pandas 17,
  #  and astype() doesn't work to convert object type to float)
  #df.astype(np.float64)
  #df = df.apply(pandas.to_numeric) # convert all columns of DataFrame
  #df.convert_objects(convert_numeric=True)

  # All these other methods are not working on pandas 14...
  # So just manually convert the types
  array = []
  for i, df in enumerate(df_array):

    if i > n_events_max-1:
      break
    
    px_arr = np.empty(n_particles, dtype=float)
    for j, row in df.iterrows():
      px_arr[j] = float(row['px'])

    df_px = pandas.DataFrame({'px': px_arr})
    df_temp = df[['py','pz','m']]
    df_new = df_px.join(df_temp)
    array.append(df_new)
    
  return array
      
#---------------------------------------------------------------------------------------------------
if __name__ == '__main__':
  pu14_reader()
                                            
