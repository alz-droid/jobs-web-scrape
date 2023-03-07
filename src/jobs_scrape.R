library(tidyverse)
library(rvest)
library(glue)
library(dplyr)
library(furrr)

get_job_types <- function(job_url) {
  job_types <- read_html(job_url) %>% 
    html_nodes(".a1msqif6 .a1msqi6m:nth-child(3) .lnocuoa") %>% 
    html_text2()
  return(job_types)
}

get_job_descriptions <- function(job_url) {
  job_descriptions <- read_html(job_url) %>% 
    html_nodes("._1v38w810") %>% 
    html_text2()
  return(job_descriptions)
}

get_job_posted_by <- function(job_url) {
  posted_by <- read_html(job_url) %>% 
    html_nodes("._1wkzzau0.a1msqi6q > .lnocuo22.lnocuoa") %>% 
    html_text2()
  return(posted_by)
}

page_num <- 1
data_analytics_jobs <- tibble()

repeat {
  job_portal <- glue("https://www.seek.co.nz/data-analyst-jobs?page={page_num}")
  page <- read_html(job_portal)
  
  job_roles <- page %>% 
    html_nodes("._1rct8jye") %>% html_text2()
  
  job_urls <- page %>% 
    html_nodes("._1rct8jye") %>% html_attr("href") %>% 
    future_map_chr(function(x) glue("https://www.seek.co.nz{x}#"))
  
  job_companies <- page %>% 
    html_nodes("._1wkzzau0.a1msqi4u.lnocuo0.lnocuo2.lnocuo21._1d0g9qk4.lnocuod") %>% 
    html_text2()
  
  job_locations <- page %>% 
    html_nodes(".a1msqi66 .a1msqi6i:nth-child(1) .lnocuo7") %>% html_text2()
  
  job_class <- page %>% 
    html_nodes(".a1msqib2.a1msqiei:nth-child(2)") %>% html_text2()
  
  job_subclass <- page %>% 
    html_nodes(".a1msqib2:nth-child(5)") %>% html_text2()
  
  job_types <- future_map_chr(job_urls, get_job_types)
  
  job_dates_posted <- future_map_chr(job_urls, get_job_posted_by)
  
  job_descriptions <- future_map_chr(job_urls, get_job_descriptions)
  
  data_analytics_jobs <- bind_rows(data_analytics_jobs, tibble(
    Job = job_roles,
    Link = job_urls,
    Company = job_companies,
    Location = job_locations,
    Classification = job_class,
    Subclassification = job_subclass,
    Type = job_types,
    Date_Posted = job_dates_posted,
    Description = job_descriptions)
  )
  page_num = page_num + 1
  if(page_num == 47) {
    break
  }
}

write_csv(data_analytics_jobs, "analytics_jobs.csv")
