#!/usr/bin/env python
# coding: utf-8

# # WCA Results - Automated Download and Import
# 
# Created by Michael George (AKA Logiqx)
# 
# Download the latest database extract from https://www.worldcubeassociation.org/results/misc/export.html
# 
# Note: Downloads with a specific filename instead of  https://www.worldcubeassociation.org/results/misc/WCA_export.sql.zip

# ## Database Parameters
# 
# Update the connection details for your MySQL environment.

# In[1]:


hostname = "mariadb"
database = "wca"
username = "root"
password = "R00tP4ss"


# ## Generic SQL Function
# 
# Simple function to run a SQL script

# In[5]:


# Use the OS library to execute mysql script
import os

# Time module used for performance counters
import time

def runSqlScript(source):   
    cmd = 'mysql --host=%s --database=%s --user=%s --password=%s --execute="source %s" --default-character-set=utf8' % (hostname, database, username, password, source)
    result = os.system(cmd)
    if result != 0:
        print('%s returned %d' % (source, result))


# ## Download the HTML
# 
# Fetch the database export  page from the WCA website.

# In[3]:


# The library urllib2 will be used for the download
import urllib.request
import ssl

# Specify the URL
base_url = "https://www.worldcubeassociation.org/results/misc/"

# Specify the URL
html_url = base_url + "export.html"

# Do not verify certicates
context = ssl._create_unverified_context()

# Open the URL and retrieve the TML
page = urllib.request.urlopen(html_url, context=context)


# ## Parse the HTML
# 
# Locate the link for the ZIP file containing the SQL script.

# In[4]:


# The library Beautiful Soup will be used for the HTML parsing
from bs4 import BeautifulSoup

# Parse the HTML using beautiful soup
soup = BeautifulSoup(page, "lxml")

# Find all of the links on the page
links = soup.find_all("a")

# Iterate through links
for link in links:
    
    # Get the hyperlink reference
    href = link.get("href")
    
    # If it is the SQL script it's the one that we want
    if href.endswith(".sql.zip"):
        
        # Record the SQL and exit the loop
        zip_fn = href
        zip_url = base_url + href
        break
        
print(zip_url)


# ## Download the ZIP
# 
# Save the ZIP to the local machine.

# In[5]:


# Start time in fractional seconds
pc1 = time.perf_counter()

# Create file handle for the ZIP
infile = urllib.request.urlopen(zip_url, context=context)

# Write the ZIP to a local file
with open(zip_fn, "wb") as outfile:
    outfile.write(infile.read())

# Close the URL
infile.close()

# End time in fractional seconds
pc2 = time.perf_counter()

print("Download completed in %0.2f seconds" % (pc2 - pc1))


# ## Extract the SQL
# 
# Extract the SQL script from within the ZIP file.

# In[6]:


# Use the zipfile library to handle the zipfile
import zipfile

# Start time in fractional seconds
pc1 = time.perf_counter()

# Open the ZIP file
zipfile = zipfile.ZipFile(zip_fn, "r")

# Iterate through members
for member in zipfile.namelist():
    
    # Is it the SQL?
    if member.endswith(".sql"):
        
        # Extract the SQL
        zipfile.extract(member)

# Close the ZIP file
zipfile.close()

# End time in fractional seconds
pc2 = time.perf_counter()

print("Extract completed in %0.2f seconds" % (pc2 - pc1))


# ## Populate the WCA Database
# 
# Note: The actual database is expected to exist already

# In[8]:


# Start time in fractional seconds
pc1 = time.perf_counter()

runSqlScript('WCA_export.sql')

# End time in fractional seconds
pc2 = time.perf_counter()

print("Load completed in %0.2f seconds" % (pc2 - pc1))


# ## Schema Changes
# 
# Alter tables and create table indices

# In[9]:


# Start time in fractional seconds
pc1 = time.perf_counter()

runSqlScript('../sql/alter_tables.sql')
runSqlScript('../sql/create_indices.sql')

# End time in fractional seconds
pc2 = time.perf_counter()

print("Indexing completed in %0.2f seconds" % (pc2 - pc1))


# # All Done!
