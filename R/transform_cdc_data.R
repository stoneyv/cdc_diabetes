library(dplyr)
library(data.table)
library(ggplot2)
library(readxl)
library(rgdal)

# Read modified Census shapefiles that have AK and HI positioned below
counties <- readOGR(dsn = "./data/shapefiles/cb_2013_us_county_akhi_20m/cb_2013_us_county_akhi_20m.shp")
states <- readOGR(dsn = "./data/shapefiles/cb_2013_us_state_akhi_20m/cb_2013_us_state_akhi_20m.shp")

# Read Diabetes and Obesity excel files downloaded from the CDC
# by the download script. Do this read in two parts to skip reading
# data for other years and then merge the geo data with the data
# for the particular year or years.

# Diabetes Mellitus
# State, FIPS Codes, County
# Read rectangular are of cells Column A Row 3 to Column 3226 Row 3226
cdc_dm_abc_df <- read_excel('./data/cdc/DM_PREV_ALL_STATES.xlsx',
                       range="A3:C3226",
                       col_names=c("state",
                                   "geoid",
                                   "county"),
                       col_types=c("text",
                                   "text",
                                   "text"))

# Diabetes Mellitus 2013
# Rows 3:3226 Columns BO:BU
cdc_dm_bo2bu_df <- read_excel('./data/cdc/DM_PREV_ALL_STATES.xlsx',
                       range="BO3:BU3226",
                       col_names=c("number",
                                   "percent",
                                   "low_conf",
                                   "up_conf",
                                   "age_adj_pct",
                                   "age_adj_low_conf",
                                   "age_adj_up_conf"),
                       col_types=c("numeric",
                                   "numeric",
                                   "numeric",
                                   "numeric",
                                   "numeric",
                                   "numeric",
                                   "numeric"))

cdc_dm_df <- data.frame( state=cdc_dm_abc_df$state,
                         geoid=cdc_dm_abc_df$geoid,
                         county=cdc_dm_abc_df$county,
                         dm_number=cdc_dm_bo2bu_df$number,
                         dm_percent=cdc_dm_bo2bu_df$percent,
                         dm_low_conf=cdc_dm_bo2bu_df$low_conf,
                         dm_up_conf=cdc_dm_bo2bu_df$up_conf,
                         dm_age_adj_pct=cdc_dm_bo2bu_df$age_adj_pct,
                         dm_age_adj_low_conf=cdc_dm_bo2bu_df$age_adj_low_conf,
                         dm_age_adj_up_conf=cdc_dm_bo2bu_df$age_adj_up_conf) %>%
                         filter(state != 'Puerto Rico')

# Obesity
# State, FIPS Codes, County
cdc_ob_abc_df <- read_excel('./data/cdc/OB_PREV_ALL_STATES.xlsx',
                       range="A3:C3226",
                       col_names=c("state",
                                   "geoid",
                                   "county"),
                       col_types=c("text",
                                   "text",
                                   "text"))

# Obesity 2013
cdc_ob_bo2bu_df <- read_excel('./data/cdc/OB_PREV_ALL_STATES.xlsx',
                       range="BO3:BU3226",
                       col_names=c("number",
                                   "percent",
                                   "low_conf",
                                   "up_conf",
                                   "age_adj_pct",
                                   "age_adj_low_conf",
                                   "age_adj_up_conf"),
                       col_types=c("numeric",
                                   "numeric",
                                   "numeric",
                                   "numeric",
                                   "numeric",
                                   "numeric",
                                   "numeric"))

cdc_ob_df <- data.frame( state=cdc_ob_abc_df$state,
                         geoid=cdc_ob_abc_df$geoid,
                         county=cdc_ob_abc_df$county,
                         ob_number=cdc_ob_bo2bu_df$number,
                         ob_percent=cdc_ob_bo2bu_df$percent,
                         ob_low_conf=cdc_ob_bo2bu_df$low_conf,
                         ob_up_conf=cdc_ob_bo2bu_df$up_conf,
                         ob_age_adj_pct=cdc_ob_bo2bu_df$age_adj_pct,
                         ob_age_adj_low_conf=cdc_ob_bo2bu_df$age_adj_low_conf,
                         ob_age_adj_up_conf=cdc_ob_bo2bu_df$age_adj_up_conf) %>%
                         filter(state != 'Puerto Rico')

# Merge County shapefile with 2013 diabetes data
# Both base an sp have merge functions.  This resolves to base::merge
dm_2013_sdf <- merge(counties, cdc_dm_df,
                    by.x="GEOID",
                    by.y="geoid",
                    suffixes = c(".x",".y"))

writeOGR(dm_2013_sdf,
         dsn = "./data/shapefiles/cdc_diabetes_2013_us_county_akhi_20m",
         layer = "cdc_diabetes_2013_us_county_akhi_20m",
         driver="ESRI Shapefile")


# Merge County shapefile with 2013 obesity data
ob_2013_sdf <- merge(counties, cdc_ob_df,
                     by.x="GEOID",
                     by.y="geoid",
                     suffixes = c(".x",".y"))

writeOGR(ob_2013_sdf,
         dsn = "./data/shapefiles/cdc_obesity_2013_us_county_akhi_20m",
         layer = "cdc_obesity_2013_us_county_akhi_20m",
         driver="ESRI Shapefile")
