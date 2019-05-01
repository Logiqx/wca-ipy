#!/usr/bin/env python
# coding: utf-8

# # WCA Results - Data Preparation
# 
# Created by Michael George (AKA Logiqx)
# 
# Extract data from the WCA database and reformat into individual CSV files for each event.
# 
# Note: This script can only be run if you have the contents of the "private" data folder.

# ## Database Parameters
# 
# Update the connection details for your MySQL environment.

# In[7]:


hostname = "mariadb"
database = "wca"
username = "root"
password = "R00tP4ss"


# ## Generic SQL Function
# 
# Simple function to run a SQL script

# In[8]:


# Use the OS library to execute mysql script
import os

# Time module used for performance counters
import time

def runSqlScript(source):   
    cmd = 'mysql --host=%s --database=%s --user=%s --password=%s --execute="source %s" --default-character-set=utf8' % (hostname, database, username, password, source)
    result = os.system(cmd)
    if result != 0:
        print('%s returned %d' % (source, result))


# ## Apply DOB
# 
# Apply date of birth where known or approximated

# In[3]:


# Start time in fractional seconds
pc1 = time.perf_counter()

runSqlScript('../sql/apply_known_dob.sql')

pc2 = time.perf_counter()

print("DOBs applied in %0.2f seconds" % (pc2 - pc1))


# ## Run Extracts
# 
# Extract data from database for subsequent analysis - percentiles, rankings, etc

# In[4]:


# Remove previous extracts
import os, glob
for f in glob.glob(os.path.join('..', 'data', 'public', 'extract', '*.csv')):
    os.remove(f)
    
# Start time in fractional seconds
pc1 = time.perf_counter()

runSqlScript('../sql/extract_senior_details.sql')
runSqlScript('../sql/extract_senior_aggs.sql')
runSqlScript('../sql/extract_senior_deltas.sql')
runSqlScript('../sql/extract_wca_aggs.sql')

# End time in fractional seconds
pc2 = time.perf_counter()

print("Extracts completed in %0.2f seconds" % (pc2 - pc1))


# ## Generic Processing
# 
# Turn the raw database extracts into a standard format:
# * Split into multiple files - one file per event
# * Standardise the layout - CSV with minimal quoting
# * Apply time limits / cutoffs to aggregated data
# 
# Note: All of the output files can be made public due to the application of time limits / cutoffs

# In[5]:


import os, csv

from EventsLib import *

def writeResults(basename, event, eventResults):
    """Write event results from memory to CSV"""

    fn = os.path.join('..', 'data', 'public', 'ready', basename, event + '.csv')
    with open(fn, 'w') as f:
        csvWriter = csv.writer(f, quoting = csv.QUOTE_MINIMAL, lineterminator = os.linesep)
        for eventResult in eventResults:
            csvWriter.writerow(eventResult)


def prepareCounts(basename, subfolder):
    """Split file into individual events and apply time limits"""

    # Ensure that a CSV exists for all events, even if empty
    for event in events:
        writeResults(basename, event[0], [])
        
    fn = os.path.join('..', 'data', subfolder, basename + '.csv')
    with open(fn, 'r') as f:
        csvReader = csv.reader(f)
        
        # Initilise event
        event = None
        cut1 = 0
        cut2 = 0
        cut3 = 0
        eventResults = []

        # Initilise result
        result = None
        count = 0

        # Process each row individually
        for inputRow in csvReader:

            # Only process the current row if it is a recognised event
            if inputRow[0] == event or inputRow[0] in eventsDict:

                thisEvent = inputRow[0]
                thisResult = int(inputRow[1])

                # Detect change of event
                if thisEvent != event:
                    # Buffer the final result
                    if count != 0:
                        eventResults.append([result, count])
                    # Save the previous event
                    if event:
                        writeResults(basename, event, eventResults)

                    # Initilise event
                    event = thisEvent
                    cut1 = int(eventsDict[event][3])
                    cut2 = int(eventsDict[event][4])
                    cut3 = int(eventsDict[event][5])
                    eventResults = []

                    # Initilise result
                    result = None
                    count = 0
                    
                # Apply cutoffs
                if thisResult > cut3:
                    thisResult = cut3
                elif thisResult > cut2:
                    thisResult = thisResult // 60 * 60
                elif thisResult > cut1:
                    thisResult = thisResult // 10 * 10

                # Detect change of result
                if thisResult != result:
                    # Buffer the current result
                    if count != 0:
                        eventResults.append([result, count])

                    result = thisResult
                    count = 0

                count += int(inputRow[2])

        # Save the final event
        if count != 0:
            eventResults.append([result, count])
        writeResults(basename, event, eventResults)

        
def prepareResults(basename, subfolder):
    """Split file into individual events"""
    
    fn = os.path.join('..', 'data', subfolder, basename + '.csv')
    with open(fn, 'r') as f:
        csvReader = csv.reader(f)
        
        event = None
        eventResults = []

        # Process each row individually
        for inputRow in csvReader:

            # Only process the current row if it is a recognised event
            if inputRow[0] == event or inputRow[0] in eventsDict:

                # Detect change of event
                if inputRow[0] != event:
                    if event:
                        writeResults(basename, event, eventResults)
                    event = inputRow[0]
                    eventResults = []

                # Buffer the current result
                eventResults.append(inputRow[1:])

        # Save the final event
        writeResults(basename, event, eventResults)


def preparePeople(basename, subfolder):
    """Essentially a file copy but it will reformat the records if necessary"""
    
    rows = []
    
    # Read rows using the CSV reader
    fn = os.path.join('..', 'data', subfolder, basename + '.csv')
    with open(fn, 'r') as f:
        csvReader = csv.reader(f)
        for inputRow in csvReader:
            rows.append(inputRow)

    # Write rows using the CSV writer
    fn = os.path.join('..', 'data', 'public', 'ready', basename + '.csv')
    with open(fn, 'w') as f:
        csvWriter = csv.writer(f, quoting = csv.QUOTE_MINIMAL, lineterminator = os.linesep)
        for row in rows:
            csvWriter.writerow(row)


# # Format Extracts
# 
# Prepare all of the CSV files

# In[6]:


# Process known seniors from local database export
public_dir = os.path.join('public', 'extract')
preparePeople('known_senior_details', public_dir)
prepareResults('known_senior_averages', public_dir)
prepareResults('known_senior_singles', public_dir)
prepareCounts('known_senior_averages_agg', public_dir)
prepareCounts('known_senior_averages_delta', public_dir)
prepareCounts('known_senior_singles_agg', public_dir)
prepareCounts('wca_averages_agg', public_dir)
prepareCounts('wca_singles_agg', public_dir)
print("Processed known seniors in %s" % public_dir)

# Process data from remote database export (provided by WCA results team)
private_dir = os.path.join('private', '2019-02-01')
prepareCounts('senior_averages_agg', private_dir)
print("Processed all seniors in %s" % private_dir)


# In[ ]:




