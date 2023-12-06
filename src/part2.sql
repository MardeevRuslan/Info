-- Active: 1686291172146@@127.0.0.1@5435@school21

DROP TRIGGER IF EXISTS trg_add_TransferredPoints ON P2P CASCADE;

DROP TRIGGER IF EXISTS trg_xp_insert_xp ON XP CASCADE;

DROP PROCEDURE
    IF EXISTS fnc_trg_add_transferredpoints,
    add_P2P_check;

DROP FUNCTION IF EXISTS fnc_trg_xp_insert_xp, add_verter_check;

/*
 1) Написать процедуру добавления P2P проверки
 Параметры: ник проверяемого, ник проверяющего, название задания, статус P2P проверки, время. 
 Если задан статус "начало", добавить запись в таблицу Checks (в качестве даты использовать сегодняшнюю). 
 Добавить запись в таблицу P2P. 
 Если задан статус "начало", в качестве проверки указать только что добавленную запись, иначе указать 
 проверку с незавершенным P2P этапом.
 */

--------------------- PROCEDURE add_P2P_check -----------

CREATE OR REPLACE PROCEDURE ADD_P2P_CHECK(IN CHECKED_NICKNAME 
VARCHAR, IN CHECKING_NICKNAME VARCHAR, IN TASK_NAME 
VARCHAR, IN P2P_STATUS CHECK_STATUS, IN CHECK_TIME 
TIME) LANGUAGE PLPGSQL AS $$ 
	DECLARE check_id INTEGER := get_max_id_table('checks');
	DECLARE state_last_check VARCHAR;
	BEGIN
	    IF p2p_status = 'start' THEN
	INSERT INTO
	    Checks (ID, Peer, Task, Date)
	VALUES ( (
	            SELECT MAX(ID)
	            FROM
	                Checks
	        ) + 1,
	        checked_nickname,
	        task_name,
	        CURRENT_DATE :: DATE
	    );
	INSERT INTO
	    p2p (
	        ID,
	        "Check",
	        checkingpeers,
	        state,
	        time
	    )
	VALUES ( (
	            SELECT MAX(ID)
	            FROM p2p
	        ) + 1, (
	            SELECT MAX(ID)
	            FROM
	                Checks
	        ),
	        checking_nickname,
	        p2p_status,
	        check_time
	    );
	ELSE state_last_check := get_state_last_P2P(checked_nickname, task_name);
	IF state_last_check = 'start' THEN
	INSERT INTO
	    P2P (
	        ID,
	        "Check",
	        checkingpeers,
	        state,
	        time
	    )
	VALUES ( (
	            SELECT MAX(ID)
	            FROM p2p
	        ) + 1, (
	            SELECT MAX(ID)
	            FROM
	                Checks
	        ),
	        checking_nickname,
	        p2p_status,
	        check_time
	    );
	ELSE RAISE EXCEPTION 'Ошибка записи в таблицу P2P';
	END IF;
	END IF;
	END;
$$; 

/*
 2) Написать процедуру добавления проверки Verter'ом
 Параметры: ник проверяемого, название задания, статус проверки Verter'ом, время. 
 Добавить запись в таблицу Verter (в качестве проверки указать проверку 
 соответствующего задания с самым поздним (по времени) успешным P2P этапом)
 */

--------------------- PROCEDURE add_verter_check -----------

CREATE OR REPLACE PROCEDURE ADD_VERTER_CHECK(IN CHECKED_NICKNAME 
VARCHAR, IN TASK_NAME VARCHAR, IN STATE_VERTER CHECK_STATUS
, IN CHECK_TIME TIME) LANGUAGE PLPGSQL AS $$ 
	DECLARE
	    state_last_check VARCHAR := get_state_last_P2P(checked_nickname, task_name);
	DECLARE
	    check_id INTEGER := get_check_id(checked_nickname, task_name);
	BEGIN
	    IF state_last_check = 'success' THEN
	INSERT INTO
	    verter (id, "Check", state, time)
	VALUES ( (
	            SELECT MAX(ID)
	            FROM
	                verter
	        ) + 1,
	        check_id,
	        state_verter,
	        check_time
	    );
	ELSE RAISE EXCEPTION 'Ошибка записи в таблицу Verter %',
	state_last_check;
	END IF;
	END;
$$; 

/* 
 3) Написать триггер: после добавления записи со статутом "начало" 
 в таблицу P2P, изменить соответствующую запись в таблице TransferredPoints 
 */

--------------------- PROCEDURE fnc_trg_add_transferredpoints -----------

CREATE OR REPLACE FUNCTION FNC_TRG_ADD_TRANSFERREDPOINTS
() RETURNS TRIGGER LANGUAGE PLPGSQL AS $$ 
	DECLARE
	    CheckedPeer_ VARCHAR := (
	        SELECT peer
	        FROM Checks
	        WHERE
	            NEW."Check" = Checks.ID
	        LIMIT 1
	    );
	DECLARE
	    points INTEGER := get_PointsAmount(
	        NEW.CheckingPeers,
	        CheckedPeer_
	    );
	CheckingPeer_ VARCHAR := NEW.CheckingPeers;
	BEGIN
	    IF NEW.state = 'start' THEN IF points <> 0 THEN
	UPDATE transferredpoints
	SET PointsAmount = points + 1
	WHERE
	    CheckingPeer = CheckingPeer_
	    AND CheckedPeer = CheckedPeer_;
	ELSE
	INSERT INTO
	    transferredpoints (
	        ID,
	        CheckingPeer,
	        CheckedPeer,
	        PointsAmount
	    )
	VALUES (
	        COALESCE( (
	                SELECT
	                    MAX(ID)
	                FROM
	                    transferredpoints
	            ) + 1,
	            0
	        ),
	        CheckingPeer_,
	        CheckedPeer_,
	        1
	    );
	END IF;
	END IF;
	RETURN NEW;
	END;
$$; 

------------------------- TRIGGER trg_add_TransferredPoints ------------

CREATE OR REPLACE TRIGGER TRG_ADD_TRANSFERREDPOINTS 
	AFTER
	INSERT ON p2p FOR EACH ROW
	EXECUTE
	    FUNCTION fnc_trg_add_transferredpoints();
; 

;

;

/* 
 4) Написать триггер: перед добавлением записи в таблицу XP, проверить корректность добавляемой записи
 Запись считается корректной, если:
 Количество XP не превышает максимальное доступное для проверяемой задачи
 Поле Check ссылается на успешную проверку
 Если запись не прошла проверку, не добавлять её в таблицу.
 */

--------------------- FUNCTION fnc_trg_xp_insert_xp  ----------------------------

CREATE OR REPLACE FUNCTION FNC_TRG_XP_INSERT_XP() RETURNS 
TRIGGER LANGUAGE PLPGSQL AS $$ 
	DECLARE max_xp INT:= get_maxXP(NEW."Check");
	check_status VARCHAR := get_state_last_verter(NEW."Check");
	BEGIN
	    IF NEW.xpamount > max_xp
	    OR check_status != 'success' THEN RAISE EXCEPTION 'Ошибка записи в таблицу XP max_xp = %  state = %',
	    max_xp,
	    check_status;
	END IF;
	RETURN NEW;
	END;
$$; 

---------------------------- TRIGGER fnc_trg_trg_xp_insert_xpxp_insert_xp ------------

CREATE OR REPLACE TRIGGER TRG_XP_INSERT_XP 
	BEFORE
	INSERT ON XP FOR EACH ROW
	EXECUTE
	    FUNCTION fnc_trg_xp_insert_xp();
; 

;