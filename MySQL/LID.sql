--
-- Requêtes LID de base
--
-- 1. Sélectionne les types de musées
SELECT * FROM type_musee;

-- 2. Sélectionne le nom des institutions
SELECT Nom_Institution FROM institution;

-- 3. Sélectionne le nom des environnements
SELECT Nom_environnement FROM type_environnement;

-- 4. Sélectionne les musées qui ont ZOO dans leur nom
SELECT Nom_Musee
FROM musee
WHERE Nom_Musee LIKE '%ZOO%';

-- 5. Sélectionne les musées qui n’ont pas de numéro de téléphone
SELECT Nom_Musee
FROM musee
WHERE Telephone IS NULL;

-- 6. Sélectionne les Régions correspondants à chaque Etat
SELECT Nom_Region, Nom_Etat FROM region
INNER JOIN etat ON region.ID_Region = etat.RefRegion;

-- 7. Sélectionne tous les musées du Mississipi (Optimisation avec index)
CREATE INDEX idx_zip_code_refville ON zip_code (RefVille);
CREATE INDEX idx_etat_nom ON etat (Nom_Etat);

SELECT Nom_Musee FROM musee
INNER JOIN zip_code ON musee.RefZip_Code = zip_code.ID_Zip_Code
INNER JOIN ville ON zip_code.RefVille = ville.ID_Ville
INNER JOIN etat ON ville.RefEtat = etat.ID_Etat
WHERE etat.Nom_Etat = 'Mississippi';

-- 8. Sélectionne tous les musées qui ne font pas de bénéfices (Optimisation avec index)
CREATE INDEX idx_musee_refemployeur ON musee (RefEmployeur);
CREATE INDEX idx_finance_refemployeur ON finance (RefEmployeur);
CREATE INDEX idx_finance_benefice ON finance (Benefice);

SELECT m.Nom_Musee, f.Benefice
FROM musee m
INNER JOIN finance f ON m.RefEmployeur = f.RefEmployeur
WHERE f.Benefice = 0;

-- 9. Sélectionne les musées qui ont renseigné leurs données fiscales en 2014 ou 2015 en Louisiane
SELECT m.Nom_Musee
FROM musee m
INNER JOIN zip_code z ON m.RefZip_Code = z.ID_Zip_Code
INNER JOIN ville v ON z.RefVille = v.ID_Ville
INNER JOIN etat e ON v.RefEtat = e.ID_Etat
INNER JOIN finance f ON m.RefEmployeur = f.RefEmployeur
WHERE e.Nom_Etat = 'Louisiana'
AND YEAR(f.Tax_Period) BETWEEN 2014 AND 2015;

-- 10. Sélectionne les musées de la ville de Baton Rouge
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

-- 11. Sélectionne les musées d'Harvard
SELECT m.ID_Musee, m.Nom_Musee FROM musee m
WHERE m.RefInstitution IN (
        SELECT i.ID_Institution FROM institution i
        WHERE i.Nom_Institution LIKE '%HARVARD%'
    );

-- 12. Musées d'art en Louisiane
SELECT m.ID_Musee, m.Nom_Musee FROM musee m
WHERE m.RefType_Musee IN (
        SELECT tm.ID_Type FROM type_musee tm
        WHERE tm.Nom_Type LIKE '%ART%'
    )
    AND m.RefZip_Code IN (
        SELECT zc.ID_Zip_Code FROM zip_code zc
        INNER JOIN ville v ON zc.RefVille = v.ID_Ville
        INNER JOIN etat e ON v.RefEtat = e.ID_Etat
        WHERE e.Nom_Etat = 'LOUISIANA'
    );

--
-- Requêtes de synthèse
--

-- 1. Répartition des types de musées
SELECT tm.Nom_Type, COUNT(*) AS Nombre_Musees
FROM musee m
INNER JOIN type_musee tm ON m.RefType_Musee = tm.ID_Type
GROUP BY tm.Nom_Type;

-- 2. Types de musées les plus représentées par type d’environnement
SELECT Nom_Environnement, Nom_Type, Nombre_Musees
FROM (
    SELECT te.Nom_Environnement, tm.Nom_Type, COUNT(*) AS Nombre_Musees,
        ROW_NUMBER() OVER (PARTITION BY te.Nom_Environnement ORDER BY COUNT(*) DESC) as rn
    FROM musee m
    INNER JOIN type_musee tm ON m.RefType_Musee = tm.ID_Type
    INNER JOIN type_environnement te ON m.RefType_Environnement = te.ID_Environnement
    GROUP BY te.Nom_Environnement, tm.Nom_Type
) AS Sous_requete
WHERE rn = 1;

-- 3. Classement des institutions par nombre de musées
SELECT i.Nom_Institution, COUNT(m.ID_Musee) AS Nombre_Musees
FROM musee m
INNER JOIN institution i ON m.RefInstitution = i.ID_Institution
GROUP BY i.ID_Institution, i.Nom_Institution
ORDER BY Nombre_Musees DESC;

-- 4. Nombre de musées par Ville
SELECT ville.Nom, COUNT(musee.ID_Musee) AS NombreDeMusees
FROM musee
INNER JOIN zip_code ON musee.RefZip_Code = zip_code.ID_Zip_Code
INNER JOIN ville ON zip_code.RefVille = ville.ID_Ville
GROUP BY ville.Nom
ORDER BY NombreDeMusees DESC;

-- 5. Nombre de musées par Etat
SELECT etat.Nom_Etat, COUNT(musee.ID_Musee) AS NombreDeMusees
FROM musee
INNER JOIN zip_code ON musee.RefZip_Code = zip_code.ID_Zip_Code
INNER JOIN ville ON zip_code.RefVille = ville.ID_Ville
INNER JOIN etat ON ville.RefEtat = etat.ID_Etat
GROUP BY etat.Nom_Etat
ORDER BY NombreDeMusees DESC;

-- 6. Nombre de musées par région
SELECT region.Nom_Region, COUNT(musee.ID_Musee) AS NombreDeMusees
FROM musee
INNER JOIN zip_code ON musee.RefZip_Code = zip_code.ID_Zip_Code
INNER JOIN ville ON zip_code.RefVille = ville.ID_Ville
INNER JOIN etat ON ville.RefEtat = etat.ID_Etat
INNER JOIN region ON etat.RefRegion = region.ID_Region
GROUP BY region.Nom_Region
ORDER BY NombreDeMusees DESC;

-- 7. Moyenne des chiffres d'affaires par type de musée
SELECT tm.Nom_Type, AVG(f.Chiffre_Affaires) AS Moyenne_Chiffre_Affaires
FROM musee m
INNER JOIN type_musee tm ON m.RefType_Musee = tm.ID_Type
INNER JOIN finance f ON m.RefEmployeur = f.RefEmployeur
GROUP BY tm.Nom_Type;

-- 8. Top 5 villes ayant le plus de musées dans le Midwest
SELECT v.Nom, COUNT(m.ID_Musee) AS Nombre_De_Musees FROM ville v
INNER JOIN zip_code zc ON v.ID_Ville = zc.RefVille
JOIN musee m ON zc.ID_Zip_Code = m.RefZip_Code
JOIN etat e ON v.RefEtat = e.ID_Etat
JOIN region r ON e.RefRegion = r.ID_Region
WHERE r.Nom_Region = 'Midwest'
GROUP BY v.Nom
ORDER BY Nombre_De_Musees DESC
LIMIT 5;

-- 9. Pourcentage de musées par type d'environnement
SELECT te.Nom_Environnement, COUNT(*) * 100.0 / (SELECT COUNT(*) FROM musee) AS Pourcentage
FROM type_environnement te
JOIN musee m ON te.ID_Environnement = m.RefType_Environnement
GROUP BY te.Nom_Environnement;

-- 10. Les musées les plus éloignés de New York
SELECT m.Nom_Musee, e.Nom_Etat, ROUND(
  6371000 * ACOS(
    COS(RADIANS(40.712784)) * COS(RADIANS(m.Latitude)) * COS(RADIANS(m.Longitude) -
    RADIANS(-74.005941)) + SIN(RADIANS(40.712784)) * SIN(RADIANS(m.Latitude))
  ),
  2
) AS Distance_en_metres FROM musee m
      INNER JOIN zip_code z ON m.Refzip_code = z.ID_Zip_Code 
      INNER JOIN ville v ON z.RefVille = v.ID_Ville 
      INNER JOIN etat e ON v.RefEtat = e.ID_Etat
      ORDER BY Distance_en_metres
      DESC LIMIT 10;

--
-- Requêtes Complexes
--

-- 1. Taux d'évolution des bénéfices par rapport à l'année précédente
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

-- 2. Répartition de la santé financière des musées
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

-- 3. Distance moyenne de chaque musée par rapport à Baton Rouge et Lafayette
CREATE VIEW DistanceMoyenneVilles AS
SELECT tm.Nom_Type AS Type_Musee,
       m.Nom_Musee AS Nom_Musee,
       te.Nom_Environnement AS Environnement,
    ROUND(
        6371000 * ACOS(
            COS(RADIANS(30.4493218)) * COS(RADIANS(m.Latitude)) * COS(RADIANS(m.Longitude) -
            RADIANS(-91.1813374)) + SIN(RADIANS(30.4493218)) * SIN(RADIANS(m.Latitude))
        ),
        2
    ) AS Distance_BatonRouge_en_metres,
    ROUND(
        6371000 * ACOS(
            COS(RADIANS(30.2240897)) * COS(RADIANS(m.Latitude)) * COS(RADIANS(m.Longitude) -
            RADIANS(-92.0198427)) + SIN(RADIANS(30.2240897)) * SIN(RADIANS(m.Latitude))
        ),
        2
    ) AS Distance_Lafayette_en_metres FROM musee m
INNER JOIN type_musee tm ON m.RefType_Musee = tm.ID_Type
INNER JOIN type_environnement te ON m.RefType_Environnement = te.ID_Environnement
WHERE m.Latitude IS NOT NULL AND m.Longitude IS NOT NULL;

-- 4. Musée de chaque type qui minimise la somme des distances depuis les deux villes
SELECT
    Type_Musee,
    Nom_Musee,
    Environnement,
    Distance_BatonRouge_en_metres,
    Distance_Lafayette_en_metres
FROM (
    SELECT *,
        RANK() OVER (PARTITION BY Type_Musee ORDER BY Distance_BatonRouge_en_metres + Distance_Lafayette_en_metres) AS Classement
    FROM DistanceMoyenneVilles
) AS ClassementMusees
WHERE Classement = 1;

-- 5. Sélectionne les musées ainsi que leurs institutions même si ils n'en ont pas
SELECT m.Nom_Musee, i.Nom_Institution
FROM musee m
LEFT JOIN institution i ON m.RefInstitution = i.ID_Institution;

-- 6. Employeur ayant le plus gros chiffre d affaires et combien de musées il possède
SELECT e.ID_Employeur, e.Nom_Employeur, YEAR(f.Tax_Period) AS Annee,
    f.Chiffre_Affaires AS Chiffre_Affaires, COUNT(m.ID_Musee) AS Nombre_Musees
FROM employeur e
INNER JOIN finance f ON e.ID_Employeur = f.RefEmployeur
LEFT JOIN musee m ON e.ID_Employeur = m.RefEmployeur
GROUP BY e.ID_Employeur, e.Nom_Employeur, Annee, f.Chiffre_Affaires
ORDER BY Chiffre_Affaires DESC, Annee DESC
LIMIT 5;