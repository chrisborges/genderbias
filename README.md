# Analysis of Gender Bias in Statistical Journals
The goal of the project is to assess whether gender bias exists in statistical journals, and in the academic Statistics world in general. To do so, we determine whether there is a significant disparity in citation counts between papers with male and female (first) authors, that cannot be explained by common confounding factors such as seniority (job title) or country of employment. The data was collected by scraping data from the four largest statistical journals, Google scholar, and the Mathematics Geneology Project. Scraping, cleaning, and combining of data were performed in Python. Some further cleaning and the analysis were performed in R. A resubmission of this work is currently in progress to the journal Annals of Applied Statistics. 


**Brief description of data.**
Consists of 3,246 journal papers with 1,889 unique authors. There are 6 variables total: citation count (response), gender, publication year, year obtained PhD, job title (including seniority if in academia), employment country. 

**Results.** 
There is a significant disparity in citation counts between papers with male and female (first) authors, but they can be largely explained by two primary factors: A relatively small number of highly prolific authors with high citation counts (mostly male), and the fact that there appear to be less women at higher seniority positions in academia (Professor or Distinguished Professor). From a sociological perspective, I do not feel qualified to comment on whether this constitutes gender bias, but the data does seem to suggest that the statistics world is trending in a direction of greater equality. 

**Description of files.**

1. *scrape.py*. 
2. Test2
