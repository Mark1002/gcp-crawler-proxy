#!/bin/bash
read -r -e -p "Please enter your tf backend gcs name: " gcs_name
gsutil mb gs://"${gcs_name}"