library("stringr")
library("dplyr")
library("ggplot2")
library("usmap")
library("ggthemes")


######################################################################################################
## Infection numbers in relation to total Pop
######################################################################################################

## Imports Data from The New York Times, based on reports from state and local health agencies.
Covid_data = read.csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/live/us-counties.csv")
  Covid_data = Covid_data[!is.na(Covid_data$fips),] # Removes any fips values that are NA

## Imports Data county population data from the census bureau. 
County_data = read.csv("Downloaded_Data/co-est2020.csv")
  County_data = County_data[!County_data$COUNTY == 0,] # Removes any county values labeled as 0 (total state population)
  County_data$COUNTY = str_pad(County_data$COUNTY, 3 ,side = "left","0") # Adds 0s 
  County_data$fips = str_c(County_data$STATE, "", County_data$COUNTY) # Crates fips labels to compare to covid dataset
  County_data = County_data[c(22,6,7,21)] # Rearranges data into more readable format

## Merges nytimes Covid Data with census data based on fips number
Combined.data = merge(x = Covid_data, County_data, by = "fips")
  Combined.data[,1]= str_pad(Combined.data[,1], 5 ,side = "left","0") # Adds zeros to the left of any fips values less than 5 numbers wide

## Calls the counties data set from the usmaps package
data(countypop)

## Combines datasets based on fips
Combined.data = merge(x = countypop, Combined.data, by = "fips")

## Calculates the percentage of each population that was infected
Combined.data$Percentinf = Combined.data$cases/Combined.data$POPESTIMATE2020

## Graph percentage of cases vs total pop across the whole US
us_totinf = plot_usmap(data = Combined.data, values = "Percentinf", color = "white", size = NA) +
  scale_fill_continuous(low = "white", high = "blue", name = "Proportion I")

#ggsave(path = "Final_project/Graphs", filename = "US_Inf_Map.png", width = 49, height = 30) # Save map

######################################################################################################
# Current Infection Averages per County
######################################################################################################

## Imports Data from The New York Times, based on reports from state and local health agencies.
Covid_avg_data = read.csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/rolling-averages/us-counties-2021.csv")
Covid_avg_data$geoid = gsub("\\D","", Covid_avg_data$geoid) # extracts numeric value from geoid column

## Filters out all but the most recent day. Average data tends to drag behind by about a day so this may need to be changed depending on when the results were last updated.
Covid_avg_data = subset(Covid_avg_data, date == Sys.Date() -1)

names(Covid_avg_data)[2] = "fips" #relabels geoid as fips

Covid_avg_data = Covid_avg_data[,c(2,6)] # Pulls just average covid cases and the fips number

Combined.data = merge(x = Combined.data, Covid_avg_data, by = "fips")

Combined.data$cases_avg = Combined.data$cases_avg/Combined.data$POPESTIMATE2020

us_curinf =plot_usmap(data = Combined.data, values = "cases_avg", color = "white", size = NA) +
  scale_fill_continuous(low = "white", high = "dark green", name = "Avg Cases")

#ggsave(path = "Final_project/Graphs", filename = "US_Inf_avg_Map.png", width = 49, height = 30) # Save map

######################################################################################################
## Recording Mask mandate Usage
######################################################################################################

## Call Mask Mandate Data
mask_mandate_data = read.csv("Downloaded_Data/county_mask_mandate_data.csv")
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

## Used to test and record infection values based on whether or not a mask mandate was in place
masky = NULL
maskn = NULL

# Classifies each as rural or urban
for(i in 1:nrow(Combined.data)){
  if(Combined.data$maskyn[i] == 1){
    masky = rbind(masky,Combined.data$Percentinf[i])
  }
  
  else{
    maskn = rbind(maskn,Combined.data$Percentinf[i])
  }
}

# Test significance
mask.t.test = t.test(masky,maskn)

# Record mean and SD of mask data
maskavg = data.frame(c("Mask Mandate", "No Mask Mandate"),c(mean(masky),mean(maskn)),c(sd(masky),sd(maskn))) # Creates dataframe with the mean and sd for both rural and urban areas

## Plot mask data
us_mask = plot_usmap(data = Combined.data, values = "maskyn", color = "black", size = .1) +
  scale_fill_continuous(low = "white", high = "lightgreen", name = "Proportion I") +
  theme(legend.position = "none")

# Save bar graphs
#ggsave(path = "Final_project/Graphs", filename = "US_mask_mandate.png", width = 49, height = 30)

bar_mask = ggplot(data = maskavg, aes(x=maskavg[,1], y = maskavg[,2]))+
  geom_bar(stat="identity",fill =c("lightgreen","white") )+
  geom_errorbar(aes(ymin=maskavg[,2]-maskavg[,3], ymax=maskavg[,2]+maskavg[,3]), width=.2,
                position=position_dodge(.9))+
  labs(x=NULL, y = "Total Infection Prevalence")

#ggsave(path = "Final_project/Graphs", filename = "US_mask_Bar.png") # Save bar graph

#######################################################################################################
## Classifying county as Rural or Urban
#######################################################################################################

## According to the United States Health Resources and Services Administration, counties are considered rural if the population is less than 50,000 people
## Classifies counties as rural or urban based on whether or not the population is above 50,000
for(i in 1:nrow(Combined.data)){
  if(Combined.data$POPESTIMATE2020[i] < 50000){
    Combined.data$rural_urban_HRSA[i] = 0
  }
  else{
    Combined.data$rural_urban_HRSA[i] = 1
  }
}
US_RU_HRSA = plot_usmap(data = Combined.data, values = "rural_urban_HRSA", color = "black", size = .1) +
  scale_fill_continuous(low = "white", high = "brown", name = "Proportion I") +
  theme(legend.position = "none")

#ggsave(path = "Final_project/Graphs", filename = "US_RU_HRSA_Map.png", width = 49, height = 30) # Save map


########################################################################################################
## Comparing infection rates between rural and non-rural counties assuming HRSA Standard
########################################################################################################
rural = NULL
urban = NULL

cur_rural = NULL
cur_urban = NULL

# Runs through data to record which values are rural and urban
for(i in 1:nrow(Combined.data)){
  if(Combined.data$POPESTIMATE2020[i] >= 50000){
    urban = rbind(urban,Combined.data$Percentinf[i])
    cur_urban = rbind(cur_urban,Combined.data$cases_avg[i])
  }
  else{
    rural = rbind(rural,Combined.data$Percentinf[i])
    cur_rural = rbind(cur_rural,Combined.data$cases_avg[i])
  }
}

# Record mean and SD of rural and urban data
urb.rur1 = data.frame(c("Rural", "Urban"),c(mean(rural),mean(urban)),c(sd(rural),sd(urban))) # Creates dataframe with the mean and sd for both rural and urban areas

# Runs t.test
ur.t.test = t.test(urban,rural)

# Graphs difference
Bar_RU_HRSA = ggplot(data = urb.rur1, aes(x=urb.rur1[,1], y = urb.rur1[,2]))+
  geom_bar(stat="identity", fill =c("brown","white") )+
  geom_errorbar(aes(ymin=urb.rur1[,2]-urb.rur1[,3], ymax=urb.rur1[,2]+urb.rur1[,3]), width=.2,
                position=position_dodge(.9))+
  labs(x="County Classification", y = "Total Infection Prevalence")
  
#ggsave(path = "Final_project/Graphs", filename = "US_Inf_HRSA_Bar.png") # Save bar graph