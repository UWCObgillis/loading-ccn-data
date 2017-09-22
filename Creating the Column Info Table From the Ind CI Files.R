###
###   This one shouldn't have to be rerun each time, small edits should happen in a SQL environment
###

library(readxl)
library(dplyr)
library(tools)
####
source("C:/Users/bgillis/Documents/R/SQL Connections.R")
con <- mssql_con("ccn")

### pull from the files #??? may want to create a seperate dat folder for these
files <- list.files("~/CCN Accountability Data Share 6.28.2017")
files <- files[file_ext(files)=="xlsx"]
files <- files[substr(files,1,2) !="~$"]

# for testing:  file <- files[1]


ci0 <- data.frame()
  
for (file in files) {
  ### Clean up the file name (fn)  ### ??? needs generalized
  report <- gsub(" ","_",
             trimws(gsub("_7.11.2017.xlsx",'',
                         gsub("_6.29.2017.xlsx",'',
                              gsub("_6.28.2017.xlsx",'',
                                   gsub("hub_",'',tolower(file)),fixed=T),fixed=T),fixed=T)),fixed=T)
  
  ci <- read_excel(paste0("~/CCN Accountability Data Share 6.28.2017/",file), 
                   sheet = "col_info")
  
  ci$report <- rep(report, length(ci$old_name))
  
  ci <- ci %>%
    select(
      report,
      old_name,
      new_name,
      r_data_type,
      sql_data_type
    )
  
  ci0 <- rbind(ci0, ci)
}

#####  fix some inconsistencies

ci0$sql_data_type <- ifelse(substr(ci0$sql_data_type,1,7) =='varchar', 'varchar', ci0$sql_data_type)
ci0$sql_data_type <- ifelse(substr(ci0$sql_data_type,1,7) =='varchar', 'varchar(255)', ci0$sql_data_type)

####  Move to MSSQL
sqlQuery(con, "Drop Table if Exists report_column_info")
sqlSave(con, ci0, "report_column_info", rownames = F)


