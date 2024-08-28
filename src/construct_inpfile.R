library(ggplot2)
library(tidyverse)
library(readxl)
library(reshape)
library(ggpubr)
library(scales)
library(splitstackshape)
library(tm)
library(plyr)

locality <- "Middelkerke"
month <-"06"
year <-"2024"
oever<-""
setwd(paste0("./localities/",year,"_",month,"_",locality,oever))

input<-list.files(paste0(getwd(),"/data/input/"), pattern= "\\.xlsx$")
data <-
  read_excel(
    paste0("./data/input/",input),
    skip = 3,
    sheet = "Data_fuiken",
    col_names = TRUE,
    col_types = "guess",
    na = ""
  )


catch_data <-
  data[,c("Fuiknummer","Fuiktype","Locatie", "Naam waterloop", "Datum","Capture","Recapture")]
names(catch_data) <-
  c("Fuiknummer", "Fuiktype", "Locatie", "Waterloop", "Datum", "Capture", "Recapture")

#merge all crayfish in one column
catch_data<-unite(catch_data, crayfish, Capture, Recapture, na.rm = TRUE, sep = ';') %>%
  separate_rows(crayfish, sep=";") %>%
  filter(crayfish >0) %>%
  select(Waterloop, Datum, crayfish) %>%
  mutate(occ = 1 ) 

# Filter on specific watercourse if needed
# catchdat <- cf_catch %>%
#   filter(Waterloop == "Leebeek")%>%
#   mutate(occ = 1 ) 
  
full<-expand.grid(unique(catch_data$Datum), unique(catch_data$crayfish)) %>%
  mutate(occ = 0)

catchdat <-left_join(full, catch_data, by= c("Var1" = "Datum", "Var2"="crayfish"))%>%
  mutate(occ=occ.x+occ.y)%>%
  replace(is.na(.), 0) %>%
  select(c("Var1","Var2","occ"))%>%
  pivot_wider(names_from = "Var1", values_from = "occ")
  
CH<-catchdat[,-1]%>%
  unite(ch, sep="")%>%
  as.data.frame()

write.table(CH, "./data/input/CH.txt", sep = "\t", row.names = FALSE, col.names = c("ch"), quote = FALSE, eol = "\n")

# Confirmation message
cat("Text file 'CH' has been saved in the working directory.")
