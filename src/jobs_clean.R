library(tidyverse)
library(stringr)
library(lubridate)
library(glue)
library(furrr)

analytics_jobs_df <- read_csv("https://raw.githubusercontent.com/alz-droid/jobs-web-scrape/main/data/analytics_jobs.csv")

analytics_jobs_df <- analytics_jobs_df %>% 
  mutate(Company = str_replace(Company, "at ", ""),
         Location =  if_else(grepl("Manawatu", Location), "Manawatū", Location) %>% str_replace_all(".*, ", ""),
         Description = str_replace_all(Description, "[\r\n\t]", " "))

analytics_jobs_df <- analytics_jobs_df %>% 
  mutate(Date_Posted = if_else(grepl("d ago", Date_Posted),
                               as_date(format(Sys.Date() - days(parse_number(Date_Posted)), "%d-%m-%Y")),
                               as_date(format(Sys.Date(), "%d-%m-%Y"))))