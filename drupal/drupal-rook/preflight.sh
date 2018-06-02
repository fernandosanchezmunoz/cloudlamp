#!/usr/bin/env bash

set -o errexit -o nounset -o pipefail

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


# # create bucket for Terraform state
# ###################################

# TODO: Fix up this thing:

#make bucket - catch if it already exists so we don't exit but ask
echo "**INFO: Creating bucket for Terraform state"
if gsutil ls gs://${TF_VAR_bucket_name}; then
	echo "**INFO: Terraform state bucket "${TF_VAR_bucket_name} "found."
else
	echo "**INFO: Terraform state bucket "${TF_VAR_bucket_name} "does not exist."
	read -r -p "Do you want to create it? [y/N] " response
	case "$response" in
	[yY][eE][sS] | [yY])
		gsutil mb -l ${TF_VAR_region} "gs://"${TF_VAR_bucket_name}
		;;
	*)
		echo "Terraform state bucket is needed. Exiting."
		exit
		;;
	esac
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
