library(tools)
library(readxl)
library(dplyr)

#??? There are still some issues with large strings of data, I have used the r_data_type 'skip' to exclude them


source("C:/Users/bgillis/Documents/R/SQL Connections.R")
con <- mssql_con("ccn")

# pull down the column info from SQL (rci)
rci <- sqlFetch(con,"report_column_info", stringsAsFactors=F)

# now we need to load the CCN data

files <- list.files("~/CCN Accountability Data Share 6.28.2017")
files <- files[file_ext(files)=="xlsx"]
files <- files[substr(files,1,2) !="~$"]

#  for Testing:  file <- files[1]

for (file in files) {
  ### Get the file name cleaned up??? Still need to standardize this
  # clean up the file names
  report <- gsub(" ","_",
             trimws(gsub("_7.11.2017.xlsx",'',
                         gsub("_6.29.2017.xlsx",'',
                              gsub("_6.28.2017.xlsx",'',
                                   gsub("hub_",'',tolower(file)),fixed=T),fixed=T),fixed=T)),fixed=T)
  
  # get the columns we have
  d <- read_excel(paste0("~/CCN Accountability Data Share 6.28.2017/",file), 
                  sheet = "data",n_max=0)
  
  # use the old names to get the right new names and data types
  old_name <- names(d)
  on <- data.frame(old_name, stringsAsFactors = F)
  on$report <- rep(report, length(on$old_name))
  
  rci_x <- on %>%
    left_join(rci)
  
  # reading it in again has less errors than trying to convert - go figure
  d <- read_excel(paste0("~/CCN Accountability Data Share 6.28.2017/",file), 
                  sheet = "data", col_types = rci_x$r_data_type)
  
  # since we skipped some fields in some reports, we need to get a new list of fields and types
  old_name <- names(d)
  on <- data.frame(old_name, stringsAsFactors = F)
  on$report <- rep(report, length(on$old_name))
  
  rci_x <- on %>%
    left_join(rci)
  # rename columns
  names(d) <- rci_x$new_name
  
  # create the varTypes - must be NAMED vector
  varTypes <- rci_x$sql_data_type
  names(varTypes) <- rci_x$new_name

  # send it to SQL
  sqlQuery(con, paste0("Drop table if exists ",report))
  sqlSave(con, d, report,varTypes = varTypes, rownames = F, fast=T, verbose = F)
  
}

###
###  Now, we need some checks
###



