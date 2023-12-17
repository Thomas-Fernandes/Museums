--
-- Requêtes LID de base
--
-- 1. Liste des types de musées
SELECT * FROM type_musee;

-- 2. Noms des institutions
SELECT Nom_Institution FROM institution;

-- 3. Musées qui ont ZOO dans leur nom
SELECT Nom_Musee
FROM musee
WHERE Nom_Musee LIKE '%ZOO%';

-- 4. Régions et etats correspondants
SELECT Nom_Region, Nom_Etat FROM region
INNER JOIN etat ON region.ID_Region = etat.RefRegion;

-- 5. Tous les musées du Mississippi (Optimisation avec index)
CREATE INDEX idx_zip_code_refville ON zip_code (RefVille);
CREATE INDEX idx_etat_nom ON etat (Nom_Etat);

SELECT Nom_Musee FROM musee
INNER JOIN zip_code ON musee.RefZip_Code = zip_code.ID_Zip_Code
INNER JOIN ville ON zip_code.RefVille = ville.ID_Ville
INNER JOIN etat ON ville.RefEtat = etat.ID_Etat
WHERE etat.Nom_Etat = 'Mississippi';

-- 6. Musées qui ne font pas de bénéfices (Optimisation avec index)
CREATE INDEX idx_musee_refemployeur ON musee (RefEmployeur);
CREATE INDEX idx_finance_refemployeur ON finance (RefEmployeur);
CREATE INDEX idx_finance_benefice ON finance (Benefice);

SELECT m.Nom_Musee, f.Benefice
FROM musee m
INNER JOIN finance f ON m.RefEmployeur = f.RefEmployeur
WHERE f.Benefice = 0;

-- 7. Musées qui ont une Tax Period entre 2014 et 2015 en Louisianne
SELECT m.Nom_Musee
FROM musee m
INNER JOIN zip_code z ON m.RefZip_Code = z.ID_Zip_Code
INNER JOIN ville v ON z.RefVille = v.ID_Ville
INNER JOIN etat e ON v.RefEtat = e.ID_Etat
INNER JOIN finance f ON m.RefEmployeur = f.RefEmployeur
WHERE e.Nom_Etat = 'Louisiana'
AND YEAR(f.Tax_Period) BETWEEN 2014 AND 2015;

-- 8. Musées de la ville de Baton Rouge
SELECT Nom_Musee
FROM musee
WHERE RefZip_Code IN (
    SELECT ID_Zip_Code
    FROM zip_code
    WHERE RefVille IN (
        SELECT ID_Ville
        FROM ville
        WHERE Nom = 'Baton Rouge'
    )
);

-- 9. Musées sans données financières en Louisianne pour les années 2014 ou 2015
SELECT m.Nom_Musee
FROM musee m
JOIN zip_code z ON m.RefZip_Code = z.ID_Zip_Code
JOIN ville v ON z.RefVille = v.ID_Ville
JOIN etat e ON v.RefEtat = e.ID_Etat
WHERE m.RefEmployeur NOT IN (
    SELECT f.RefEmployeur
    FROM finance f
    WHERE YEAR(f.Tax_Period) IN (2014, 2015)
)
AND e.Nom_Etat = 'Louisiana';


--
-- Requêtes de synthèse
--

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

-- 3. Employeur ayant le plus gros chiffre d affaires et combien de musées il possède
SELECT e.ID_Employeur, e.Nom_Employeur,
	   f.Chiffre_Affaires AS Chiffre_Affaires, COUNT(m.ID_Musee) AS Nombre_Musees
FROM employeur e
INNER JOIN finance f ON e.ID_Employeur = f.RefEmployeur
LEFT JOIN musee m ON e.ID_Employeur = m.RefEmployeur
GROUP BY e.ID_Employeur, e.Nom_Employeur, f.Chiffre_Affaires
ORDER BY Chiffre_Affaires DESC
LIMIT 5;

-- 4. Classement des institutions par nombre de musées
SELECT i.Nom_Institution, COUNT(m.ID_Musee) AS Nombre_Musees
FROM musee m
INNER JOIN institution i ON m.RefInstitution = i.ID_Institution
GROUP BY i.ID_Institution, i.Nom_Institution
ORDER BY Nombre_Musees DESC;

-- 5. Nombre de musées par Ville
SELECT ville.Nom, COUNT(musee.ID_Musee) AS NombreDeMusees
FROM musee
INNER JOIN zip_code ON musee.RefZip_Code = zip_code.ID_Zip_Code
INNER JOIN ville ON zip_code.RefVille = ville.ID_Ville
GROUP BY ville.Nom
ORDER BY NombreDeMusees DESC;

-- 6. Nombre de musées par Etat
SELECT etat.Nom_Etat, COUNT(musee.ID_Musee) AS NombreDeMusees
FROM musee
INNER JOIN zip_code ON musee.RefZip_Code = zip_code.ID_Zip_Code
INNER JOIN ville ON zip_code.RefVille = ville.ID_Ville
INNER JOIN etat ON ville.RefEtat = etat.ID_Etat
GROUP BY etat.Nom_Etat
ORDER BY NombreDeMusees DESC;

-- 7. Nombre de musées par région
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

-- 11. Distance moyenne de chaque musée par rapport à Baton Rouge et Lafayette
CREATE VIEW DistanceMoyenneVilles AS
SELECT
    tm.Nom_Type AS Type_Musee,
    m.Nom_Musee AS Nom_Musee,
    te.Nom_Environnement AS Environnement,
    ROUND(
        6371000 * ACOS(
            COS(RADIANS(30.4493218)) * COS(RADIANS(m.Latitude)) * COS(RADIANS(m.Longitude) - RADIANS(-91.1813374)) +
            SIN(RADIANS(30.4493218)) * SIN(RADIANS(m.Latitude))
        ),
        2
    ) AS Distance_BatonRouge_en_metres,
    ROUND(
        6371000 * ACOS(
            COS(RADIANS(30.2240897)) * COS(RADIANS(m.Latitude)) * COS(RADIANS(m.Longitude) - RADIANS(-92.0198427)) +
            SIN(RADIANS(30.2240897)) * SIN(RADIANS(m.Latitude))
        ),
        2
    ) AS Distance_Lafayette_en_metres
FROM
    musee m
INNER JOIN
    type_musee tm ON m.RefType_Musee = tm.ID_Type
INNER JOIN
    type_environnement te ON m.RefType_Environnement = te.ID_Environnement
WHERE
    m.Latitude IS NOT NULL
    AND m.Longitude IS NOT NULL;

-- 11. Musée de chaque type qui minimise la somme des distances depuis les deux villes
SELECT
    Type_Musee,
    Nom_Musee,
    Environnement,
    Distance_BatonRouge_en_metres,
    Distance_Lafayette_en_metres
FROM (
    SELECT
        *,
        RANK() OVER (PARTITION BY Type_Musee ORDER BY Distance_BatonRouge_en_metres + Distance_Lafayette_en_metres) AS Classement
    FROM DistanceMoyenneVilles
) AS ClassementMusees
WHERE Classement = 1;
