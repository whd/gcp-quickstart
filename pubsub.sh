#!/bin/bash

input "Listing pubsub topics"
gcloud --project=$SHARED_PROJECT pubsub topics list --format 'value(name)'

if ! gcloud --project=$PROJECT pubsub subscriptions describe $PUBSUB_SUBSCRIPTION &>/dev/null ; then
  input "Creating a pubsub subscription for telemetry decoded data"
  gcloud --project=$PROJECT pubsub subscriptions create --topic projects/${SHARED_PROJECT}/topics/telemetry-decoded $PUBSUB_SUBSCRIPTION
fi
echo
echo "https://console.cloud.google.com/cloudpubsub/subscriptions/${PUBSUB_SUBSCRIPTION}?project=${PROJECT}"

input "Listing pubsub subscriptions"
gcloud --project=$PROJECT pubsub subscriptions list --format 'value(name)'

# reset subscription
echo
echo "Resetting subscription to latest offsets"
gcloud --project=$PROJECT pubsub subscriptions seek ${PUBSUB_SUBSCRIPTION} --time=+0s
# this will likely crash due to binary data being improperly handled by gcloud
# gcloud pubsub subscriptions pull --auto-ack $PUBSUB_SUBSCRIPTION --limit 1
# inspect attributes only
input "Pulling a single message from the subscription (developer credentials)"
gcloud --project=$PROJECT pubsub subscriptions pull --auto-ack $PUBSUB_SUBSCRIPTION --limit 1 --format 'value(ATTRIBUTES)'

input "Running the pubsub pull on a compute instance (service account credentials)"
gcloud compute --project $PROJECT ssh --zone $ZONE $COMPUTE_INSTANCE_NAME --command \
  "gcloud --project=$PROJECT pubsub subscriptions pull --auto-ack $PUBSUB_SUBSCRIPTION --limit 1 --format 'value(ATTRIBUTES)'"
