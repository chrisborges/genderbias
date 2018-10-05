import requests
import os
import getauthors as gf
import re
import random

def authorsToNum(fileName,abbrev=False):
    with open(fileName,'r') as f:
        names = f.readlines()
        names = [x.strip() for x in names]

    authors = []
    for q in range(len(names)):
        currLine = names[q]
        sep = currLine.split(' ',1); name = sep[1]

        if (name[1] == '.') == abbrev:
            authors.append(currLine)

    authorDict = {}
    for a in authors:
        sep = a.split(' ', 1)
        num = (sep[0])[:-1]; name = sep[1]
        if name in authorDict:
            authorDict[name].append(num)
        else:
            authorDict[name] = [num]
    return authorDict

def authorsToCite(fileName,authorDict):
    with open(fileName, 'r') as f:
        papers = f.readlines()
        papers = [x.strip() for x in papers]

    authorDictCitations = {}
    for key, value in authorDict.iteritems():
        for x in value:
            allitems = papers[int(x)].split(',')
            numcite = allitems[len(allitems) - 1]
            if key in authorDictCitations:
                authorDictCitations[key].append(numcite)
            else:
                authorDictCitations[key] = [numcite]
    return authorDictCitations