#!/bin/bash

## Contains configuration values for the Docker registry.

# Registry stack name
STACK_NAME=${STACK_NAME:-k8s-docker-registry}

# Keypair for registry stack
REGISTRY_KEYPAIR_NAME=${KUBERNETES_KEYPAIR_NAME:-kubernetes_keypair}

INSTANCE_FLAVOR=${INSTANCE_FLAVOR:-m1.small}

EXTERNAL_NETWORK=${EXTERNAL_NETWORK:-public}

FIXED_NETWORK_CIDR=${FIXED_NETWORK_CIDR:-10.1.0.0/24}

# Image id which will be used for kubernetes stack
IMAGE_ID=${IMAGE_ID:-0b9fec74-1f5b-4a08-9812-770b23a2fac8}

# DNS server address
DNS_SERVER=${DNS_SERVER:-8.8.8.8}

# Public RSA key path
CLIENT_PUBLIC_KEY_PATH=${CLIENT_PUBLIC_KEY_PATH:-~/.ssh/id_rsa.pub}

# Max time period for stack provisioning. Time in minutes.
STACK_CREATE_TIMEOUT=${STACK_CREATE_TIMEOUT:-60}

K8S_VERSION=${K8S_VERSION:-1.2.0}

ETCD_VERSION=${ETCD_VERSION:-2.2.1}

FLANNEL_VERSION=${FLANNEL_VERSION:-0.5.5}
