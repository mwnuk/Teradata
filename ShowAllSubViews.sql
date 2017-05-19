--Show all sub-views refered by a view

SHOW QUALIFIED SELECT * FROM myView

SHOW SELECT * FROM myViewLIVE_DO_MatrixCosts 



-- Show all references to an object
sel top 100 * from dbc.tvm 
where requesttext like '%ModeledDates%'




sel top 100 * from dbc.tvm 
where TVMName like 'GTT_%' and tableKind='V'