library(dplyr)
library(rhandsontable)
library(feather)
library(rgdal)
library(tmap)
library(tmaptools)

counties <- readOGR(dsn = "../data/shapefiles/cdc_diabetes_2013_us_county_akhi_20m",
                    layer ="cdc_diabetes_2013_us_county_akhi_20m")
states <- readOGR(dsn = "../data/shapefiles/cb_2013_us_state_akhi_20m",
                  layer = "cb_2013_us_state_akhi_20m")

#ttm()

map_conus_akhi <- tm_shape(counties, projection = 2163) +
                  tm_polygons("dm_prcn",
                              border.col = "gray80",
                              border.alpha = .5,
                              title = "",
                              showNA = TRUE) +
                  tm_shape(states, projection= 2163) +
                  tm_borders(lwd=0.5, col = "black", alpha = .5) +
                  tm_credits("US CDC Diabetes Diagnosed 2013\n https://www.cdc.gov/diabetes/atlas/countydata") +
                  tm_layout(title="",
                            title.position = c("center", "top"),
                            legend.position = c("right", "bottom"),
                            frame = FALSE,
                            inner.margins = c(0.2, 0.1, 0.05, 0.05))

NC_counties <- counties %>%
                 subset(STATEFP == "37")

map_nc <- tm_shape(NC_counties, projection = 2264) +
          tm_polygons("dm_prcn",
                      border.col = "gray80",
                      border.alpha = .5,
                      title = "% Diabetes\nDiagnosis",
                      showNA = TRUE) +
          tm_layout(title="",
                    title.position = c("center", "top"),
                    legend.position = c("right", "bottom"),
                    frame = FALSE,
                    inner.margins = c(0.2, 0.1, 0.05, 0.05))

dm_2013_df <- read_feather('../data/cdc_dm_2013.feather')
dm_table <- rhandsontable(dm_2013_df, width = 600, height = 300)
