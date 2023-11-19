CREATE DATABASE IF NOT EXISTS Musees;

USE Musees;

CREATE TABLE IF NOT EXISTS type_musee (
    ID_Type TINYINT NOT NULL AUTO_INCREMENT,
    Nom_Type VARCHAR(50) NOT NULL,
    PRIMARY KEY (ID_Type)
);

CREATE TABLE IF NOT EXISTS institution (
    ID_Institution SMALLINT NOT NULL AUTO_INCREMENT,
    Nom_Institution VARCHAR(100),
    PRIMARY KEY (ID_Institution)
);

CREATE TABLE IF NOT EXISTS type_environnement (
    ID_Environnement TINYINT NOT NULL AUTO_INCREMENT,
    Nom_Environnement VARCHAR(6) NOT NULL,
    PRIMARY KEY (ID_Environnement)
);

CREATE TABLE IF NOT EXISTS region (
    ID_Region TINYINT NOT NULL AUTO_INCREMENT,
    Nom_Region VARCHAR(14) NOT NULL,
    PRIMARY KEY (ID_Region)
);

CREATE TABLE IF NOT EXISTS etat (
    ID_Etat TINYINT NOT NULL AUTO_INCREMENT,
    Nom_Etat VARCHAR(20) NOT NULL,
    RefRegion TINYINT NOT NULL,
    PRIMARY KEY (ID_Etat),
    FOREIGN KEY (RefRegion) REFERENCES region (ID_Region)
);

CREATE TABLE IF NOT EXISTS ville (
    ID_Ville MEDIUMINT NOT NULL AUTO_INCREMENT,
    Nom VARCHAR(50) NOT NULL,
    RefEtat TINYINT NOT NULL,
    PRIMARY KEY (ID_Ville),
    FOREIGN KEY (RefEtat) REFERENCES etat (ID_Etat)
);

CREATE TABLE IF NOT EXISTS zip_code (
    ID_Zip_Code MEDIUMINT NOT NULL,
    RefVille MEDIUMINT NOT NULL,
    PRIMARY KEY (ID_Zip_Code),
    FOREIGN KEY (RefVille) REFERENCES ville (ID_Ville)
);

CREATE TABLE IF NOT EXISTS employeur (
    ID_Employeur INT NOT NULL,
    Nom_Employeur VARCHAR(50),
    PRIMARY KEY (ID_Employeur)
);

CREATE TABLE IF NOT EXISTS finance (
    ID_Finance MEDIUMINT NOT NULL AUTO_INCREMENT,
    Tax_Period DATE,
    Chiffre_Affaires BIGINT,
    Benefice BIGINT,
    RefEmployeur INT NOT NULL,
    PRIMARY KEY (ID_Finance),
    FOREIGN KEY (RefEmployeur) REFERENCES employeur (ID_Employeur)
);

CREATE TABLE IF NOT EXISTS musee (
    ID_Musee BIGINT NOT NULL,
    Nom_Musee VARCHAR(150) NOT NULL,
    Telephone BIGINT,
    Adresse VARCHAR(100),
    Latitude FLOAT,
    Longitude FLOAT,
    RefType_Musee TINYINT NOT NULL,
    RefInstitution SMALLINT,
    RefZip_Code MEDIUMINT NOT NULL,
    RefType_Environnement TINYINT NOT NULL,
    RefEmployeur INT NOT NULL,
    PRIMARY KEY (ID_Musee),
    FOREIGN KEY (RefType_musee) REFERENCES type_musee (ID_Type),
    FOREIGN KEY (RefInstitution) REFERENCES institution (ID_Institution),
    FOREIGN KEY (RefZip_Code) REFERENCES zip_code (ID_Zip_Code),
    FOREIGN KEY (RefType_Environnement) REFERENCES type_environnement (ID_Environnement),
    FOREIGN KEY (RefEmployeur) REFERENCES employeur (ID_Employeur)
);