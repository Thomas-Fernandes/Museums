library(readr)
library(readxl)
library(dplyr)

#------------------#
# Importation data #
#------------------#

County_code <- read_csv("Data/Raw/County-code.csv")
museums <- read_csv("Data/Raw/museums.csv")

# Dans le fichier museums, lorsque "State Code (FIPS)" = 60, on met 6, 80 on met 8 et 90 on met 9
museums$`State Code (FIPS)`[museums$`State Code (FIPS)` == 60] <- 6
museums$`State Code (FIPS)`[museums$`State Code (FIPS)` == 80] <- 8
museums$`State Code (FIPS)`[museums$`State Code (FIPS)` == 90] <- 9


#Pré-traitement
#museums <- museums[!is.na(museums$`County Code (FIPS)`),]
#museums <- museums[!is.na(museums$`Locale Code (NCES)`),]

#Ccolonne "County Code (FIPS)" en 3 caractères (ex: 001)
#museums$`County Code (FIPS)` <- formatC(museums$`County Code (FIPS)`, width = 3, flag = "0")
#museums$`State Code (FIPS)` <- formatC(museums$`State Code (FIPS)`, width = 2, flag = "0")

#Numéro de state code (FIPS) au début du county code (FIPS)
#museums$`County Code (FIPS)` <- paste0(museums$`State Code (FIPS)`, museums$`County Code (FIPS)`)

#On compte combien de musée n'ont pas de coordonnées
#sum(is.na(museums$`Tax Period`))

#-------------#
#   Tables    #
#-------------#

#musees
type <- museums %>% 
  select(`Museum Type`) %>% 
  unique() %>%
  rename(TypeMusee = `Museum Type`) %>%
  mutate(`ID_TypeMusee` = row_number()) %>%
  relocate(`ID_TypeMusee`, .before = 1)

 #institutions
institution <- museums %>% 
  select(`Institution Name`) %>% 
  unique() %>%
  rename(`Nom Institution` = `Institution Name`) %>%
  mutate(`ID_Institution` = row_number()) %>%
  relocate(`ID_Institution`, .before = 1)

#locale code (NCES)
localecode_nces <- museums %>% 
  select(`Locale Code (NCES)`) %>% 
  unique() %>%
  mutate(Nom = case_when(
    `Locale Code (NCES)` == 1 ~ "City",
    `Locale Code (NCES)` == 2 ~ "Suburb",
    `Locale Code (NCES)` == 3 ~ "Town",
    `Locale Code (NCES)` == 4 ~ "Rural"
  ))

#State Code (FIPS)
statecode_FIPS <- read_csv("Data/Raw/State_Code_FIPS.csv") %>%
  rename(`ID_State` = `Country-level FIPS code`,
         `Nom` = `Place name`)

#Region Code (AAM)
regioncode_aam <- museums %>%
  select(`Region Code (AAM)`) %>%
  unique() %>%
  rename(`ID_Region` = `Region Code (AAM)`) %>%
  mutate(Nom = case_when(
    `ID_Region` == 1 ~ "New England",
    `ID_Region` == 2 ~ "Mid-Atlantic",
    `ID_Region` == 3 ~ "Southeastern",
    `ID_Region` == 4 ~ "Midwest",
    `ID_Region` == 5 ~ "Montain Plains",
    `ID_Region` == 6 ~ "Western"
  ))

#County Code (FIPS)
countycode_fips <- County_code %>%
  rename(`ID_County` = `Country-level FIPS code`,
         `Nom` = `Place name`)

#ville
ville <- museums %>% 
  select(`Zip Code (Administrative Location)`, `City (Administrative Location)`) %>% 
  unique() %>%
  rename(`Nom` = `City (Administrative Location)`,
         `ID_ZIP_Code` = `Zip Code (Administrative Location)`)

#finances (on doit créer la PK, on fait un AUTO_INCREMENT)
finances <- museums %>%
  select(`Tax Period`, `Income`, `Revenue`, `Museum ID`) %>%
  mutate(`ID_Finances` = row_number()) %>%
  relocate(`ID_Finances`, .before = 1)

#musee
musee <- museums %>%
  select(`Museum ID`, `Museum Name`, `Phone Number`, `Street Address (Administrative Location)`) %>%
  rename(`ID_Musee` = `Museum ID`,
         `Nom` = `Museum Name`,
         `Telephone` = `Phone Number`,
         `Adresse` = `Street Address (Administrative Location)`)

#geocodes

#-------------------#
#   Foreign Keys    #
#-------------------#


