#!/usr/bin/env python
# coding: utf-8

# # WCA Results - Percentile Rankings
# 
# Created by Michael George (AKA Logiqx)
# 
# Link: https://www.speedsolving.com/forum/showthread.php?54128-How-fast-are-the-over-40-s-in-competitions

# In[29]:


from EventsLib import *


# ## Read Event Results from CSV
# 
# Read event data from CSV into memory, prior to processing

# In[30]:


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

    def calculatePercentiles(self):
        """Append percentile to each result"""

        for result in self.results:
            percentile = '%0.3f' % (100.0 * result[1] / self.total)
            result.append(percentile)


# ## Analyse Results
# 
# Process all three sets of results simultaneously

# In[31]:


class EventAnalysis:
    
    def __init__(self):
        """Initialisise the event analysis"""

        self.event = None
        self.wcaResults = None
        self.seniorResults = None
        self.knownResults = None
        self.limit = 0
        self.verbose = False


    def readResults(self, event):
        """Read event results from CSV into memory"""

        # Skip processing if no cutoff is defined
        if event[4] > 0:
            self.event = event

            self.wcaResults = EventResults()
            self.wcaResults.readResults('wca_averages_agg', self.event)
            self.wcaResults.calculatePercentiles()

            knownDeltas = EventResults()
            knownDeltas.readResults('known_senior_averages_delta', self.event)
            self.seniorResults = EventResults()
            self.seniorResults.readResults('senior_averages_agg', self.event, knownDeltas.results)
            self.seniorResults.calculatePercentiles()

            self.knownResults = EventResults()
            self.knownResults.readResults('known_senior_averages_agg', self.event)
            self.knownResults.calculatePercentiles()

            self.limit = max(len(self.wcaResults.results),
                             len(self.seniorResults.results),
                             len(self.knownResults.results))

        else:
            self.event = None
            self.limit = 0


    def checkSanity(self):
        """General sanity checks"""

        if self.event:
            # Initialisation
            wcaResult = [0, 0, 0]
            seniorResult = [0, 0, 0]
            knownResult = [0, 0, 0]

            for i in range(self.limit):
                # WCA results with a boundary check
                if len(self.wcaResults.results) > i:
                    wcaResult = self.wcaResults.results[i]
                else:
                    wcaResult = [0] + wcaResult[1:]

                # Senior results with a boundary check
                if len(self.seniorResults.results) > i:
                    seniorResult = self.seniorResults.results[i]
                else:
                    seniorResult = [0] + seniorResult[1:]

                # Known results with a boundary check
                if len(self.knownResults.results) > i:
                    knownResult = self.knownResults.results[i]
                else:
                    knownResult = [0] + knownResult[1:]

                result = formatResult(self.event, i * 100)

                self.checkUniqueness(result, wcaResult, seniorResult, knownResult)
                self.checkSenior(result, wcaResult, seniorResult)
                self.checkKnown(result, seniorResult, knownResult)


    def checkUniqueness(self, result, wcaResult, seniorResult, knownResult):
        """Check for personally identifiable result"""

        # Determine the number of unknown results
        unknown = seniorResult[0] - knownResult[0]

        # Calculate uniqueness
        # Note: Output for 6x6x6, 7x7x7, 3BLD also contains the regex :[0-9][0-9]</td><td>0</td>
        possible = wcaResult[0] - knownResult[0]
        if possible > 0:
            uniqueness = 100.0 * unknown / possible

            if uniqueness > 50:
                print('WARNING: %s result of %s - uniqueness is %.2f%% (%d of %d)' %                 (self.event[1], result, uniqueness, unknown, possible))


    def checkSenior(self, result, wcaResult, seniorResult):
        """Check for counts which don't make sense"""

        if wcaResult[0] < seniorResult[0]:
            print('WARNING: %s result of %s - senior exceeds wca (%d vs %d)' %                 (self.event[1], result, seniorResult[0], wcaResult[0]))


    def checkKnown(self, result, seniorResult, knownResult):
        """Check for counts which don't make sense"""

        if seniorResult[0] < knownResult[0]:
            print('WARNING: %s result of %s - known exceeds senior (%d vs %d)' %                 (self.event[1], result, knownResult[0], seniorResult[0]))


    def getHtml(self):
        """Get the HTML for the event"""

        html = ''

        if self.event:
            # Initialisation
            wcaResult = [0, 0, 0]
            seniorResult = [0, 0, 0]
            knownResult = [0, 0, 0]

            # Event title and table header
            html += '<details>\n'
            html += '  <summary>%s</summary>\n' % self.event[1]
            html += '  <table>\n'
            html += '    <tr>'
            for field in ['Sub-X', 'WCA #', 'WCA Total', 'WCA %tile',
                          'Seniors #', 'Seniors Total', 'Seniors %tile',
                          'Known #', 'Known Total', 'Known %tile']:
                html += '<td><b>%s</b></td>' % field
            html += '</tr>\n'

            for i in range(self.limit):

                # WCA results with a boundary check
                if len(self.wcaResults.results) > i:
                    wcaResult = self.wcaResults.results[i]
                else:
                    wcaResult = [0] + wcaResult[1:]

                # Skip past all of the empty results
                if wcaResult[1] > 0:
                    # Skip records affected by soft cutoffs  /groupings
                    if i < self.event[4] or i < self.event[5] and i % 10 == 0 or i % 60 == 0:
                        html += '    <tr>'

                        # The result may be a time or count
                        if i < self.limit - 1:
                            if i < self.event[4]:
                                result = formatResult(self.event, (i + 1) * 100)
                            elif i < self.event[5]:
                                result = formatResult(self.event, (i + 10) * 100)
                            else:
                                result = formatResult(self.event, (i + 60) * 100)
                        else:
                            result = '...'

                        html += '<td>%s</td>' % result

                        for field in wcaResult:
                            html += '<td>%s</td>' % field

                        # Senior results with a boundary check
                        if len(self.seniorResults.results) > i:
                            seniorResult = self.seniorResults.results[i]
                        else:
                            seniorResult = [0] + seniorResult[1:]

                        for field in seniorResult:
                            html += '<td>%s</td>' % field

                        # Known results with a boundary check
                        if (len(self.knownResults.results) > i):
                            knownResult = self.knownResults.results[i]
                        else:
                            knownResult = [0] + knownResult[1:]

                        for field in knownResult:
                            html += '<td>%s</td>' % field
                            
                        html += '</tr>\n'

                    if i in (self.event[4], self.event[5], self.event[6]):
                        if self.verbose:
                            print('%s, sub-%s = %s' % (self.event[1], formatResult(self.event, i * 100), debug))
                    
                    debug = str(wcaResult[1:] + seniorResult[1:] + knownResult[1:])

            html += '  </table>\n'
            html += '</details>\n\n'

        return html


# ## Analyse Events
# 
# Process the events one-by-one

# In[32]:


with open(os.path.join('..', 'templates', 'Percentile_Rankings.md'), 'r') as f:
    html = ''.join(f.readlines())

html += '<h2>%s</h2>\n\n' % 'Official Averages'

for event in events:
    eventAnalysis = EventAnalysis()
    eventAnalysis.readResults(event)
    eventAnalysis.checkSanity()
    html += eventAnalysis.getHtml()

with open(os.path.join('..', 'docs', 'Percentile_Rankings.md'), 'w') as f:
    f.write(html)

print('Percentile Rankings updated!')


# In[ ]:




