# Clinical-Trial-Regristry-Scraper
An R-based project to scrape and aggregate clinical trial details from the CTRI (Clinical Trials Registry - India) website.

# CTRI Scraper

This project scrapes trial detail pages from the Clinical Trials Registry - India (CTRI) and aggregates structured metadata.

## Requirements
- R (>= 4.0)
- CRAN packages: xml2, rvest, stringr, data.table, tidyverse, httr, lubridate

## Installation
```sh
install.packages(c(
  'xml2', 'rvest', 'stringr', 'data.table',
  'tidyverse', 'httr', 'lubridate'
))


## USAGE

# Run the scraper (will save HTML and metadata)
Rscript scripts/scrape_ctri.R \
  --start_id 1 \
  --end_id   90000 \
  --html_dir data/raw_html \
  --meta_out data/metadata.csv

# After scraping, parse HTML into structured CSV
Rscript scripts/parse_ctri.R \
  --html_dir data/raw_html \
  --out      output/trials_data.csv
