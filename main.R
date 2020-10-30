# Title     : HM-10 Reader
# Objective : Read table HM-10 and save as a machine readable .CSV.
# Created by: Brian Brotsos, Viktoriia Dunleavy, and David.Winter
# Created on: 10/29/2020
library (tidyverse)
library(readxl)

# Working directory where input file is located and where output file is saved.
# setwd("S:/HPPI/ROUTES Initiative/Data Files")

startRow <- 12

# Reading input Excel file from working directory.
# hm10_file <- '2018_hm10.xlsx'
# hm_raw <- read_excel(hm10_file, sheet="A", skip=startRow)

# Reading input Excel file from OHPI website.
hm10_url <- 'https://www.fhwa.dot.gov/policyinformation/statistics/2018/xls/hm10.xls'
destination_file <- "hm10-download-fhwa.xlsx"

if (!file.exists(destination_file)){
  download.file(hm10_url, destfile = destination_file, mode="wb")
}
hm_raw <- read_xls(destination_file, sheet="A", skip=startRow)

colnames (hm_raw) <- c("state_name",
                       "rural_state",
                       "rural_county",
                       "rural_township",
                       "rural_other",
                       "rural_federal",
                       "rural_total",
                       "urban_state",
                       "urban_county",
                       "urban_township",
                       "urban_other",
                       "urban_federal",
                       "urban_total",
                       "unreported_unreported",
                       "grand_total"
)
# Deleting blank row at top, total columns, and rows.
hm_raw = hm_raw[-1,]
hm_raw <- hm_raw %>% select(-c('rural_total','urban_total','grand_total'))
# hm_raw <- hm_raw[-c(54,55), ]

#remove grand totals
hm_raw <- hm_raw %>% filter(state_name != 'Grand Total')

#remove footnotes:
hm_raw <- hm_raw %>% filter(state_name != 'For footnotes, see Footnotes Page.')


# Taking cleaned up data table and pivoting to machine readable format.
hm_tidy <- hm_raw %>%
  pivot_longer('rural_state':'unreported_unreported', names_to="COLUMN_KEY", values_to='Miles') %>%
  separate(COLUMN_KEY, into = c("RuralUrbanCode", "Ownership"), sep='_')
hm_tidy <- filter(hm_tidy,RuralUrbanCode != 'grand')

# Saving machine readable file.
write.csv(hm_tidy,file = "S:/HPPI/ROUTES Initiative/Data Files/2018_hm10.csv")