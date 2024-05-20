# Index-match-in-R
## When running a huge excel file with several index-match formulas, it always takes a long time.
## Plus, if doing left join in R, there are normally added records due to duplicates. However, we want the full records of left table and don't want to drop duplicates from the left table. This method makes sure that the joined result has exactly the same row number as left table. 
## "2023Feb-AprCustomerReturns.csv" is the left table, each row represents a return record. We want to keep each row in this table, even duplicates.
### "SQL result.xlsx" is the right table, containing the price information we want to add to the left table.
### The results of this R code was put into pivot table for a regular report. This is real-world data. 
