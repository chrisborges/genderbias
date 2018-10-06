import requests
import os
import re
from lxml import html

#Scrape journal page HTML for all papers, based on DOI number
#folder is the folder in the working directory that will contain all the scraped HTML pages
def getFiles(indices,papersListFile,folder,verbose=False):
    myList = []
    with open(papersListFile,'r') as papersList:
        for line in papersList:
            myList.append(line)

    for q in indices:
        firstLine = myList[q].split(',')
        dataTitle = firstLine[3]; dataTitle = dataTitle[1:(len(dataTitle)-1)]
        DOI = firstLine[1]; DOI = DOI[1:(len(DOI)-1)]
        header = 'http://dx.doi.org/'
        URL = header + DOI
        page = requests.get(URL)
        fileName = "page" + str(q) + ".txt"
        os.chdir(folder)
        with open(fileName,'wb') as outFile:
            outFile.write(page.content)
        if verbose:
            print("Completed page " + str(q))

#Skipping 961-1711 Biometrika, as the scraping is difficult
def getFirstAuthorFromHTML(indices,folder,verbose=False):
    authors = []; searchString = ''; errorNums = []
    for i in indices:
        try:
            if verbose & (i%100==0):
                print("Iteration " + str(i))
            if i in range(1,961):
                searchString = '<meta name="citation_author" content="' + '(.*?)' + '"/>'
            elif i in range(1712,2838):
                searchString = '<meta name="dc.Creator" content="' + '(.*?)' + '" />'
            elif i in range(2838,3248):
                searchString = '<meta name="citation_author" content="' + '(.*?)' + '" />'
            page = folder + 'page' + str(i) + '.txt'
            with open(page, 'r') as myfile:
                html = myfile.read().replace('\n', '')
            firstAuthor = re.search(searchString, html).group(1)
            authors.append(firstAuthor)
        except AttributeError:
            errorNums.append(i)
    return [authors,errorNums]

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

def main():
    workingDirectory = "C:/Users/jstwa/Desktop/" #Change as necessary
    papersListFile = workingDirectory + 'paperList.txt' #Make sure the paper list from Ji & Jin is named paperList.txt

    #Create directory to store HTML pages in
    folder = workingDirectory + "Pages3/"
    if not os.path.exists(folder):
        os.makedirs(folder)

    authorFile = 'authorList.txt' #The file that the author list will be saved to
    indices = range(1,10)
    getFiles(indices,papersListFile,folder,verbose=True)
    ats = getFirstAuthorFromHTML(indices,folder,verbose=True)
    authorList = ats[0]; exceptions = ats[1]
    with open(authorFile,'w') as f:
        for item in authorList:
            f.write(item +'\n')
        f.close()

if __name__ == "__main__":
    main()