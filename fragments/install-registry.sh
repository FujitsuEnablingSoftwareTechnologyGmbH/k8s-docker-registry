#!/bin/bash

set -o errexit
set -o nounset
set -o pipefail

source /etc/sysconfig/registry

tee /etc/yum.repos.d/docker.repo <<-'EOF'
[dockerrepo]
name=Docker Repository
baseurl=https://yum.dockerproject.org/repo/main/centos/$releasever/
enabled=1
gpgcheck=1
gpgkey=https://yum.dockerproject.org/gpg
EOF

yum install -y docker-engine

systemctl enable docker
systemctl restart docker

docker run -d -p 5000:5000 --name registry registry:2

docker pull gcr.io/google_containers/etcd-amd64:${ETCD_VERSION}
docker pull quay.io/coreos/flannel:${FLANNEL_VERSION}
docker pull gcr.io/google_containers/hyperkube-amd64:v${K8S_VERSION}
docker pull fest/addons_services:latest
docker pull gcr.io/google_containers/pause:2.0

docker tag gcr.io/google_containers/etcd-amd64:${ETCD_VERSION} localhost:5000/gcr.io/google_containers/etcd-amd64:${ETCD_VERSION}
docker push localhost:5000/gcr.io/google_containers/etcd-amd64:${ETCD_VERSION}

docker tag quay.io/coreos/flannel:${FLANNEL_VERSION} localhost:5000/quay.io/coreos/flannel:${FLANNEL_VERSION}
docker push localhost:5000/quay.io/coreos/flannel:${FLANNEL_VERSION}

docker tag gcr.io/google_containers/hyperkube-amd64:v${K8S_VERSION} localhost:5000/gcr.io/google_containers/hyperkube-amd64:v${K8S_VERSION}
docker push localhost:5000/gcr.io/google_containers/hyperkube-amd64:v${K8S_VERSION}

docker tag fest/addons_services:latest localhost:5000/fest/addons_services:latest
docker push localhost:5000/fest/addons_services:latest

docker tag gcr.io/google_containers/pause:2.0 localhost:5000/gcr.io/google_containers/pause:2.0
docker push localhost:5000/gcr.io/google_containers/pause:2.0
