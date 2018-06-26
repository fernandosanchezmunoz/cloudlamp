#!/usr/bin/env bash
# CloudLAMP Pre-flight script
# Copyright 2018 Google, LLC
# Sebastian Weigand <tdg@google.com>
# Fernando Sanchez <fersanchez@google.com>

echo "Welcome to CloudLAMP!"

error() {
  echo -e "\n\nCloudLAMP Error: $@\n" >&2
}

printf '%-50s' "Checking for gcloud..."
command -v gcloud >/dev/null 2>&1 || {
  error "The 'gcloud' command was not found. Please install the Google Cloud SDK from: https://cloud.google.com/sdk/downloads"
  exit 1
}
echo "[ OK ]"

printf '%-50s' "Checking for kubectl..."
command -v kubectl >/dev/null 2>&1 || {
  error "The 'kubectl' command was not found. You can install it via: 'gcloud components install kubectl'"
  exit 1
}
echo "[ OK ]"

# This executes all the gcloud commands in parallel and then assigns them to separate variables:
# Needed for non-array capabale bashes, and for speed.
printf '%-50s' "Checking gcloud configuration..."
PARAMS=$(cat <(gcloud config get-value compute/zone 2>&1) \
    <(gcloud config get-value compute/region 2>&1) \
    <(gcloud config get-value project 2>&1) \
  <(gcloud auth application-default print-access-token 2>&1))
read GCP_ZONE GCP_REGION GCP_PROJECT GCP_AUTHTOKEN <<< $(echo $PARAMS)

for VAR in $GCP_PROJECT $GCP_REGION $GCP_ZONE; do
	if [[ $VAR == "(unset)" ]]; then
    error "Please set the 'compute/region', 'compute/zone', and 'project' in your gcloud config:
    gcloud config set <component> <value>"
    echo "Your current gcloud config:"
    gcloud config list
		exit 1
	fi
done

if [[ $GCP_AUTHTOKEN == *"ERROR"* ]]; then
  error "You do not have application-default credentials set, please run this command:
  gcloud auth application-default login"
  exit 1
fi
echo "[ OK ]"

# Create a GCS bucket for Terraform state; ignore if it's already there:
printf '%-50s' "Checking Terraform state bucket..."
BUCKET_STATUS=$(gsutil mb -l $GCP_REGION -c Regional gs://$GCP_PROJECT-terraform-state 2>&1)
if [[ $? != 0 ]]; then
  if [[ $BUCKET_STATUS != *"409"* ]]; then
    error "Error creating Terraform state bucket:\n\n$BUCKET_STATUS"
    exit 1
  fi
fi
echo "[ OK ]"

# Create backend Terraform file:
printf '%-50s' "Creating Terraform backend file..."
cat << EOF > backend.tf
# Note: This file is generated from preflight.sh:
terraform {
 backend "gcs" {
   bucket  = "$GCP_PROJECT-terraform-state"
   prefix  = "/tf/terraform.tfstate"
   project = "$GCP_PROJECT"
 }
}
EOF
echo "[ OK ]"

# Populate Terraform default variables:
printf '%-50s' "Setting Terraform variables..."
cat << EOF > terraform.tfvars
# Note: This file is generated from preflight.sh:
gcp_region  = "$GCP_REGION"
gcp_zone    = "$GCP_ZONE"
gcp_project = "$GCP_PROJECT"
EOF
echo "[ OK ]"

echo "
Success! You are now ready to deploy CloudLAMP via Terraform via:
  terraform init
  terraform [ plan | apply ]
"
