# 1. Répartition des types de musées
SELECT tm.Nom_Type, COUNT(*) AS Nombre_Musees
FROM musee m
INNER JOIN type_musee tm ON m.RefType_Musee = tm.ID_Type
GROUP BY tm.Nom_Type;

# 2. Types de musées les plus représentées par type_environnement
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
