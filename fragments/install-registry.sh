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

docker tag gcr.io/google_containers/etcd-amd64:${ETCD_VERSION} localhost:5000/etcd-amd64:${ETCD_VERSION}
docker push localhost:5000/etcd-amd64:${ETCD_VERSION}

docker tag quay.io/coreos/flannel:${FLANNEL_VERSION} localhost:5000/flannel:${FLANNEL_VERSION}
docker push localhost:5000/flannel:${FLANNEL_VERSION}

docker tag gcr.io/google_containers/hyperkube-amd64:v${K8S_VERSION} localhost:5000/hyperkube-amd64:v${K8S_VERSION}
docker push localhost:5000/hyperkube-amd64:v${K8S_VERSION}
