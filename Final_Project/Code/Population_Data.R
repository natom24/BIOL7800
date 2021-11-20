library("stringr")
library("tidyverse")
#devtools::install_github("UrbanInstitute/urbnmapr")
library("socviz")
library("ggthemes")

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
data(county_map)

## Renames the fips column to "fips"
county_map = rename(county_map, fips = id)

county_map$fips <- sub("^0+", "", county_map$fips)

Combined.data = merge(x = county_map, Combined.data, by = "fips")

p <- ggplot(data = Combined.data,
            mapping = aes(x = long, y = lat,
                          fill = cases, 
                          group = group))

p1 <- p + geom_polygon(color = "gray90", size = 0.05) + coord_equal()
