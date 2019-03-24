#!/bin/bash

input "Listing bigquery datasets"
bq --project $SHARED_PROJECT ls
input "Listing telemetry tables"
bq --project $SHARED_PROJECT ls telemetry_dev
input "Describing core ping v10 table"
bq --project $SHARED_PROJECT show telemetry_dev.core_v10
input "Displaying a single row from core ping v10 table"
bq head -n 1 --project moz-fx-data-shar-nonprod-efed telemetry_dev.core_v10
input "Running an example query on the compute instance"
# gcloud compute --project $PROJECT ssh --zone $ZONE $COMPUTE_INSTANCE_NAME
gcloud compute --project $PROJECT ssh --zone $ZONE $COMPUTE_INSTANCE_NAME --command \
  "echo -e '#standardSQL\nSELECT metadata.geo_country, metadata.geo_city, metadata.app_name FROM telemetry_dev.core_v10 where metadata.app_name IS NOT NULL AND metadata.geo_city IS NOT NULL limit 5' | bq query --project $SHARED_PROJECT"
