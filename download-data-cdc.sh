#!/bin/bash

# Run this from the directory FARS-traffic

# Check for wget and unzip
command -v wget >/dev/null 2>&1 || { echo "wget not installed.  Aborting." >&2; exit 1; }
command -v unzip >/dev/null 2>&1 || { echo "unzip not installed.  Aborting." >&2; exit 1; }

# Make directories for each year
if [ ! -e ./data/cdc ]; then
  mkdir -p ./data/cdc
fi

# CDC County Obesity and Diabetes Mellitus
base_url_cdc="https://www.cdc.gov/diabetes/atlas/countydata"
declare -a cdc_urls=( "DMPREV/DM_PREV_ALL_STATES.xlsx"
                       "OBPREV/OB_PREV_ALL_STATES.xlsx")

# enter the data directory
pushd data/cdc
for url in "${cdc_urls[@]}"; do
  wget ${base_url_cdc}/${url}
done

# Return to the previous directory
popd


## Download Census 2015 US boundary shapefiles ##
## State, County                               ##
base_url_census_tiger="https://www2.census.gov/geo/tiger"
declare -a tiger_urls=("GENZ2013/cb_2013_us_state_20m.zip"
                       "GENZ2013/cb_2013_us_county_20m.zip")

if [ ! -e ./data/shapefiles ]; then
  mkdir -p ./data/shapefiles
fi

# Enter the ./data/shapefiles directory
pushd ./data/shapefiles

for shapefile in "${tiger_urls[@]}"; do
  wget ${base_url_census_tiger}/${shapefile}
done

# Unzip all of the shapefiles into their own directory
# and remove the zip file.
zipfile_arr=(*.zip)
for file in "${zipfile_arr[@]}"; do
  base=${file%%.*}
  mkdir $base
  unzip -d $base $file
  rm $file
done

# Return to the main directory
popd
