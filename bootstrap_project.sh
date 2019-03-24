#!/bin/bash
# Set up a sandbox project with appropriate APIs enabled

ORGANIZATION_ID=$(gcloud organizations list --filter=DISPLAY_NAME=firefox.gcp.mozilla.com --format 'value(ID)')
DATAOPS_FOLDER=$(gcloud resource-manager folders list --organization $ORGANIZATION_ID --filter DISPLAY_NAME=dataops --format 'value(ID)')
SANDBOX_FOLDER=$(gcloud resource-manager folders list --folder $DATAOPS_FOLDER --filter DISPLAY_NAME=sandbox --format 'value(ID)')
BILLING_ACCOUNT=$(gcloud beta billing accounts list --filter "displayName ~ Services Engineering" --format 'value(ACCOUNT_ID)')

if ! gcloud projects describe $PROJECT &>/dev/null ; then
  input "Creating project"
  gcloud projects create --folder=$SANDBOX_FOLDER $PROJECT
  echo "Enabling billing on project"
  gcloud beta billing projects link $PROJECT --billing-account $BILLING_ACCOUNT
  echo "Enabling APIs in project"
  gcloud --project=$PROJECT services enable {compute,pubsub,dataflow}.googleapis.com
fi
echo "https://console.cloud.google.com/home/dashboard?project=${PROJECT}&folder=&organizationId="

if ! gcloud --project $PROJECT iam service-accounts describe $COMPUTE_SERVICE_ACCOUNT@$PROJECT.iam.gserviceaccount.com &>/dev/null ; then
  input "Creating service account for compute"
  gcloud --project=$PROJECT iam service-accounts create $COMPUTE_SERVICE_ACCOUNT
  gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$COMPUTE_SERVICE_ACCOUNT@$PROJECT.iam.gserviceaccount.com \
    --role roles/pubsub.editor
fi

if ! gcloud --project $PROJECT iam service-accounts describe $DATAFLOW_SERVICE_ACCOUNT@$PROJECT.iam.gserviceaccount.com &>/dev/null ; then
  input "Creating service account for dataflow"
  gcloud --project=$PROJECT iam service-accounts create $DATAFLOW_SERVICE_ACCOUNT
  gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$DATAFLOW_SERVICE_ACCOUNT@$PROJECT.iam.gserviceaccount.com \
    --role roles/dataflow.admin
  gcloud projects add-iam-policy-binding $PROJECT \
    --member serviceAccount:$DATAFLOW_SERVICE_ACCOUNT@$PROJECT.iam.gserviceaccount.com \
    --role roles/storage.objectAdmin
fi

echo https://console.cloud.google.com/iam-admin/serviceaccounts?project=${PROJECT}
