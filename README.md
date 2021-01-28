# Free5GC K8S

This repository is effectively a K8S version of the free5gc-compose docker compose version of [free5GC](https://github.com/free5gc/free5gc) for stage 3, which itself is inspired by [free5gc-docker-compose](https://github.com/calee0219/free5gc-docker-compose) and also reference to [docker-free5GC](https://github.com/abousselmi/docker-free5gc).

The original free5gc-compose config can be found in the [config](./config) folder and the original docker-compose.yaml is at [docker-compose.yaml](docker-compose.yaml). These are for reference only and were taken from the free5gc-compose project around 26th January 2021.

Note that unfortunately, due to problems with k8s container volume mounts (it seems to want to treat the files as directories) the
config files in the ./config folder are not used and the relevant config files are instead placed in the nf_network-function folders where the nf docker images are built and copied into the docker image at build time. This means, in contrast to free5gc-compose, you cannot change the config and have it picked up next time the cluster is started. Clearly a fix is required.

Note also that the kompose_yaml_hostPath.yaml, whilst it was originally generated from the docker-compose.yaml (with the command kompose convert -o kompose_yaml_hostPath.yaml --volumes hostPath), has subsequently been manually edited to remove the volume commands (because of the problem above) and to change the names of the docker images to get them from a named repository (currently  bsconsul/free5gc-network-function - these image names must match the names in the .yaml file) 

## Prerequisites

### GTP5G kernel module

Due to the UPF issue, the host must using kernel `5.0.0-23-generic` or above (free5gc-k8s has been tested with Ubuntu 18.04.5
without updating the kernel so is fine in this respect). And it should contain `gtp5g` kernel module.

On your host OS:
```
git clone https://github.com/PrinzOwO/gtp5g.git
cd gtp5g
make
sudo make install
```

### Docker engine

To install docker on your favorite OS, you can follow instruction here: https://docs.docker.com/engine/install/

### minikube

Install minikube as detailed at https://v1-18.docs.kubernetes.io/docs/tasks/tools/install-minikube/

### kompose

Install kompose as detailed here https://kompose.io/installation/

## minikube setup

Run minikube with the docker driver and then check status with kubectl

```bash
$ minikube start --driver=docker
$ kubectl version
```
K8s uses a different local container repository to docker. If you will be building docker images locally to be picked up
by K8s (rather than pulling them from docker.io) it is advisable to all operations from within shells with the environment
modified to have docker use the K8s registry

Run

```bash
$ minikube docker-env

#This will produce something like;

export DOCKER_TLS_VERIFY="1"
export DOCKER_HOST="tcp://192.168.49.2:2376"
export DOCKER_CERT_PATH="/home/../.minikube/certs"
export MINIKUBE_ACTIVE_DOCKERD="minikube"

To point your shell to minikube's docker-daemon, run:

eval $(minikube -p minikube docker-env)

#copy and paste that eval command into the shell

$ eval $(minikube -p minikube docker-env)
```
## Start Free5gc-k8s

```bash
$ git clone https://github.com/bsconsul/free5gc-k8s.git
$ cd free5gc-k8s
# make the base container image which involves building the network functions inside the container,
# for subsequent extraction into the individual network function docker images
$ make base
$
# make all network functions and webui
$ make net
$
# Start the deployment (may need root as indicated in free5gc-compose README (quote: Because we need to create tunnel
# interface, we need to use privileged container with root permission))
$ sudo kubectl apply -f kompose_yaml_hostPath.yaml
$
# Check out deployment
$ kubectl get deployment

#Should see something better than;

NAME            READY   UP-TO-DATE   AVAILABLE   AGE
db              1/1     1            1           12h
free5gc-amf     1/1     1            1           12h
free5gc-ausf    1/1     1            1           12h
free5gc-n3iwf   0/1     1            0           12h
free5gc-nrf     1/1     1            1           12h
free5gc-nssf    1/1     1            1           12h
free5gc-pcf     1/1     1            1           12h
free5gc-smf     0/1     1            0           12h
free5gc-udm     1/1     1            1           12h
free5gc-udr     1/1     1            1           12h
free5gc-upf     0/1     1            0           12h
free5gc-upf-2   0/1     1            0           12h
free5gc-upf-b   0/1     1            0           12h
free5gc-webui   1/1     1            1           12h

#Check out what services are running

$ kubectl get svc

#Should see something like;

NAME            TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)     AGE
db              ClusterIP   10.103.135.120   <none>        27017/TCP   12h
free5gc-amf     ClusterIP   10.100.131.100   <none>        29518/TCP   12h
free5gc-ausf    ClusterIP   10.111.81.61     <none>        29509/TCP   12h
free5gc-nrf     ClusterIP   10.98.142.185    <none>        29510/TCP   12h
free5gc-nssf    ClusterIP   10.101.93.222    <none>        29531/TCP   12h
free5gc-pcf     ClusterIP   10.103.13.216    <none>        29507/TCP   12h
free5gc-smf     ClusterIP   10.106.255.121   <none>        29502/TCP   12h
free5gc-udm     ClusterIP   10.99.114.180    <none>        29503/TCP   12h
free5gc-udr     ClusterIP   10.102.202.143   <none>        29504/TCP   12h
free5gc-webui   ClusterIP   10.103.72.59     <none>        5000/TCP    12h
kubernetes      ClusterIP   10.96.0.1        <none>        443/TCP     38h

#Check out pods

$ kubectl get pods -o wide

Should see something better than the following (hopefully!)

NAME                             READY   STATUS             RESTARTS   AGE   IP            NODE       NOMINATED NODE   READINESS GATES
db-5947bb46fd-9ndp5              1/1     Running            0          12h   172.17.0.4    minikube   <none>           <none>
free5gc-amf-5fbb948f4c-s9shz     1/1     Running            0          12h   172.17.0.12   minikube   <none>           <none>
free5gc-ausf-8568f5b9bc-x9dm8    1/1     Running            0          12h   172.17.0.15   minikube   <none>           <none>
free5gc-n3iwf-8744dfc49-p9n92    0/1     CrashLoopBackOff   5          12h   172.17.0.17   minikube   <none>           <none>
free5gc-nrf-667679cc85-cm7f7     1/1     Running            0          12h   172.17.0.8    minikube   <none>           <none>
free5gc-nssf-5f78b4dd74-9n48t    1/1     Running            0          12h   172.17.0.6    minikube   <none>           <none>
free5gc-pcf-69dff95d7c-2hrtj     1/1     Running            0          12h   172.17.0.10   minikube   <none>           <none>
free5gc-smf-767f54d4b8-5s2cw     0/1     CrashLoopBackOff   5          12h   172.17.0.9    minikube   <none>           <none>
free5gc-udm-7f4cb87b4c-dzptv     1/1     Running            0          12h   172.17.0.11   minikube   <none>           <none>
free5gc-udr-7cf8df8bc4-jjkzg     1/1     Running            0          12h   172.17.0.7    minikube   <none>           <none>
free5gc-upf-2-5c45566fff-2gfbx   0/1     CrashLoopBackOff   5          12h   172.17.0.16   minikube   <none>           <none>
free5gc-upf-859475c8b8-fmsrj     0/1     CrashLoopBackOff   5          12h   172.17.0.13   minikube   <none>           <none>
free5gc-upf-b-5c4947-mlb4x       0/1     CrashLoopBackOff   5          12h   172.17.0.14   minikube   <none>           <none>
free5gc-webui-5ff75bdb98-crhkl   1/1     Running            1          12h   172.17.0.5    minikube   <none>           <none>
```

## Troubleshooting

Endless and ongoing!

For free5gc basics see Troubleshooting from https://www.free5gc.org/installation.

free5gc-compose also has relevant information see Troubleshooting at https://github.com/free5gc/free5gc-compose.

For k8s issues note that this is in its infancy and there will be many issues to resolve; start up order, networking etc..

## Reference