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
    ID_environnement TINYINT NOT NULL AUTO_INCREMENT,
    Nom_environnement VARCHAR(6) NOT NULL,
    PRIMARY KEY (ID_environnement)
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
    ID_Ville MEDIUMINT NOT NULL,
    Nom VARCHAR(50) NOT NULL,
    RefEtat TINYINT NOT NULL,
    PRIMARY KEY (ID_Ville),
    FOREIGN KEY (RefEtat) REFERENCES etat (ID_Etat)
);

CREATE TABLE IF NOT EXISTS finance (
    Employer_ID INT NOT NULL,
    Tax_Period DATE,
    Chiffre_Affaires BIGINT,
    Benefice BIGINT,
    PRIMARY KEY (Employer_ID)
);

CREATE TABLE IF NOT EXISTS musee (
    ID_Musee BIGINT NOT NULL AUTO_INCREMENT,
    Nom_musee VARCHAR(150) NOT NULL,
    Telephone BIGINT,
    Adresse VARCHAR(100),
    Latitude FLOAT,
    Longitude FLOAT,
    RefType_musee TINYINT NOT NULL,
    RefInstitution SMALLINT,
    RefVille MEDIUMINT NOT NULL,
    RefType_environnement TINYINT NOT NULL,
    RefFinance INT NOT NULL,
    PRIMARY KEY (ID_Musee),
    FOREIGN KEY (RefType_musee) REFERENCES type_musee (ID_Type),
    FOREIGN KEY (RefInstitution) REFERENCES institution (ID_Institution),
    FOREIGN KEY (RefVille) REFERENCES ville (ID_Ville),
    FOREIGN KEY (RefType_environnement) REFERENCES type_environnement (ID_environnement),
    FOREIGN KEY (RefFinance) REFERENCES finance (Employer_ID)
);