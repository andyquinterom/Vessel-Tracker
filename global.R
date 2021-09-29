library(shiny)
library(shiny.semantic)
library(dplyr)
library(purrr)
library(tidyr)
library(feather)
library(stringr)
library(leaflet)
library(geosphere)

message("Libraries loaded...")
# Source the modules
load_modules <- file.path("modules", list.files("modules")) %>%
  purrr::map(source)

message("Modules sourced...")
# Some data-preprocessing, this could be done off the application in a
# cron-job and be left alone in order to accelerate the application. However,
# I included it for the example.
ship_data <- read_feather("data/data.feather")
