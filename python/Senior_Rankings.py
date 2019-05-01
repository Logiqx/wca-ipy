#!/usr/bin/env python
# coding: utf-8

# # WCA Results - Complete Over-40's Rankings
# 
# Created by Michael George (AKA Logiqx)
# 
# Link: https://www.speedsolving.com/forum/showthread.php?54128-How-fast-are-the-over-40-s-in-competitions

# In[1]:


from EventsLib import *


# ## Read Event Results from CSV
# 
# Read event data from CSV into memory, prior to processing

# In[2]:


import os, csv

class EventResults:
    
    def __init__(self):
        """Initialisise the event results"""
        
        self.event = None
        self.results = []
        self.total = 0


    def readResults(self, basename, event, deltas = []):
        """Read event results from CSV into memory"""
        
        self.event = event
        self.results = []
        self.total = 0

        # Read rows using the CSV reader
        fn = os.path.join('..', 'data', 'public', 'ready', basename, self.event[0] + '.csv')
        with open(fn, 'r') as f:
            csvReader = csv.reader(f)
            
            # Process each row individually
            for inputRow in csvReader:
                
                # Pack out results with zeros
                while (int(inputRow[0]) > len(self.results)):
                    self.results.append([0, self.total])
                
                count = int(inputRow[1])
                self.total += count
                self.results.append([count, self.total])

        # Apply deltas
        for i in range(len(deltas)):
            if deltas[i][0] != 0:
                self.results[i][0] = self.results[i][0] + deltas[i][0]
                self.results[i][1] = self.results[i][1] + deltas[i][0]


# ## Read Partial Results from CSV
# 
# Read event data from CSV into memory, prior to processing

# In[3]:


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
        self.results = {}

        # Read rows using the CSV reader
        fn = os.path.join('..', 'data', 'public', 'ready', basename, self.event[0] + '.csv')
        with open(fn, 'r') as f:
            csvReader = csv.reader(f)
            
            # Process each row individually
            for inputRow in csvReader:
                
                result = int(inputRow[1]) // 100
                
                # Apply cutoffs / groups
                if result > self.event[6]:
                    result = self.event[6]
                elif result > self.event[5]:
                    result = result // 60 * 60
                elif result > self.event[4]:
                    result = result // 10 * 10
                
                if result in self.results:
                    self.results[result] += [inputRow]
                else:
                    self.results[result] = [inputRow]


# ## Analyse Results
# 
# Process all three sets of results simultaneously

# In[42]:


class EventAnalysis:
    
    def __init__(self):
        """Initialisise the event analysis"""
        
        self.event = None
        self.seniorResults = EventResults()
        self.partialResults = PartialResults()


    def readPersons(self):
        """Read seniors from CSV into memory"""

        self.partialResults.readPersons('known_senior_details')


    def listPersons(self):
        """List seniors from memory"""

        return self.partialResults.listPersons()


    def readResults(self, event):
        """Read event results from CSV into memory"""

        # Skip processing if no cutoff is defined
        if event[4] > 0:
            self.event = event
            knownDeltas = EventResults()
            knownDeltas.readResults('known_senior_averages_delta', self.event)
            self.seniorResults.readResults('senior_averages_agg', self.event, knownDeltas.results)
            self.partialResults.readResults('known_senior_averages', self.event)
        else:
            self.event = None


    def listResults(self):
        """Get the HTML for the event"""

        html = ''
        
        if self.event:
            html += '<details>\n'
            html += '  <summary>%s</summary>\n' % self.event[1]
            html += '  <table>\n'
            html += '    <tr>'
            for field in ['Rank', 'Person', 'Result']:
                html += '<td><b>%s</b></td>' % field
            html += '</tr>\n'

            i = 0
            rank = 1
            
            while i < len(self.seniorResults.results):
                
                seniorResult = self.seniorResults.results[i]
                
                if i in self.partialResults.results:
                    knownResults = self.partialResults.results[i]
                else:
                    knownResults = []

                known = len(knownResults)
                unknown = seniorResult[0] - len(knownResults)

                # If all results are known then they can be displayed individually
                if unknown == 0:
                    persons = ''
                    results = ''
                    count = 0
                    prevResult = None

                    for knownResult in knownResults:

                        if persons and knownResult[1] != prevResult:
                            html += '    <tr>'
                            html += '<td>%s</td>' % rank
                            html += '<td>%s</td>' % persons
                            html += '<td>%s</td>' % results
                            html += '</tr>\n'
                            
                            rank += count
                            
                            persons = ''
                            results = ''
                            
                            count = 0

                        if persons:
                            persons += '<br/>'
                            results += '<br/>'

                        person = self.partialResults.persons[knownResult[0]]
                        persons += '<a href="https://www.worldcubeassociation.org/results/p.php?i=%s#%s">%s</a>, %s' %                                 (knownResult[0], self.event[0], person[0], person[1])
                        results += formatResult(self.event, knownResult[1], showFractions = True)
                        
                        count += 1
                        prevResult = knownResult[1]                           

                    if persons:
                        html += '    <tr>'
                        html += '<td>%s</td>' % rank
                        html += '<td>%s</td>' % persons
                        html += '<td>%s</td>' % results
                        html += '</tr>\n'
                        rank += count

                # If some results are unknown then results need to be combined
                else:
                    result = formatResult(self.event, i * 100, showFractions = True)
                    if i >= self.event[6]:
                        result = result + '+'
                    elif i >= self.event[5]:
                        result = result[:-5] + 'xx.xx'
                    elif i >= self.event[4]:
                        result = result[:-4] + 'x.xx'
                    else:
                        result = result[:-3] + '.xx'

                    if len(knownResults) > 0:
                        persons = ''
                        results = ''

                        for knownResult in knownResults:
                            if persons:
                                persons += '<br/>'
                                results += '<br/>'
                                
                            person = self.partialResults.persons[knownResult[0]]
                            persons += '<a href="https://www.worldcubeassociation.org/results/p.php?i=%s#%s">%s</a>, %s' %                                 (knownResult[0], self.event[0], person[0], person[1])
                            results += formatResult(self.event, knownResult[1], showFractions = True)
                            
                        if unknown > 0:
                            persons += '<br/>+ %d unknown%s' % (unknown, 's' if unknown > 1 else '')
                            results += '<br/>%s' % result
                    else:
                        persons = '%d unknown%s' % (unknown, 's' if unknown > 1 else '')
                        results = '%s' % result

                    html += '    <tr>'
                    html += '<td>%s</td>' % (rank if seniorResult[0] == 1 else '%d-%d' % (rank, rank + seniorResult[0] - 1))
                    html += '<td>%s</td>' % persons
                    html += '<td>%s</td>' % results
                    html += '</tr>\n'

                    rank += seniorResult[0]
                    
                i += 1

            html += '  </table>\n'
            html += '</details>\n\n'
        
        return html


# ## Analyse Events
# 
# Process the events one-by-one

# In[43]:


with open('Senior_Rankings.md', 'r') as f:
    html = ''.join(f.readlines())

eventAnalysis = EventAnalysis()

html += '<h2>%s</h2>\n\n' % 'Official Competitors'
eventAnalysis.readPersons()
html += eventAnalysis.listPersons()

html += '<h2>%s</h2>\n\n' % 'Official Averages'
for event in events:
    eventAnalysis.readResults(event)
    html += eventAnalysis.listResults()
    
with open("../Senior_Rankings.md", 'w') as f:
    f.write(html)
    
print('Representative Rankings updated!')


# In[ ]:




