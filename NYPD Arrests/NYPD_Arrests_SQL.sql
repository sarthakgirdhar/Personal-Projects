SELECT * FROM NEWYORKPOLICEDEPARTMENT.ARRESTSRAWDATA.NYPD_ARRESTS
LIMIT 5;

SELECT COUNT(*) FROM NEWYORKPOLICEDEPARTMENT.ARRESTSRAWDATA.NYPD_ARRESTS;

/* Which boroughs witness the most number of arrests? */
SELECT "arrest_boro", COUNT("arrest_boro") AS "Number of Arrests"
FROM NYPD_ARRESTS
GROUP BY "arrest_boro"
ORDER BY "Number of Arrests" DESC;

/* Which months see the most number of arrests? */
SELECT MONTHNAME("arrest_date") as "Month", COUNT(date_part(month, "arrest_date")) as "Number of Arrests"
FROM NYPD_ARRESTS
GROUP BY "Month"
ORDER BY "Number of Arrests" DESC;

/* Does New York City have more serious crimes (like, felonies) or less serious ones (like, misdemeanors & violations)? */
-- F (Felony) > M (Misdemeanor)> V (Violation)
SELECT "law_cat_cd" AS "Violation type", COUNT("law_cat_cd") AS "Count of Violation"
FROM NYPD_ARRESTS
GROUP BY "Violation type"
ORDER BY "Count of Violation" DESC;
/* Misdemeanors happen the most, followed by serious crimes/felonies. Violations are less than 1500. */

/* What kind of crimes are committed by less than 18 years old? */
SELECT "law_cat_cd" AS "Violation type", COUNT("law_cat_cd") AS "Count of Violation"
FROM NYPD_ARRESTS
WHERE "age_group" = '<18'
GROUP BY "Violation type"
ORDER BY "Count of Violation" DESC;
/* Minors (less than 18 year olds) are committing more felonies (more than 2.5 times as misdemeanors). 
Something to worry about :( */

/* Felony vs Misdemeanor comparison for all age groups */
SELECT "age_group", 
        COUNT(CASE WHEN "law_cat_cd" = 'F' THEN 1 END) AS "Number of felonies", 
        COUNT(CASE WHEN "law_cat_cd" = 'M' THEN 1 END) AS"Number of misdemeanors"
FROM NYPD_ARRESTS
GROUP BY "age_group"
ORDER BY 2,3 DESC;
/* Minors (less than 18 year olds) is the only age group that has more felonies than misdemeanors. 
This is very concerning. */
