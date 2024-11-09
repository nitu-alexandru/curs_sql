CREATE SEQUENCE authors2_seq START WITH 1 -- Starting value of the sequence INCREMENT BY 1 -- Increment value for each new row NOCACHE;
CREATE SEQUENCE articles_seq START WITH 1 -- Starting value of the sequence INCREMENT BY 1 -- Increment value for each new row NOCACHE;


BEGIN
    
    FOR i in (
--    SELECT  DISTINCT regexp_substr(json_value(RAW_EVENT, '$.authors'), '[^,]+')  AS autori FROM stag_events

SELECT count(distinct regexp_substr(json_value(RAW_EVENT, '$.authors'), '[^,]+'))  AS nr, 
regexp_substr(json_value(RAW_EVENT, '$.authors'), '[^,]+')  AS autori
FROM stag_events
group by regexp_substr(json_value(RAW_EVENT, '$.authors'), '[^,]+')
HAVING COUNT(distinct regexp_substr(json_value(RAW_EVENT, '$.authors'), '[^,]+'))= 1

)
    LOOP
      
        INSERT INTO AUTHORS2 
        values (authors2_seq.NEXTVAL, i.autori, SYSDATE );
    END LOOP;

END;



BEGIN

    FOR i in (
        SELECT 
        json_value(RAW_EVENT, '$.link') AS art_link,
        json_value(RAW_EVENT, '$.headline') AS headline,
        json_value(RAW_EVENT, '$.short_description') AS short_description,
        json_value(RAW_EVENT, '$.date') AS art_date,
        (SELECT CAT_ID FROM CATEGORIES2 WHERE CAT_NAME = json_value(RAW_EVENT, '$.category')) AS cat_id,
        (SELECT AUT_ID FROM AUTHORS2 WHERE AUT_NAME = regexp_substr(json_value(RAW_EVENT, '$.authors'), '[^,]+')) AS aut_id,
        SYSDATE AS load_date
        FROM stag_events
    )
    
    LOOP
        INSERT INTO ARTICLES VALUES (
        articles_seq.NEXTVAL, i.art_link, i.headline, i.short_description, to_date(i.art_date,'YYYY-MM-DD'), i.cat_id, i.aut_id, SYSDATE
        );
    END LOOP;

END;
