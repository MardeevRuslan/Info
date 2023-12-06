-- Active: 1686291172146@@127.0.0.1@5435@school21

DROP FUNCTION
    IF EXISTS get_readable_TransferredPoints,
    get_table_peer_task_XP,
    get_campus_peers,
    get_change_peerpoint,
    get_change_peerpoint2,
    get_most_checked_task_per_day,
    get_peer_completion_date,
    find_best_peer,
    get_block_stats,
    get_birthday_stats,
    get_task_stats,
    get_prev_count_for_tasks,
    find_lucky_days,
    get_peer_with_max_xp,
    get_peers_who_came_early,
    get_early_entrance_percentage;

/* 
 1) Написать функцию, возвращающую таблицу TransferredPoints в более человекочитаемом виде
 Ник пира 1, ник пира 2, количество переданных пир поинтов. 
 Количество отрицательное, если пир 2 получил от пира 1 больше поинтов.
 */

---------------------- FUNCTION get_Readable_TransferredPoints ----------------------

CREATE OR REPLACE FUNCTION GET_READABLE_TRANSFERREDPOINTS
() RETURNS TABLE(PEER1_NICKNAME VARCHAR, PEER2_NICKNAME 
VARCHAR, POINTS INT) AS $$ 
	BEGIN RETURN QUERY
	SELECT
	    checkingpeer AS peer1_nickname,
	    checkedpeer AS peer2_nickname,
	    get_pointsamount(t.checkingpeer, t.checkedpeer) - get_pointsamount(t.checkedpeer, t.checkingpeer) AS points
	FROM transferredpoints AS t
	WHERE
	    checkingpeer <> checkedpeer
	    AND get_pointsamount(t.checkingpeer, t.checkedpeer) - get_pointsamount(t.checkedpeer, t.checkingpeer) <> 0;
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE VIEW PART3_1 
	AS SELECT * FROM get_readable_transferredpoints();
; 

;

;

/* 
 2) Написать функцию, которая возвращает таблицу вида: ник пользователя, название проверенного 
 задания, кол-во полученного XP
 В таблицу включать только задания, успешно прошедшие проверку (определять по таблице Checks). 
 Одна задача может быть успешно выполнена несколько раз. В таком случае в таблицу включать 
 все успешные проверки.
 */

---------------------- FUNCTION get_table_peer_task_XP ----------------------

CREATE OR REPLACE FUNCTION GET_TABLE_PEER_TASK_XP() 
RETURNS TABLE(PEER VARCHAR, TASK VARCHAR, XP INT) 
AS $$ 
	BEGIN RETURN QUERY
	SELECT
	    c.peer AS peer,
	    c.task AS task,
	    x.XPAmount AS xp
	FROM Checks AS c
	    INNER JOIN XP AS x ON c.ID = x."Check"
	    INNER JOIN Verter AS v ON c.ID = v."Check"
	WHERE v.state = 'success';
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE VIEW PART3_2 
	AS SELECT * FROM get_table_peer_task_XP();
; 

;

;

/* 
 3) Написать функцию, определяющую пиров, которые не выходили из кампуса в течение всего дня
 Параметры функции: день, например 12.05.2022. 
 Функция возвращает только список пиров.
 */

------------------------------- FUNCTION get_campus_peers ----------------------

CREATE OR REPLACE FUNCTION GET_CAMPUS_PEERS(DATE_VALUE 
DATE) RETURNS TABLE(PEER_NICKNAME VARCHAR) AS $$ 
	BEGIN RETURN QUERY
	SELECT peer
	FROM TimeTracking
	WHERE date = date_value
	GROUP BY peer
	HAVING COUNT(*) = 2;
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE VIEW PART3_3 
	AS SELECT * FROM get_campus_peers('2021-01-25');
; 

;

/* 4) Посчитать изменение в количестве пир поинтов каждого пира по таблице TransferredPoints
 Результат вывести отсортированным по изменению числа поинтов. 
 Формат вывода: ник пира, изменение в количество пир поинтов */

------------------------- FUNCTION get_change_peerpoint ----------------------

CREATE OR REPLACE FUNCTION GET_CHANGE_PEERPOINT() RETURNS 
TABLE(PEER VARCHAR, POINTSCHANGE INT) AS $$ 
	BEGIN RETURN QUERY
	WITH plus AS (
	        SELECT
	            checkingpeer AS peer,
	            sum(PointsAmount) AS plus
	        FROM
	            transferredpoints
	        GROUP BY
	            checkingpeer
	    ),
	minus
	AS (
	    SELECT
	        checkedpeer AS peer,
	        sum(PointsAmount) * (-1) AS
	    minus
	    FROM transferredpoints
	    GROUP BY
	        checkedpeer
	),
	p_m AS (
	    SELECT
	        plus.peer,
	        plus AS pointschange
	    FROM plus
	    UNION ALL
	    SELECT
	    minus
	.peer,
	    minus
	    AS pointschange
	    FROM
	    minus
	)
	SELECT
	    DISTINCT p_m.peer AS peer,
	    sum(p_m.pointschange) :: INTEGER AS pointschange
	FROM p_m
	GROUP BY p_m.peer;
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE VIEW PART3_4 
	AS SELECT * FROM get_change_peerpoint();
; 

;

;

/* 
 5) Посчитать изменение в количестве пир поинтов каждого пира по таблице, возвращаемой первой функцией из Part 3
 Результат вывести отсортированным по изменению числа поинтов. 
 Формат вывода: ник пира, изменение в количество пир поинтов 
 */

------------------------- FUNCTION get_change_peerpoint2 ----------------------

CREATE OR REPLACE FUNCTION GET_CHANGE_PEERPOINT2() 
RETURNS TABLE(PEER VARCHAR, POINTSCHANGE INT) AS $$ 
	BEGIN RETURN QUERY
	WITH plus AS (
	        SELECT
	            t.peer1_nickname AS peer,
	            sum(points) AS plus
	        FROM (
	                SELECT *
	                FROM
	                    get_readable_transferredpoints()
	            ) AS t
	        GROUP BY peer
	    ),
	minus
	AS (
	    SELECT
	        t.peer2_nickname AS peer,
	        sum(points) * (-1) AS
	    minus
	    FROM (
	            SELECT *
	            FROM
	                get_readable_transferredpoints()
	        ) AS t
	    GROUP BY peer
	), p_m AS (
	    SELECT
	        plus.peer,
	        plus AS pointschange
	    FROM plus
	    UNION ALL
	    SELECT
	    minus
	.peer,
	    minus
	    AS pointschange
	    FROM
	    minus
	)
	SELECT
	    DISTINCT p_m.peer AS peer,
	    sum(p_m.pointschange) :: INTEGER AS pointschange
	FROM p_m
	GROUP BY p_m.peer;
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE VIEW PART3_5 
	AS SELECT * FROM get_change_peerpoint2();
; 

;

;

/* 
 6) Определить самое часто проверяемое задание за каждый день
 При одинаковом количестве проверок каких-то заданий в определенный день, вывести их все. 
 Формат вывода: день, название задания 
 */

------------------------- FUNCTION get_most_checked_task_per_day ----------------------

CREATE OR REPLACE FUNCTION GET_MOST_CHECKED_TASK_PER_DAY
() RETURNS TABLE("DAY" DATE, TASK VARCHAR) AS $$ 
	BEGIN RETURN QUERY
	WITH check_count AS(
	        SELECT
	            date,
	            Checks.task,
	            COUNT(*) AS check_count
	        FROM Checks
	        GROUP BY
	            1,
	            2
	    ),
	    max_count AS(
	        SELECT
	            date,
	            MAX(check_count) AS max_check_count
	        FROM check_count
	        GROUP BY 1
	    )
	SELECT
	    check_count.date :: DATE AS "Day",
	    check_count.task :: VARCHAR AS Task
	FROM max_count
	    JOIN check_count ON max_count.date = check_count.date AND max_count.max_check_count = check_count.check_count;
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE VIEW PART3_6 
	AS SELECT * FROM get_most_checked_task_per_day();
; 

;

;

/* 
 7) Найти всех пиров, выполнивших весь заданный блок задач и дату завершения последнего задания
 Параметры процедуры: название блока, например "CPP". 
 Результат вывести отсортированным по дате завершения. 
 Формат вывода: ник пира, дата завершения блока (т.е. последнего выполненного задания из этого блока) 
 */

---------------------------- FUNCTION get_peer_completion_date ----------------------

CREATE OR REPLACE FUNCTION GET_PEER_COMPLETION_DATE
(BLOCK_NAME VARCHAR) RETURNS TABLE(PEER VARCHAR, DAY 
DATE) AS $$ 
	BEGIN RETURN QUERY
	WITH count_task AS (
	        SELECT
	            c.peer,
	            get_count_completed_tasks_in_block(block_name, c.peer) AS count_tasks
	        FROM Checks AS c
	    )
	SELECT
	    c.peer AS peer,
	    c.date AS day
	FROM Checks AS c
	    JOIN count_task ON c.peer = count_task.peer
	WHERE
	    count_task.count_tasks = get_count_tasks_in_block(block_name);
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE VIEW PART3_7 
	AS SELECT * FROM get_peer_completion_date('CPP');
; 

;

;

/* 
 8) Определить, к какому пиру стоит идти на проверку каждому обучающемуся
 Определять нужно исходя из рекомендаций друзей пира, т.е. нужно найти пира, проверяться у 
 которого рекомендует наибольшее число друзей. 
 Формат вывода: ник пира, ник найденного проверяющего
 */

----------------------- FUNCTION find_best_peer ----------------------

CREATE OR REPLACE FUNCTION FIND_BEST_PEER() RETURNS 
TABLE(PEER VARCHAR, RECOMMENDEDPEER VARCHAR) AS $$ 
	BEGIN RETURN QUERY
	WITH f AS (
	        SELECT
	            peer1 AS peer1,
	            peer2 AS peer2
	        FROM Friends
	        UNION
	        SELECT
	            peer2 AS peer1,
	            peer1 AS peer2
	        FROM Friends
	    ), r AS (
	        SELECT
	            peer1,
	            peer2,
	            reccomendedpeer
	        FROM f
	            LEFT JOIN recommendations AS r ON f.peer2 = r.Peer
	    ), c AS (
	        SELECT
	            peer1 AS peer,
	            reccomendedpeer,
	            COUNT(*)
	        FROM r
	        WHERE
	            peer1 <> reccomendedpeer
	        GROUP BY
	            1,
	            2
	    ),
	    max_c AS (
	        SELECT
	            c.peer,
	            reccomendedpeer,
	            MAX("count") OVER (PARTITION BY c.peer) AS max_count
	        FROM c
	    )
	SELECT
	    c.peer,
	    reccomendedpeer
	FROM c
	WHERE (c.peer, "count") IN (
	        SELECT
	            max_c.peer,
	            max_count
	        FROM max_c
	    );
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE VIEW PART3_8 
	AS SELECT * FROM find_best_peer();
; 

;

;

/* 
 9) Определить процент пиров, которые:
 Приступили только к блоку 1
 Приступили только к блоку 2
 Приступили к обоим
 Не приступили ни к одному
 Пир считается приступившим к блоку, если он проходил хоть одну проверку любого задания из этого блока 
 (по таблице Checks)
 Параметры процедуры: название блока 1, например SQL, название блока 2, например A. 
 Формат вывода: процент приступивших только к первому блоку, процент приступивших только ко 
 второму блоку, процент приступивших к обоим, процент не приступивших ни к одному
 */

----------------------- FUNCTION get_block_stats ----------------------

CREATE OR REPLACE FUNCTION GET_BLOCK_STATS(BLOCK1_NAME 
VARCHAR, BLOCK2_NAME VARCHAR) RETURNS TABLE(STARTEDBLOCK1 
NUMERIC(2), STARTEDBLOCK2 NUMERIC(2), STARTEDBOTHBLOCKS 
NUMERIC(2), DIDNTSTARTANYBLOCK NUMERIC(2)) AS $$ 
	DECLARE only_block1_count INTEGER;
	only_block2_count INTEGER;
	both_blocks_count INTEGER;
	none_blocks_count INTEGER;
	total_peers_count INTEGER;
	BEGIN
	SELECT
	    COUNT(DISTINCT Nickname) INTO total_peers_count
	FROM Peers;
	SELECT
	    COUNT(DISTINCT Peer) INTO only_block1_count
	FROM Checks
	WHERE
	    Task LIKE block1_name || '%'
	    AND Peer NOT IN (
	        SELECT DISTINCT Peer
	        FROM Checks
	        WHERE
	            Task LIKE block2_name || '%'
	    );
	SELECT
	    COUNT(DISTINCT Peer) INTO only_block2_count
	FROM Checks
	WHERE
	    Task LIKE block2_name || '%'
	    AND Peer NOT IN (
	        SELECT DISTINCT Peer
	        FROM Checks
	        WHERE
	            Task LIKE block1_name || '%'
	    );
	SELECT
	    COUNT(DISTINCT Peer) INTO both_blocks_count
	FROM Checks
	WHERE
	    Task LIKE block1_name || '%'
	    AND Peer IN (
	        SELECT DISTINCT Peer
	        FROM Checks
	        WHERE
	            Task LIKE block2_name || '%'
	    );
	SELECT
	    COUNT(DISTINCT Nickname) INTO none_blocks_count
	FROM Peers
	WHERE Nickname NOT IN (
	        SELECT DISTINCT Peer
	        FROM Checks
	    );
	RETURN QUERY
	SELECT
	    ROUND(
	        100.0 * only_block1_count / total_peers_count,
	        2
	    ),
	    ROUND(
	        100.0 * only_block2_count / total_peers_count,
	        2
	    ),
	    ROUND(
	        100.0 * both_blocks_count / total_peers_count,
	        2
	    ),
	    ROUND(
	        100.0 * none_blocks_count / total_peers_count,
	        2
	    );
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE VIEW PART3_9 
	AS SELECT * FROM get_block_stats('C', 'CPP');
; 

;

;

/*
 10) Определить процент пиров, которые когда-либо успешно проходили проверку в свой день рождения
 Также определите процент пиров, которые хоть раз проваливали проверку в свой день рождения. 
 Формат вывода: процент пиров, успешно прошедших проверку в день рождения, процент пиров, 
 проваливших проверку в день рождения
 */

---------------------- FUNCTION get_birthday_stats ----------------------

CREATE OR REPLACE FUNCTION GET_BIRTHDAY_STATS() RETURNS 
TABLE(SUCCESSFULCHECKS DECIMAL(5, 2), UNSUCCESSFULCHECKS 
DECIMAL(5, 2)) AS $$ 
	DECLARE total_peers_count INTEGER;
	success_birthday_count INTEGER;
	failed_birthday_count INTEGER;
	BEGIN
	    CREATE
	    OR replace VIEW total AS (
	        SELECT c.ID
	        FROM Checks AS c
	            INNER JOIN Peers AS p ON p.Nickname = c.Peer AND to_char(c.date, 'MMDD') = to_char(p.Birthday, 'MMDD')
	    );
	SELECT
	    COUNT(*) INTO total_peers_count -- общее количество пиров, когда-либо проходили проверку в свой день рождения
	FROM total;
	-- SELECT COUNT(*) INTO total_peers_count -- общее количество пиров,
	-- FROM Peers;
	SELECT
	    COUNT(*) INTO success_birthday_count
	FROM total AS t
	    INNER JOIN P2P AS pp ON pp."Check" = t.ID
	    INNER JOIN Verter AS v ON v."Check" = t.ID
	WHERE
	    pp.state = 'success'
	    AND v.state = 'success';
	SELECT
	    COUNT(*) INTO failed_birthday_count
	FROM total AS t
	    INNER JOIN P2P AS pp ON pp."Check" = t.ID
	    INNER JOIN Verter AS v ON v."Check" = t.ID
	WHERE
	    pp.state = 'failure'
	    OR v.state = 'failure';
	DROP VIEW total;
	RETURN QUERY
	SELECT
	    ROUND(
	        100.0 * success_birthday_count / total_peers_count,
	        2
	    ),
	    ROUND(
	        100.0 * failed_birthday_count / total_peers_count,
	        2
	    );
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE VIEW PART3_10 
	AS SELECT * FROM get_birthday_stats();
; 

;

;

/*
 11) Определить всех пиров, которые сдали заданные задания 1 и 2, но не сдали задание 3
 Параметры процедуры: названия заданий 1, 2 и 3. 
 */

-------------------- FUNCTION get_task_stats ----------------------

CREATE OR REPLACE FUNCTION GET_TASK_STATS(TASK1 VARCHAR
, TASK2 VARCHAR, TASK3 VARCHAR) RETURNS TABLE(NICKNAME 
VARCHAR) AS $$ 
	BEGIN RETURN QUERY
	WITH t1 AS (
	        SELECT Peer
	        FROM CHECKS AS c
	            JOIN Verter AS v ON v."Check" = c.ID
	        WHERE
	            Task = task1
	            AND v.state = 'success'
	    ),
	    t2 AS (
	        SELECT Peer
	        FROM CHECKS AS c
	            JOIN Verter AS v ON v."Check" = c.ID
	        WHERE
	            Task = task2
	            AND v.state = 'success'
	    ),
	    t3 AS (
	        SELECT DISTINCT Peer
	        FROM CHECKS AS c
	            LEFT JOIN Verter AS v ON v."Check" = c.ID
	        WHERE (
	                Task = 'A3_s21_math'
	                AND v.state != 'success'
	            )
	            OR Task != 'A3_s21_math'
	    )
	SELECT p.Nickname
	FROM Peers AS p
	    JOIN t1 ON p.Nickname = t1.Peer
	    JOIN t2 ON p.Nickname = t2.Peer
	    JOIN t3 ON p.Nickname = t3.Peer;
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE VIEW PART3_11 
	AS
	SELECT *
	FROM
	    get_task_stats(
	        'C5_s21_calculator',
	        'CPP1_s21_bash',
	        'A3_s21_math'
	    );
; 

;

;

/*
 12) Используя рекурсивное обобщенное табличное выражение, для каждой задачи вывести кол-во предшествующих ей задач
 То есть сколько задач нужно выполнить, исходя из условий входа, чтобы получить доступ к текущей. 
 Формат вывода: название задачи, количество предшествующих
 */

------------------ FUNCTION get_prev_count_for_tasks ----------------------

CREATE OR REPLACE FUNCTION GET_PREV_COUNT_FOR_TASKS
() RETURNS TABLE(TASK VARCHAR, PREVCOUNT INTEGER) 
AS $$ 
	BEGIN RETURN QUERY
	WITH RECURSIVE task_deps AS (
	        SELECT
	            Title,
	            1 AS depth
	        FROM Tasks
	        UNION ALL
	        SELECT
	            Tasks.Title,
	            task_deps.depth + 1
	        FROM Tasks
	            INNER JOIN task_deps ON Tasks.ParentTask = task_deps.Title
	    )
	SELECT
	    Title AS Task,
	    MAX(depth) - 1 AS PrevCount
	FROM task_deps
	GROUP BY 1
	ORDER BY 1;
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE VIEW PART3_12 
	AS SELECT * FROM get_prev_count_for_tasks();
; 

;

;

/*
 13) Найти "удачные" для проверок дни. День считается "удачным", если в нем есть хотя бы N идущих подряд успешных проверки
 Параметры процедуры: количество идущих подряд успешных проверок N. 
 Временем проверки считать время начала P2P этапа. 
 Под идущими подряд успешными проверками подразумеваются успешные проверки, между которыми нет неуспешных. 
 При этом кол-во опыта за каждую из этих проверок должно быть не меньше 80% от максимального. 
 Формат вывода: список дней
 */

-- ------------------ FUNCTION find_lucky_days ----------------------

CREATE OR REPLACE FUNCTION FIND_LUCKY_DAYS(IN N INTEGER
, OUT LUCKY_DAYS VARCHAR) RETURNS SETOF VARCHAR LANGUAGE 
PLPGSQL AS $$ 
	DECLARE current_date_ DATE;
	num_consecutive_successes INTEGER;
	current_check_date DATE;
	fail_check_count INTEGER;
	BEGIN FOR current_date_ IN
	SELECT DISTINCT Checks.Date
	FROM checks
	ORDER BY
	    Checks.Date LOOP fail_check_count := 0;
	num_consecutive_successes := 0;
	current_check_date := current_date_;
	WHILE num_consecutive_successes < N
	AND fail_check_count = 0 LOOP RAISE NOTICE 'messageLOOP %',
	num_consecutive_successes;
	IF EXISTS (
	    SELECT 1
	    FROM checks
	        JOIN XP AS x ON x."Check" = checks.ID
	        JOIN Tasks AS t ON t.Title = checks.Task
	    WHERE
	        Checks.Date = current_check_date
	        AND x.XPAmount >= t.MaxXP * 0.8
	        AND x.XPAmount < t.MaxXP
	) THEN num_consecutive_successes := num_consecutive_successes + 1;
	ELSE num_consecutive_successes := 0;
	fail_check_count := 1;
	END IF;
	END LOOP;
	IF num_consecutive_successes >= N THEN lucky_days := current_date_;
	RETURN NEXT;
	END IF;
	END LOOP;
	END;
$$; 

CREATE VIEW PART3_13 
	AS SELECT * FROM find_lucky_days(1);
; 

;

;

/*
 14) Определить пира с наибольшим количеством XP
 Формат вывода: ник пира, количество XP
 */

---------------------- FUNCTION get_peer_with_max_xp ----------------------

CREATE OR REPLACE FUNCTION GET_PEER_WITH_MAX_XP() RETURNS 
TABLE(PEER VARCHAR, XP INTEGER) AS $$ 
	BEGIN RETURN QUERY
	SELECT
	    c.Peer AS Peer,
	    COALESCE(sum(x.XPAmount), 0) :: INTEGER AS XP
	FROM Checks AS c
	    JOIN XP AS x ON x."Check" = c.ID
	GROUP BY c.Peer
	ORDER BY sum(x.XPAmount) DESC
	LIMIT 1;
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE VIEW PART3_14 
	AS SELECT * FROM get_peer_with_max_xp();
; 

;

;

/*
 15) Определить пиров, приходивших раньше заданного времени не менее N раз за всё время
 Параметры процедуры: время, количество раз N. 
 Формат вывода: список пиров
 */

---------------------- FUNCTION get_peers_who_came_early ----------------------

CREATE OR REPLACE FUNCTION GET_PEERS_WHO_CAME_EARLY
(N INTEGER, CHECK_TIME TIME) RETURNS TABLE(PEER VARCHAR
) AS $$ 
	BEGIN RETURN QUERY
	SELECT t.Peer AS peer
	FROM TimeTracking AS t
	WHERE t.Time < check_time
	GROUP BY t.Peer
	HAVING COUNT(*) >= N;
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE VIEW PART3_15 
	AS SELECT * FROM get_peers_who_came_early(1, '14:00:00');
; 

;

;

/*
 16) Определить пиров, выходивших за последние N дней из кампуса больше M раз
 Параметры процедуры: количество дней N, количество раз M. 
 Формат вывода: список пиров
 */

---------------------- FUNCTION get_peers_who_left_campus ----------------------

CREATE OR REPLACE FUNCTION GET_PEERS_WHO_LEFT_CAMPUS
(N INTEGER, M INTEGER) RETURNS TABLE(PEER VARCHAR) 
AS $$ 
	BEGIN RETURN QUERY
	SELECT t.Peer AS peer
	FROM TimeTracking AS t
	WHERE
	    t.Date >= NOW() - INTERVAL '1 DAY' * N
	    AND t.State = '2'
	GROUP BY t.Peer
	HAVING COUNT(*) > M;
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE VIEW PART3_16 
	AS SELECT * FROM get_peers_who_left_campus(1, 1);
; 

;

;

/*
 17) Определить для каждого месяца процент ранних входов
 Для каждого месяца посчитать, сколько раз люди, родившиеся в этот месяц, 
 приходили в кампус за всё время (будем называть это общим числом входов). 
 Для каждого месяца посчитать, сколько раз люди, родившиеся в этот месяц, 
 приходили в кампус раньше 12:00 за всё время (будем называть это числом ранних входов). 
 Для каждого месяца посчитать процент ранних входов в кампус относительно общего числа входов. 
 Формат вывода: месяц, процент ранних входов
 */

---------------------- FUNCTION get_early_entrance_percentage ----------------------

CREATE OR REPLACE FUNCTION GET_EARLY_ENTRANCE_PERCENTAGE
(OUT MONTH_NAME VARCHAR, OUT EARLY_ENTRY_PERCENTAGE 
NUMERIC) RETURNS SETOF RECORD AS $$ 
	DECLARE total_count_entrys INTEGER;
	earle_count_entrys INTEGER;
	current_month INTEGER := 1;
	max_month INTEGER := 12;
	BEGIN
	    WHILE current_month <= max_month LOOP month_name := to_char(
	        DATE_TRUNC('year', CURRENT_DATE) + (current_month - 1) * INTERVAL '1 MONTH',
	        'Month'
	    );
	SELECT
	    COUNT(*) INTO total_count_entrys
	FROM TimeTracking AS t
	    JOIN Peers AS p ON t.Peer = p.Nickname
	WHERE EXTRACT(
	        MONTH
	        FROM
	            t.Date
	    ) = current_month
	    AND t.State = '2'
	    AND EXTRACT(
	        MONTH
	        FROM
	            p.Birthday
	    ) = current_month;
	SELECT
	    COUNT(*) INTO earle_count_entrys
	FROM TimeTracking AS t
	    JOIN Peers AS p ON t.Peer = p.Nickname
	WHERE EXTRACT(
	        MONTH
	        FROM
	            t.Date
	    ) = current_month
	    AND t.State = '2'
	    AND EXTRACT(
	        MONTH
	        FROM
	            p.Birthday
	    ) = current_month
	    AND t.Time < '12:00:00';
	IF total_count_entrys = 0 THEN early_entry_percentage := 0;
	ELSE early_entry_percentage := (
	    earle_count_entrys / total_count_entrys
	) * 100;
	END IF;
	RETURN NEXT;
	current_month := current_month + 1;
	END LOOP;
	END;
	$$ LANGUAGE 
PLPGSQL; 

CREATE VIEW PART3_17 
	AS SELECT * FROM get_early_entrance_percentage();
; 

;

;