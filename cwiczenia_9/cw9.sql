CREATE TABLE south_wales AS
SELECT ST_Union(rast) AS rast
FROM public."Exports";

SELECT *
FROM south_wales;
