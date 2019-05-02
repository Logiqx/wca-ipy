#!/usr/bin/env python
# coding: utf-8

# # WCA Results - Partial Over-40's Rankings
# 
# Created by Michael George (AKA Logiqx)
# 
# Link: https://www.speedsolving.com/forum/showthread.php?54128-How-fast-are-the-over-40-s-in-competitions

# In[1]:


from EventsLib import *


# ## Read Partial Results from CSV
# 
# Read event data from CSV into memory, prior to processing

# In[2]:


import os, csv

class PartialResults:
    
    def __init__(self):
        """Initialisise the partial results"""
        
        self.event = None
        self.persons = {}
        self.ids = []
        self.results = {}


    def readPersons(self, basename):
        """Read seniors from CSV into memory"""
        
        self.persons = {}

        # Read rows using the CSV reader
        fn = os.path.join('..', 'data', 'public', 'ready', basename + '.csv')
        with open(fn, 'r') as f:
            csvReader = csv.reader(f)
            
            # Process each row individually
            for person in csvReader:
                self.persons[person[0]] = person[1:]
                self.ids.append(person[0])
        
                
    def listPersons(self):
        """List seniors from memory"""
        
        html = '<details>\n'
        html += '  <summary>%s</summary>\n' % 'Known Over-40s'
        html += '  <table>\n'
        html += '    <tr>'
        for field in ['Person', 'Speedsolving.com']:
            html += '<td><b>%s</b></td>' % field
        html += '</tr>\n'
            
        for id in self.ids:
            person = self.persons[id]
            
            name = person[0]
            link = '<a href="https://www.worldcubeassociation.org/results/p.php?i=%s">%s</a>' % (id, name)

            html += '    <tr>'
            html += '<td>%s, %s</td>' % (link, person[1])
            html += '<td>%s</td>' % person[2]
            html += '</tr>\n'

        html += '  </table>\n'
        html += '</details>\n\n'
        
        return html
            
        
    def readResults(self, basename, event):
        """Read event results from CSV into memory"""
        
        self.event = event
        self.results = []
        
        if event[0] == '333fm' and 'single' in basename:
            self.fmSingle = True
        else:
            self.fmSingle = False

        # Read rows using the CSV reader
        fn = os.path.join('..', 'data', 'public', 'ready', basename, event[0] + '.csv')
        with open(fn, 'r') as f:
            csvReader = csv.reader(f)
            
            # Process each row individually
            for inputRow in csvReader:
                
                self.results.append(inputRow)
                

    def listResults(self):
        """List seniors from memory"""
        
        html = '<details>\n'
        html += '  <summary>%s</summary>\n' % self.event[1]
        html += '  <table>\n'
        html += '    <tr>'
        for field in ['Rank', 'Person', 'Result']:
            html += '<td><b>%s</b></td>' % field
        html += '</tr>\n'
        
        rank = 1
        prevResult = None
        
        for result in self.results:
            
            person = self.persons[result[0]]
            name = person[0]
            country = person[1]
            
            link = '<a href="https://www.worldcubeassociation.org/results/p.php?i=%s#%s">%s</a>' %                     (result[0], self.event[0], name)

            if self.fmSingle:
                result = formatResult(self.event, int(result[1]) * 100, showFractions = False)
            else:
                result = formatResult(self.event, result[1], showFractions = True)

            html += '    <tr>'
            html += '<td>%s</td>' % (rank if result != prevResult else '')
            html += '<td>%s, %s</td>' % (link, country)
            html += '<td>%s</td>' % result
            html += '</tr>\n'
            
            prevResult = result
            rank += 1

        html += '  </table>\n'
        html += '</details>\n\n'
        
        return html


# ## Analyse Events
# 
# Process the events one-by-one

# In[3]:


with open(os.path.join('..', 'templates', 'Partial_Rankings.md'), 'r') as f:
    html = ''.join(f.readlines())

partialResults = PartialResults()

html += '<h2>%s</h2>\n\n' % 'Official Competitors'
partialResults.readPersons('known_senior_details')
html += partialResults.listPersons()

html += '<h2>%s</h2>\n\n' % 'Official Averages'
for event in events:
    if event[3] != 'multi':
        partialResults.readResults('known_senior_averages', event)
        html += partialResults.listResults()
    
html += '<h2>%s</h2>\n\n' % 'Official Singles'
for event in events:
    partialResults.readResults('known_senior_singles', event)
    html += partialResults.listResults()
    
with open(os.path.join('..', 'docs', 'Partial_Rankings.md'), 'w') as f:
    f.write(html)

print('Partial Rankings updated!')


# # All Done!

# In[5]:


ids = partialResults.ids
ids.sort()
print('WCA Ids = ' + ','.join(id for id in ids) + ' = ' + str(len(ids)) + ' competitors')


# In[ ]:




