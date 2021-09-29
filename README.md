# Vessel Tracker

This repository is Andrés F. Quintero's submission for Appsilon's Shiny
Challenge.

## How to run the app

1. Download the ships.csv dataset and place it inside a directory named "ignore"
inside the root directory of the repo.
2. Make sure the follow packages are installed:
    1. readr
    1. shiny
    1. shiny.semantic
    1. dplyr
    1. purrr
    1. tidyr
    1. feather
    1. stringr
    1. leaflet
    1. geosphere
3. Run the script named "pre.R". This will do some manipulation on the dataset
prior to the app running.
4. Run the app!

## How to run tests

To run tests source the file "test.R"

This project includes two main tests:

1. Module test on dropdowns
2. Plot and Info card tests

### Module test on dropdown

This test validates that the intended value is returned from the module.

### Plot and Info card tests

This validates that both the map plot and info card outputs work on every single
vessel type and vessel. It iterates through all combinations and validates no
warnings or errors occurr. 

If this test passes the user should be able to select any vessel type and vessel
without experiencing crashes.
