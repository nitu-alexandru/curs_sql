set serveroutput on;
DECLARE
    v_AUTHOR_ID NUMBER;
    v_CATEGORY_ID NUMBER;
BEGIN
    FOR i IN (
        SELECT top (10),
            json_value(RAW_EVENT, '$.link') AS ARTICLE_LINK,
            json_value(RAW_EVENT, '$.headline') AS HEADLINE,
            json_value(RAW_EVENT, '$.short_description') AS SHORT_DESC,
            json_value(RAW_EVENT, '$.date') AS ARTICLE_DATE,
            json_value(RAW_EVENT, '$.category') AS CATEGORY,
            json_value(RAW_EVENT, '$.authors') AS AUTHOR,
            SYSDATE AS load_date
        FROM alex_stag_events
    ) LOOP

--        dbms_output.put_line(i.author);
--        SELECT aut_id INTO v_AUTHOR_ID FROM authors2 WHERE aut_name = regexp_substr(i.author, '[^,]+') fetch first 10 rows only;
        
        SELECT cat_id INTO v_CATEGORY_ID FROM categories2 WHERE cat_name = i.CATEGORY;
      -- Insert data into the ARTICLES table
        INSERT INTO alex_ARTICLES  VALUES (
            ALEX_articles_seq.NEXTVAL,  -- Assuming this is the sequence for article_id
            i.ARTICLE_LINK,
            i.HEADLINE,
            i.SHORT_DESC,
            TO_DATE(i.ARTICLE_DATE, 'YYYY-MM-DD'),  -- Converts string date to DATE type
            v_CATEGORY_ID,
            v_AUTHOR_ID,
            SYSDATE
        );
    END LOOP;

    -- Commit the transaction
--    COMMIT;
END;
/



--s-au mai dezactivat cheile tabelului alex_articles;    
    alter table alex_articles
        disable constraint FK_CATEGORY_ID;