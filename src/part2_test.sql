-- Active: 1686291172146@@127.0.0.1@5435@school21

/*
 1) Написать процедуру добавления P2P проверки
 Параметры: ник проверяемого, ник проверяющего, название задания, статус P2P проверки, время. 
 Если задан статус "начало", добавить запись в таблицу Checks (в качестве даты использовать сегодняшнюю). 
 Добавить запись в таблицу P2P. 
 Если задан статус "начало", в качестве проверки указать только что добавленную запись, иначе указать 
 проверку с незавершенным P2P этапом.
 */

CALL
    add_p2p_check(
        'Abobo',
        'Ebobo',
        'A1_s21_maze',
        'start',
        CURRENT_TIME :: TIME
    );

CALL
    add_p2p_check(
        'Abobo',
        'Ebobo',
        'A1_s21_maze',
        'success',
        CURRENT_TIME :: TIME
    );

CALL
    add_p2p_check(
        'Abobo',
        'Ebobo',
        'A1_s21_maze',
        'failure',
        CURRENT_TIME :: TIME
    );

/*
 2) Написать процедуру добавления проверки Verter'ом
 Параметры: ник проверяемого, название задания, статус проверки Verter'ом, время. 
 Добавить запись в таблицу Verter (в качестве проверки указать проверку 
 соответствующего задания с самым поздним (по времени) успешным P2P этапом)
 */

CALL
    add_verter_check(
        'Abobo' :: VARCHAR,
        'C2_s21_sttring' :: VARCHAR,
        'start' :: check_status,
        CURRENT_TIME :: TIME
    );

CALL
    add_verter_check(
        'Ebobo' :: VARCHAR,
        'C2_s21_sttring' :: VARCHAR,
        'start' :: check_status,
        CURRENT_TIME :: TIME
    );

/* 
 3) Написать триггер: после добавления записи со статутом "начало" 
 в таблицу P2P, изменить соответствующую запись в таблице TransferredPoints 
 */

--------------------- PROCEDURE fnc_trg_add_transferredpoints -----------

INSERT INTO
    Checks (ID, Peer, Task, Date)
VALUES ( (
            SELECT max(ID)
            FROM
                Checks
        ) + 1,
        'Abobo',
        'C1_s21_bash',
        '2021-01-01'
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
            SELECT max(ID)
            FROM p2p
        ) + 1, (
            SELECT max(ID)
            FROM
                Checks
        ),
        'Ebobo',
        'start',
        '10:00:00'
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
            SELECT max(ID)
            FROM p2p
        ) + 1, (
            SELECT max(ID)
            FROM
                Checks
        ),
        'Ebobo',
        'success',
        '10:00:00'
    );

/* 
 4) Написать триггер: перед добавлением записи в таблицу XP, проверить корректность добавляемой записи
 Запись считается корректной, если:
 Количество XP не превышает максимальное доступное для проверяемой задачи
 Поле Check ссылается на успешную проверку
 Если запись не прошла проверку, не добавлять её в таблицу.
 */

DELETE FROM xp;

INSERT INTO
    xp (id, "Check", xpamount)
VALUES (1, 3, 29), (2, 5, 40), (3, 6, 50);

INSERT INTO xp (id, "Check", xpamount) VALUES (4, 1, 9);

INSERT INTO xp (id, "Check", xpamount) VALUES (5, 3,50);