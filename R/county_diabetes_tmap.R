library(dplyr)
library(DT)
library(feather)
library(rgdal)
library(tmap)
library(tmaptools)

counties <- readOGR(dsn = "../data/shapefiles/cdc_diabetes_2013_us_county_akhi_20m",
                    layer ="cdc_diabetes_2013_us_county_akhi_20m")
states <- readOGR(dsn = "../data/shapefiles/cb_2013_us_state_akhi_20m",
                  layer = "cb_2013_us_state_akhi_20m")

ALMI_counties <- counties %>%
                   subset(STATEFP %in% c("01","28"))

map_conus_akhi <- tm_shape(counties, projection = 2163) +
                  tm_polygons("dm_prcn",
                              border.col = "gray80",
                              border.alpha = .5,
                              title = "%",
                              showNA = TRUE) +
                  tm_shape(states, projection= 2163) +
                  tm_borders(lwd=0.5, col = "black", alpha = .5) +
                  tm_credits("US CDC Diabetes Diagnosed 2013\n https://www.cdc.gov/diabetes/atlas/countydata") +
                  tm_layout(title="",
                            title.position = c("center", "top"),
                            legend.position = c("right", "bottom"),
                            frame = FALSE,
                            inner.margins = c(0.2, 0.1, 0.05, 0.05))

# Use Alabama West EPSG:26930 projection
# https://github.com/veltman/d3-stateplane
map_ALMI <- tm_shape(ALMI_counties, projection = 26930 ) +
          tm_polygons("dm_prcn",
                      border.col = "gray80",
                      border.alpha = .5,
                      title = "%",
                      showNA = TRUE) +
          tm_layout(title="",
                    title.position = c("center", "top"),
                    legend.position = c("right", "bottom"),
                    frame = FALSE,
                    inner.margins = c(0.2, 0.1, 0.05, 0.05))

dm_2013_df <- read_feather('../data/cdc_dm_2013.feather')
dm_table <- DT::datatable(dm_2013_df,
                          class = c('compact','table-hover','table-striped'))
dm_table

tmap_mode("view")

# Remove tm_view to output a static map
map_conus_akhi +  tm_view(alpha = 1, basemaps = NA, basemaps.alpha = 0)
