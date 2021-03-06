#!/bin/bash
if ! gcloud compute --project=$PROJECT instances describe --zone $ZONE $COMPUTE_INSTANCE_NAME &>/dev/null ; then
  input "Creating compute instance"
  gcloud compute --project=$PROJECT instances create $COMPUTE_INSTANCE_NAME \
    --zone=$ZONE \
    --machine-type=n1-standard-1 \
    --subnet=default \
    --network-tier=PREMIUM \
    --maintenance-policy=MIGRATE \
    --service-account=$COMPUTE_SERVICE_ACCOUNT@$PROJECT.iam.gserviceaccount.com \
    --scopes=https://www.googleapis.com/auth/cloud-platform \
    --image=debian-9-stretch-v20190312 \
    --image-project=debian-cloud \
    --boot-disk-size=10GB \
    --boot-disk-type=pd-standard \
    --boot-disk-device-name=$COMPUTE_INSTANCE_NAME
fi

echo https://console.cloud.google.com/compute/instancesDetail/zones/us-west1-a/instances/${COMPUTE_INSTANCE_NAME}?project=${PROJECT}
