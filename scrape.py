import requests
import os
from lxml import html


myList = []
paperList = open('C:/Users/jstwa/Desktop/paperList.txt',mode='r')
for line in paperList:
    myList.append(line)

firstLine = myList[1].split(',')
dataTitle = firstLine[3]; dataTitle = dataTitle[1:(len(dataTitle)-1)]
DOI = firstLine[1]; DOI = DOI[1:(len(DOI)-1)]
DOI = DOI.replace('/','%2F')
URL = 'https://projecteuclid.org/search_result?q.s=' + DOI + '&type=all'
page = requests.get(URL)
tree = html.fromstring(page.content)
print(tree)
authorItem = tree.xpath('//*[@id="export-form"]/div/div[1]/p/a[1]')
print(authorItem)


def getURL(q):
    os.chdir("C:/Users/jstwa/Desktop/")
    myList = []
    paperList = open('C:/Users/jstwa/Desktop/paperList.txt', mode='r')
    for line in paperList:
        myList.append(line)

    myLine = myList[q].split(',')
    DOI = myLine[1]; DOI = DOI[1:(len(DOI) - 1)]
    URL = 'http://dx.doi.org/' + DOI
    return URL

def writeList(list,file="genders.txt"):
    os.chdir("C:/Users/jstwa/Desktop/")
    with open(file,'w') as f:
        for item in list:
            f.write(item +'\n')
        f.close()