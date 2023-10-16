CREATE EXTENSION postgis;

CREATE TABLE budynki(
	id int,
	geometria geometry,
	nazwa varchar(30)
);

CREATE TABLE drogi(
	id int,
	geometria geometry,
	nazwa varchar(30)
);

CREATE TABLE punkty_informacyjne(
	id int,
	geometria geometry,
	nazwa varchar(30)
);

INSERT INTO budynki 
VALUES
(1, ST_GeomFromText('POLYGON((8 1.5,10.5 1.5,10.5 4,8 4,8 1.5))', -1), 'BuildingA'),
(2, ST_GeomFromText('POLYGON((4 5,6 5,6 7,4 7, 4 5))', -1), 'BuildingB'),
(3, ST_GeomFromText('POLYGON((3 6,5 6,5 8,3 8, 3 6))', -1), 'BuildingC'),
(4, ST_GeomFromText('POLYGON((9 8,10 8,10 9,9 9, 9 8))', -1), 'BuildingD'),
(5, ST_GeomFromText('POLYGON((1 1,2 1,2 2,1 2, 1 1))', -1), 'BuildingF');

SELECT * 
FROM budynki;

INSERT INTO punkty_informacyjne 
VALUES
(1, ST_GeomFromText('POINT(1 3.5)', -1), 'G'),
(2, ST_GeomFromText('POINT(5.5 1.5)', -1), 'H'),
(3, ST_GeomFromText('POINT(9.5 6)', -1), 'I'),
(4, ST_GeomFromText('POINT(6.5 6)', -1), 'J'),
(5, ST_GeomFromText('POINT(6 9.5)', -1), 'K');

SELECT * 
FROM punkty_informacyjne;

INSERT INTO drogi 
VALUES
(1, ST_GeomFromText('LINESTRING(0 4.5, 12 4.5)', -1), 'RoadX'),
(2, ST_GeomFromText('LINESTRING(7.5 10.5, 7.5 0)', -1), 'RoadY');

SELECT * 
FROM drogi;

--zad.6
--a

SELECT ST_Length(ST_Collect(ARRAY(SELECT geometria FROM drogi;)));

--b

SELECT ST_AsEWKT(geometria) AS geometria_WKT, ST_Area(geometria) AS pole_pow, ST_Perimeter(geometria) AS obwod 
FROM budynki
WHERE nazwa = 'BuildingA';

--c

SELECT nazwa, ST_Area(geometria) AS pole_pow  
FROM budynki
ORDER BY nazwa ASC;

--d

WITH temp_table (nazwa, obwod, pole_pow) AS										--CTE
(SELECT nazwa, ST_Perimeter(geometria) AS obwod, ST_Area(geometria) AS pole_pow
FROM budynki)

SELECT nazwa, obwod
FROM temp_table
ORDER BY pole_pow DESC
LIMIT 2;

--e

SELECT ST_Distance(budynki.geometria, punkty_informacyjne.geometria) AS distance
FROM budynki, punkty_informacyjne
WHERE budynki.nazwa = 'BuildingC' AND punkty_informacyjne.nazwa = 'G';

--f

SELECT ST_Area(ST_Difference((SELECT geometria FROM budynki WHERE budynki.nazwa = 'BuildingC'), ST_Buffer((SELECT geometria FROM budynki WHERE budynki.nazwa = 'BuildingB'), 0.5))) AS pole_pow
FROM budynki
LIMIT 1;

--e

SELECT id, nazwa, geometria
FROM budynki
WHERE ST_Y(ST_Centroid(geometria)) > ST_Y(ST_AsText(ST_PointN((SELECT geometria FROM drogi WHERE nazwa = 'RoadX'), 2)));


--zad.8
 
SELECT ST_Area(ST_Union((SELECT geometria FROM budynki WHERE nazwa = 'BuildingC'), 'POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')) - ST_Area(ST_Intersection((SELECT geometria FROM budynki WHERE nazwa = 'BuildingC'), 'POLYGON((4 7, 6 7, 6 8, 4 8, 4 7))')) AS pole_pow




































