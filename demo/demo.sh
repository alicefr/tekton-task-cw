#!/bin/bash

set -x
export KUBECONFIG=~/.crc/machines/crc/kubeconfig
LOCAL_IMAGE=localhost/image-tekton-encrypt:latest
IS=tekton-encrypt-images
IS_INSECURE_PROJECT=insecure
NS=encrypt-image-demo
SA=tekton-encryp-images
INSECURE_NS=insecure-demo
# Push into the local registry
oc login -u kubeadmin -p $(cat ~/.crc/machines/crc/kubeadmin-password) https://api.crc.testing:6443
oc patch configs.imageregistry.operator.openshift.io/cluster --patch '{"spec":{"defaultRoute":true}}' --type=merge
HOST=$(oc get route default-route -n openshift-image-registry --template='{{ .spec.host }}')
podman login -u kubeadmin -p $(oc whoami -t) --tls-verify=false $HOST 
oc create imagestream $IS
IMAGE=$HOST/$NS/$IS:latest
podman tag $LOCAL_IMAGE $IMAGE
podman push --tls-verify=false $IMAGE

# Create the tekton task
oc new-prject $INSECURE_NS
oc create imagestream $IS_INSECURE_PROJECT
oc new-project $NS

# Create sa for tekton task
oc apply -f ../security-context.yaml
oc create sa $SA
oc adm policy add-scc-to-user scc-admin-demo  system:serviceaccount:$NS:$SA


oc apply -f ../tekton-task.yaml
# Run the tekton task
tkn task  start encrypt-image -p input-image=fedora:latest \
	-p output-image="encrypt-image:latest" \
	-p password=myamazingpassword -p user=kubeadmin -p reg-password=$(oc whoami -t)  -s $SA \
	--use-taskrun demo-task-encryp-image

