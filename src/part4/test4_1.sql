DROP VIEW IF EXISTS part4_1;

CREATE VIEW PART4_1 
	AS SELECT tablename FROM 
PG_TABLES; 

CALL drop_tables();