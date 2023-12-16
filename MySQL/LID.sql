# Requêtes LID de base

# 1. Liste des types de musées
SELECT * FROM type_musee;

# 2. Noms des institutions
SELECT Nom_Institution FROM institution;

# 3. Régions et etats correspondants
SELECT Nom_Region, Nom_Etat FROM region
INNER JOIN etat ON region.ID_Region = etat.RefRegion;

# 4. Tous les musées du Mississippi
SELECT Nom_Musee FROM musee
JOIN zip_code ON musee.RefZip_Code = zip_code.ID_Zip_Code
JOIN ville ON zip_code.RefVille = ville.ID_Ville
JOIN etat ON ville.RefEtat = etat.ID_Etat
WHERE etat.Nom_Etat = 'Mississippi';

# 5. Musées qui ne font pas de bénéfices
EXPLAIN SELECT m.Nom_Musee, f.Benefice
FROM musee m
INNER JOIN finance f ON m.RefEmployeur = f.RefEmployeur
WHERE f.Benefice = 0;



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



-- Requêtes de synthèse

-- 1. Répartition des types de musées
SELECT tm.Nom_Type, COUNT(*) AS Nombre_Musees
FROM musee m
INNER JOIN type_musee tm ON m.RefType_Musee = tm.ID_Type
GROUP BY tm.Nom_Type;

-- 2. Types de musées les plus représentées par type_environnement
SELECT Nom_Environnement, Nom_Type, Nombre_Musees
FROM (
    SELECT te.Nom_Environnement, tm.Nom_Type, COUNT(*) AS Nombre_Musees,
        ROW_NUMBER() OVER (PARTITION BY te.Nom_Environnement ORDER BY COUNT(*) DESC) as rn
    FROM musee m
    INNER JOIN type_musee tm ON m.RefType_Musee = tm.ID_Type
    INNER JOIN type_environnement te ON m.RefType_Environnement = te.ID_Environnement
    GROUP BY te.Nom_Environnement, tm.Nom_Type
) AS subquery
WHERE rn = 1;

# 3. Employeur ayant le plus gros chiffre d affaires et combien de musées il possède
SELECT e.ID_Employeur, e.Nom_Employeur,
	   f.Chiffre_Affaires AS Chiffre_Affaires, COUNT(m.ID_Musee) AS Nombre_Musees
FROM employeur e
INNER JOIN finance f ON e.ID_Employeur = f.RefEmployeur
LEFT JOIN musee m ON e.ID_Employeur = m.RefEmployeur
GROUP BY e.ID_Employeur, e.Nom_Employeur, f.Chiffre_Affaires
ORDER BY Chiffre_Affaires DESC
LIMIT 5;

# 4. Classement des institutions par nombre de musées
SELECT i.Nom_Institution, COUNT(m.ID_Musee) AS Nombre_Musees
FROM musee m
INNER JOIN institution i ON m.RefInstitution = i.ID_Institution
GROUP BY i.ID_Institution, i.Nom_Institution
ORDER BY Nombre_Musees DESC;

# 5. Nombre de musées par Ville
SELECT ville.Nom, COUNT(musee.ID_Musee) AS NombreDeMusees
FROM musee
INNER JOIN zip_code ON musee.RefZip_Code = zip_code.ID_Zip_Code
INNER JOIN ville ON zip_code.RefVille = ville.ID_Ville
GROUP BY ville.Nom
ORDER BY NombreDeMusees DESC;

# 6. Nombre de musées par Etat
SELECT etat.Nom_Etat, COUNT(musee.ID_Musee) AS NombreDeMusees
FROM musee
INNER JOIN zip_code ON musee.RefZip_Code = zip_code.ID_Zip_Code
INNER JOIN ville ON zip_code.RefVille = ville.ID_Ville
INNER JOIN etat ON ville.RefEtat = etat.ID_Etat
GROUP BY etat.Nom_Etat
ORDER BY NombreDeMusees DESC;

# 7. Nombre de musées par région
SELECT region.Nom_Region, COUNT(musee.ID_Musee) AS NombreDeMusees
FROM musee
INNER JOIN zip_code ON musee.RefZip_Code = zip_code.ID_Zip_Code
INNER JOIN ville ON zip_code.RefVille = ville.ID_Ville
INNER JOIN etat ON ville.RefEtat = etat.ID_Etat
INNER JOIN region ON etat.RefRegion = region.ID_Region
GROUP BY region.Nom_Region
ORDER BY NombreDeMusees DESC;

-- 8. Moyenne des chiffres d'affaires par type de musée
SELECT tm.Nom_Type, AVG(f.Chiffre_Affaires) AS Moyenne_Chiffre_Affaires
FROM musee m
INNER JOIN type_musee tm ON m.RefType_Musee = tm.ID_Type
INNER JOIN finance f ON m.RefEmployeur = f.RefEmployeur
GROUP BY tm.Nom_Type;

-- 9. Taux d'évolution des bénéfices par rapport à l'année précédente
WITH BeneficeParAnnee AS (
    SELECT YEAR(Tax_Period) AS Annee,
           AVG(Benefice) AS BeneficeMoyen
    FROM finance
    GROUP BY Annee
    ORDER BY Annee
),
TauxEvolution AS (
    SELECT a1.Annee AS AnneeActuelle,
           a1.BeneficeMoyen AS BeneficeActuel,
           a2.Annee AS AnneePrecedente,
           a2.BeneficeMoyen AS BeneficePrecedent
    FROM BeneficeParAnnee a1
    LEFT JOIN BeneficeParAnnee a2 ON a1.Annee = a2.Annee + 1
)
SELECT 
    AnneeActuelle,
    BeneficeActuel,
    AnneePrecedente,
    BeneficePrecedent,
    CASE 
        WHEN BeneficePrecedent IS NOT NULL AND BeneficePrecedent <> 0 THEN
            ((BeneficeActuel - BeneficePrecedent) / BeneficePrecedent) * 100
        ELSE NULL
    END AS TauxEvolution
FROM TauxEvolution
ORDER BY AnneeActuelle;

-- 10. Répartition de la santé financière des musées
WITH ClassementMusees AS (
    SELECT Nom_Musee, Benefice,
        CASE
            WHEN Benefice < 0 THEN 'Déficit'
            WHEN Benefice = 0 THEN 'Équilibre'
            WHEN Benefice > 0 THEN 'Bénéfice'
        END AS Statut_Benefice
    FROM musee m
    INNER JOIN finance f ON m.RefEmployeur = f.RefEmployeur
    WHERE Benefice IS NOT NULL
)
SELECT Statut_Benefice, COUNT(*) AS Nombre_Musees
FROM ClassementMusees
GROUP BY Statut_Benefice;

-- 11. Distance moyenne de chaque type de musée depuis Baton Rouge (30.4493218 -91.1813374)
CREATE VIEW DistanceMoyenneBatonRouge AS
SELECT
    tm.Nom_Type AS Type_Musee,
    m.Nom_Musee AS Nom_Musee,
    te.Nom_Environnement AS Environnement,
    ROUND(
        1609.344 * 3959 * ACOS(
            COS(RADIANS(30.4493218)) * COS(RADIANS(m.Latitude)) * COS(RADIANS(m.Longitude) - RADIANS(-91.1813374)) +
            SIN(RADIANS(30.4493218)) * SIN(RADIANS(m.Latitude))
        ),
        2
    ) AS Distance_en_metres
FROM
    musee m
INNER JOIN
    type_musee tm ON m.RefType_Musee = tm.ID_Type
INNER JOIN
    type_environnement te ON m.RefType_Environnement = te.ID_Environnement
WHERE
    m.Latitude IS NOT NULL
    AND m.Longitude IS NOT NULL;

-- 12. Distance la plus proche par type de musée depuis Baton Rouge
SELECT Type_Musee, Nom_Musee, Environnement, Distance_en_metres
FROM (
    SELECT
        Type_Musee,
        Nom_Musee,
        Environnement,
        Distance_en_metres,
        ROW_NUMBER() OVER (PARTITION BY Type_Musee ORDER BY Distance_en_metres) AS RowNum
    FROM DistanceMoyenneBatonRouge
) AS MuseesLesPlusProches
WHERE RowNum = 1;

-- 13. Distance moyenne de chaque musée par rapport à Lafayette (30.2240897 -92.0198427)
CREATE VIEW DistanceMoyenneLafayette AS
SELECT
    m.Nom_Musee AS Nom_Musee,
    ROUND(
        AVG(
            1609.344 * 3959 * ACOS(
                COS(RADIANS(m.Latitude)) * COS(RADIANS(30.2240897)) * COS(RADIANS(m.Longitude) - RADIANS(-92.0198427)) +
                SIN(RADIANS(m.Latitude)) * SIN(RADIANS(30.2240897))
            )
        ),
        2
    ) AS DistanceMoyenne_en_metres
FROM
    musee m
WHERE
    m.Latitude IS NOT NULL
    AND m.Longitude IS NOT NULL
GROUP BY
    m.Nom_Musee;

-- 14. Musée de chaque type qui minimise la distance depuis les deux villes
WITH MuseesAvecClassement AS (
    SELECT
        db.Type_Musee,
        db.Nom_Musee,
        db.Environnement,
        db.Distance_en_metres AS Distance_BatonRouge,
        dl.DistanceMoyenne_en_metres AS Distance_Lafayette,
        RANK() OVER (PARTITION BY db.Type_Musee ORDER BY db.Distance_en_metres + dl.DistanceMoyenne_en_metres) AS Classement
    FROM
        DistanceMoyenneBatonRouge db
    INNER JOIN
        DistanceMoyenneLafayette dl ON db.Nom_Musee = dl.Nom_Musee
)
SELECT
    Type_Musee,
    Nom_Musee,
    Environnement,
    Distance_BatonRouge,
    Distance_Lafayette
FROM MuseesAvecClassement
WHERE Classement = 1;