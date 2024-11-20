--1. This query fetches all article IDs (`art_id`) and headlines (`headline`) from the `proc.articles` table that belong to the category named "U.S. NEWS."
--cost 2466, time 161
--cost 59, time 425 cu indecsi
--cost 61, timp 65 cu un index
SELECT article_id, headline 
FROM iulia_articles 
WHERE category_id = (SELECT category_id 
                FROM iulia_categories where category_name='U.S. NEWS');
                
                
-------
CREATE or REPLACE PROCEDURE iulia_1  (
cat_name IN varchar2,
cat_id OUT number
)
AS
BEGIN
SELECT category_id into cat_id FROM iulia_categories where category_name=cat_name;
END;

set serveroutput on;
DECLARE 
cat_id number;
BEGIN
iulia_1('U.S. NEWS',cat_id);
FOR req in (
SELECT article_id, headline 
FROM iulia_articles 
WHERE category_id = cat_id)
loop
dbms_output.put_line(req.headline);
end loop;
END;


set serveroutput on;
--EXPLAIN PLAN FOR
DECLARE 
cat_id number;
req SYS_REFCURSOR;
BEGIN
iulia_1('U.S. NEWS',cat_id);
OPEN req FOR 
SELECT article_id, headline 
FROM iulia_articles 
WHERE category_id = cat_id;
DBMS_SQL.RETURN_RESULT(req);
END;

                
--cost 2467, time 400
SELECT a.article_id, a.headline FROM iulia_articles a
inner join iulia_categories c on a.category_id=c.category_id
where c.category_name='U.S. NEWS';

--cost 2467, time 345
--cost 58, time 78 cu indecsi
--cost 60, time 104 cu un index
with cte as (
SELECT article_id, headline, category_id 
FROM iulia_articles
)
select cte.article_id, cte.headline from cte
where cte.category_id in (SELECT category_id FROM iulia_categories 
where category_name='U.S. NEWS');

--cost 2467, time 369
SELECT /*+ INDEX(iulia_categories (category_name)) */ a.article_link, a.headline FROM iulia_articles a 
where category_id in (select category_id from iulia_categories  WHERE category_name='U.S. NEWS');

--cost 2467, time 409
SELECT /*+ PARALLEL(iulia_articles, 4) */a.article_link, a.headline  FROM iulia_articles a 
where category_id in (select category_id from iulia_categories  WHERE category_name='U.S. NEWS');


---------
drop index iulia_CATEGORIES_INDEX_1;
--ON iulia_categories (category_name, category_id);
drop INDEX iulia_ARTICLES_INDEX_1;
--ON iulia_articles (category_id,HEADLINE,article_id );

select * from iulia_articles;

SELECT /*+ DYNAMIC_SAMPLING(iulia_ARTICLES 10) */ *
FROM iulia_ARTICLES;


--2. This query retrieves the names of authors (`author_name`) and the count of their articles (`total_articles`). It filters authors who have written more than 5 articles using a `HAVING` clause.
--cost 2821, time 91313
--cost 507, time 113763
SELECT a.author_name AS author_name, COUNT(ar.article_id) AS total_articles
FROM iulia_articles ar
JOIN iulia_authors a ON ar.author_id = a.author_id
GROUP BY a.author_name
HAVING COUNT(ar.article_id) > 5;

--cost 2571, time 52417
--cost 257, time 60800 cu index
with cte as(
select author_id, count(article_id) as total_articles
from iulia_articles
group by author_id
)
select a.author_name, cte.total_articles
from cte inner join iulia_authors a on a.author_id=cte.author_id
where cte.total_articles>5;

--var DICA
--cost 2571, time 54321
--cost 257, time 48266 cu index
SELECT a.author_name, ac.total_articles
FROM (
    SELECT ar.author_id, COUNT(ar.article_id) AS total_articles
    FROM iulia_articles ar
    GROUP BY ar.author_id
    HAVING COUNT(ar.article_id) > 5
) ac
JOIN iulia_authors a
ON ac.author_id = a.author_id;

--var2 DICA
--cost 2571, time 52864
--cost 257, time 49633
WITH ArticleCounts AS (
        SELECT  ar.author_id,
        COUNT(ar.article_id) AS total_articles
        FROM iulia_articles ar
        GROUP BY ar.author_id
        )
SELECT a.author_name, ac.total_articles
FROM ArticleCounts ac
JOIN iulia_authors a
ON ac.author_id = a.author_id
WHERE ac.total_articles > 5;

--var FILIP
--cost 2821, time 89983
--cost 507, time 117534 cu index
WITH AuthorArticleCount AS (
    SELECT a.author_name AS author_name, COUNT(ar.article_id) AS total_articles
    FROM iulia_articles ar
    JOIN iulia_authors a ON ar.author_id = a.author_id
    GROUP BY a.author_name
)
SELECT author_name, total_articles
FROM AuthorArticleCount
WHERE total_articles > 5;

CREATE INDEX iulia_authors_index ON iulia_authors (author_name, author_id);
CREATE INDEX iulia_articles_1 ON iulia_articles (author_Id, article_id);

--var Bogdan
with cte as (
SELECT DISTINCT 
    a.author_name AS author_name,
    COUNT(ar.article_id) OVER (PARTITION BY a.author_id) AS total_articles
FROM iulia_articles ar
JOIN iulia_authors a ON ar.author_id = a.author_id
)
select * from cte where total_articles>5;


--3. This query retrieves each category's name (`category_name`) and the total number of articles (`total_articles`) in that category. The query uses a cross join (implicit join via `FROM a, c` syntax) and filters the results using the `WHERE` clause.
--cost 2472, time 70773
--cost 131, time 98969
SELECT c.category_name AS category_name, COUNT(a.article_id) AS total_articles
FROM iulia_articles a, iulia_categories c
WHERE a.category_id = c.category_id
GROUP BY c.category_name;

--cost 2472, time 40961
--cost 131, time 110917
with cte as (
select count(article_id) as total_articles, category_id from iulia_articles
group by category_id
)
select c.category_name, cte.total_articles from cte
inner join iulia_categories c on cte.category_id=c.category_id;

CREATE INDEX iulia_ARTICLES_INDEX_2 ON iulia_ARTICLES (CATegory_ID);

--var NITU
--cost 131, time 110743
with cte_table as (
    SELECT
        count(category_id) as numaratoare,
        category_id
    FROM iulia_ARTICLES
    GROUP BY category_id
)
SELECT c.numaratoare, c2.category_name FROM  cte_table c, iulia_categories c2
where c.category_id = c2.category_id;

--var FILIP
--cost 235, time 55
SELECT c.category_name AS category_name,
       (SELECT COUNT(a.article_id) 
        FROM iulia_articles a 
        WHERE a.category_id = c.category_id) AS total_articles
FROM iulia_categories c;

--var DICA
--cost 131, time 93868
SELECT c.category_name, COUNT(a.article_id) AS total_articles
FROM iulia_categories c
INNER JOIN iulia_articles a
ON a.category_id = c.category_id
GROUP BY c.category_name;

 
--var DICA 2
--cost 131, time `08384
WITH Numar_Articole AS (
    SELECT category_id, COUNT(article_id) AS total_articles
    FROM iulia_articles
    GROUP BY category_id
)
SELECT c.category_name, na.total_articles
FROM iulia_categories c
inner JOIN Numar_Articole na
ON c.category_id = na.category_id;

--var Bogdan
CREATE OR REPLACE FUNCTION get_articles_by_category(p_cat_name VARCHAR2)
RETURN SYS_REFCURSOR
AS
    v_cat_id NUMBER;
    cur_articles SYS_REFCURSOR;
BEGIN
    -- Get the cat_id
    iulia_1(p_cat_name, v_cat_id);
    -- Open a cursor for the query
    OPEN cur_articles FOR
        SELECT article_id, headline
        FROM iulia_articles
        WHERE category_id = v_cat_id;
    RETURN cur_articles;
END;
/
select get_articles_by_category('U.S. NEWS') from dual;

SELECT *
FROM TABLE(get_articles_by_category('U.S. NEWS'))
WHERE headline LIKE '%breaking%';


--var Alin
--cost 3, time 35
select * from alin_view;

create materialized view alin_view
build immediate
refresh complete on demand
as
select c.cat_name AS category_name,
       count(a.art_id) AS total_articles
from alin_categories c
left join alin_articles a on a.cat_id = c.cat_id
group by c.cat_name;

--var view clasic
--cost 131, time 109670
CREATE VIEW iulia_view AS
with cte as (
select count(article_id) as total_articles, category_id from iulia_articles
group by category_id
)
select c.category_name, cte.total_articles from cte
inner join iulia_categories c on cte.category_id=c.category_id;

select * from iulia_view;


--4. This query retrieves article IDs and headlines for two conditions:
--  1. Articles published on or after January 1, 2022.
--  2. Articles that belong to the category "U.S. NEWS."
--   The results are combined using a `UNION`, which removes duplicates.

--cost 5180, time 65368
SELECT article_id, headline 
FROM iulia_articles 
WHERE article_date >= TO_DATE('2022-01-01', 'YYYY-MM-DD')
UNION
SELECT article_id, headline 
FROM iulia_articles 
WHERE category_id = (SELECT category_id FROM iulia_categories WHERE category_name = 'U.S. NEWS');

--cost 4654, time 35147
with cte as(
SELECT article_id, headline 
FROM iulia_articles 
WHERE article_date >= TO_DATE('2022-01-01', 'YYYY-MM-DD')
UNION ALL
SELECT article_id, headline 
FROM iulia_articles 
WHERE category_id = (SELECT category_id FROM iulia_categories WHERE category_name = 'U.S. NEWS')
)
select distinct * from cte;

--cost 2464, time 58
SELECT article_id, headline 
FROM iulia_articles 
WHERE article_date >= TO_DATE('2022-01-01', 'YYYY-MM-DD')
or category_id = (SELECT category_id FROM iulia_categories WHERE category_name = 'U.S. NEWS');

--var Nitu
--cost 2464, time 53
SELECT 
article_id,
headline
FROM iulia_ARTICLES
WHERE article_date >= TO_DATE('2022-01-01', 'YYYY-MM-DD')
OR  category_id = (SELECT category_id FROM iulia_categories WHERE category_name = 'U.S. NEWS');


--var Filip
--cost 2464, time 63
WITH us_news_category AS (
    SELECT category_id
    FROM iulia_categories
    WHERE category_name = 'U.S. NEWS'
)
SELECT article_id, headline 
FROM iulia_articles 
WHERE article_date >= TO_DATE('2022-01-01', 'YYYY-MM-DD')
   OR category_id IN (SELECT category_id FROM us_news_category);
   

--5. This query ranks articles in each category by their publication date (`date`) in descending order. It retrieves only the most recent article for the category "U.S. NEWS."
--nu merge
SELECT a.article_id, a.headline, 
       RANK() OVER (PARTITION BY c.category_name ORDER BY a.article_date DESC) AS rank_in_category
FROM iulia_articles a
JOIN iulia_categories c ON a.category_id = c.category_id
WHERE c.category_name = 'U.S. NEWS' 
AND RANK() OVER (PARTITION BY c.category_name ORDER BY a.article_date DESC) = 1;

--cost 2468, time 42738
with cte as (
SELECT a.article_id, a.headline, 
       RANK() OVER (PARTITION BY c.category_name ORDER BY a.article_date DESC) AS rank_in_category
FROM iulia_articles a
JOIN iulia_categories c ON a.category_id = c.category_id
WHERE c.category_name = 'U.S. NEWS' 
)
select * from cte where cte.rank_in_category=1;

--cost 2468, time 41852
with cte as (
select category_id, category_name from iulia_categories where category_name = 'U.S. NEWS'
)
select a.article_id, a.headline,
RANK() OVER (PARTITION BY cte.category_name ORDER BY a.article_date DESC) AS rank_in_category
from cte inner join iulia_articles a on cte.category_id=a.category_id
fetch first rows only;

--cost 2468, time 42200
SELECT a.article_id, a.headline, 
       RANK() OVER (PARTITION BY c.category_name ORDER BY a.article_date DESC) AS rank_in_category
FROM iulia_articles a
JOIN iulia_categories c ON a.category_id = c.category_id
WHERE c.category_name = 'U.S. NEWS' 
fetch first 1 rows only;

select * from iulia_articles where article_id=2961;
select * from iulia_articles where headline like '%New Lava Flow Encroaches Onto Power Station Property%';

--cost 2468, time 42515
SELECT a.article_id, a.headline, 
       RANK() OVER (PARTITION BY c.category_name ORDER BY a.article_date DESC) AS rank_in_category
FROM iulia_articles a
JOIN iulia_categories c ON a.category_id = c.category_id
WHERE c.category_name = 'U.S. NEWS' 
OFFSET 0 ROWS FETCH NEXT 1 ROWS ONLY;

--var Nitu
--cost 2191 time 2497
with cte_table as (
    SELECT 
        ARTicle_DATE,
        CATegory_ID,
        headline,
        DENSE_RANK() OVER (PARTITION BY category_id order by article_date desc) as RANK_CAT
        FROM iulia_articles
)
SELECT c.article_date, c.rank_cat, cc.category_name, c.headline FROM cte_table c
INNER JOIN iulia_categories CC
ON c.category_id = cc.category_id
WHERE c.RANK_CAT = 1 AND CC.category_name = 'U.S. NEWS';