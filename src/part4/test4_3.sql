DROP VIEW IF EXISTS part4_3;

CREATE VIEW PART4_3 
	AS
	SELECT *
	FROM
	    information_schema.triggers
	WHERE
	    trigger_schema = 'public'
	    AND event_object_schema =
'PUBLIC'; 

SELECT get_drop_all_dml_triggers();