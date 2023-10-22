CREATE EXTENSION postgis;

--zad 4.

CREATE TABLE tableB AS
SELECT p.gid, p.cat, p.f_codedesc, p.f_code, p.type, p.geom
FROM popp AS p, rivers AS r
WHERE p.f_codedesc = 'Building' AND (ST_Distance(p.geom, r.geom) < 1000);

SELECT COUNT(CASE WHEN (ST_Distance(popp.geom, rivers.geom) < 1000) THEN 1 END)
FROM popp, rivers
WHERE popp.f_codedesc = 'Building';

--zad 5.

CREATE TABLE airportsNew AS
SELECT name, elev, geom
FROM airports;

--a)

SELECT name, elev, geom, ST_Y(geom) AS wsp_Y		--wschód
FROM airportsNew
ORDER BY wsp_Y DESC
LIMIT 1;

SELECT name, elev, geom, ST_Y(geom) AS wsp_Y		--zachód
FROM airportsNew
ORDER BY wsp_Y ASC
LIMIT 1;

--b)

INSERT INTO airportsNew 
VALUES
('airportB', 50, ST_Centroid(ST_MakeLine((SELECT geom FROM airportsNew WHERE name='NOATAK'), (SELECT geom FROM airportsNew WHERE name='NIKOLSKI AS'))))

--zad 6.

SELECT ST_Area(ST_Buffer(ST_ShortestLine(lakes.geom, airportsNew.geom), 1000)) AS pole
FROM lakes, airportsNew
WHERE lakes.names = 'Iliamna Lake' AND airportsNew.name = 'AMBLER';

--zad 7.

SELECT SUM(ST_Area(t.geom))
FROM trees AS t, swamp AS s, tundra AS td
WHERE ST_Contains(t.geom, s.geom) OR ST_Contains(t.geom, td.geom);












