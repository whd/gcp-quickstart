#!/bin/bash

if gcloud compute --project=$PROJECT instances describe --zone $ZONE $COMPUTE_INSTANCE_NAME &>/dev/null ; then
  gcloud compute --project=$PROJECT instances delete $COMPUTE_INSTANCE_NAME
fi

for job  in $(gcloud --project=$PROJECT dataflow jobs list --filter state=running --format 'value(id)') ; do
  input "Draining job ${job}"
  gcloud --project=$PROJECT dataflow jobs drain $job
done

if gcloud --project=$PROJECT pubsub subscriptions describe $PUBSUB_SUBSCRIPTION &>/dev/null ; then
  input "Deleting pubsub subscription"
  gcloud --project=$PROJECT pubsub subscriptions delete $PUBSUB_SUBSCRIPTION
fi

if gcloud --project=$PROJECT pubsub subscriptions describe $DATAFLOW_PUBSUB_SUBSCRIPTION &>/dev/null ; then
  input "Deleting dataflow pubsub subscription"
  gcloud --project=$PROJECT pubsub subscriptions delete $DATAFLOW_PUBSUB_SUBSCRIPTION
fi

if gcloud --project $PROJECT iam service-accounts describe $COMPUTE_SERVICE_ACCOUNT@$PROJECT.iam.gserviceaccount.com &>/dev/null ; then
  input "Deleting compute service account"
  gcloud --project=$PROJECT iam service-accounts delete $COMPUTE_SERVICE_ACCOUNT@$PROJECT.iam.gserviceaccount.com
fi

if gcloud --project $PROJECT iam service-accounts describe $DATAFLOW_SERVICE_ACCOUNT@$PROJECT.iam.gserviceaccount.com &>/dev/null ; then
  input "Deleting dataflow service account"
  gcloud --project=$PROJECT iam service-accounts delete $DATAFLOW_SERVICE_ACCOUNT@$PROJECT.iam.gserviceaccount.com
fi

if gsutil ls $BUCKET/ &>/dev/null ; then
  input "Deleting gcs bucket"
  gsutil rm -r $BUCKET
fi
