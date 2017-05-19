-- SLOWEST QUERIES today
SELECT UserName, QueryText, ElapsedTime, 
RANK() OVER(ORDER BY ElapsedTime DESC) AS RNK 
FROM DBC.QRYLOG
--FROM PDCRINFO.DBQLogTbl
WHERE STARTTIME(DATE) >= CURRENT_DATE-1 
AND DefaultDatabase='myDATABASE'
AND username like 'xvic%'
QUALIFY RNK <= 10


-- SLOWEST QUERIES last month
LOCK ROW FOR ACCESS 

SELECT UserName, QueryText,  
( ( firstresptime - starttime  ) HOUR( 4 )   ) AS ElapsedTime,
RANK() OVER(ORDER BY ElapsedTime DESC) AS RNK 
--FROM DBC.QRYLOG
FROM PDCRINFO.DBQLogTbl
WHERE STARTTIME(DATE) >= CURRENT_DATE-30
AND DefaultDatabase='myDATABASE'
--AND username like 'xvic%'
QUALIFY RNK <= 10


 -- myStProc history
LOCK ROW FOR ACCESS 
SELECT LogDate, QueryText,  
( ( firstresptime - starttime  ) HOUR( 4 )   ) AS ElapsedTime,
RANK() OVER(ORDER BY ElapsedTime DESC) AS RNK 
--FROM DBC.QRYLOG
FROM PDCRINFO.DBQLogTbl
WHERE STARTTIME(DATE) >= CURRENT_DATE-30
AND DefaultDatabase='myDATABASE'
--AND username like 'xvic%'
AND QueryText like '%myStProc%'



-- CPU intensive Queries
SELECT UserName, QueryText, AMPCPUTime, --TotalCPUTime, 
RANK() OVER(ORDER BY AMPCPUTime DESC) AS RNK
FROM DBC.QRYLOG
WHERE STARTTIME(DATE) >= CURRENT_DATE-5
AND DefaultDatabase='myDATABASE'
QUALIFY RNK <= 10

-----------------------------------------------------------------------------      
--You might have to join with the DBC.QryLogSQL (on query id and proc id) 
depending on whether DBQL was enabled to log no SQL text on QryLog and 
SQLs are logged on QryLogSQL.
----------------------------------------------------------------------------- 
select * FROM PDCRINFO.DBQLogTbl
WHERE STARTTIME(DATE) >= CURRENT_DATE-1


select * 
from Users
where userid like '%xvic%'





------- What is running slow now -------------------------
LOCK ROW FOR ACCESS
SELECT
mt.simid
,mt.sqlsessionid
,mt.TABLENAME
,(CURRENT_TIMESTAMP - mt.StartTime) DAY(4) TO SECOND as "CurrentRunTime"
FROM ZZ_Madonna m
INNER JOIN zz_madonnatrack mt
       ON m.SQLSessionID = mt.sqlsessionid
WHERE mt.CompleteTime IS NULL
AND m.NotifyTime IS NULL
AND m.SQLResult = 'Running'
AND (
       EXTRACT(MINUTE FROM CurrentRunTime) > 29
       OR EXTRACT(HOUR FROM CurrentRunTime) > 0
       OR EXTRACT(DAY FROM CurrentRunTime) > 0
)


----------------------------------------------------------------------------- 
Top CPU hungry queries
----------------------------------------------------------------------------- 
LOCK ROW FOR ACCESS
select  
      ProcID
    , QueryID
    , WDName           
    , FinalWDName       
    , cal.day_of_week  
    , pdr.starttime
    ,( ( pdr.firstresptime - pdr.starttime  )Minute( 4 )   ) AS ElapsedTime
    , AMPCPUTime
    , MaxAMPCPUTime * (hashamp () + 1) CPUImpact
    , CAST (100 - ((AmpCPUTime / (hashamp () + 1)) * 100 / NULLIFZERO (MaxAMPCPUTime)) AS INTEGER) AS CPUSkew
    , TotalIOCount
    , MaxAMPIO * (hashamp () + 1) IOImpact
    , CAST (100 - ((TotalIOCount / (hashamp () + 1)) * 100 / NULLIFZERO (MaxAMPIO) ) AS INTEGER) AS IOSkew
    , spoolUsage
    , AMPCPUTime * 1000 / nullifzero (TotalIOCount) LHR
    , TotalIOCount / nullifzero (AMPCPUTime * 1000) RHL
    , ParserCPUTime
  --  , Queryband
   -- , REGEXP_REPLACE(CAST(QueryText AS CHAR(3000)),'[\t\r\n\v\f|]', ' ', 1, 0, 'I') as QueryText
FROM PDCRINFO.DBQLogTbl pdr
INNER JOIN Sys_Calendar.Calendar cal
   ON cal.calendar_date=pdr.LogDate
    WHERE pdr.STARTTIME(DATE) >= CURRENT_DATE- interval '6' month
    and ampcputime>0
    AND QueryText like '%INSERT INTO gtt_table SELECT *  FROM myTable%' 
    
    
    --AND ElapsedTime>5
order by  ElapsedTime 
