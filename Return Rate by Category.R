library('dplyr')
library("tidyverse")

options(scipen = 999)
getwd()
setwd("~/Return/Return Rate by Category")
wfs_rpt_23<-read.csv("2023Feb-AprCustomerReturns.csv")

head(wfs_rpt_23)

colnames(wfs_rpt_23)

table(wfs_rpt_23['CURRENT_TRACKING_STATUS'])

cust_rtn <- wfs_rpt_23 %>%
  filter(grepl("deliveredToRC",CURRENT_TRACKING_STATUS))# keep only delivered returns

cust_rtn <- cust_rtn[-which(cust_rtn$DISPOSITION== "DISPOSE" & cust_rtn$FAULT == "WFS"),]
head(cust_rtn)

# get po number and paste the result to "PO number" file, runtime set as python. Then copy the result to SQL
str_po<-cat(paste0(sprintf('"%s"', cust_rtn$PO.), collapse = ", "))

## paste PO number to SQL Query and import results

library('readxl')

df_sc<-read_excel("SQL result.xlsx",sheet="sql")

colnames(df_sc)

# look up certain orders
# df_sc %>% filter_all(any_vars(. %in% c("108833685633509")))

dim(cust_rtn)

# delete 2022 data
#cust_rtn <- cust_rtn %>%
#  filter(!grepl("2022",Date))

### first join

# for rows in sql query results that have same PO# and UPC, keep only one record
df_sc_1 <- df_sc %>%
  slice_head(.,n = 1,by = c('PO#', 'UPC'))

dim(df_sc)

dim(df_sc_1)

joined_df <- cust_rtn %>% left_join(df_sc_1,by=c('PO.'='PO#', 'UPC'))

dim(joined_df)

# take out the unmatched records for first joined file
joined_df1 <- joined_df %>%
  filter(!is.na(`Subtotal`)) %>%
  select(-c('PO Line#'))

# count matched records based on "PO#" & "UPC"
dim(joined_df1)

# take the unmatched records
joined_df2 <- joined_df[is.na(joined_df$`Subtotal`),]

dim(joined_df1)

### second join

# try another way of join
joined_df2 <- joined_df2 %>%
  select(-c('PO Line#','SKU','Category','Grade','Series','Item Cost','Subtotal')) %>%
  left_join(df_sc,by = c('PO.'='PO#','PO.Line.'='PO Line#'))

joined_df2 <-joined_df2 %>%
  select(-c('UPC.y'))

names(joined_df2)[names(joined_df2) == 'UPC.x'] <- 'UPC'

dim(joined_df2)

# show records can't be matched using two ways
joined_df3 <- joined_df2 %>%
  filter(is.na(`Subtotal`))

na_po <- joined_df2 %>%
  filter(is.na(`Subtotal`)) %>%
  select(c('PO.'))

# take out the unmatched records for second joined file
joined_df2 <- joined_df2 %>%
  filter(!is.na(`Subtotal`))

### Third join

# look up these orders in sql results
df_sc %>% filter_all(any_vars(. %in% na_po$PO.))

# for rows in sql query results that have same PO# but different UPC, keep only one record
df_sc_2 <- df_sc %>%
  select(-c('PO Line#','UPC')) %>%
  slice_head(.,n = 1,by = c('PO#'))

colnames(joined_df3)

dim(joined_df3)

# try another way of join
joined_df3 <- joined_df3 %>%
  select(-c('SKU','Category','Grade','Series','Item Cost','Subtotal')) %>%
  left_join(df_sc_2,by = c('PO.'='PO#'))

# show records can't be matched using two ways
joined_df3 %>%
  filter(is.na(`Subtotal`))

# put 3 joined results together
df_total <- rbind(joined_df1, joined_df2, joined_df3)

dim(df_total)

colnames(df_total)

# prompt: convert df_total$RETURN.DATE to mm/dd/yyyy

df_total$RETURN.DATE <- format(as.Date(df_total$RETURN.DATE), '%m/%d/%Y')


rtn_results_23 <- df_total %>%
  select(c('RETURN.DATE','SKU','Category','Grade','Series','UNIT','Subtotal')) %>%
  mutate('Movement Type'="Return",.before = 'RETURN.DATE') %>%
  mutate('Company'= "K.E", .after = 'RETURN.DATE') %>%
  mutate('Channel' = "WFS", .before = 'SKU')

head(rtn_results_23)

colnames(rtn_results_23)

na_cat_23 <- rtn_results_23 %>%
  filter(is.na(Category)| Category == "NULL") %>%
  select(c('SKU')) %>%
  distinct(.)

# write.csv(na_cat_23, "Empty in Category.csv")

## 24
wfs_rpt_24<-read.csv("2024Feb-AprCustomerReturns.csv")

head(wfs_rpt_24)

colnames(wfs_rpt_24)

table(wfs_rpt_24['CURRENT_TRACKING_STATUS'])

cust_rtn <- wfs_rpt_24 %>%
  filter(grepl("deliveredToRC",CURRENT_TRACKING_STATUS))# keep only delivered returns

cust_rtn <- cust_rtn[-which(cust_rtn$DISPOSITION== "DISPOSE" & cust_rtn$FAULT == "WFS"),]
head(cust_rtn)

# get po number and paste the result to "PO number" file, runtime set as python. Then copy the result to SQL
str_po<-cat(paste0(sprintf('"%s"', cust_rtn$PO.), collapse = ", "))

## paste PO number to SQL Query and import results

library('readxl')

df_sc<-read_excel("SQL result.xlsx",sheet="sql")

colnames(df_sc)

# look up certain orders
# df_sc %>% filter_all(any_vars(. %in% c("108833685633509")))

dim(cust_rtn)

# delete 2022 data
#cust_rtn <- cust_rtn %>%
#  filter(!grepl("2022",Date))

### first join

# for rows in sql query results that have same PO# and UPC, keep only one record
df_sc_1 <- df_sc %>%
  slice_head(.,n = 1,by = c('PO#', 'UPC'))

dim(df_sc)

dim(df_sc_1)

joined_df <- cust_rtn %>% left_join(df_sc_1,by=c('PO.'='PO#', 'UPC'))

dim(joined_df)

# take out the unmatched records for first joined file
joined_df1 <- joined_df %>%
  filter(!is.na(`Subtotal`)) %>%
  select(-c('PO Line#'))

# count matched records based on "PO#" & "UPC"
dim(joined_df1)

# take the unmatched records
joined_df2 <- joined_df[is.na(joined_df$`Subtotal`),]

dim(joined_df1)

### second join

# try another way of join
joined_df2 <- joined_df2 %>%
  select(-c('PO Line#','SKU','Category','Grade','Series','Item Cost','Subtotal')) %>%
  left_join(df_sc,by = c('PO.'='PO#','PO.Line.'='PO Line#'))

joined_df2 <-joined_df2 %>%
  select(-c('UPC.y'))

names(joined_df2)[names(joined_df2) == 'UPC.x'] <- 'UPC'

dim(joined_df2)

# show records can't be matched using two ways
joined_df3 <- joined_df2 %>%
  filter(is.na(`Subtotal`))

na_po <- joined_df2 %>%
  filter(is.na(`Subtotal`)) %>%
  select(c('PO.'))

# take out the unmatched records for second joined file
joined_df2 <- joined_df2 %>%
  filter(!is.na(`Subtotal`))

### Third join

# look up these orders in sql results
df_sc %>% filter_all(any_vars(. %in% na_po$PO.))

# for rows in sql query results that have same PO# but different UPC, keep only one record
df_sc_2 <- df_sc %>%
  select(-c('PO Line#','UPC')) %>%
  slice_head(.,n = 1,by = c('PO#'))

colnames(joined_df3)

dim(joined_df3)

# try another way of join
joined_df3 <- joined_df3 %>%
  select(-c('SKU','Category','Grade','Series','Item Cost','Subtotal')) %>%
  left_join(df_sc_2,by = c('PO.'='PO#'))

# show records can't be matched using two ways
joined_df3 %>%
  filter(is.na(`Subtotal`))

# put 3 joined results together
df_total <- rbind(joined_df1, joined_df2, joined_df3)

dim(df_total)

colnames(df_total)

# prompt: convert df_total$RETURN.DATE to mm/dd/yyyy

df_total$RETURN.DATE <- format(as.Date(df_total$RETURN.DATE), '%m/%d/%Y')


rtn_results_24 <- df_total %>%
  select(c('RETURN.DATE','SKU','Category','Grade','Series','UNIT','Subtotal')) %>%
  mutate('Movement Type'="Return",.before = 'RETURN.DATE') %>%
  mutate('Company'= "K.E", .after = 'RETURN.DATE') %>%
  mutate('Channel' = "WFS", .before = 'SKU')

head(rtn_results_24)

colnames(rtn_results_24)

na_cat_24 <- rtn_results_24 %>%
  filter(is.na(Category)| Category == "NULL") %>%
  select(c('SKU')) %>%
  distinct(.)

# write.csv(na_cat_24, "Empty in Category.csv")

rtn_results_total <- rbind(rtn_results_23,rtn_results_24)
write.csv(rtn_results_total,"WFS Return Rate.csv")