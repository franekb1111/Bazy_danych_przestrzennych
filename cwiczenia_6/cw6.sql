CREATE EXTENSION postgis;

CREATE TABLE obiekty (
	id INT,
	nazwa VARCHAR(10),
	geom GEOMETRY
);

INSERT INTO obiekty VALUES
(1,'obiekt1', ST_GeomFromEWKT('COMPOUNDCURVE((0 1, 1 1),CIRCULARSTRING(1 1, 2 0, 3 1), CIRCULARSTRING(3 1, 4 2, 5 1), (5 1, 6 1))'));

INSERT INTO obiekty VALUES
(2,'obiekt2', ST_GeomFromEWKT('GEOMETRYCOLLECTION(COMPOUNDCURVE((10 6, 14 6),CIRCULARSTRING(14 6, 16 4, 14 2),CIRCULARSTRING(14 2, 12 0, 10 2),(10 2, 10 6)),CIRCULARSTRING(11 2 ,13 2, 11 2))'));

INSERT INTO obiekty VALUES
(3,'obiekt3', ST_GeomFromEWKT('LINESTRING(7 15, 10 17, 12 13, 7 15)'));

INSERT INTO obiekty VALUES
(4,'obiekt4', ST_GeomFromEWKT('LINESTRING(20 20, 25 25, 27 24, 25 22, 26 21, 22 19, 20.5 19.5)'));

INSERT INTO obiekty VALUES
(5,'obiekt5', ST_GeomFromEWKT('MULTIPOINT((30 30 59), (38 32 234))'));

INSERT INTO obiekty VALUES
(6,'obiekt6', ST_GeomFromEWKT('GEOMETRYCOLLECTION(LINESTRING(1 1, 3 2), POINT(4 2))'));

SELECT * 
FROM obiekty
WHERE id = 7;

DELETE FROM obiekty
WHERE id = 6;

--zad 1.

SELECT ST_Area(ST_Buffer(ST_ShortestLine((SELECT geom FROM obiekty WHERE id = 3), (SELECT geom FROM obiekty WHERE id = 4)), 5))

--zad 2.

UPDATE obiekty
SET geom = ST_MakePolygon(ST_AddPoint((SELECT geom FROM obiekty WHERE id = 4), ST_StartPoint((SELECT geom FROM obiekty WHERE id = 4))))
WHERE id = 4;

--zad 3.
INSERT INTO obiekty VALUES
(7, 'obiekt7', (SELECT(ST_Union((SELECT geom FROM obiekty WHERE id = 3), (SELECT geom FROM obiekty WHERE id = 4)))));

--zad 4.

WITH temp AS(
	SELECT ST_HasArc(geom) AS luk, geom
	FROM obiekty 
)
SELECT ST_Area(ST_Buffer(geom , 5))
FROM temp
WHERE luk = FALSE;




