----------------------------------------------------------------------------------------------------
--  1. TABLE USAGE  
----------------------------------------------------------------------------------------------------
SELECT DB.DatabaseName AS DatabaseName      ,TBL.TVMName        AS TableName, TBL.tablekind                                                                           
    , OU.UsageType                                                                           
    ,OU.UserAccessCnt   AS UseCount                                                                       
    ,OU.UserInsertCnt   AS InsertCount                                                                    
    ,OU.UserUpdateCnt   AS UpdateCount                                                                              
    ,OU.UserDeleteCnt   AS DeleteCount                                                                 
    ,OU.SysAccessCnt    AS SysUseCount                                                                  
    ,OU.SysInsertCnt    AS SysInsertCount                                                                                
    ,OU.SysUpdateCnt    AS SysUpdateCount                                                                         
    ,OU.SysDeleteCnt    AS SysDeleteCount                                                                            
    ,CAST(OU.LastAccessTimeStamp AS DATE) AS DateLastUsed                                                                   
                                                                                
FROM  DBC.Dbase DB                                                                    
JOIN DBC.TVM  TBL                                                                         
    ON DB.databaseid   = TBL.databaseid                                                                  
LEFT JOIN DBC.ObjectUsage OU                                                                                
    ON DB.DatabaseId    = OU.DatabaseId                                                                                
    AND TBL.TVMId       = OU.ObjectId                                                                       
    AND OU.UsageType = 'DML'                                                   
WHERE  DB.databasename = 'SOME_DATABASE'                                                                       
AND INDEXNumber IS NULL                                                                        
AND FieldID IS NULL;      

----------------------------------------------------------------------------------------------------
-- 2. INDEX USAGE  
----------------------------------------------------------------------------------------------------

/* Object Usage of Indexes */                                                   
SELECT DB.DatabaseName                                                           
       ,TBL.TVMName AS TableName                                                           
       ,IND.Name AS IndexName                                                   
       ,OU.IndexNumber                                                   
       ,COLS.FieldName                                                      
       ,IND.FieldPosition                                                     
       ,OU.UsageType                                                         
       ,UserAccessCnt AS AccessCount                                                        
       ,CAST(OU.LastAccessTimeStamp AS DATE) AS DateLastUsed                                                                
      ,IND.CreateTimeStamp AS IndexCreateTS                                                      
      ,RT.TimeCreated AS DBQLRuleCreateTS                                                          
      ,RT.TimeAccessed AS DBQLRuleAccessTS                                                        
      ,IND.IndexType                                                          
FROM ObjectUsage OU                                                                
JOIN DBC.Dbase DB                                                        
    ON DB.DatabaseId = OU.DatabaseId                                                   
JOIN DBC.TVM TBL                                                          
    ON TBL.TVMId = OU.ObjectId                                                                
    AND TBL.DatabaseId = OU.DatabaseId                                                               
JOIN DBC.Indexes  IND                                                  
    ON IND.DatabaseId = OU.DatabaseId                                                 
                 AND IND.TableId =OU.ObjectId                                                               
                 AND IND.IndexNumber = OU.IndexNumber                                                      
                AND IND.FieldID=OU.FieldID                                                      
                 AND IND.TableID=TBL.TVMID                                                   
                 and IND.DatabaseID = TBL.DatabaseID                                                  
JOIN DBC.TVFields COLS                                                               
    ON COLS.DatabaseId = OU.DatabaseId                                                              
                 AND COLS.TableId = OU.ObjectId                                                            
                 AND COLS.FieldId = OU.FieldId                                                 
LEFT JOIN DBC.DBQLRuleTbl RT                                                  
    ON IND.DatabaseId = RT.UserID                                                           
WHERE OU.UsageType = 'DML'  
AND TableKind ='T'   -- F- functon,  'P' stproc , 'M' mcros                                 
AND DB.Databasename = 'SOME_DATABASE'                                                             
AND OU.IndexNumber is not null                                                             
-- and tablename = 'PARTS'                                                                
Order by DB.Databasename, TBL.tvmnamei,IND.IndexNumber,IND.FieldPosition;                                                           


-------------------------------------------------------------
--3. COLUMN USAGE 
-------------------------------------------------------------
SELECT
DB.DatabaseName                                                           
       ,TBL.TVMName AS TableName                                                           
       ,COL.fieldname AS ColumnName                                                   
       ,OU.IndexNumber                                                                                                          
       ,UserAccessCnt AS AccessCount                                                        
       ,CAST(OU.LastAccessTimeStamp AS DATE) AS DateLastUsed                                                                                                                  
      ,RT.TimeCreated AS DBQLRuleCreateTS  
FROM  DBC.Dbase DB                                                        
    ON DB.DatabaseId = OU.DatabaseId                                                   
JOIN DBC.TVM TBL                                                          
    --ON TBL.TVMId = OU.ObjectId                                                                
    ON TBL.DatabaseId = OU.DatabaseId                                                               
JOIN DBC.Indexes  IND                                                  
    ON IND.DatabaseId = OU.DatabaseId                                                 
                 AND IND.TableId =OU.ObjectId                                                               
                 AND IND.IndexNumber = OU.IndexNumber                                                      
                AND IND.FieldID=OU.FieldID                                                      
                 AND IND.TableID=TBL.TVMID                                                   
                 and IND.DatabaseID = TBL.DatabaseID                                                  
JOIN DBC.TVFields COL                                                            
    ON COL.DatabaseId = TBL.DatabaseId                                                              
          AND COL.TableId = TBL.tvmid                                                          

LEFT JOIN DBC.ObjectUsage OU                                                                
	ON DB.databaseID=OU.databaseID
	AND TBL.TVMid=OU.ObjectID
	AND COL.filedid= OU.fieldid
	AND OU>usageType='DML'
where DB.databasename = 'MYDBname'
and indexnumber is null
--and tbl.TVMNAme=='sometable'
		  
LEFT JOIN DBC.DBQLRuleTbl RT                                                  
    ON IND.DatabaseId = RT.UserID                                                           
WHERE OU.UsageType = 'DML'  
AND TableKind ='T'   -- F- functon,  'P' stproc , 'M' mcros                                 
AND DB.Databasename = 'SOME_DATABASE'                                                             
AND OU.IndexNumber is not null 

---------------------------------------------------------------------------
-- 4. STATISTICS Usage
---------------------------------------------------------------------------
SELECT
DB.DatabaseName                                                           
       ,TBL.TVMName AS TableName                                                           
       ,COALESCE(ST.StatsName, ST.ExpressionList,'Summary stats...') AS StatsNAme                                                   
                                                                                                          
       ,OU.UserAccessCnt 
       ,OU.SysAccessCnt  	   
       ,CAST(OU.LastAccessTimeStamp AS DATE) AS DateLastUsed   
	   ,ST.CreateTimeStamp,ST.StatsType
	   ,CURRENT_DATE - CAST(ST.CreateTimeStampAS DATE) StatsCreateSince
       ,RT.TimeCreated AS DBQLRuleCreateTS  
FROM DBC.STATSTbl ST 
JOIN DBC.Dbase DB                                                        
    ON DB.DatabaseId = ST.DatabaseId                                                   
JOIN DBC.TVM TBL                                                          
    --ON TBL.TVMId = OU.ObjectId                                                                
    ON TBL.DatabaseId = OU.DatabaseId                                                               
                                                
JOIN DBC.TVM TBL                                                            
    ON TBL.TVMId = ST.ObjectID                                                              

		  
LEFT JOIN DBC.DBQLRuleTbl RT                                                  
    ON ST.DatabaseId = RT.UserID                                                          

LEFT JOIN DBC.ObjectUsage OU                                                                
	ON DB.databaseID=OU.databaseID
	AND TBL.TVMid=OU.ObjectID
	AND ST.Statsid= OU.fieldid
	AND OU.usageType='STA'
	
where DB.databasename = 'SOME_DATABASE'




