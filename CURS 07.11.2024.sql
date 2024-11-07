
--==================================== 07/11/2024

SELECT * FROM USER_tables;

SELECT * FROM stag_events;

SELECT DISTINCT json_value(RAW_EVENT, '$.category') AS Categorie FROM stag_events;

SELECT DISTINCT json_value(RAW_EVENT, '$.category') AS Categorie FROM stag_events;

SELECT DISTINCT json_value(RAW_EVENT, '$.category') AS Categorie FROM stag_events
WHERE LOAD_DATE > (SELECT MAX(LOAD_DATE) FROM categories2);


BEGIN

    FOR i in (SELECT DISTINCT json_value(RAW_EVENT, '$.category') AS Categorie FROM stag_events)
    
    LOOP
    
        INSERT INTO categories2 
        values (CATEGORY2_SEQ.NEXTVAL, i.CATEGORIE, SYSDATE );
    
    END LOOP;

END;



BEGIN
    
    FOR i in (
    SELECT DISTINCT json_value(RAW_EVENT, '$.category') AS Categorie FROM stag_events
    WHERE LOAD_DATE > (SELECT MAX(LOAD_DATE) FROM categories2)
    AND NOT EXISTS (SELECT 1 FROM categories2 WHERE json_value(RAW_EVENT, '$.category') = cat_name)
    )
    
    LOOP
    
        INSERT INTO categories2 
        values (CATEGORY2_SEQ.NEXTVAL, i.CATEGORIE, SYSDATE );
    
    END LOOP;

END;



SELECT * FROM categories2;


CREATE TABLE categories2 (
    cat_id number primary key,
    cat_name varchar(50),
    load_date DATE DEFAULT SYSDATE
);


CREATE TABLE authors2 (
    aut_id number primary key,
    aut_name varchar2(250),
    load_date DATE DEFAULT SYSDATE  
    
);

CREATE TABLE articles (
    art_id number primary key,
    art_link varchar2(500),
    headline varchar2(500),
    short_desc varchar2(2000),
    art_date DATE,
    cat_id NUMBER,
    aut_id number,
    load_date DATE DEFAULT SYSDATE,
    CONSTRAINT fk_categories2 FOREIGN KEY (cat_id) REFERENCES categories2(cat_id),
    CONSTRAINT fk_authors2 FOREIGN KEY (aut_id) REFERENCES authors2(aut_id)
);

CREATE SEQUENCE category2_seq START WITH 1 -- Starting value of the sequence INCREMENT BY 1 -- Increment value for each new row NOCACHE;

-- BRAVO FILIP <3
ALTER TABLE articles ADD  CONSTRAINT fk_categories2 FOREIGN KEY (cat_id) REFERENCES categories2(cat_id);
ALTER TABLE articles ADD CONSTRAINT fk_authors2 FOREIGN KEY (aut_id) REFERENCES authors2(aut_id);



INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/bc-soc-wcup-captains-armbands_n_632b1c98e4b0913a3dd7554a", "headline": "World Cup Captains Want To Wear Rainbow Armbands In Qatar", "category": "WORLD NEWS", "short_description": "FIFA has come under pressure from several European soccer federations who want to support a human rights campaign against discrimination at the World Cup.", "authors": "GRAHAM DUNBAR, AP", "date": "2022-09-21"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/man-sets-fire-protest-abe-funeral_n_632ae462e4b07198f0146afd", "headline": "Man Sets Himself On Fire In Apparent Protest Of Funeral For Japan''s Abe", "category": "WORLD NEWS", "short_description": "The incident underscores a growing wave of protests against the funeral for Shinzo Abe, who was one of the most divisive leaders in postwar Japanese politics.", "authors": "Mari Yamaguchi, AP", "date": "2022-09-21"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/fiona-threatens-to-become-category-4-storm-headed-to-bermuda_n_632ad1cae4b07198f0143244", "headline": "Fiona Threatens To Become Category 4 Storm Headed To Bermuda", "category": "WORLD NEWS", "short_description": "Hurricane Fiona lashed the Turks and Caicos Islands and was forecast to squeeze past Bermuda later this week.", "authors": "Dánica Coto, AP", "date": "2022-09-21"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/twitch-streamers-threaten-strike-gambling_n_632a72bce4b0cd3ec2628b20", "headline": "Twitch Bans Gambling Sites After Streamer Scams Folks Out Of $200,000", "category": "TECH", "short_description": "One man''s claims that he scammed people on the platform caused several popular streamers to consider a Twitch boycott.", "authors": "Ben Blanchet", "date": "2022-09-21"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/virginia-thomas-agrees-to-interview-with-jan-6-panel_n_632ba0f2e4b09d8701bbe16d", "headline": "Virginia Thomas Agrees To Interview With Jan. 6 Panel", "category": "U.S. NEWS", "short_description": "Conservative activist Virginia Thomas, the wife of Supreme Court Justice Clarence Thomas, has agreed to participate in a voluntary interview with the House panel investigating the Jan. 6 insurrection.", "authors": "Eric Tucker and Mary Clare Jalonick, AP", "date": "2022-09-21"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/valery-polyakov-dies_n_6329d497e4b0913a3dd5336c", "headline": "Russian Cosmonaut Valery Polyakov Who Broke Record With 437-Day Stay In Space Dies At 80", "category": "WORLD NEWS", "short_description": "Polyakov''s record-breaking trip to outer space saw him orbit Earth 7,075 times and travel nearly 187 million miles.", "authors": "Marco Margaritoff", "date": "2022-09-20"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/hulu-reboot-should-you-watch-it_n_6324a099e4b0eac9f4e18b46", "headline": "\'Reboot\' Is A Clever And Not Too Navel-Gazey Look Inside TV Reboots", "category": "CULTURE AND ARTS", "short_description": "Starring Keegan-Michael Key, Judy Greer and Johnny Knoxville, the Hulu show follows the revival of a fictional early 2000s sitcom.", "authors": "Marina Fang and Candice Frederick", "date": "2022-09-20"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/dodgers-baseball-obit-wills_n_6329feb3e4b07198f0134500", "headline": "Maury Wills, Base-Stealing Shortstop For Dodgers, Dies At 89", "category": "SPORTS", "short_description": "Maury Wills, who helped the Los Angeles Dodgers win three World Series titles with his base-stealing prowess, has died.", "authors": "Beth Harris, AP", "date": "2022-09-20"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/russian-controlled-ukrainian-regions-referendum_n_6329d53ae4b07198f012f023", "headline": "4 Russian-Controlled Ukrainian Regions Schedule Votes This Week To Join Russia", "category": "WORLD NEWS", "short_description": "The concerted and quickening Kremlin-backed efforts to swallow up four regions could set the stage for Moscow to escalate the war.", "authors": "Jon Gambrell, AP", "date": "2022-09-20"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/hurricane-fiona-barrels-toward-turks-and-caicos-islands_n_63298597e4b0ed991abcacf9", "headline": "Fiona Barrels Toward Turks And Caicos Islands As Category 3 Hurricane", "category": "WORLD NEWS", "short_description": "The Turks and Caicos Islands government imposed a curfew as the intensifying storm kept dropping copious rain over the Dominican Republic and Puerto Rico.", "authors": "Dánica Coto, AP", "date": "2022-09-20"}');




INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/reporter-gets-adorable-surprise-from-her-boyfriend-while-working-live-on-tv_n_632ccf43e4b0572027b10d74", "headline": "Reporter Gets Adorable Surprise From Her Boyfriend While Live On TV", "category": "U.S. NEWS", "short_description": "\'Who''s that behind you?\' an anchor for New York’s PIX11 asked journalist Michelle Ross as she finished up an interview.", "authors": "Elyse Wanshel", "date": "2022-09-22"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/puerto-rico-water-hurricane-fiona_n_632bdfd8e4b0d12b54014e13", "headline": "Puerto Ricans Desperate For Water After Hurricane Fiona’s Rampage", "category": "WORLD NEWS", "short_description": "More than half a million people remained without water service three days after the storm lashed the U.S. territory.", "authors": "DÁNICA COTO, AP", "date": "2022-09-22"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/mija-documentary-immigration-isabel-castro-interview_n_632329aee4b000d98858dbda", "headline": "How A New Documentary Captures The Complexity Of Being A Child Of Immigrants", "category": "CULTURE & ARTS", "short_description": "In \"Mija,\" director Isabel Castro combined music documentaries with the style of \"Euphoria\" and \"Clueless\" to tell a more nuanced immigration story.", "authors": "Marina Fang", "date": "2022-09-22"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/biden-un-russian-war-an-affront-to-bodys-charter_n_632ad9e3e4b0bfdf5e1bf5f7", "headline": "Biden At UN To Call Russian War An Affront To Body''s Charter", "category": "WORLD NEWS", "short_description": "White House officials say the crux of the president''s visit to the U.N. this year will be a full-throated condemnation of Russia and its brutal war.", "authors": "Aamer Madhani, AP", "date": "2022-09-21"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/bc-soc-wcup-captains-armbands_n_632b1c98e4b0913a3dd7554a", "headline": "World Cup Captains Want To Wear Rainbow Armbands In Qatar", "category": "WORLD NEWS", "short_description": "FIFA has come under pressure from several European soccer federations who want to support a human rights campaign against discrimination at the World Cup.", "authors": "GRAHAM DUNBAR, AP", "date": "2022-09-21"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/man-sets-fire-protest-abe-funeral_n_632ae462e4b07198f0146afd", "headline": "Man Sets Himself On Fire In Apparent Protest Of Funeral For Japan''s Abe", "category": "WORLD NEWS", "short_description": "The incident underscores a growing wave of protests against the funeral for Shinzo Abe, who was one of the most divisive leaders in postwar Japanese politics.", "authors": "Mari Yamaguchi, AP", "date": "2022-09-21"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/fiona-threatens-to-become-category-4-storm-headed-to-bermuda_n_632ad1cae4b07198f0143244", "headline": "Fiona Threatens To Become Category 4 Storm Headed To Bermuda", "category": "WORLD NEWS", "short_description": "Hurricane Fiona lashed the Turks and Caicos Islands and was forecast to squeeze past Bermuda later this week.", "authors": "Dánica Coto, AP", "date": "2022-09-21"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/twitch-streamers-threaten-strike-gambling_n_632a72bce4b0cd3ec2628b20", "headline": "Twitch Bans Gambling Sites After Streamer Scams Folks Out Of $200,000", "category": "TECH", "short_description": "One man''s claims that he scammed people on the platform caused several popular streamers to consider a Twitch boycott.", "authors": "Ben Blanchet", "date": "2022-09-21"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/virginia-thomas-agrees-to-interview-with-jan-6-panel_n_632ba0f2e4b09d8701bbe16d", "headline": "Virginia Thomas Agrees To Interview With Jan. 6 Panel", "category": "U.S. NEWS", "short_description": "Conservative activist Virginia Thomas, the wife of Supreme Court Justice Clarence Thomas, has agreed to participate in a voluntary interview with the House panel investigating the Jan. 6 insurrection.", "authors": "Eric Tucker and Mary Clare Jalonick, AP", "date": "2022-09-21"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/valery-polyakov-dies_n_6329d497e4b0913a3dd5336c", "headline": "Russian Cosmonaut Valery Polyakov Who Broke Record With 437-Day Stay In Space Dies At 80", "category": "WORLD NEWS", "short_description": "Polyakov''s record-breaking trip to outer space saw him orbit Earth 7,075 times and travel nearly 187 million miles.", "authors": "Marco Margaritoff", "date": "2022-09-20"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/hulu-reboot-should-you-watch-it_n_6324a099e4b0eac9f4e18b46", "headline": "\'Reboot\' Is A Clever And Not Too Navel-Gazey Look Inside TV Reboots", "category": "CULTURE & ARTS", "short_description": "Starring Keegan-Michael Key, Judy Greer and Johnny Knoxville, the Hulu show follows the revival of a fictional early 2000s sitcom.", "authors": "Marina Fang and Candice Frederick", "date": "2022-09-20"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/dodgers-baseball-obit-wills_n_6329feb3e4b07198f0134500", "headline": "Maury Wills, Base-Stealing Shortstop For Dodgers, Dies At 89", "category": "SPORTS", "short_description": "Maury Wills, who helped the Los Angeles Dodgers win three World Series titles with his base-stealing prowess, has died.", "authors": "Beth Harris, AP", "date": "2022-09-20"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/russian-controlled-ukrainian-regions-referendum_n_6329d53ae4b07198f012f023", "headline": "4 Russian-Controlled Ukrainian Regions Schedule Votes This Week To Join Russia", "category": "WORLD NEWS", "short_description": "The concerted and quickening Kremlin-backed efforts to swallow up four regions could set the stage for Moscow to escalate the war.", "authors": "Jon Gambrell, AP", "date": "2022-09-20"}');

INSERT INTO stag_events (raw_event) VALUES ('{"link": "https://www.huffpost.com/entry/hurricane-fiona-barrels-toward-turks-and-caicos-islands_n_63298597e4b0ed991abcacf9", "headline": "Fiona Barrels Toward Turks And Caicos Islands As Category 3 Hurricane", "category": "WORLD NEWS", "short_description": "The Turks and Caicos Islands government imposed a curfew as the intensifying storm kept dropping copious rain over the Dominican Republic and Puerto Rico.", "authors": "Dánica Coto, AP", "date": "2022-09-20"}');


