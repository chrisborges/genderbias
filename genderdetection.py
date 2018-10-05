import authors
import sexmachine.detector as gender
import getauthors
import os
import matplotlib.pyplot as plt
import numpy as np
import scipy.stats as stats

#Create file that matches author names to gender
d = gender.Detector(unknown_value='unknown',case_sensitive=False)
fileNameAuthors = 'C:/Users/jstwa/Desktop/Names/allAuthors.txt'
authorDict = authors.authorsToNum(fileNameAuthors)
count = 1
gendersList = []; exceptionsList = [];
for author,nums in authorDict.iteritems():
    firstName = author.split(' ')[0]
    currGender = d.get_gender(firstName)
    try:
        gendersList.append(author + ", " + currGender)
    except UnicodeDecodeError:
        exceptionsList.append(firstName + ", "  + str(nums[0]) + ", " + currGender)
    if count % 50 == 0:
        getauthors.writeList(gendersList)
        getauthors.writeList(exceptionsList, "exceptions.txt")
    count += 1

#After creating gender file, creates a list of unknown gender authors
os.chdir("C:/Users/jstwa/Desktop")
with open("genders.txt",'r') as f:
    genderAll = f.readlines()
unknownList = []
for item in genderAll:
    split = item.split(", ")
    author = split[0]; gender = split[1].rstrip()
    if gender == 'unknown':
        unknownList.append(author)
print("Number of unknowns is " + str(len(unknownList)))
getauthors.writeList(unknownList, "unknown.txt")

#Create gender bias dataset
os.chdir("C:/Users/jstwa/Desktop")
fileNameAuthors = 'C:/Users/jstwa/Desktop/Names/allAuthors.txt'
authorDict = authors.authorsToNum(fileNameAuthors)
fileNamePapers = 'C:/Users/jstwa/Desktop/paperList.txt'
authorDictCite = authors.authorsToCite(fileNamePapers,authorDict)
with open("genders.txt",'r') as f:
    genderAll = f.readlines()
male_cites = []; female_cites = []

for item in genderAll:
    split = item.split(", ")
    author = split[0]; gender = split[1].rstrip()
    currCites = authorDictCite[author]
    if gender == 'male' or gender == 'mostly_male':
        male_cites.extend(currCites)
    elif gender == 'female' or gender == 'mostly_female':
        female_cites.extend(currCites)
male_cites = [int(x) for x in male_cites]
female_cites = [int(x) for x in female_cites]
print(stats.ttest_ind(male_cites,female_cites))

#Identifying duplicate names
os.chdir("C:/Users/jstwa/Desktop")
abbrevDict = {}
with open("abbrevauthornames.txt",'r') as f:
    abbrev = f.readlines()
for item in abbrev:
    itemsplit = item.rstrip().split()
    givenname = itemsplit[len(itemsplit)-1]
    surname = itemsplit[len(itemsplit)-2].replace(".","")
    if surname in abbrevDict:
        abbrevDict[surname].append(givenname)
    else:
        abbrevDict[surname] = [givenname]

for surname,givennames in abbrevDict.iteritems():
    if(len(givennames)>1):
        print (surname + ": " + ",".join(givennames))