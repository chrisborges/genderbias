#Setup and Read - make sure data is in the same directory
data <- read.table("genderbiasdata.txt",header=TRUE)

#Helper Functions
as.numeric.factor <- function(x) { as.numeric(levels(x)[x]) }
generateCountry <- function(data) {
  country.table <- table(na.omit(data$Author_Employment_Country))
  country.list <- names(country.table)
  country.probs <- unname(country.table/sum(country.table))
  sample(country.list,size=1,replace=TRUE,prob=country.probs)
}

#Drop observations missing the gender variable
data <- data[-which(is.na(data$Author_Gender)),]

#Convert Year Obtained PhD and Cite Count to numeric
data$Author_Year_Obtained_PhD <- as.numeric.factor(data$Author_Year_Obtained_PhD)
data$Cite_Count <- as.numeric.factor(data$Cite_Count)

#Merge some categories together
data$Author_Job_Title[which(data$Author_Job_Title == "Industry_Researcher")] <- "Industry"
data$Author_Employment_Country[which(data$Author_Employment_Country == "New_Zealand")] <- "Foreign"
data <- droplevels(data)

#Remove 3 Rejoinders with N/A citations
data <- data[-which(is.na(data$Cite_Count)),]

#Impute the Bachelor's graduation year for Christopher R. Gjestvang
nophdnames <- c('Christopher R. Gjestvang','Douglas N. Midthune')
data[which(data$Author_Name==nophdnames[1]),"Author_Year_Obtained_PhD"] <- 2005


#Impute for observations that are only missing year of graduation
data.yr <- data
indices.yr <- which(is.na(data$Author_Year_Obtained_PhD) & !is.na(data$Author_Job_Title) & !is.na(data$Author_Employment_Country))


for(i in 1:length(indices.yr)) {
  a <- indices.yr[i]
  obs <- data[a,]
  curr.jobtitle <- toString(obs$Author_Job_Title)
  curr.country <- toString(obs$Author_Employment_Country)
  curr.gender <- toString(obs$Author_Gender)
  
  subindices <- which(data$Author_Job_Title == curr.jobtitle & data$Author_Employment_Country == curr.country & data$Author_Gender == curr.gender)
  if (length(subindices) <= 10) { subindices <- which(data$Author_Job_Title == curr.jobtitle & data$Author_Employment_Country == curr.country) }
  if (length(subindices) <= 10) { subindices <- which(data$Author_Job_Title == curr.jobtitle) }
  subdata <- data[subindices,]

  subyrs <- na.omit(subdata$Author_Year_Obtained_PhD)
  if(length(which(subyrs == "No PhD")) > 0) { subyrs <- subyrs[-which(subyrs == "No PhD")] }
  imputeyr <- round(mean(subyrs))
  
  data.yr[a,"Author_Year_Obtained_PhD"] <- imputeyr
}
data <- data.yr


#Impute for observations that are missing all 3 author covariates
data.all <- data
indices.all <- which(is.na(data$Author_Job_Title) & is.na(data$Author_Employment_Country))

for(i in 1:length(indices.all)) { 
  a <- indices.all[i]
  obs <- data[a,]
  
  if(is.na(obs$Author_Year_Obtained_PhD)) { 
    obs$Author_Year_Obtained_PhD <- min(data$Publication_Year[which(data$Author_Name == obs$Author_Name)]) + 1  
  }
  
  obs$Author_Job_Title <- "Industry"
  obs$Author_Employment_Country <- generateCountry(data)
  data.all[a,] <- obs
}
data <- data.all