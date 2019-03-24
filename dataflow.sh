#!/bin/bash

if ! gcloud --project=$PROJECT pubsub subscriptions describe $DATAFLOW_PUBSUB_SUBSCRIPTION &>/dev/null ; then
  input "Creating a pubsub subscription for dataflow"
  gcloud --project=$PROJECT pubsub subscriptions create --topic projects/${SHARED_PROJECT}/topics/structured-decoded $DATAFLOW_PUBSUB_SUBSCRIPTION
fi
echo https://console.cloud.google.com/cloudpubsub/subscriptions/${DATAFLOW_PUBSUB_SUBSCRIPTION}?project=$PROJECT

if ! gsutil ls $BUCKET/ &>/dev/null ; then
  input "Creating a gcs bucket for dataflow"
  gsutil mb $BUCKET
fi
echo https://console.cloud.google.com/storage/browser/$(basename $BUCKET)?project=$PROJECT

if ! [[ -d gcp-ingestion ]] ; then
  input "Checking out gcp-ingestion repo"
  git clone https://github.com/mozilla/gcp-ingestion
fi

cd gcp-ingestion/ingestion-beam

if ! [[ -f key.json ]]; then
  input "Writing service account credentials to local filesystem"
  gcloud iam service-accounts keys create ./key.json --iam-account $DATAFLOW_SERVICE_ACCOUNT@$PROJECT.iam.gserviceaccount.com
fi

export GOOGLE_APPLICATION_CREDENTIALS=key.json

input "Compiling and running dataflow job"
./bin/mvn compile exec:java -Dexec.args="\
    --project=$PROJECT \
    --runner=Dataflow \
    --gcpTempLocation=$BUCKET/tmp \
    --inputFileFormat=json \
    --inputType=pubsub \
    --input=projects/$PROJECT/subscriptions/$DATAFLOW_PUBSUB_SUBSCRIPTION \
    --outputFileFormat=json \
    --outputType=file \
    --output=$BUCKET/output \
    --errorOutputType=file \
    --outputNumShards=10 \
    --errorOutputNumShards=10 \
    --errorOutput=$BUCKET/error \
"

echo https://console.cloud.google.com/dataflow?project=${PROJECT}
