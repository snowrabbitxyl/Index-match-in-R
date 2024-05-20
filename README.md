# Index-match-in-R
When running a huge excel file with several index-match formulas, it always take a long time.
Plus, if doing left join in R, there are normally added records due to duplicates. However, we want the full records of left table and don't want to drop duplicates from the left table. This method makes sure that the joined result has exactly the same row number as left table. 
