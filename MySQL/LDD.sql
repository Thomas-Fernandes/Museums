CREATE DATABASE IF NOT EXISTS Musees;

USE Musees;

CREATE TABLE IF NOT EXISTS type (
    ID_Type INT NOT NULL AUTO_INCREMENT,
    Type_Musee VARCHAR(100) NOT NULL,
    PRIMARY KEY (ID_Type)
);

CREATE TABLE IF NOT EXISTS institution (
    ID_Institution INT NOT NULL AUTO_INCREMENT,
    Nom_Institution VARCHAR(100),
    PRIMARY KEY (ID_Institution)
);

CREATE TABLE IF NOT EXISTS localecode_nces (
    ID_Locale INT NOT NULL AUTO_INCREMENT,
    Nom_locale VARCHAR(10) NOT NULL,
    PRIMARY KEY (ID_Locale)
);

CREATE TABLE IF NOT EXISTS regioncode_aam (
    ID_Region INT NOT NULL AUTO_INCREMENT,
    Nom VARCHAR(255) NOT NULL,
    PRIMARY KEY (ID_Region)
);

CREATE TABLE IF NOT EXISTS statecode_fips (
    ID_State INT NOT NULL AUTO_INCREMENT,
    Nom VARCHAR(255) NOT NULL,
    RefRegion INT NOT NULL,
    PRIMARY KEY (ID_State),
    FOREIGN KEY (RefRegion) REFERENCES regioncode_aam (ID_Region)
);

CREATE TABLE IF NOT EXISTS ville (
    ID_ZipCode INT NOT NULL,
    Nom VARCHAR(255) NOT NULL,
    RefState INT NOT NULL,
    PRIMARY KEY (ID_ZipCode),
    FOREIGN KEY (RefState) REFERENCES statecode_fips (ID_State)
);

CREATE TABLE IF NOT EXISTS musee (
    ID_Musee INT NOT NULL AUTO_INCREMENT,
    Nom VARCHAR(255) NOT NULL,
    PhoneNumber INT,
    Address VARCHAR(255),
    Latitude FLOAT,
    Longitude FLOAT,
    Employer_ID INT,
    Tax_Period DATE,
    Income FLOAT,
    Revenue FLOAT,
    RefType INT NOT NULL,
    RefInstitution INT NOT NULL,
    RefVille INT NOT NULL,
    RefLocale INT NOT NULL,
    PRIMARY KEY (ID_Musee),
    FOREIGN KEY (RefType) REFERENCES type (ID_Type),
    FOREIGN KEY (RefInstitution) REFERENCES institution (ID_Institution),
    FOREIGN KEY (RefVille) REFERENCES ville (ID_ZipCode),
    FOREIGN KEY (RefLocale) REFERENCES localecode_nces (ID_Locale)
);