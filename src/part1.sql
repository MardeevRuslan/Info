DROP TABLE IF EXISTS Peers CASCADE;

DROP TABLE IF EXISTS Tasks CASCADE;

DROP TABLE IF EXISTS Checks CASCADE;

DROP TYPE IF EXISTS check_status CASCADE;

DROP TABLE IF EXISTS P2P CASCADE;

DROP TABLE IF EXISTS Verter CASCADE;

DROP TABLE IF EXISTS TransferredPoints CASCADE;

DROP TABLE IF EXISTS Friends CASCADE;

DROP TABLE IF EXISTS Recommendations CASCADE;

DROP TABLE IF EXISTS TimeTracking CASCADE;

DROP TYPE IF EXISTS check_state CASCADE;

DROP TABLE IF EXISTS XP CASCADE;

CREATE TYPE check_status AS ENUM ('start', 'success', 'failure') ;

CREATE TYPE check_state AS ENUM ('1', '2') ;

------------------- TABLE Peers --------------------

CREATE TABLE
    IF NOT EXISTS Peers (
        Nickname VARCHAR NOT NULL PRIMARY KEY,
        Birthday DATE NOT NULL
    );

DELETE FROM Peers;

------------------- TABLE Tasks ------------------

CREATE TABLE
    IF NOT EXISTS Tasks (
        Title VARCHAR NOT NULL PRIMARY KEY,
        ParentTask VARCHAR REFERENCES Tasks (Title) ON DELETE CASCADE,
        MaxXP INT NOT NULL
    );

DELETE FROM Tasks;

-------------------- TABLE Checks -----------------------------

CREATE TABLE
    IF NOT EXISTS Checks (
        ID INT NOT NULL PRIMARY KEY,
        Peer VARCHAR NOT NULL REFERENCES Peers (Nickname) ON DELETE CASCADE,
        Task VARCHAR NOT NULL REFERENCES Tasks (Title) ON DELETE CASCADE,
        Date DATE NOT NULL
    );

DELETE FROM Checks;

------------------- TABLE P2P -------------------------------

CREATE TABLE
    P2P (
        ID INT NOT NULL PRIMARY KEY,
        "Check" INT NOT NULL references Checks (ID) ON DELETE CASCADE,
        CheckingPeers VARCHAR NOT NULL REFERENCES Peers (Nickname) ON DELETE CASCADE,
        State check_status,
        Time TIME,
        CONSTRAINT unique_check_peer_status UNIQUE ("Check", CheckingPeers, State)
    );

DELETE FROM P2P;

-------------------- table Verter ---------------------------------------------

CREATE TABLE
    Verter (
        ID INT NOT NULL PRIMARY KEY,
        "Check" INT NOT NULL references Checks (ID),
        State check_status,
        Time TIME
    );

--------------- TABLE TransferredPoints -------------------------------

CREATE TABLE
    IF NOT EXISTS TransferredPoints (
        ID INT NOT NULL PRIMARY KEY,
        CheckingPeer VARCHAR NOT NULL REFERENCES Peers (Nickname) ON DELETE CASCADE,
        CheckedPeer VARCHAR NOT NULL REFERENCES Peers (Nickname) ON DELETE CASCADE,
        PointsAmount INT NOT NULL
    );

DELETE FROM TransferredPoints;

------------------- TABLE Friends ------------------------

CREATE TABLE
    IF NOT EXISTS Friends (
        ID INT NOT NULL PRIMARY KEY,
        Peer1 VARCHAR NOT NULL REFERENCES Peers (Nickname) ON DELETE CASCADE,
        Peer2 VARCHAR NOT NULL REFERENCES Peers (Nickname) ON DELETE CASCADE
    );

DELETE FROM Friends;

--------------------- TABLE Recommendations ---------------------

CREATE TABLE
    IF NOT EXISTS Recommendations (
        ID INT NOT NULL PRIMARY KEY,
        Peer VARCHAR NOT NULL REFERENCES Peers (Nickname) ON DELETE CASCADE,
        ReccomendedPeer VARCHAR NOT NULL REFERENCES Peers (Nickname) ON DELETE CASCADE
    );

DELETE FROM Recommendations;

--------------------- TABLE TimeTracking --------------------------------------

CREATE TABLE
    IF NOT EXISTS TimeTracking (
        ID INT NOT NULL PRIMARY KEY,
        Peer VARCHAR NOT NULL REFERENCES Peers (Nickname) ON DELETE CASCADE,
        Date DATE NOT NULL,
        Time TIME,
        State check_state
    );

DELETE FROM TimeTracking;

--------------------- TABLE XP ------------------------

CREATE TABLE
    IF NOT EXISTS XP (
        ID INT NOT NULL PRIMARY KEY,
        "Check" INT NOT NULL references Checks (ID) ON DELETE CASCADE,
        XPAmount INT NOT NULL
    );

DELETE FROM XP;

------------------------- PROCEDURE IMPORT_TABLE_TO_CSV -------------------

CREATE OR REPLACE PROCEDURE IMPORT_TABLE_TO_CSV(PATH 
VARCHAR, DELIM CHAR) LANGUAGE PLPGSQL AS $$ 
	BEGIN
	EXECUTE
	    format(
	        'COPY peers FROM ''%s/peers.csv''   WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY tasks FROM ''%s/tasks.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY friends FROM ''%s/friends.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY checks FROM ''%s/checks.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY recommendations FROM ''%s/recommendations.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY timetracking FROM ''%s/timetracking.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY p2p FROM ''%s/p2p.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY transferredpoints FROM ''%s/transferredpoints.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY verter FROM ''%s/verter.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY xp FROM ''%s/xp.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	DELIMITER;
	END;
$$; 

--------------------- PROCEDURES EXPORT_TABLE_TO_CSV -----------

CREATE OR REPLACE PROCEDURE EXPORT_TABLE_TO_CSV(PATH 
VARCHAR, DELIM CHAR) LANGUAGE PLPGSQL AS $$ 
	BEGIN
	EXECUTE
	    format(
	        'COPY peers FROM ''%s/peers.csv''  WITH (FORMAT CSV, DELIMITER ''%L'', HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY p2p TO ''%s/p2p.csv'' WITH (FORMAT CSV, DELIMITER ''%L'', HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY checks TO ''%s/checks.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY friends TO ''%s/friends.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY peers TO ''%s/peers.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY recommendations TO ''%s/recommendations.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY tasks TO ''%s/tasks.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY timetracking TO ''%s/timetracking.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY transferredpoints TO ''%s/transferredpoints.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY verter TO ''%s/verter.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	EXECUTE
	    format(
	        'COPY xp TO ''%s/xp.csv'' WITH (FORMAT CSV, DELIMITER %L, HEADER)',
	        path,
	        delim
	    );
	DELIMITER ;
	END;
$$; 