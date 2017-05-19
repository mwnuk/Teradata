CREATE VOLATILE TABLE  Employee
(
EMP_ID INTEGER,
MGR_ID INTEGER,
EMP_NAME VARCHAR(100)
)
ON COMMIT PRESERVE ROWS;



INSERT INTO Employee VALUES(202,201,'Mark');
INSERT INTO Employee VALUES(201,203,'Brian');
INSERT INTO Employee VALUES(203,204,'Sean');
INSERT INTO Employee VALUES(205,204,'Sean');
INSERT INTO Employee VALUES(204,null,'Sugato');

select * from Employee

DEV_ICE_SIMULATION_DATA

WITH RECURSIVE MGR_JRS( EMP_ID, MGR_ID, MGR_NAME, DEPTH) AS
(

    SELECT   EMPL.EMP_ID
           , EMPL.MGR_ID
           , EMPL.EMP_NAME 
           , 1 AS DEPTH
    FROM Employee empl
    WHERE MGR_ID=203

UNION ALL

    SELECT 
         MGR_JRS.EMP_ID
        ,EMPL.MGR_ID
       -- ,empl1.EMP_NAME
        ,MGR_JRS.DEPTH + 1
    FROM MGR_JRS 
INNER JOIN Employee empl
    ON MGR_JRS.MGR_ID = EMPL.EMP_ID

--INNER JOIN Employee empl1
--    ON empl.mgr_id = empl1.emp_id
   WHERE  MGR_JRS.DEPTH<5 

)

SELECT * FROM MGR_JRS;

------------------------------------------------
SELECT EMPL.EMP_ID, EMPL.MGR_ID, EMPL1.EMP_NAME AS MGR_NAME, 1 AS DEPTH
FROM Employee empl
inner join Employee empl1
on empl.mgr_id = empl1.emp_id
WHERE empl.EMP_ID=202
------------------------------------------------

 WITH RECURSIVE temp_table (EMP_ID) AS

   (SELECT root.EMP_ID

    FROM employee AS root

    WHERE root.MGR_ID = 204

 UNION ALL 

    SELECT indirect.EMP_ID

    FROM temp_table AS direct, employee AS indirect

    WHERE direct.EMP_ID = indirect.MGR_ID

   )

    SELECT * 

    FROM temp_table 

    ORDER BY EMP_ID;
               