library("stringr")
library("tidyverse")
#devtools::install_github("UrbanInstitute/urbnmapr")
library("urbnmapr")

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

## Removes repeated columns
Combined.data = Combined.data[,-c(11,12)]

## Calls the counties data set from urbnmapr
data(counties)

## Renames the fips column to "fips"
counties = rename(counties, fips = county_fips)

counties$fips <- sub("^0+", "", counties$fips)

Combined.data = merge(x = counties, Combined.data, by = "fips")

Combined.data %>%
  ggplot(aes(long, lat, group = group, fill = deaths)) +
  geom_polygon(color = NA) +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45) +
  labs(fill = "Median Household Income")
