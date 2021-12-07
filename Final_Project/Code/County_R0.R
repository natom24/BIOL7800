library("stringr")
library("usmap")
library("ggplot2")

Covid_data = read.csv("https://raw.githubusercontent.com/nytimes/covid-19-data/master/live/us-counties.csv")
  Covid_data = Covid_data[!is.na(Covid_data$fips),] # Removes any fips values that are NA


County_data = read.csv("Downloaded_Data/co-est2020.csv")
County_data = County_data[!County_data$COUNTY == 0,] # Removes any county values labeled as 0 (total state population)
County_data$COUNTY = str_pad(County_data$COUNTY, 3 ,side = "left","0") # Adds 0s 
County_data$fips = str_c(County_data$STATE, "", County_data$COUNTY) # Crates fips labels to compare to covid dataset
County_data = County_data[,c(22,21)] # Rearranges data into more readable format


Combined.data = merge(x = Covid_data, County_data, by = "fips")
Combined.data[,1]= str_pad(Combined.data[,1], 5 ,side = "left","0") # Adds zeros to the left of any fips values less than 5 numbers wide


R0_data = read.csv("Downloaded_Data/42003_2020_1609_MOESM4_ESM.csv")
R0_data[,3]= str_pad(R0_data[,3], 5 ,side = "left","0") # Adds zeros to the left of any fips values less than 5 numbers wide
R0_data = R0_data[,c(3,13)]

Combined.data = merge(x = Combined.data, R0_data, by = "fips")

# Imports CDC Vaccine Data
vac.data = read.csv("Downloaded_Data/COVID-19_Vaccinations_in_the_United_States_County.csv")
vac.data = vac.data[vac.data$Date == "12/06/2021",] # Pulls Vaccine data from December 6, 2021
vac.data = vac.data[,c(2,6)]
names(vac.data)[1] = "fips"
vac.data[,2] = vac.data[,2]/100
Combined.data = merge(x = Combined.data, vac.data, by = "fips")

## Parameter values from Ahmed et al 2021
lambda = .0025 # Births into system
gam = 2.01e-4 #Rate of exposed to quarantined
mu =  .0015 #Natural mortality rate
ep =  .45 #Rate of exposed to symptomatic infected
sig = .067 #Rate of transfer from exposed to asymptomatic infected
tau = 2e-4 #Transfer of susceptible to quarantine



Combined.data$beta = Combined.data$R0.pred*((ep+mu+sig+gam)*(tau+mu))/lambda

Combined.data$curRt = ((Combined.data$POPESTIMATE2020-Combined.data$cases)* Combined.data$Series_Complete_Pop_Pct)/Combined.data$POPESTIMATE2020*((Combined.data$beta*lambda)/((ep+mu+sig+gam)*(tau+mu)))

map_rt_cur = plot_usmap(data = Combined.data, values = "curRt", color = "white",exclude =c("AK","HI"), size = .1) +
  scale_fill_continuous(low = "yellow", high = "blue", name = "Rt", limits = c(0,4))

#ggsave(path = "Final_project/Graphs", filename = "US_Cur_Rt_Map.png", width = 49, height = 30) # Save map

## Parameter values from Ahmed et al 2021
otau = 1e-4 #Transfer of susceptible to quarantine

Combined.data$omnicron_Rt = ((Combined.data$POPESTIMATE2020-Combined.data$cases)* Combined.data$Series_Complete_Pop_Pct)/Combined.data$POPESTIMATE2020*((1.5*Combined.data$beta*lambda)/((ep+mu+sig+gam)*(otau+mu)))

map_rt_omeg = plot_usmap(data = Combined.data, values = "omnicron_Rt", color = "white",exclude =c("AK","HI"), size = .1) +
  scale_fill_continuous(low = "yellow", high = "blue", name = "Rt", limits = c(0,4))
