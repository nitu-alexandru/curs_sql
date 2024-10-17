SELECT /*+ GATHER_PLAN_STATISTICS */
    Title, 
    (SELECT CategoryName FROM Categories WHERE Categories.CategoryID = Books.CategoryID) AS CategoryName
FROM Books;


SELECT * FROM TABLE(DBMS_XPLAN.DISPLAY_CURSOR(NULL, NULL, 'ALLSTATS LAST'));
SET AUTOTRACE ON


--=========
SELECT * FROM BOOKS;

SELECT 
    Title, 
    (SELECT CategoryName FROM Categories WHERE Categories.CategoryID = Books.CategoryID) AS CategoryName
FROM Books;


with temp as (
SELECT categoryid, CategoryName FROM Categories 
)

select * from temp t
INNER join books b
on b.CategoryID = t.CategoryID;


SELECT b.Title, c.CategoryName FROM Books b
INNER join Categories c
on b.CategoryID = c.CategoryID;

--======================================================
SELECT * FROM Customers;
SELECT * FROM Sales;

SELECT 
    c.CustomerID, 
    c.FirstName, 
    c.LastName 
FROM Customers c;

SELECT * FROM Customers;
SELECT * FROM Sales;

--===============================================================
SELECT * FROM BOOKS;
SELECT * FROM Authors;

SELECT 
    b.Title, 
    a.FirstName, 
    a.LastName 
FROM Books b, Authors a;

SELECT    
    b.Title, 
    a.FirstName, 
    a.LastName 
    FROM books b
--INNER
    FULL JOIN Authors a
ON b.authorid = a.authorid
WHERE b.authorid is not null;

--==========================================================
SELECT * FROM Customers;
SELECT * FROM Sales;

SELECT DISTINCT
    c.CustomerID, 
    c.FirstName, 
    c.LastName 
FROM Customers c
INNER JOIN Sales s ON c.CustomerID = s.CustomerID;

-- CTE CU CUSTOMER ID DIN SALES
-- INVERSARE JOIN CU DISTINCT CUSTID DIN SALES
-- CUSTID EXIST IN SALES CUSTID
-- GROUP BY TOATE

SELECT c.CustomerID,c.FirstName, c.LastName  FROM Customers c
JOIN Sales s ON c.CustomerID = s.CustomerID
GROUP BY c.CustomerID,c.FirstName, c.LastName;

WITH temp as (
 SELECT DISTINCT(CUSTOMERID) FROM Sales
)
SELECT    
c.CustomerID, 
    c.FirstName, 
    c.LastName 
FROM temp t
INNER JOIN customers c
ON T.CustomerID = C.CustomerID;


WITH temp as (
 SELECT DISTINCT(CUSTOMERID) FROM Sales
)
SELECT   
c.CustomerID, 
    c.FirstName, 
    c.LastName 
FROM customers C WHERE existS  (select * from temp WHERE customerid = c.customerid);
-- EXISTS < IN (TIMP)


SELECT DISTINCT(s.customerid),
    c.CustomerID, 
    c.FirstName, 
    c.LastName 
FROM Sales s
INNER JOIN Customers c ON c.CustomerID = s.CustomerID;

--==========================================================

--Exercise 5: Using Subquery Instead of a JOIN
--Description: Fetch book titles along with their authors. Use a subquery instead of a more efficient join.


WITH temp as (
    SELECT authorid,
        FirstName || ' ' || LastName as nume
        FROM Authors
)
SELECT b.title, t.nume FROM books b
inner join temp t
ON b.authorid = t.authorid;


WITH temp as (
    SELECT 
        authorid,
        FirstName || ' ' || LastName as nume
        FROM Authors
)
SELECT b.title, t.nume FROM books b
natural join temp t;


SELECT 
    b.Title, 
    (SELECT a.FirstName || ' ' || a.LastName FROM Authors a WHERE a.AuthorID = b.AuthorID) AS Author

FROM Books b;

--==========================================================
--Exercise 6: Aggregation Without Grouping
--Description: Count the number of books per category, using a query that calculates totals inefficiently without proper grouping.

SELECT * FROM Books;
SELECT 
    b.CategoryID, 
    COUNT(b.BookID) AS BookCount 
FROM Books b
GROUP BY b.CategoryID;


SELECT 
    COUNT(b.BookID) OVER (PARTITION BY b.CategoryID ORDER BY b.CategoryID DESC) AS BookCount ,
    b.CategoryID
FROM Books b;

--================================================================================================

--Exercise 7: Double Subquery for Simple Condition
--Description: Find customers who made more than one purchase by using nested subqueries instead of aggregation.

SELECT * FROM SALES;
SELECT 
    CustomerID 
FROM Customers c
WHERE exists (
    SELECT CustomerID 
    FROM Sales where c.customerid = customerid);
    
    
SELECT COUNT(CUSTOMERID), CUSTOMERID
FROM SALES
GROUP BY CUSTOMERID
HAVING COUNT(CUSTOMERID)>1;


--================================================================================================
--Exercise 14: Non-Optimized Date Filter
--Description: Retrieve sales from the year 2021. This query prevents index use by wrapping the `SaleDate` in a function.
SELECT * FROM SALES;

SELECT 
    SaleID, 
    SaleDate 
FROM Sales 
WHERE TO_CHAR(SaleDate, 'YYYY') = '2021';

SELECT 
    SaleID, 
    SaleDate 
FROM Sales 
WHERE EXTRACT(YEAR FROM SaleDate) = '2021';

SELECT 
    SaleID, 
    SaleDate 
FROM Sales 
WHERE TO_CHAR(SaleDate, 'YYYY') BETWEEN  '2021' AND '2021';


SELECT 
    SaleID, 
    SaleDate 
FROM Sales 
WHERE SaleDate BETWEEN '01-JAN-2021 00:00:00' AND '31-DEC-2021 00:00:00';

SELECT 
    SaleID, 
    SaleDate 
FROM Sales 
WHERE SaleDate LIKE '%2021%' ;

-===========================================================================================

--Exercise 15: Multiple Subqueries in SELECT Clause
--Description: Get the title of the book with the highest price, using multiple subqueries in the `SELECT` clause.

SELECT 
    (SELECT Title FROM Books WHERE Price = (SELECT MAX(Price) FROM Books)) AS MostExpensiveBook,
    (SELECT Price FROM Books WHERE Price = (SELECT MAX(Price) FROM Books)) AS HighestPrice;

SELECT * FROM BOOKS;

SELECT MAX(PRICE), TITLE FROM BOOKS
ORDER BY PRICE DESC;

SELECT PRICE, TITLE FROM BOOKS
WHERE PRICE = (SELECT MAX(Price) FROM Books);

-- NU MERGE DACA AI 2 VALORI CU PRICE =
SELECT PRICE, TITLE FROM BOOKS
WHERE ROWNUM = 1
ORDER BY PRICE DESC;


select price from books
order by price desc
fetch first 1 rows only;

 

select max(price) from books
fetch first 10 rows only;


-===========================================================================================

WITH TEMP AS (
    SELECT MAX(PRICE) AS PRICE  FROM BOOKS 
    
)
SELECT * FROM BOOKS B
JOIN TEMP T
ON B.PRICE = T.PRICE;


CREATE INDEX BOOKS_PRICE ON BOOKS(PRICE)