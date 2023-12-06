-- Active: 1686291172146@@127.0.0.1@5435@school21

DROP FUNCTION
    IF EXISTS get_max_id_table,
    get_state_last_P2P,
    get_check_id,
    get_PointsAmount,
    get_state_last_verter,
    get_maxXP,
    get_count_tasks_in_block,
    get_count_completed_tasks_in_block;

---------------------- FUNCTION get_maxXP ----------------------

CREATE OR REPLACE FUNCTION GET_MAXXP(CHECK_ID INTEGER
) RETURNS INTEGER AS $$ 
	BEGIN RETURN COALESCE( (
	            SELECT
	                DISTINCT t.maxxp :: integer
	            FROM checks AS c
	                INNER JOIN tasks AS t ON c.task = t.title
	            WHERE
	                c.ID = check_id
	        ),
	        0
	    );
	END;
	$$ LANGUAGE 
PLPGSQL; 

------------------- FUNCTION get_state_last_verter ----------------------

CREATE OR REPLACE FUNCTION GET_STATE_LAST_VERTER(CHECK_ID 
INTEGER) RETURNS VARCHAR AS $$ 
	BEGIN RETURN COALESCE( (
	            SELECT State
	            FROM verter
	            WHERE
	                "Check" = check_id
	            ORDER BY
	                time DESC
	            LIMIT
	                1
	        ), 'failure'
	    );
	END;
	$$ LANGUAGE 
PLPGSQL; 

------------------------- FUNCTION get_max_id_table -----------------------------

CREATE OR REPLACE FUNCTION GET_MAX_ID_TABLE(TABLE_NAME 
VARCHAR) RETURNS INTEGER AS $$ 
	DECLARE max_id INTEGER;
	BEGIN
	EXECUTE
	    'SELECT MAX(id) FROM ' || TABLE_NAME INTO max_id;
	RETURN COALESCE(max_id, 0);
	END;
	$$ LANGUAGE 
PLPGSQL; 

------------------------- FUNCTION get_state_last_P2P -----------------------------

CREATE OR REPLACE FUNCTION GET_STATE_LAST_P2P(CHECKED_NICKNAME 
VARCHAR, TASK_NAME VARCHAR) RETURNS VARCHAR AS $$ 
	BEGIN RETURN (
	        SELECT p2p.state
	        FROM P2P
	            JOIN checks AS c ON p2p."Check" = c.ID
	        WHERE
	            checked_nickname = c.Peer
	            AND task_name = c.Task
	        ORDER BY p2p.ID DESC
	        LIMIT 1
	    );
	END;
	$$ LANGUAGE 
PLPGSQL; 

------------------------- FUNCTION get_check_id ----------------------------

CREATE OR REPLACE FUNCTION GET_CHECK_ID(CHECKING_NICKNAME 
VARCHAR, TASK_NAME VARCHAR) RETURNS INTEGER AS $$ 
	BEGIN RETURN COALESCE( (
	            SELECT id
	            FROM checks
	            WHERE
	                checking_nickname = Peer
	                AND task_name = Task
	        ),
	        0
	    );
	END;
	$$ LANGUAGE 
PLPGSQL; 

---------------------------- FUNCTION get_PointsAmount ----------------------------

CREATE OR REPLACE FUNCTION GET_POINTSAMOUNT(CHECKING_NICKNAME 
VARCHAR, CHECKED_NICKNAME VARCHAR) RETURNS INTEGER 
AS $$ 
	DECLARE points INTEGER:= 0;
	BEGIN
	SELECT
	    PointsAmount INTO points
	FROM TRANSFERREDPOINTS
	WHERE
	    checking_nickname = CheckingPeer
	    AND checked_nickname = CheckedPeer;
	IF points IS NULL THEN points := 0;
	END IF;
	RETURN points;
	END;
	$$ LANGUAGE 
PLPGSQL; 

--------------------------------- FUNCTION get_count_tasks_in_block ----------------------------

CREATE OR REPLACE FUNCTION GET_COUNT_TASKS_IN_BLOCK
(BLOCK_NAME VARCHAR) RETURNS INTEGER AS $$ 
	BEGIN RETURN (
	        SELECT COUNT(*)
	        FROM tasks
	        WHERE
	            title LIKE block_name || '%'
	    );
	END;
	$$ LANGUAGE 
PLPGSQL; 

------------------------------------ FUNCTION get_count_completed_tasks_in_block -----------------------------

CREATE OR REPLACE FUNCTION GET_COUNT_COMPLETED_TASKS_IN_BLOCK
(BLOCK_NAME VARCHAR, PEER_NAME VARCHAR) RETURNS INTEGER 
AS $$ 
	BEGIN RETURN (
	        SELECT COUNT(*)
	        FROM checks AS c
	            JOIN XP AS x ON x."Check" = c.ID
	        WHERE
	            c.Task LIKE block_name || '%'
	            AND c.Peer = peer_name
	    );
	END;
	$$ LANGUAGE 
PLPGSQL; 