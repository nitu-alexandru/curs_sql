SELECT * FROM ALEX_AUTHORS;

CREATE TABLE logs (
    log_id number,
    start_date date default sysdate,
    end_date date,
    log_process varchar2(5000),
    log_state varchar(25) check(log_state in ('Success','Error')),
    log_zone varchar(25) check(log_zone in ('staging','processed'))
);



CREATE SEQUENCE log_seq START WITH 1 -- Starting value of the sequence 

INCREMENT BY 1 -- Increment value for each new row 

NOCACHE;

SELECT * FROM logs;

SELECT * FROM logs;

CREATE OR REPLACE PROCEDURE processed_category 
(
    id in NUMBER,
    last_load_date in date
 )
AS 
BEGIN
    INSERT INTO logs (log_process, log_state, log_zone, log_id) 
    VALUES ('processed_category','Success', 'processed', id);
    COMMIT;
    
    FOR i IN (
            
        SELECT 
        DISTINCT json_value(RAW_EVENT, '$.category') AS CATEGORY_NAME
        FROM 
        ALEX_STAG_EVENTS
        WHERE 
        json_value(RAW_EVENT, '$.category') IS NOT NULL
        and load_date > last_load_date 
        and  not exists (select category_name from alex_categories where category_name = json_value(RAW_EVENT, '$.category'))

    )
        LOOP
            INSERT INTO ALEX_CATEGORIES
            VALUES (ALEX_CATEGORY_SEQ.NEXTVAL, i.CATEGORY_NAME, SYSDATE);
        END LOOP;
    
    UPDATE logs
    SET END_DATE = SYSDATE
    WHERE LOG_ID = id;
    COMMIT;
    EXCEPTION
        WHEN OTHERS
            THEN 
                ROLLBACK;
                UPDATE logs
                SET END_DATE = SYSDATE,
                LOG_STATE = 'Error'
                WHERE LOG_ID = id;
                COMMIT;
    
END;
/
DECLARE
 MAX_LOAD_d DATE;
 BEGIN
 
 select max(CATEGORY_load_date) into MAX_LOAD_d from ALEX_CATEGORIES;
 processed_category(log_seq.nextval, MAX_LOAD_d );

 END;


SELECT * FROM logs;
SELECT * FROM alex_stag_events;
SELECT * FROM ALEX_CATEGORIES;
TRUNCATE TABLE ALEX_CATEGORIES;


BEGIN

    DBMS_SCHEDULER.create_job (

        job_name        => 'load_alex_categories',

        job_type        => 'PLSQL_BLOCK',

        job_action      => 'DECLARE
                            MAX_LOAD_d DATE;
                            BEGIN
                            select max(CATEGORY_load_date) into MAX_LOAD_d from ALEX_CATEGORIES;
                            processed_category(log_seq.nextval, MAX_LOAD_d );
                            END;', 

        start_date      => SYSTIMESTAMP,

        repeat_interval => 'FREQ=MINUTELY; INTERVAL=1',

        enabled         => TRUE

    );

END;

/


