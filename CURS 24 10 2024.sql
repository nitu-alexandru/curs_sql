

--=24.10

SELECT * FROM user_tables;

SELECT * FROM EMPLOYEES
ORDER BY MANAGER_ID ASC;

WITH temp as (

    SELECT 
    EMPLOYEE_ID,
    FIRST_NAME,
    LAST_NAME,
    MANAGER_ID,
    DENSE_RANK() OVER(ORDER BY MANAGER_ID DESC)
    FROM EMPLOYEES

    
)
SELECT  * FROM temp;

--===== DE FACUT FARA RECURSIVA ====----
SELECT e1.Manager_ID,

COUNT(*) AS Depth,

RANK() OVER (ORDER BY COUNT(*) DESC, e1.Manager_ID) AS Rank

FROM Employees e1

JOIN Employees e2 ON e1.Manager_ID = e2.Employee_ID

--WHERE e1.Manager_ID IS NOT NULL

GROUP BY e1.Manager_ID

ORDER BY Depth;
--=====================================

--==== 5. -> WORK ===---


--1. Basic Transaction with COMMIT
--Insert a new customer into the Customers table and commit the transaction.

SELECT * FROM CUSTOMERS;
SELECT * FROM CUSTOMERS WHERE CUSTOMERID = 2004;

Insert into CUSTOMERS (CUSTOMERID,FIRSTNAME,LASTNAME,EMAIL,PHONE,ADDRESS,JOINDATE) 
values (2005,'IONUT IONEL','IONICA','IONICA@IONEL.com','555-124','4 GARA HERASTRAU',to_date('24-10-2024 09:37:00','DD-MM-YYYY HH24:MI:SS'));

Insert into CUSTOMERS (CUSTOMERID,FIRSTNAME,LASTNAME,EMAIL,PHONE,ADDRESS,JOINDATE) 
values (CUSTOMERS_SEQ.NEXTVAL,'IONUT IONEL','IONICA','IONICA@IONEL.com','555-124','4 GARA HERASTRAU',to_date('24-10-2024 09:37:00','DD-MM-YYYY HH24:MI:SS'));


SET SERVEROUTPUT ON;
declare 
     v_sqe number;
BEGIN
    select CUSTOMERS_SEQ.nextval into v_sqe FROM DUAL;
    Insert into CUSTOMERS (CUSTOMERID,FIRSTNAME,LASTNAME,EMAIL,PHONE,ADDRESS,JOINDATE) 
    values (v_sqe,'GELU GELUTU','GELICA','GELUT@IONEL.com','555-124','5 GARA HERASTRAU',to_date('24-10-2024 09:38:00','DD-MM-YYYY HH24:MI:SS'));
    
    COMMIT;
    FOR rec IN (SELECT CustomerID, FirstName, LastName, Email, Phone, Address, JoinDate FROM Customers WHERE CustomerID = v_sqe)
    LOOP DBMS_OUTPUT.PUT_LINE('CustomerID: ' || rec.CustomerID || ', Name: ' || rec.FirstName || ' ' || rec.LastName || ', Email: ' || rec.Email || ', Phone: ' || rec.Phone || ', Address: ' || rec.Address || ', JoinDate: ' || TO_CHAR(rec.JoinDate, 'YYYY-MM-DD')); END LOOP;
    
END;

ALTER SEQUENCE my_sequence INCREMENT BY 993;

--2. Transaction with ROLLBACK
--Insert a new book into the Books table, then roll back the transaction to cancel the insertion.
SELECT * FROM BOOKS;

BEGIN

    Insert into BOOKS  
    values (BOOKS_SEQ.NEXTVAL,'HARAP ALB AND FRIENDS','2','501','1000',to_date('18-10-2022 14:32:02','DD-MM-YYYY HH24:MI:SS'),'Genre_0');
    

    ROLLBACK;
    
END;
--==========================================

--3. Using TRY-CATCH with Transactions
--Write a transaction that updates the price of a book in the Books table. Use a TRY-CATCH block to handle any errors and roll back the transaction if an error occurs.

SELECT * FROM BOOKS;

BEGIN
        
    UPDATE BOOKS
    SET    PRICE = 'afafaf' 
    WHERE  BOOKID = 502;
    
    DBMS_OUTPUT.PUT_LINE('Succes: ' || SQLERRM);
    COMMIT;
    EXCEPTION -- Handle any exceptions that occur 
    WHEN OTHERS THEN -- Roll back the transaction if an error occurs 
    ROLLBACK; -- Output the error message 
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
    
END;


BEGIN
    DECLARE  ErrorOccurred BOOLEAN;
    
    UPDATE BOOKS
    SET    PRICE = 'afafaf' 
    WHERE  BOOKID = 502;
    
    IF ErrorOccurred THEN
    DBMS_OUTPUT.PUT_LINE('Error: ' || SQLERRM);
   
    ROLLBACK; -- Output the error message 
    ELSE COMMIT;
    DBMS_OUTPUT.PUT_LINE('Succes: ' || SQLERRM);
    END IF;
    
END;


--4. Multiple Insert Operations in a Transaction
--Insert a new customer, a new book, and a new sale in a single transaction. Commit the transaction if all operations are successful.

BEGIN
    SAVEPOINT salvare_1; 
    --1. 
    INSERT INTO CUSTOMERS 
    values (CUSTOMERS_SEQ.NEXTVAL,'IULICA','IULICA DA O BERE','BT@IONEL.com','555-124','UNDEVA IN CLUJ...',to_date('24-10-2024 09:38:00','DD-MM-YYYY HH24:MI:SS'));
    
--    EXCEPTION -- Handle any exceptions that occur 
--    WHEN OTHERS THEN -- Roll back the transaction if an error occurs 
--    ROLLBACK TO salvare_1; -- Output the error message 
    
    --2.
    Insert into BOOKS  
    values (BOOKS_SEQ.NEXTVAL,'DRAGOSTE IN LAN-UL DE GRAU','A','501','9999',to_date('18-10-2022 14:32:02','DD-MM-YYYY HH24:MI:SS'),'Genre_1');
    
--    EXCEPTION -- Handle any exceptions that occur 
--    WHEN OTHERS THEN -- Roll back the transaction if an error occurs 
--    ROLLBACK TO salvare_1; -- Output the error message 

    --3.
    Insert into SALES
    VALUES (SALES_SEQ.NEXTVAL, 999, '28-05-2024 12:56:52',3,1989);
    COMMIT;
    EXCEPTION -- Handle any exceptions that occur 
    WHEN OTHERS THEN -- Roll back the transaction if an error occurs 
    ROLLBACK TO salvare_1; -- Output the error message 

END;


SELECT * FROM SALES;


BEGIN
    --1. 
    INSERT INTO CUSTOMERS 
    values (CUSTOMERS_SEQ.NEXTVAL,'IULICA','IULICA -> SUCUL E PT FETE','BT@IONEL.com','555-124','UNDEVA IN CLUJ...',to_date('24-10-2024 09:38:00','DD-MM-YYYY HH24:MI:SS'));
    
--    EXCEPTION -- Handle any exceptions that occur 
--    WHEN OTHERS THEN -- Roll back the transaction if an error occurs 
--    ROLLBACK TO salvare_1; -- Output the error message 
    
    --2.
    Insert into BOOKS  
    values (BOOKS_SEQ.NEXTVAL,'DRAGOSTE IN LAN-UL DE GRAU','A','501','9999',to_date('18-10-2022 14:32:02','DD-MM-YYYY HH24:MI:SS'),'Genre_1');
    
--    EXCEPTION -- Handle any exceptions that occur 
--    WHEN OTHERS THEN -- Roll back the transaction if an error occurs 
--    ROLLBACK TO salvare_1; -- Output the error message 

    --3.
    Insert into SALES
    VALUES (SALES_SEQ.NEXTVAL, 999, '28-05-2024 12:56:52',3,1989);
    COMMIT;
    EXCEPTION -- Handle any exceptions that occur 
    WHEN OTHERS THEN -- Roll back the transaction if an error occurs 
    ROLLBACK ; -- Output the error message 

END;




BEGIN
    
    --1. 
    INSERT INTO CUSTOMERS 
    values (CUSTOMERS_SEQ.NEXTVAL,'IULICA','IULICA DA UN VIN ROSU ALB CA FATA','BT@IONEL.com','555-124','UNDEVA IN CLUJ...',to_date('24-10-2024 09:38:00','DD-MM-YYYY HH24:MI:SS'));
    SAVEPOINT salvare_1;
--    EXCEPTION -- Handle any exceptions that occur 
--    WHEN OTHERS THEN -- Roll back the transaction if an error occurs 
--    ROLLBACK TO salvare_1; -- Output the error message 
    
    --2.
    Insert into BOOKS  
    values (BOOKS_SEQ.NEXTVAL,'DRAGOSTE IN LAN-UL DE LUCERNA','A','501','2',to_date('18-10-2022 14:32:02','DD-MM-YYYY HH24:MI:SS'),'Genre_1');
    
--    EXCEPTION -- Handle any exceptions that occur 
--    WHEN OTHERS THEN -- Roll back the transaction if an error occurs 
--    ROLLBACK TO salvare_1; -- Output the error message 

    --3.
    Insert into SALES
    VALUES (SALES_SEQ.NEXTVAL, 999, '28-05-2024 12:56:52',3,1989);
    COMMIT;
    EXCEPTION -- Handle any exceptions that occur 
    WHEN OTHERS THEN -- Roll back the transaction if an error occurs 
    ROLLBACK TO salvare_1; -- Output the error message 

END;
