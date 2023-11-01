library(readr)
library(readxl)
library(dplyr)
library(stringr)

#------------------#
# Importation data #
#------------------#

museums <- read_csv("Data/Raw/museums.csv")

# Dans le fichier museums, lorsque "State Code (FIPS)" = 60, on met 6, 80 on met 8 et 90 on met 9
museums$`State Code (FIPS)`[museums$`State Code (FIPS)` == 60] <- 6
museums$`State Code (FIPS)`[museums$`State Code (FIPS)` == 80] <- 8
museums$`State Code (FIPS)`[museums$`State Code (FIPS)` == 90] <- 9

#suppression des lignes sans locale code NCES
museums <- museums[!is.na(museums$`Locale Code (NCES)`),]

#Suppression abréviations
state_abbreviations <- c('AL', 'AK', 'AZ', 'AR', 'CA', 'CO', 'CT', 'DE', 'FL', 'GA', 'HI',
                         'ID', 'IL', 'IN', 'IA', 'KS', 'KY', 'LA', 'ME', 'MD', 'MA', 'MI',
                         'MN', 'MS', 'MO', 'MT', 'NE', 'NV', 'NH', 'NJ', 'NM', 'NY', 'NC',
                         'ND', 'OH', 'OK', 'OR', 'PA', 'RI', 'SC', 'SD', 'TN', 'TX', 'UT',
                         'VT', 'VA', 'WA', 'WV', 'WI', 'WY')

state_names <- c('ALABAMA', 'ALASKA', 'ARIZONA', 'ARKANSAS', 'CALIFORNIA', 'COLORADO',
                 'CONNECTICUT', 'DELAWARE', 'FLORIDA', 'GEORGIA', 'HAWAII', 'IDAHO',
                 'ILLINOIS', 'INDIANA', 'IOWA', 'KANSAS', 'KENTUCKY', 'LOUISIANA', 'MAINE',
                 'MARYLAND', 'MASSACHUSETTS', 'MICHIGAN', 'MINNESOTA', 'MISSISSIPPI', 'MISSOURI',
                 'MONTANA', 'NEBRASKA', 'NEVADA', 'NEW HAMPSHIRE', 'NEW JERSEY', 'NEW MEXICO',
                 'NEW YORK', 'NORTH CAROLINA', 'NORTH DAKOTA', 'OHIO', 'OKLAHOMA', 'OREGON',
                 'PENNSYLVANIA', 'RHODE ISLAND', 'SOUTH CAROLINA', 'SOUTH DAKOTA', 'TENNESSEE',
                 'TEXAS', 'UTAH', 'VERMONT', 'VIRGINIA', 'WASHINGTON', 'WEST VIRGINIA', 'WISCONSIN', 'WYOMING')

museums$`State (Administrative Location)` <- state_names[match(museums$`State (Administrative Location)`, state_abbreviations)]


#Traitement manuel des erreurs
museums$`State (Administrative Location)` <- ifelse(is.na(museums$`State (Administrative Location)`),
                                                    museums$`State (Physical Location)`,
                                                    museums$`State (Administrative Location)`)

museums$`State (Administrative Location)` <- ifelse(museums$`State Code (FIPS)` == 51, "VIRGINIA",
                                             ifelse(museums$`State Code (FIPS)` == 13, "GEORGIA",
                                             ifelse(museums$`State Code (FIPS)` == 11, "DISTRICT OF COLUMBIA",
                                             ifelse(museums$`State Code (FIPS)` == 24, "MARYLAND",
                                             ifelse(museums$`State Code (FIPS)` == 2, "ALASKA",
                                             ifelse(museums$`State Code (FIPS)` == 11, "DISTRICT OF COLUMBIA",
                                             museums$`State (Administrative Location)`))))))

museums <- museums[museums$`City (Administrative Location)` != "CHATSWORTH", ]

#Erreurs finances
museums <- museums[-which(museums$`Employer ID Number` == 113327144 & is.na(museums$`Tax Period`) & is.na(museums$`Income`) & is.na(museums$`Revenue`)), ]
museums <- museums[-which(museums$`Employer ID Number` == 232773714 & is.na(museums$`Tax Period`) & is.na(museums$`Income`) & is.na(museums$`Revenue`)), ]
museums <- museums[-which(museums$`Employer ID Number` == 912054439 & museums$`Tax Period` == 201406 & museums$`Income` == 0 & museums$`Revenue` == 0), ]
museums <- museums[-which(is.na(museums$`Employer ID Number`) & museums$`Tax Period` == 201412 & museums$`Income` == 14063 & museums$`Revenue` == 14063), ]

#Supression des lignes où Employer ID Number est NA
museums <- museums[!is.na(museums$`Employer ID Number`),]

#Tax Period (YYYYMM) en date (YYYY-MM-DD)
museums$`Tax Period` <- ifelse(!is.na(museums$`Tax Period`), 
                              ifelse(substr(museums$`Tax Period`, 5, 6) == "02",
                                     sprintf("%s-%s-28", substr(museums$`Tax Period`, 1, 4), substr(museums$`Tax Period`, 5, 6)),
                                     sprintf("%s-%s-30", substr(museums$`Tax Period`, 1, 4), substr(museums$`Tax Period`, 5, 6))),
                              NA)



#-------------#
#   Tables    #
#-------------#

#type
type <- museums %>% 
  select(`Museum Type`) %>% 
  unique() %>%
  rename(TypeMusee = `Museum Type`) %>%
  mutate(`ID_Type` = row_number()) %>%
  relocate(`ID_Type`, .before = 1)

#institutions
institution <- museums %>% 
  filter(!is.na(`Institution Name`)) %>% 
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
  )) %>%
  rename(`ID_Locale` = `Locale Code (NCES)`)

#State Code (FIPS)
statecode_FIPS <- read_csv("Data/Raw/State_Code_FIPS.csv") %>%
  rename(`ID_State` = `Country-level FIPS code`,
         `Nom` = `Place name`) %>%
  mutate(ID_State = as.numeric(ID_State))

#Jointure pour y ajouter le region code (AAM), on récupère le code AAM depuis la table museums
statecode_FIPS <- statecode_FIPS %>%
  left_join(museums %>% select(`State Code (FIPS)`, `Region Code (AAM)`) %>% unique(), by = c("ID_State" = "State Code (FIPS)")) %>%
  rename(`RefRegion` = `Region Code (AAM)`)

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

#ville
ville <- museums %>% 
  select(`Zip Code (Administrative Location)`, `City (Administrative Location)`, `State (Administrative Location)`) %>% 
  unique() %>%
  rename(`Nom` = `City (Administrative Location)`,
         `ID_ZIP_Code` = `Zip Code (Administrative Location)`) %>%
  mutate(`RefState` = statecode_FIPS$ID_State[match(`State (Administrative Location)`, statecode_FIPS$Nom)]) %>%
  select(-`State (Administrative Location)`)

#finances
finances <- museums %>%
  select(`Employer ID Number`, `Tax Period`, `Income`, `Revenue`) %>%
  distinct() %>%
  rename(`Employer ID` = `Employer ID Number`)

#musee
musee <- museums %>%
  select(`Museum ID`, `Museum Name`, `Phone Number`, `Street Address (Administrative Location)`,
         `Museum Type`, `Institution Name`, `City (Administrative Location)`, `Employer ID Number`,
         `Latitude`, `Longitude`, `Locale Code (NCES)`) %>%
  rename(`ID_Musee` = `Museum ID`,
         `Nom` = `Museum Name`,
         `Telephone` = `Phone Number`,
         `Adresse` = `Street Address (Administrative Location)`) %>%
  mutate(`RefType` = type$ID_Type[match(`Museum Type`, type$TypeMusee)]) %>%
  select(-`Museum Type`) %>%
  mutate(`RefInstitution` = institution$ID_Institution[match(`Institution Name`, institution$`Nom Institution`)]) %>%
  select(-`Institution Name`) %>%
  mutate(`RefVille` = ville$ID_ZIP_Code[match(`City (Administrative Location)`, ville$Nom)]) %>%
  select(-`City (Administrative Location)`) %>%
  mutate(`RefFinances` = finances$`Employer ID`[match(`Employer ID Number`, finances$`Employer ID`)]) %>%
  select(-`Employer ID Number`) %>%
  mutate(`RefLocale` = localecode_nces$ID_Locale[match(`Locale Code (NCES)`, localecode_nces$ID_Locale)]) %>%
  select(-`Locale Code (NCES)`)



#-------------#
# Exportation #
#-------------#

#type
write_csv(type, "Data/Processed/type_musee.csv", na = "NULL")

#institutions
write_csv(institution, "Data/Processed/institution.csv", na = "NULL")

#locale code (NCES)
write_csv(localecode_nces, "Data/Processed/type_environnement.csv", na = "NULL")

#State Code (FIPS)
write_csv(statecode_FIPS, "Data/Processed/etat.csv", na = "NULL")

#Region Code (AAM)
write_csv(regioncode_aam, "Data/Processed/region.csv", na = "NULL")

#ville
write_csv(ville, "Data/Processed/ville.csv")

#finances
write_csv(finances, "Data/Processed/finance.csv", na = "NULL")

#musee
write_csv(musee, "Data/Processed/musee.csv", na = "NULL")
