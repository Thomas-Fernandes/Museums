-- Ajouter des lignes dans la base

-- 1. Ajout d'un nouveau type de musée
INSERT INTO type_musee (Nom_Type) VALUES ('INTERACTIVE AND EXPERIENCE-BASED');

-- 2. Ajout d'un nouveau musée
INSERT INTO musee (
    ID_Musee, 
    Nom_Musee, 
    Telephone, 
    Adresse, 
    Latitude, 
    Longitude, 
    RefType_Musee, 
    RefInstitution, 
    RefZip_Code, 
    RefType_Environnement, 
    RefEmployeur
) VALUES (
    8409504385,
    'Musée intéractif municipal de Baton Rouge',
    1234567890,
    '1399 River Road',
    30.4359398,
    -91.1952359,
    (SELECT ID_Type FROM type_musee WHERE Nom_Type LIKE '%ZOO%'),
    (SELECT ID_Institution FROM institution WHERE Nom_Institution = 'CENTENARY COLLEGE OF LOUISIANA'),
    70802,
    (SELECT ID_Environnement FROM type_environnement WHERE Nom_Environnement = 'City'),
    720408915
);

-- Requêtes de mise à jour

-- 1. Rachat d'un musée par une institution
UPDATE musee
SET RefInstitution = (
    SELECT ID_Institution
    FROM institution
    WHERE Nom_Institution = 'CENTENARY COLLEGE OF LOUISIANA'
)
WHERE RefZip_Code IN (
    SELECT z.ID_Zip_Code
    FROM zip_code z
    INNER JOIN ville v ON z.RefVille = v.ID_Ville
    INNER JOIN etat e ON v.RefEtat = e.ID_Etat
    WHERE v.Nom = 'Baton Rouge' AND e.Nom_Etat = 'Louisiana'
);

-- 2. Fusion des villes de Baton Rouge et de Port Allen
INSERT INTO zip_code (ID_Zip_Code, RefVille)
VALUES (70899, (SELECT ID_Ville FROM ville WHERE Nom = 'Port Allen'));

UPDATE musee
SET RefZip_Code = 70899
WHERE RefZip_Code IN (
    SELECT ID_Zip_Code
    FROM zip_code
    WHERE RefVille = (SELECT ID_Ville FROM ville WHERE Nom = 'Port Allen')
);

-- 3. Un musée change de numéro de téléphone
UPDATE musee
SET Telephone = '2524220673'
WHERE Nom_Musee = 'THREE NOTCH MUSEUM';

-- 4. Le JUDSON COLLEGE ferme et tous ses musées ferment avec
DELETE FROM musee WHERE RefInstitution IN (SELECT ID_Institution FROM institution WHERE Nom_Institution = 'JUDSON COLLEGE');

DELETE FROM institution WHERE Nom_Institution = 'JUDSON COLLEGE';
