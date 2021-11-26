library("stringr")
library("dplyr")
library("ggplot2")
library("usmap")
library("ggthemes")

##############################################
## Infection numbers in relation to total Pop
##############################################

## Imports Data from The New York Times, based on reports from state and local health agencies.
Covid_data = read.csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/live/us-counties.csv")
  Covid_data = Covid_data[!is.na(Covid_data$fips),] # Removes any fips values that are NA

## Imports Data county population data from the census bureau. 
County_data = read.csv("Final_Project/Downloaded_Data/co-est2020.csv")
  County_data = County_data[!County_data$COUNTY == 0,] # Removes any county values labeled as 0 (total state population)
  County_data$COUNTY = str_pad(County_data$COUNTY, 3 ,side = "left","0") # Adds 0s 
  County_data$fips = str_c(County_data$STATE, "", County_data$COUNTY) # Crates fips labels to compare to covid dataset
  County_data = County_data[c(22,6,7,21)] # Rearranges data into more readable format

## Merges nytimes Covid Data with census data based on fips number
Combined.data = merge(x = Covid_data, County_data, by = "fips")
  Combined.data[,1]= str_pad(Combined.data[,1], 5 ,side = "left","0") # Adds zeros to the left of any fips values less than 5 numbers wide

## Calls the counties data set from the usmaps package
data(countypop);

## Combines the 
Combined.data = merge(x = countypop, Combined.data, by = "fips")

## Calculates the percentage of each population that was infected
Combined.data$Percentinf = Combined.data$cases/Combined.data$POPESTIMATE2020

## Graph percentage of cases vs total pop across the whole US
plot_usmap(data = Combined.data, values = "Percentinf", color = "white") +
  scale_fill_continuous(low = "white", high = "blue", name = "Proportion I")

#############################################
## Recording Mask mandate Usage
#############################################

## Call Mask Mandate Data
mask_mandate_data = read.csv("Final_Project/Downloaded_Data/county_mask_mandate_data.csv")
  mask_mandate_data[,3]= str_pad(mask_mandate_data[,3], 5 ,side = "left","0") # Adds zeros to the left of any fips values less than 5 numbers wide
  names(mask_mandate_data)[3] = "fips"

## Translates whether or not a mask mandate was present into a form that R can read
for(i in 1:nrow(mask_mandate_data)){
  if(mask_mandate_data[i,5] == ""){
    mask_mandate_data$maskyn[i] = 0
}
  else{
    mask_mandate_data$maskyn[i] = 1
  }
}
# Records if a county had a mask mandate into Combined.data
Combined.data = merge(x = Combined.data,mask_mandate_data[,c(3,20)] , by = "fips")


## Plot mask data
plot_usmap(data = Combined.data, values = "maskyn", color = "black") +
  scale_fill_continuous(low = "white", high = "lightgreen", name = "Proportion I") +
  theme(legend.position = "none")

############################################
## Classifying county as Rural or Urban
############################################

## According to the United States Health Resources and Services Administration, counties are considered rural if the population is less than 50,000 people
## Classifies counties as rural or urban based on whether or not the population is above 50,000
for(i in 1:nrow(Combined.data)){
  if(Combined.data$POPESTIMATE2020[i] < 50000){
    Combined.data$rural_urban[i] = 0
  }
  else{
    Combined.data$rural_urban[i] = 1
  }
}
plot_usmap(data = Combined.data, values = "rural_urban", color = "black") +
  scale_fill_continuous(low = "white", high = "brown", name = "Proportion I") +
  theme(legend.position = "none")

#############################################
## Comparing infection rates
#############################################
rural = NULL
urban = NULL


for(i in 1:nrow(Combined.data)){
  if(Combined.data$rural_urban[i] == 1){
    urban = rbind(urban,Combined.data$Percentinf[i])
  }
  else{
    rural = rbind(rural,Combined.data$Percentinf[i])
  }
}

rubar = data.frame(c("Rural", "Urban"),c(mean(rural),mean(urban)),c(sd(rural),sd(urban)))

ggplot(data = rubar, aes(x=rubar[,1], y = rubar[,2]))+
  geom_bar(stat="identity")+
  geom_errorbar(aes(ymin=rubar[,2]-rubar[,3], ymax=rubar[,2]+rubar[,3]), width=.2,
                position=position_dodge(.9))+
  labs(x="County Classification", y = "Total Infection Prevalence")
  