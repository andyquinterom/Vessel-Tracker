# This script makes some transformations to the data
# to accelerate performance prior to deployment

# The ships.csv file needs to be placed in a directory
# ignore. This directory will not be sent to GIT as
# it is ignored.

readr::read_csv("ignore/ships.csv") %>%
  arrange(DATETIME) %>%
  group_by(SHIPNAME) %>%
  # Usually this would not be needed. However, the geosphere library is not
  # very good at multiple calculations from my findings and dedicating
  # devlopment time to make a fast implementation is not in the scope of the
  # project. If there is a better solution, it is welcome.
  mutate(LAT_LAST = lag(LAT), LON_LAST = lag(LON)) %>%
  # While doing some tests, I found that ships with a single observation
  # caused a warning. This replaces NA lagged Long and Lat values with
  # the actual longitude and latitude. The result should be the same
  # and should give and accurate measure of distance.
  mutate(
    LON_LAST = case_when(is.na(LON_LAST) ~ LON, TRUE ~ LON_LAST),
    LAT_LAST = case_when(is.na(LAT_LAST) ~ LAT, TRUE ~ LAT_LAST)
  ) %>%
  write_feather("data/data.feather")

