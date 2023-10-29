CREATE EXTENSION postgis;

--zad 1.
CREATE VIEW wyremontowane_budynki AS
SELECT t8.name AS b_2018_name, t8.polygon_id AS b_2018_polygon_id, t8.geom AS b_2018_geom, t9.name AS b_2019_name, t9.polygon_id AS b_2019_polygon_id, t9.geom AS b_2019_geom
FROM t2018_kar_buildings AS t8
RIGHT JOIN t2019_kar_buildings AS t9 ON t8.gid = t9.gid
WHERE NOT t8.geom = t9.geom OR t8.gid IS NULL;

SELECT DISTINCT b_2019_polygon_id
FROM wyremontowane_budynki;

--zad 2.
WITH nowe_punkty AS
(SELECT t9.geom AS p_2019_geom, t9.poi_id AS p_2019_poi_id, t9.type AS p_2019_type
FROM t2018_kar_poi_table AS t8
RIGHT JOIN t2019_kar_poi_table AS t9 ON t8.gid = t9.gid
WHERE t8.gid IS NULL)


SELECT DISTINCT p_2019_poi_id
FROM nowe_punkty AS np, wyremontowane_budynki AS wb
WHERE ST_DWithin(wb.b_2019_geom, np.p_2019_geom, 500);

--zad 3.
CREATE TABLE streets_reprojected AS 
SELECT gid, link_id, st_name, ref_in_id, nref_in_id, func_class, speed_cat, fr_speed_l, to_speed_l, dir_travel, ST_Transform(geom, 3068) AS geom_t
FROM t2019_kar_streets;

SELECT * FROM streets_reprojected;

--zad 4.
CREATE TABLE input_points (
	points geometry
);

INSERT INTO input_points VALUES
(ST_Point( 8.36093, 49.03174, 4326)),
(ST_Point( 8.39876, 49.00644, 4326));

--zad 5.
UPDATE input_points
SET points = ST_Transform(points, 3068);


SELECT ST_AsText(points)
FROM input_points;

--zad 6.
WITH street_nodes_reprojected AS
(SELECT gid, node_id, link_id, point_num, z_level, t2019_kar_street_node.intersect, lat, lon, ST_Transform(geom, 3068) AS geom_t
FROM t2019_kar_street_node)
 
SELECT DISTINCT gid, geom_t
FROM street_nodes_reprojected AS snr, input_points 
WHERE ST_DWithin(ST_MakeLine(ARRAY(SELECT points FROM input_points)), snr.geom_t, 200); 
 
--zad 7.
SELECT COUNT(CASE WHEN ST_DWithin(kpt.geom, (SELECT ST_Union(geom) FROM t2019_kar_land_use_a WHERE type = 'Park (City/County)'), 300, true) THEN 1 END)
FROM t2019_kar_poi_table AS kpt
WHERE kpt.type = 'Sporting Goods Store';

--zad 8.
CREATE TABLE T2019_KAR_BRIDGES AS
SELECT ST_Intersection(kr.geom, kwl.geom) AS inters
FROM t2019_kar_water_lines AS kwl, t2019_kar_railways AS kr;







