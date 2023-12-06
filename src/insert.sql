-- Active: 1686291172146@@127.0.0.1@5435@school21

------------------------------- INSERT ----------------------------------------

INSERT INTO
    Peers (nickname, birthday)
VALUES ('Abobo', '1991-01-01'), ('Babobo', '1992-01-01'), ('Cabobo', '1993-02-02'), ('Dabobo', '1994-02-02'), ('Ebobo', '1995-03-03'), ('Zbobo', '2016-02-26');

INSERT INTO
    Tasks (title, parenttask, maxxp)
VALUES ('C1_s21_bash', NULL, 10), (
        'C2_s21_sttring',
        'C1_s21_bash',
        20
    ), (
        'C3_s21_math',
        'C2_s21_sttring',
        30
    ), (
        'C4_s21_decimal',
        'C3_s21_math',
        40
    ), (
        'C5_s21_calculator',
        'C4_s21_decimal',
        50
    ), (
        'CPP1_s21_bash',
        'C5_s21_calculator',
        60
    ), (
        'CPP2_s21_another_task',
        'CPP1_s21_bash',
        70
    ), (
        'CPP3_s21_yet_another_task',
        'CPP2_s21_another_task',
        80
    ), (
        'CPP4_s21_one_more_task',
        'CPP3_s21_yet_another_task',
        90
    ), (
        'CPP5_s21_calculator',
        'CPP4_s21_one_more_task',
        100
    ), (
        'A1_s21_maze',
        'CPP5_s21_calculator',
        110
    ), (
        'A2_s21_navigator',
        'A1_s21_maze',
        120
    ), (
        'A3_s21_parallels',
        'A2_s21_navigator',
        130
    ), (
        'A4_s21_crypto',
        'A3_s21_parallels',
        140
    ), (
        'A5_s21_maze',
        'A4_s21_crypto',
        150
    );

INSERT INTO
    Checks (ID, Peer, Task, Date)
VALUES (
        1,
        'Abobo',
        'C1_s21_bash',
        '2021-01-01'
    ), (
        2,
        'Babobo',
        'C2_s21_sttring',
        '2021-01-01'
    ), (
        3,
        'Cabobo',
        'C3_s21_math',
        '2021-02-02'
    ), (
        4,
        'Dabobo',
        'C4_s21_decimal',
        '2021-02-02'
    ), (
        5,
        'Ebobo',
        'C5_s21_calculator',
        '2021-03-03'
    ), (
        6,
        'Ebobo',
        'CPP1_s21_bash',
        '2021-03-03'
    ), (
        7,
        'Abobo',
        'C2_s21_sttring',
        '2021-03-03'
    );

INSERT INTO
    p2p (
        ID,
        "Check",
        checkingpeers,
        state,
        time
    )
VALUES (
        1,
        1,
        'Babobo',
        'start',
        '10:00:00'
    ), (
        2,
        1,
        'Babobo',
        'success',
        '11:00:00'
    ), (
        3,
        2,
        'Dabobo',
        'start',
        '13:00:00'
    ), (
        4,
        2,
        'Dabobo',
        'success',
        '14:00:00'
    ), (
        5,
        3,
        'Dabobo',
        'start',
        '13:00:00'
    ), (
        6,
        3,
        'Dabobo',
        'success',
        '14:00:00'
    ), (
        7,
        4,
        'Babobo',
        'start',
        '10:00:00'
    ), (
        8,
        4,
        'Babobo',
        'failure',
        '11:00:00'
    ), (
        9,
        5,
        'Babobo',
        'start',
        '10:00:00'
    ), (
        10,
        5,
        'Babobo',
        'success',
        '11:00:00'
    ), (
        11,
        6,
        'Abobo',
        'start',
        '10:00:00'
    ), (
        12,
        6,
        'Abobo',
        'success',
        '11:00:00'
    ), (
        13,
        7,
        'Babobo',
        'start',
        '11:00:00'
    ), (
        14,
        7,
        'Babobo',
        'success',
        '11:00:00'
    );

INSERT INTO
    Recommendations (id, peer, reccomendedpeer)
VALUES (1, 'Abobo', 'Babobo'), (2, 'Babobo', 'Cabobo'), (3, 'Cabobo', 'Dabobo');

INSERT INTO
    TimeTracking (id, peer, date, time, state)
VALUES (
        1,
        'Dabobo',
        '2021-01-25',
        '10:45:00',
        '1'
    ), (
        2,
        'Dabobo',
        '2021-01-25',
        '14:15:00',
        '2'
    ), (
        3,
        'Cabobo',
        '2021-02-20',
        '03:45:00',
        '1'
    ), (
        4,
        'Cabobo',
        '2021-02-20',
        '08:30:00',
        '2'
    ), (
        5,
        'Abobo',
        '2021-02-03',
        '10:00:00',
        '1'
    ), (
        6,
        'Abobo',
        '2021-02-03',
        '11:00:00',
        '2'
    ), (
        7,
        'Abobo',
        '2021-02-03',
        '14:30:00',
        '1'
    ), (
        8,
        'Abobo',
        '2021-02-03',
        '19:45:00',
        '2'
    ), (
        9,
        'Babobo',
        '2021-03-20',
        '14:00:00',
        '1'
    ), (
        10,
        'Babobo',
        '2021-03-20',
        '18:45:00',
        '2'
    ), (
        11,
        'Babobo',
        '2021-05-15',
        '09:30:00',
        '1'
    ), (
        12,
        'Babobo',
        '2021-05-15',
        '17:15:00',
        '2'
    ), (
        13,
        'Abobo',
        '2021-04-10',
        '08:15:00',
        '1'
    ), (
        14,
        'Abobo',
        '2021-04-10',
        '16:20:00',
        '2'
    ), (
        15,
        'Cabobo',
        '2021-04-10',
        '06:00:00',
        '1'
    ), (
        16,
        'Cabobo',
        '2021-04-10',
        '10:45:00',
        '2'
    ), (
        17,
        'Cabobo',
        '2021-06-30',
        '14:15:00',
        '1'
    ), (
        18,
        'Cabobo',
        '2021-06-30',
        '19:30:00',
        '2'
    ), (
        19,
        'Abobo',
        '2021-06-05',
        '07:00:00',
        '1'
    ), (
        20,
        'Abobo',
        '2021-06-05',
        '12:30:00',
        '2'
    ), (
        21,
        'Babobo',
        '2021-07-12',
        '03:45:00',
        '1'
    ), (
        22,
        'Babobo',
        '2021-07-12',
        '08:30:00',
        '2'
    ), (
        23,
        'Abobo',
        '2021-08-25',
        '07:45:00',
        '1'
    ), (
        24,
        'Abobo',
        '2021-08-25',
        '10:30:00',
        '2'
    ), (
        25,
        'Cabobo',
        '2021-08-20',
        '13:45:00',
        '1'
    ), (
        26,
        'Cabobo',
        '2021-08-20',
        '18:30:00',
        '2'
    ), (
        27,
        'Cabobo',
        '2021-09-05',
        '06:00:00',
        '1'
    ), (
        28,
        'Zbobo',
        '2021-09-05',
        '09:30:00',
        '1'
    ), (
        29,
        'Zbobo',
        '2021-09-05',
        '16:00:00',
        '2'
    ), (
        30,
        'Cabobo',
        '2021-09-05',
        '19:30:00,',
        '2'
    );

INSERT INTO
    verter (id, "Check", state, time)
VALUES (1, 2, 'start', '15:00:00'), (2, 2, 'failure', '16:00:00'), (3, 3, 'start', '15:00:00'), (4, 3, 'success', '16:00:00'), (5, 5, 'start', '15:00:00'), (6, 5, 'success', '16:00:00'), (7, 6, 'start', '15:00:00'), (8, 6, 'success', '16:00:00');

INSERT INTO
    friends (id, peer1, peer2)
VALUES (1, 'Abobo', 'Babobo'), (2, 'Babobo', 'Cabobo'), (3, 'Cabobo', 'Dabobo'), (4, 'Dabobo', 'Ebobo');

-- INSERT INTO TransferredPoints (id, checkingpeer, checkedpeer, pointsamount)

-- VALUES

-- (1, 'Babobo', 'Abobo', 1),

-- (2, 'Dabobo', 'Babobo', 1),

-- (3, 'Dabobo', 'Cabobo', 1),

-- (4, 'Babobo', 'Dabobo', 1),

-- (5, 'Babobo', 'Ebobo', 1),

-- (6, 'Abobo', 'Ebobo', 1);

INSERT INTO
    xp (id, "Check", xpamount)
VALUES (2, 3, 29), (3, 5, 40), (4, 6, 50);

-- CALL
--     export_table_to_csv(
--         '/Users/sommerha/SQL2_Info21_v1.0-1/src/export',
--         ','
--     );