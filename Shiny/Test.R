library(sqldf)
library(readr)

#On importe nos jeux de données

employeur <- read_csv("Data/Processed/employeur.csv")
etat <- read_csv("Data/Processed/etat.csv")
finance <- read_csv("Data/Processed/finance.csv")
institution <- read_csv("Data/Processed/institution.csv")
musee <- read_csv("Data/Processed/musee.csv")
region <- read_csv("Data/Processed/region.csv")
type_environnement <- read_csv("Data/Processed/type_environnement.csv")
type_musee <- read_csv("Data/Processed/type_musee.csv")
ville <- read_csv("Data/Processed/ville.csv")
Zip_Code <- read_csv("Data/Processed/Zip_Code.csv")

#On crée la base de données

db <- src_sqlite("Data/Processed/Database.sqlite3", create = T)
