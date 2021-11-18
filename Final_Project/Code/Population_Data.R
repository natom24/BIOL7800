library("stringr")
library("tidyverse")
library("usmap")
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

Combined.data = NULL

## for loop to run through all county fips numbers
for(i in seq(1:nrow(County_data))){
  fips.num = County_data[i,1] #Records the fips number
  
  ## runs through all covid data fips numbers to compare to county data
  for(j in seq(1:nrow(Covid_data))){
    ## Tests to see if the fips numbers for both data frames are the same
    if(fips.num == Covid_data[j,4]){
      
      Combined.data = rbind(Combined.data, cbind(County_data[i,],Covid_data[j,]))
      break
    }
  }
}

Combined.data = Combined.data[,-c(5:8)]

test = Combined.data[c(1,4)]

ggplot() + 
  geom_polygon(data = urbnmapr::states, mapping = aes(x = long, y = lat, group = group),
               fill = "grey", color = "white") +
  coord_map(projection = "albers", lat0 = 39, lat1 = 45)
