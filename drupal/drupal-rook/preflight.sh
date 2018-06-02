#!/usr/bin/env bash
# CloudLAMP Pre-flight script
# Copyright 2018 Google, LLC
# Sebastian Weigand <tdg@google.com>
# Fernando Sanchez <fersanchez@google.com>

# Check for gcloud:
command -v gcloud >/dev/null 2>&1 || {
  echo "The 'gcloud' command was not found. Please install the Google Cloud SDK from: https://cloud.google.com/sdk/downloads" >&2
  exit 1
}

# This executes all the gcloud commands in parallel and then assigns them to separate variables:
# Needed for non-array capabale bashes, and for speed.
PARAMS=$(cat <(gcloud config get-value compute/zone 2>&1) <(gcloud config get-value compute/region 2>&1) <(gcloud config get-value project 2>&1))
read GCP_ZONE GCP_REGION GCP_PROJECT <<< $(echo $PARAMS)

VARS_OK="true"
for VAR in $GCP_PROJECT $GCP_REGION $GCP_ZONE; do
	if [[ $VAR == "(unset)" ]]; then
		VARS_OK="false"
		break
	fi
done

if [[ $VARS_OK == "false" ]]; then
	echo "Please set the 'compute/region', 'compute/zone', and 'project' in your gcloud config:"
	echo "  gcloud config set <component> <value>"
	exit 1
fi

# Create a GCS bucket for Terraform state; ignore if it's already there:
BUCKET_STATUS=$(gsutil mb -l $GCP_REGION -c Regional gs://$GCP_PROJECT-terraform-state 2>&1)
if [[ $? != 0 ]]; then
  if [[ $BUCKET_STATUS != *"409"* ]]; then
    echo "Error creating Terraform state bucket: $BUCKET_STATUS"
    exit 1
  fi
fi

# Create backend Terraform file:
cat << EOF > backend.tf
terraform {
 backend "gcs" {
   bucket  = "$GCP_PROJECT-terraform-state"
   prefix  = "/tf/terraform.tfstate"
   project = "$GCP_PROJECT"
 }
}
EOF
