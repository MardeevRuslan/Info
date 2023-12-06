-- Active: 1686291172146@@127.0.0.1@5435@part4

/*
 1) Создать хранимую процедуру, которая, 
 не уничтожая базу данных, уничтожает все те таблицы текущей базы данных, 
 имена которых начинаются с фразы 'TableName'.
 */

CREATE OR REPLACE PROCEDURE DROP_TABLES() LANGUAGE 
PLPGSQL AS $$ 
	DECLARE table_name TEXT;
	BEGIN FOR table_name IN
	SELECT tablename
	FROM pg_tables
	WHERE
	    schemaname = 'public'
	    AND tablename LIKE 'tablename' || '%' LOOP
	EXECUTE
	    'DROP TABLE IF EXISTS ' || table_name || ' CASCADE;';
	END LOOP;
	END;
$$; 

/*
 2) Создать хранимую процедуру с выходным параметром, которая выводит 
 список имен и параметров всех скалярных SQL функций пользователя в текущей базе данных. 
 Имена функций без параметров не выводить. Имена и список параметров должны выводиться в одну строку. 
 Выходной параметр возвращает количество найденных функций.
 */

CREATE OR REPLACE PROCEDURE GET_USER_FUNCTIONS(OUT 
COUNT_FUNCTIONS INTEGER) LANGUAGE PLPGSQL AS $$ 
	DECLARE func_name text;
	func_args text;
	funcs_list text := '';
	BEGIN count_functions := 0;
	FOR func_name,
	func_args IN
	SELECT
	    f.routine_name,
	    t.parameter_name
	FROM (
	        SELECT *
	        FROM
	            information_schema.routines
	        WHERE
	            routine_schema NOT IN (
	                'pg_catalog',
	                'information_schema'
	            )
	            AND routine_type = 'FUNCTION'
	    ) f
	    JOIN (
	        SELECT
	            specific_name,
	            parameter_name,
	            data_type
	        FROM
	            information_schema.parameters
	        WHERE
	            specific_catalog = current_database()
	            AND specific_schema NOT IN (
	                'pg_catalog',
	                'information_schema'
	            )
	    ) t ON f.specific_name = t.specific_name LOOP funcs_list := funcs_list || ' ' || func_name || ' ' || func_args || ' ';
	count_functions := count_functions + 1;
	END LOOP;
	funcs_list := rtrim(funcs_list);
	RAISE NOTICE '%', funcs_list;
	END;
$$; 

CREATE OR REPLACE FUNCTION GET_COUNT_FUNCTIONS() RETURNS 
INTEGER LANGUAGE PLPGSQL AS $$ 
	DECLARE all_functions INTEGER;
	BEGIN CALL get_user_functions(all_functions);
	RETURN COALESCE(all_functions, 0);
	END;
$$; 

/*
 3) Создать хранимую процедуру с выходным параметром, которая уничтожает 
 все SQL DML триггеры в текущей базе данных.
 Выходной параметр возвращает количество уничтоженных триггеров.
 */

CREATE OR REPLACE PROCEDURE DROP_ALL_DML_TRIGGERS(OUT 
NUM_TRIGGERS INTEGER) LANGUAGE PLPGSQL AS $$ 
	DECLARE my_trigger_name VARCHAR;
	my_table_name VARCHAR;
	BEGIN num_triggers := 0;
	FOR my_trigger_name,
	my_table_name IN
	SELECT
	    trigger_name,
	    event_object_table
	FROM
	    information_schema.triggers
	WHERE
	    trigger_schema = 'public'
	    AND event_object_schema = 'public' LOOP
	EXECUTE
	    'DROP TRIGGER IF EXISTS ' || my_trigger_name || ' ON ' || my_table_name || ' CASCADE';
	num_triggers := num_triggers + 1;
	END LOOP;
	RETURN;
	END;
$$; 

CREATE OR REPLACE FUNCTION GET_DROP_ALL_DML_TRIGGERS
() RETURNS INTEGER LANGUAGE PLPGSQL AS $$ 
	DECLARE all_dml_triggers INTEGER;
	BEGIN CALL drop_all_dml_triggers(all_dml_triggers);
	RETURN COALESCE(all_dml_triggers, 0);
	END;
$$; 

/*
 4) Создать хранимую процедуру с входным параметром, 
 которая выводит имена и описания типа объектов (только хранимых процедур и скалярных функций), 
 в тексте которых на языке SQL встречается строка, задаваемая параметром процедуры.
 */

CREATE OR REPLACE PROCEDURE FIND_SQL_TEXT(SEARCH_TEXT 
TEXT) LANGUAGE PLPGSQL AS $$ 
	DECLARE object_name VARCHAR;
	DECLARE object_type VARCHAR;
	BEGIN
	    FOR object_name,
	    object_type IN
	SELECT
	    specific_schema,
	    routine_name,
	    routine_type,
	    routine_definition
	FROM
	    information_schema.routines
	WHERE
	    routine_schema NOT IN (
	        'pg_catalog',
	        'information_schema'
	    )
	    AND routine_type IN ('PROCEDURE', 'FUNCTION')
	    AND specific_schema NOT LIKE 'pg_%'
	    AND routine_definition LIKE '%' || SEARCH_TEXT || '%' LOOP RAISE NOTICE '%',
	    object_name || ' ' || object_type;
	END LOOP;
	END;
$$; 