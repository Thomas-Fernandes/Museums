library(readr)
library(readxl)
library(dplyr)

#------------------#
# Importation data #
#------------------#

data <- read_csv("museums.csv")
uscities <- read_excel("uscities.xlsx")

#On extrait la colonne city et state de `data` dans un nouveau dataframe
data_city <- data[,c("City (Administrative Location)", "State (Administrative Location)")]
data_city <- distinct(data_city)

# Convertir les valeurs dans les colonnes "city" et "state_id" de uscities en majuscules
uscities$city <- toupper(uscities$city)
uscities$state_id <- toupper(uscities$state_id)

# Effectuer la jointure entre data_city et uscities
merged_data <- merge(data_city, uscities, by.x = c("City (Administrative Location)", "State (Administrative Location)"), by.y = c("city", "state_id"), all.x = TRUE)

nombre_de_NA <- sum(is.na(merged_data$population))
