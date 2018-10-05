#Basic Setup
library(dummies)
library(MASS)
library(randomForest)
library(quantreg)
library(Qtools)

#Clean the data first - make sure data file is in same directory as cleandata.R
source("cleandata.R")

#Data Setup
simplenames <- c('pubyr','cite','name','phdyr','job','country','gender') #Give the columns easier shorthand names
gb <- data
colnames(gb) <- simplenames
gb$gender <- ifelse(gb$gender=="Male",0,1)
gb.m <- gb[which(gb$gender == 0),]; gb.f <- gb[which(gb$gender == 1),]


##Create dummies for the categorical variables
#gbfull is the original data gb but with all of the categorical variables turned into dummies
job.dummies <- dummy(gb$job,sep="_")
country.dummies <- dummy(gb$country,sep="_")
gbfull <- cbind(gb[,c("pubyr","cite","phdyr","gender")], job.dummies[,-6],country.dummies[,-5]  )


#Naive wilcox test and boxplot
cite.m <- gbfull$cite[which(gb$gender==0)]; cite.f <- gbfull$cite[which(gb$gender== 1)]
wilcox.test(cite.m,cite.f)
boxplot(cite.m,cite.f,names=c("Male","Female"))


#Conditional t tests

#Variable "jobinfos" stores a table containing conditional t and Wilcox tests of cites between male and female,
#given each possible job title
#Nmale and Nfemale are the sample sizes of male and female in these conditional groups, respectively
alljobs <- c("Professor_Emeretis","Distinguished_Professor","Professor",
             "Associate_Professor","Assistant_Professor","Other_Academia","Industry")
jobinfos <- matrix(0,length(alljobs),6)
colnames(jobinfos) <- c("Mean Cites","p-val (Wcx)","p-val (t)","t stat","Nmale","Nfemale")
rownames(jobinfos) <- alljobs

for(i in 1:length(alljobs)) {
  myset <- alljobs[i]
  jobindx.m <- which(gb.m$job %in% myset ); jobindx.f <- which(gb.f$job %in% myset )
  num.m <- length(jobindx.m); num.f <- length(jobindx.f)
  cc.m <- gb.m$cite[jobindx.m]; cc.f <- gb.f$cite[jobindx.f]
  avg.cites <- mean(c(cc.m,cc.f))
  wiltest <- wilcox.test(cc.m,cc.f); ttest <- t.test(cc.m,cc.f)
  pval.wil <- wiltest$p.value; pval.t <- ttest$p.value; stat <- unname(ttest$statistic)
  jobinfos[i,] <- round(c(avg.cites,pval.wil,pval.t,stat,num.m,num.f),3)
}

print(jobinfos)

#Similarly for the countries
allcountries <- c("United_States","Canada","United_Kingdom","Australia","Foreign")
countryinfos <- matrix(0,length(allcountries),6)
colnames(countryinfos) <- c("Mean Cites","p-val (Wcx)","p-val (t)","t stat","Nmale","Nfemale")
rownames(countryinfos) <- allcountries

for(i in 1:length(allcountries)) {
  myset <- allcountries[i]
  countryindx.m <- which(gb.m$country %in% myset ); countryindx.f <- which(gb.f$country %in% myset )
  num.m <- length(countryindx.m); num.f <- length(countryindx.f)
  cc.m <- gb.m$cite[countryindx.m]; cc.f <- gb.f$cite[countryindx.f]
  avg.cites <- mean(c(cc.m,cc.f))
  wiltest <- wilcox.test(cc.m,cc.f); ttest <- t.test(cc.m,cc.f)
  pval.wil <- wiltest$p.value; pval.t <- ttest$p.value; stat <- unname(ttest$statistic)
  countryinfos[i,] <- round(c(avg.cites,pval.wil,pval.t,stat,num.m,num.f),3)
}

print(countryinfos)


#Prints out the most prolific papers in the dataset with First Author's name
gb[order(gb$cite,decreasing=TRUE),]


#Correlations and scatterplots of the quantitative variables 
subdata <- gb[,c("pubyr","cite","phdyr","gender")]
cor(subdata)
pairs(subdata)

#Boxplot of cites against job title
boxplot(gb$cite~gb$job) 
summary(aov(gb$cite~gb$job))

#Boxplot of cites against country
boxplot(gb$cite~gb$country)
summary(aov(gb$cite~gb$country))

##Adding some interactions to the data. 
#In particular I added all of the job title x gender and country x gender interactions as the most relevant ones
gender <- gbfull$gender
job.gender.interactions <- job.dummies[,-6]
for(i in 1:dim(job.gender.interactions)[2]) { job.gender.interactions[,i] <- job.gender.interactions[,i]*gender }
colnames(job.gender.interactions) <- c("Ass.Prof_x_Gender","Assoc.Prof_x_Gender","D.Prof_x_Gender","Industry_x_Gender",
                                "OA_x_Gender","PE_x_Gender")

country.gender.interactions <- country.dummies[,-5]
for(i in 1:dim(country.gender.interactions)[2]) { 
  country.gender.interactions[,i] <- country.gender.interactions[,i]*gender }
colnames(country.gender.interactions) <- c("AU_x_Gender","CA_x_Gender","Foreign_x_Gender","UK_x_Gender")

gbinter <- cbind(gbfull,job.gender.interactions)


##Linear Regression Model - first attempt at modeling
lin.model <- lm(cite~.,data=gbfull)
summary(lin.model)

#Some quick diagnostics for Linear Regression
#There are some problems with normality of residuals and heteroskedasticity
qqnorm(resid(lin.model)); qqline(resid(lin.model))
hist(resid(lin.model))
plot(predict(lin.model),resid(lin.model)); abline(h=0,col=2,lty=2)


##Poisson Regression Model
#While Poisson Regression makes intuitive sense as the response are count variables, ultimately the
#dispersion is absurdly high and the residual deviance is abnormally large. This is most likely due to
#the large variance within the citation counts (response). 
pois.model <- glm(cite~.,data=gbfull,family="poisson")
summary(pois.model)
disp.test.model <- glm(cite~.,data=gbfull,family=quasipoisson(link=log))
summary(disp.test.model)


##Negative Binomial Regression Model
#An attempt to fix the overdispersion problem from before. Fit is somewhat better, but still poor. 
#The issues are similar. 
model.nb <- glm.nb(cite~.,data=gbfull)
summary(model.nb)
pchisq(model.nb$deviance,model.nb$df.residual,lower.tail=FALSE)
pchisq(2 * (logLik(model.nb) - logLik(pois.model)), df = 1, lower.tail = FALSE)


##Generalized Additive Model
#Not very interpretable, and lack of fit problem does not go away
require(gam)
gam1 <- gam(cite~s(pubyr)+s(phdyr)+job+country+gender,data=gb)
summary(gam1)
pchisq(gam1$deviance,gam1$df.residual,lower.tail=FALSE)


##Linear Model take two
#Try it again since the GLMs and GAM are not fitting the data well. Since the counts are highly varied, linear
#makes some level of sense. 

#Box-Cox: select optimal lambda for applying transformation y* = y^(lambda)
gbfull1 <- gbfull; cites <- gbfull1$cite; cites[which(cites==0)] <- 1; gbfull1$cite <- cites
model <- lm(cite~.,data=gbfull1)
boxcox(model)

#log transformation. 
newcite <- log(gb$cite) 
newcite[which(newcite < 0)] <- 0 #log 0 = undefined, so changed 0 citations -> 1 citation 
gbfull$cite <- newcite
lin.model <- lm(cite~.,data=gbfull)
summary(lin.model)

#Check assumptions again - improvement. Normality assumption improved a lot, but is still a bit off
qqnorm(resid(lin.model)); qqline(resid(lin.model))
hist(resid(lin.model))
plot(predict(lin.model),resid(lin.model)); abline(h=0,col=2,lty=2)


##Quantile regression
#Bypasses the normality of residuals assumption - does not need it
#Predict the median rather than E[Y|X]. Relevant here since there are quite a few "high-cite" papers that
#skew the results
qr.model <- rq(cite~.,data=gbfull1)
GOFTest(qr.model) #Is the model fit good?


##Prediction-based confidence intervals
#Fit model to Male data only, and then predict female data using Male Model. 
#Then construct confidence interval of predictions - Actual Female Citations.
#Used both Linear Model and Random Forest. 
gbmale <- gbfull[which(gbfull$gender==0),]; gbmale <- gbmale[,-which(colnames(gbmale) == "gender")]
gbfemale <- gbfull[which(gbfull$gender==1),]; gbfemale <- gbfemale[,-which(colnames(gbfemale) == "gender")]

male.model.lin <- lm(cite~.,data=gbmale); female.model.lin <- lm(cite~.,data=gbfemale)
pred.lin <- unname(predict(male.model.lin,gbfemale))
t.test(pred.lin,gbfemale$cite)

male.model.rf <- randomForest(cite~.,data=gbmale)
pred.rf <- unname(predict(male.model.rf,gbfemale))
t.test(pred.rf,gbfemale$cite)

male.model.qr <- qr(cite~.,data=gbmale)