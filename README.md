# Create encrypted image for Confidential workloads

## Build
```
$ cd image
$ podman build -t image-tekton-encrypt .
```

## RUN
Locally in a separate directory
```bash
$ sudo mkdir -p /var/lib/containers1 
$ sudo podman run --privileged -it -v /var/lib/containers1:/var/lib/containers:Z localhost/image-tekton-encrypt  fedora:latest encrypt myamazingpassword
$ sudo podman --root /var/lib/containers1/storage images  -a
REPOSITORY                         TAG         IMAGE ID      CREATED         SIZE
localhost/encrypt                  latest      44d10fe62130  16 minutes ago  3.25 kB
<none>                             <none>      4ae8fc7c1659  21 minutes ago  3.25 kB
registry.fedoraproject.org/fedora  latest      1b52edb08181  16 hours ago    159 MB
```

## Run in OCP

### Prerequisites
In order to run the demo you need to:
1. install and deploy an [OCP cluster using CRC](https://crc.dev/crc/)
2. the tkn [binary](https://docs.openshift.com/container-platform/4.9/cli_reference/tkn_cli/installing-tkn.html#installing-tkn) 
3. [install the pipline operator from the operator hub](https://docs.openshift.com/container-platform/4.9/cicd/pipelines/installing-pipelines.html)

If you already have an OCP cluster you need to adjust the KUBECONFIG path to point the correct one.

The demo create a tekton task that pull a container image, it transform it in an ecrypted image and push it in the internal registry and create an image stream to make the image available to the insecure namespace.
```bash
$ cd demo
$ ./demo.sh
```
