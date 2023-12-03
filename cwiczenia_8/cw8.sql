CREATE EXTENSION postgis;
CREATE EXTENSION postgis_raster;

--zad 2.

CREATE TABLE uk_250k (
	id SERIAL,
	rast raster
);

-- raster2pgsql.exe -s 4277 -N -32767 -t 100x100 -I -C -M -d "C:\Users\franekb1111\OneDrive\Pulpit\Bazy danych przestrzennych\cwiczenia_8\data\*.tif" public.uk_250k 
-- | psql.exe -d zajecia_8 -h localhost -U postgres -p 5432

SELECT * FROM uk_250k;

CREATE INDEX idx_uk_250k_rast_gist ON public.uk_250k
USING gist (ST_ConvexHull(rast));

SELECT AddRasterConstraints('public'::name,
'uk_250k'::name,'rast'::name);


--zad 3.

CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM public.uk_250k;
----------------------------------------------
SELECT lo_export(loid, 'D:\PostgreSQL\uk_250k.tiff') --> Save the file in a place
FROM tmp_out;
----------------------------------------------
SELECT lo_unlink(loid)
FROM tmp_out; --> Delete the large object.

CREATE TABLE uk_250k_mosaic AS 
SELECT ST_Union(rast) AS rast
FROM uk_250k;


--COPY uk_250k TO 'D:\PostgreSQL\uk_250k.csv' WITH (FORMAT CSV, HEADER);


--ogr2ogr.exe -f PostgreSQL "PG:user=postgres password=dziekanwms dbname=zajecia_8" D:\OS_Open_Zoomstack.gpkg w konsoli OSGeo4W Shell

--zad6.

CREATE TABLE uk_lake_district AS
SELECT ST_Clip(u.rast, ST_SetSRID(n.geom,4277), true) AS rast
FROM uk_250k AS u, national_parks AS n
WHERE ST_Intersects(u.rast, ST_SetSRID(n.geom,4277));

SELECT * FROM uk_lake_district;

CREATE TABLE tmp_out AS
SELECT lo_from_bytea(0,
ST_AsGDALRaster(ST_Union(rast), 'GTiff', ARRAY['COMPRESS=DEFLATE',
'PREDICTOR=2', 'PZLEVEL=9'])
) AS loid
FROM uk_lake_district;
----------------------------------------------
SELECT lo_export(loid, 'D:\PostgreSQL\parki.tiff') --> Save the file in a place
FROM tmp_out;
----------------------------------------------
SELECT lo_unlink(loid)
FROM tmp_out; --> Delete the large object.

COPY (SELECT ST_AsGDALRaster(ST_Union(rast), 'GTiff') FROM uk_lake_district) TO 'D:\PostgreSQL\uk_lake.tiff';


--zad 9.

CREATE TABLE sentinel_band_3 (
	id SERIAL,
	rast raster
);


CREATE TABLE sentinel_band_8 (
	id SERIAL,
	rast raster
);


--zad 10.

CREATE TABLE ndvi AS
WITH r3_c AS (
(SELECT ST_Union(ST_Clip(ST_SetBandNodataValue(r3.rast, NULL), ST_Transform(n.geom, 3857), true)) AS rast
            FROM sentinel_band_3 AS r3, national_parks AS n
            WHERE ST_Intersects(r3.rast, ST_SetSRID(n.geom, 3857))))
,r8_c AS (
(SELECT ST_Union(ST_Clip(ST_SetBandNodataValue(r8.rast, NULL), ST_Transform(n.geom, 3857), true)) AS rast
    FROM sentinel_band_8 AS r8, national_parks AS n
    WHERE ST_Intersects(r8.rast, ST_Transform(n.geom, 3857))))
SELECT ST_MapAlgebra(r3_c.rast, r8_c.rast, '([rast1.val]-[rast2.val])/([rast1.val]+[rast2.val])::float', '32BF') AS rast
FROM r3_c, r8_c;

COPY (SELECT ST_AsGDALRaster(rast, 'GTiff') FROM ndvi) TO 'D:\PostgreSQL\ndvi.tiff';

-- raster2pgsql.exe -N -32767 -t 100x100 -I -C -M -d "C:\Users\franekb1111\OneDrive\Pulpit\Bazy danych przestrzennych\cwiczenia_8\data_sent\*B03_(Raw).tiff" public.sentinel_band_3 
-- | psql.exe -d zajecia_8 -h localhost -U postgres -p 5432

























