# loading-ccn-data
The goal here is to develop a consistent, throrough loading process for CCN data

# step 1. Create the Report Column Info sql table
I wanted to be able to load new iterations of data pulls regardless of the order that the data came in.
In the excel file that was provided I mapped out the data types for R and SQL for each column along with
an updated column name.  I created one table with all of this information (ccn..report_column_info) using
the R script Creating the Column Info Table From the Ind CI Files.R.

DO NOT UPDATE WITH THIS SCRIPT EVERY TIME
Changes should be made in a sql environment.

Next time we get data, we will want to see how to go about adding to the table (probably an append section).

# step 2. Load the data from the excel files into SQL tables
Using the R script looping through the files and loading to mssql.R we do just that.  This might be
a bit wonky but I got the names of the table using the read_excel file, created a map using the 
report_column_info table, and then re-read in the data using read_excel again but specifying the data types.

I ran into problems with large, unstructured data fields, and so I just eliminated them for now. Eventually,
I will want to do something more with them.

# Still to do:
I need to do some checks on the data.
