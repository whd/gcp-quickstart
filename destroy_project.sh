#!/bin/bash

if gcloud projects describe $PROJECT &>/dev/null ; then
   gcloud projects delete $PROJECT
fi
