library("stringr")
library("tidyverse")
library("usmap")
library("ggthemes")

######################################
## Calling/Cleaning Data
######################################

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
  Combined.data[,1]= str_pad(Combined.data[,1], 5 ,side = "left","0") # Adds zeros to the left of any fips values less than 4 numbers wide

## Calls the counties data set from the usmaps package
data(countypop);

## Combines the 
Combined.data = merge(x = countypop, Combined.data, by = "fips")

## Calls the state data set from the usmaps package
data(statepop)

#############################################
#Calculations/Data Manipulations
#############################################

## Calculates the percentage of each population that was infected
Combined.data$Percentinf = Combined.data$cases/Combined.data$POPESTIMATE2020


#############################################
## Graphing data
#############################################

plot_usmap(data = Combined.data, values = "Percentinf", color = "white") +
  scale_fill_continuous(low = "white", high = "blue", name = "Proportion I")
