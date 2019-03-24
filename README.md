# GCP quickstart demo

This repository contains scripts for creating a GCP project in Mozilla's Data
Platform developer sandbox that has access to real, sanitized (decoded)
telemetry and structured ingestion data, along with examples of how to access
that data. The target audience is data engineers who need access to real data
while developing new services.

# Prerequisites
1. Bash
1. Access to GCP infrastructure
   1. If you don't have this, talk to :mreid or :jason.
   1. In particular, you must be in the `team-data-platform@firefox.gcp.mozilla.com` Google group.
1. [Google Cloud SDK](https://cloud.google.com/sdk/install)
1. [Docker](https://docs.docker.com/install/) (For Dataflow)

# Bootstrapping the sandbox project

```bash
# Optionally set your project id, defaults to $USER-sandbox-demo
export PROJECT=my-project-name

# Create your sandbox project and related service accounts
./demo bootstrap_project

# Set up a compute instance to access data
./demo compute_instance
```

# Demos
```bash
# Run bigquery examples
# list datasests, tables, and run queries
./demo bigquery

# Run pubsub examples
# create and list subscriptions, reset offsets, and pull messages
./demo pubsub

# Run dataflow example
# build our existing gcs sink application and run it as a dataflow job in your project
./demo dataflow
```
# Clean up

```bash
# Destroy resources created by demo scripts
./demo destroy

# Delete the entire project
./demo destroy_project
```

# Notes

If you see permissions errors when running commands via service accounts and
compute instances, allow 5-10 minutes for the necessary permissions to
propagate. If you're still having issues after that, ping :whd on IRC.

GCP data infrastructure is currently in pre-production and not subject to any
particular availability guarantees. Many datasets have not yet been
implemented, but will be implemented in the future.

Eventually, Ops tooling will include bootstrapping for sandbox projects via
terraform, greatly simplifying this process. It will also include support for
k8s <!-- (call me out :mreid I dare you) --> etc. At that time most of the
examples in this repo will be obsolete and replaced by documentation of that
tooling.

Developers do not have access to `$TOPIC-raw` topics by default from the
developer sandbox. If you are developing a service that needs access to
unsanitized data e.g. schema analysis, special ACLs will need to be granted to
your project (file a bug or talk to :whd).

This demo covers access to most "GCP-native" datasets i.e. datasets generated
by our [GCP ingestion
infrastructure](https://github.com/mozilla/gcp-ingestion). Automatic service
account permissions for derived and AWS-based datasets is forthcoming. For now,
file a bug [(example)](https://bugzilla.mozilla.org/show_bug.cgi?id=1525940#c1)
if you need access to those datasets from your sandbox project.

Reading real data at scale is expensive, so try to use real data sparingly. The
pubsub example demo has a command for resetting subscriptions to "latest
offsets" which should be employed. Sampled and debug / low volume topics are
coming soon, and when they are available, prefer those to using the full streams
(this repo will be updated to default to using them).

There is a
[developers](https://console.cloud.google.com/projectselector2/home/dashboard?folder=453400997095&supportedpurview=project&project=&organizationId=)
folder at the top level of our GCP hierarchy. This folder is not Data
Platform-specific and should only be used for projects that will not need
access to real data during development. The sandbox folder should generally be
preferred for Data Platform-related development.

# Links

* [GCP Ingestion Code Repository](https://github.com/mozilla/gcp-ingestion)
* [GCP Ingestion Deploy Logic Repository](https://github.com/mozilla-services/cloudops-infra/tree/ingestion)
* [PubSub Documentation](https://cloud.google.com/pubsub/docs/reference/libraries)
* [Pubsub Python API](https://github.com/googleapis/google-cloud-python/tree/master/pubsub)
* [Dataflow Documentation](https://cloud.google.com/dataflow/)
* [Sandbox Web Console](https://console.cloud.google.com/projectselector2/home/dashboard?folder=1087424465539&supportedpurview=project)
* [Sandbox Description](https://docs.google.com/document/d/1OqEePBIwdAEicS4zita6VYeVlFfgJXSyDdi55kzg_Fs/edit#heading=h.4iyidj711dro)
* [Shared Datasets BigQuery console](https://console.cloud.google.com/bigquery?project=moz-fx-data-shar-nonprod-efed&supportedpurview=project)
* [Shared PubSub console](https://console.cloud.google.com/cloudpubsub/topicList?project=moz-fx-data-shar-nonprod-efed&supportedpurview=project)
