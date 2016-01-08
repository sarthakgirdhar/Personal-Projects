# -*- coding: utf-8 -*-
"""
Created on Tue Jan 05 17:20:12 2016

@author: sarthak
"""

## import the library used to query a website
import urllib2

## specify the url
wiki = "https://en.wikipedia.org/wiki/List_of_state_and_union_territory_capitals_in_India"

## query the website and return the html to the variable 'page'
page = urllib2.urlopen (wiki)

## import the Beautiful soup functions to parse the data returned from the website
from bs4 import BeautifulSoup

## parse the html in the 'page' variable, and store it in Beautiful Soup format
soup = BeautifulSoup (page)

## use function "prettify" to look at nested structure of HTML page
print soup.prettify()

## soup.<tag>: return content between opening and closing tag including tag
print soup.title

## soup.<tag>.string: return string within given tag
print soup.title.string

## find all the links within page's <a> tags
print soup.a

## Above, you can see that we have only one output. Now to extract all the links within <a>, we will use "find_all()"
print soup.find_all("a")

## Above, it is showing all links including titles, links and other information. Now to show only links, we need to iterate over each tag and then return the link using attribute "href" with get.
all_links = soup.find_all("a")
for link in all_links:
    print link.get("href")

## extract information within all 'table' tags     
all_tables = soup.find_all('table')

## to extract information about state capitals, we will use attribute "class" of table and use it to filter the right table.
right_table = soup.find('table', class_ = 'wikitable sortable plainrowheaders')
print right_table

## generate lists
A = []
B = []
C = []
D = []
E = []
F = []
G = []

for row in right_table.findAll("tr"):
    cells = row.findAll("td")
    states = row.findAll("th")  # to store second column data
    if len(cells) == 6:  # only extract table body, not heading
        A.append(cells[0].find(text=True))
        B.append(states[0].find(text=True))
        C.append(cells[1].find(text=True))
        D.append(cells[2].find(text=True))
        E.append(cells[3].find(text=True))
        F.append(cells[4].find(text=True))
        G.append(cells[5].find(text=True))
        
## import pandas to convert list to data frame
import pandas as pd
df = pd.DataFrame (A, columns=['Number'])
df['State/UT'] = B
df['Admin_Capital'] = C
df['Legislative_Capital'] = D
df['Judiciary_Capital'] = E
df['Year_Capital'] = F
df['Former_Capital'] = G

print df
