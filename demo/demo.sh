#!/bin/bash

set -xe
export KUBECONFIG=~/.crc/machines/crc/kubeconfig
LOCAL_IMAGE=localhost/image-tekton-encrypt:latest
IS=tekton-encrypt-images

# Push into the local registry
oc login -u kubeadmin -p $(cat ~/.crc/machines/crc/kubeadmin-password) https://api.crc.testing:6443
oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge
HOST=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')
podman login -u kubeadmin -p $(oc whoami -t) --tls-verify=false $HOST 
oc create imagestream $IS
podman tag $LOCAL_IMAGE $HOST/$IS:latest

# Create the tekton task
oc new-project encrypt-image-demo
oc create -f ../tekton-task.yaml
# Run the tekton task
oc create -f ../task-run.yaml

