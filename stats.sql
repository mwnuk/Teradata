
-----------------------------                                -----------------
--!!!!!!!!!!!!!!!!!!!!!!!!!!  HELPSTATS ( like Stat Wizard ) !!!!!!!!!!!!!!!!!
------------------------------------------------------------------------------
--It is a noteworthy technical detail, that Teradata internally considers all tables to be partitioned. 
--NPPI tables are nothing else than PPI tables with exactly one partition, namely partition number zero,  
--containing all table rows.  This is the reason why you should always collect statistics on the dummy 
--column PARTITION, even for not partitioned tables, as this is used by the optimizer to estimate the 
--table cardinality of NPPI tables.


--We don't have Statistics Wizard but there is equivalent command: 
DIAGNOSTIC HELPSTATS ON FOR SESSION; 
EXPLAIN 
SELECT *  FROM myTable



SHOW STATISTICS ON myDATABASE.myTable; 
SHOW  STATISTICS VALUES ON myDATABASE.myTable
--  http://developer.teradata.com/blog/carrie/2012/08/new-opportunities-for-statistics-collection-in-teradata-14-0

COLLECT STATISTICS
        USING MAXINTERVALS 300    -- The default maximum number of intervals is 250.  The valid range is 0 to 500.
               COLUMN ( col1,col2 )
 ON myDATABASE.myTable;             
               
COLLECT STATISTICS
        USING MAXVALUELENGTH 50    -- default length is 25 bytes, when previously it was 16.  If needed, you can specify well over 1000 bytes for a maximum value length.  No padding is done 
                COLUMN ( SimID,ESN )
 ON myDATABASE.myTable; 
 
 COLLECT STATISTICS
        USING SAMPLE 10 PERCENT    -- can be set at a table level instead of a system level  to reduce collection time 
                COLUMN ( SimID,ESN ) 
ON myDATABASE.myTable; 

 COLLECT STATISTICS  USING SYSTEM SAMPLE  -- default set by DBA 
                COLUMN ( SimID,ESN ) 
ON myDATABASE.myTable; 


 COLLECT STATISTICS  
                COLUMN PARTITION  
ON myDATABASE.myTable; 


SHOW STATISTICS ON myDATABASE.myTable; 
DROP STATISTICS ON myDATABASE.myTable; 

-- Statistics are in DBC 
-- Beginning with TD14 statistics are no longer stored in dbc.TVFields and dbc.Indexes, 
-- they have been moved into dbc.StatsTbl to facilitate several enhancements. 
-- A new view dbc.StatsV returns much of the information previously extracted in my StatsInfo query.
select * from DBC.TVFields where FieldStatistics is not null;
select * from  DBC.Indexes where IndexStatistics is not null;

select * from dbc.StatsTbl -- all stats are in it !!!!

-- THE BEST 
select * from dbc.StatsV where databasename='myDATABASE' and TABLENAME ='myTable' 
select * from dbc.ColumnStatsV where databasename='myDATABASE' and TABLENAME ='myTable' 
select * from dbc.MultiColumnStatsV where databasename='myDATABASE' and TABLENAME ='myTable' 

select * from dbc.IndexStatsV where databasename='myDATABASE' and TABLENAME ='myTable' 


--------------------------------------------------------------------------------------------------------------------------------------------------

HELP STATISTICS myDATABASE.myTable
HELP STATISTICS myDATABASE.myTable COLUMN myDATABASE.myTable.ESN;

DIAGNOSTIC "COLLECTSTATS, SAMPLESIZE=n" ON FOR SESSION;

--------------------------------------------------------------------------------------------------------------------------------------------------
--Diagnostic HELPSTATs results in a list of all possible statistics for a given request.
Diagnostic helpstats on for session;

DIAGNOSTIC "COLLECTSTATS, SAMPLESIZE=n" ON FOR SESSION;   --The default for USING SAMPLE is 2%, it can be modified globally using a dbscontrol field,

DIAGNOSTIC "COLLECTSTATS, SAMPLESIZE=30" ON FOR SESSION;

--------------------------------------------------------------------------------------------------------------------------------------------------
--You can request summary statistics for a table, but even if you never do that, each individual statistics collection 
-- statement causes summary stats to be gathered. 
SHOW SUMMARY STATISTICS VALUES ON myTable;

--------------------------------------------------------------------------------------------------------------------------------------------------
--REFRESH ALL STATISTICS
COLLECT STATISTICS ON myDATABASE.myTable;             




/****************************************************************************************
New DBQL logging options USECOUNT and STATSUSAGE, introduced in Teradata Database 14.10, 
enable the logging of used and missing statistics.  The output of this logging 
can be utilized to find used, unused, and missing statistics globally (for all queries) 
or for just a subset of queries.
https://developer.teradata.com/database/articles/identifying-used-unused-and-missing-statistics
****************************************************************************************/

select top 20 * from DBC.AMPUsage

