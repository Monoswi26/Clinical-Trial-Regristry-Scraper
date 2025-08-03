#!/usr/bin/env Rscript

# CTRI HTML Scraper
# Downloads trial pages and logs metadata

suppressPackageStartupMessages({
  library(optparse)
  library(xml2)
  library(rvest)
  library(stringr)
  library(data.table)
  library(httr)
  library(lubridate)
})

# Command-line options
option_list <- list(
  make_option(c("-s", "--start_id"), type="integer", default=1,
              help="Starting trial ID"),
  make_option(c("-e", "--end_id"),   type="integer", default=90000,
              help="Ending trial ID"),
  make_option(c("-d", "--html_dir"), type="character", default="data/raw_html",
              help="Directory to save HTML files"),
  make_option(c("-m", "--meta_out"), type="character", default="data/metadata.csv",
              help="CSV file to log metadata")
)
opt <- parse_args(OptionParser(option_list=option_list))

# Ensure directories exist
dir.create(opt$html_dir, showWarnings = FALSE, recursive = TRUE)

# Initialize metadata
if (!file.exists(opt$meta_out)) {
  fwrite(data.table(
    Trial_ID = integer(),
    downloaded_time = character(),
    URL = character()
  ), opt$meta_out)
}

# Scrape loop
total <- 0
for (tid in seq(opt$start_id, opt$end_id)) {
  url <- sprintf("http://ctri.nic.in/Clinicaltrials/pmaindet2.php?trialid=%d", tid)
  
  # check robots.txt
  if (!paths_allowed(url, domain = "http://ctri.nic.in")) next
  
  # fetch page
  res <- try(GET(url, timeout(10)), silent = TRUE)
  if (inherits(res, "try-error") || status_code(res) != 200) next
  
  html <- read_html(res)
  text_all <- html %>% html_nodes("td") %>% html_text() %>% paste(collapse = " ")
  if (str_detect(text_all, "Invalid Request")) next
  
  # save HTML
  fname <- file.path(opt$html_dir, sprintf("ctri_%05d.html", tid))
  write_html(html, fname)
  
  # log metadata
  stamp <- data.table(
    Trial_ID = tid,
    downloaded_time = now(),
    URL = url
  )
  fwrite(stamp, opt$meta_out, append = TRUE)
  
  total <- total + 1
  message(sprintf("[%d] Saved trial %d", total, tid))
}

message("Scraping complete: ", total, " pages downloaded.")