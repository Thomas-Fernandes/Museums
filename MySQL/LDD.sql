CREATE DATABASE Musees;

USE Musees;

CREATE TABLE institution (
    ID_Institution INT NOT NULL AUTO_INCREMENT,
    NomInstitution VARCHAR(100),
    PRIMARY KEY (ID_Institution)
);

CREATE TABLE type (
    ID_Type INT NOT NULL AUTO_INCREMENT,
    TypeMusee VARCHAR(100) NOT NULL,
    PRIMARY KEY (ID_Type)
);

CREATE TABLE finances (
    ID_Finance INT NOT NULL AUTO_INCREMENT,
    TaxPeriod VARCHAR(255),
    Income DOUBLE,
    Revenue DOUBLE,
    PRIMARY KEY (ID_Finance)
);

CREATE TABLE musee (
    ID_Musee INT NOT NULL AUTO_INCREMENT,
    LegalName VARCHAR(255) NOT NULL,
    AlternateName VARCHAR(255),
    PhoneNumber INT,
    Address VARCHAR(255),
    RefFinances INT NOT NULL,
    RefInstitution INT NOT NULL,
    RefType INT NOT NULL,
    PRIMARY KEY (ID_Musee),
    FOREIGN KEY (RefFinances) REFERENCES finances (ID_Finance),
    FOREIGN KEY (RefInstitution) REFERENCES institution (ID_Institution),
    FOREIGN KEY (RefType) REFERENCES type (ID_Type)
);

CREATE TABLE ville (
    ID_ZipCode INT NOT NULL,
    Nom VARCHAR(255) NOT NULL,
    PRIMARY KEY (ID_ZipCode)
);

CREATE TABLE localecode_nces (
    ID_Locale INT NOT NULL AUTO_INCREMENT,
    Nom VARCHAR(255) NOT NULL,
    PRIMARY KEY (ID_Locale)
);

CREATE TABLE countycode_fips (
    ID_County INT NOT NULL AUTO_INCREMENT,
    Nom VARCHAR(255) NOT NULL,
    PRIMARY KEY (ID_County)
);

CREATE TABLE statecode_fips (
    ID_State INT NOT NULL AUTO_INCREMENT,
    Nom VARCHAR(255) NOT NULL,
    PRIMARY KEY (ID_State)
);

CREATE TABLE regioncode_aam (
    ID_Region INT NOT NULL AUTO_INCREMENT,
    Nom VARCHAR(255) NOT NULL,
    PRIMARY KEY (ID_Region)
);

CREATE TABLE geocodes (
    RefMusee INT NOT NULL,
    RefCity INT NOT NULL,
    RefLocale INT NOT NULL,
    RefCounty INT NOT NULL,
    RefState INT NOT NULL,
    RefRegion INT NOT NULL,
    Latitude DECIMAL(10,2),
    Longitude DECIMAL(10,2),
    FOREIGN KEY (RefMusee) REFERENCES musee (ID_Musee),
    FOREIGN KEY (RefCity) REFERENCES ville (ID_ZipCode),
    FOREIGN KEY (RefLocale) REFERENCES localecode_nces (ID_Locale),
    FOREIGN KEY (RefCounty) REFERENCES countycode_fips (ID_County),
    FOREIGN KEY (RefState) REFERENCES statecode_fips (ID_State),
    FOREIGN KEY (RefRegion) REFERENCES regioncode_aam (ID_Region)
);
