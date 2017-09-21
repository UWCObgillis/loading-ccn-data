library(tools)
library(readxl)


##### Things to add
##      1. create a crosswalk of old names to new names
##      2. add into that the datatype 

source("R/SQL Connections.R")
con <- mssql_con("ccn")


# now we need to load the CCN data

files <- list.files("~/CCN Accountability Data Share 6.28.2017")
files <- files[file_ext(files)=="xlsx"]

file = files[2]

for (file in files) {

  d <- read_excel(paste0("~/CCN Accountability Data Share 6.28.2017/",file), 
                                                sheet = "data")
  ci <- read_excel(paste0("~/CCN Accountability Data Share 6.28.2017/",file), 
                  sheet = "col_info")
  
  fn <- gsub(" ","_",
    trimws(gsub("_7.11.2017.xlsx",'',
             gsub("_6.29.2017.xlsx",'',
                  gsub("_6.28.2017.xlsx",'',
                       gsub("hub_",'',tolower(file)),fixed=T),fixed=T),fixed=T)),fixed=T)
  
  names(d) <- ci$new_name
  d[] <- lapply(d, as.character) # I should really go in and set the data types
  
  sqlQuery(con, paste0("Drop table if exists ",fn))
  sqlSave(con, d, fn, rownames = F)
  
}




