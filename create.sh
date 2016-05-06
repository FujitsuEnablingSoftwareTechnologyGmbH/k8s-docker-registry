#!/bin/bash

# exit on any error
set -e

readonly ROOT=$(dirname "${BASH_SOURCE}")
source "${ROOT}/openrc-default.sh"
source "${ROOT}/config-default.sh"

# Verify prereqs on host machine
function verify-prereqs() {
 # Check the OpenStack command-line clients
 for client in openstack nova;
 do
  if which $client >/dev/null 2>&1; then
    echo "$client client installed"
  else
    echo "$client client does not exist"
    echo "Please install $client client, and retry."
    exit 1
  fi
 done
}

# Create a new key pair for use with servers.
#
# Assumed vars:
#   REGISTRY_KEYPAIR_NAME
#   CLIENT_PUBLIC_KEY_PATH
function add-keypair() {
  local status=$(nova keypair-show ${REGISTRY_KEYPAIR_NAME})
  if [[ ! $status ]]; then
    nova keypair-add ${REGISTRY_KEYPAIR_NAME} --pub-key ${CLIENT_PUBLIC_KEY_PATH}
    echo "[INFO] Key pair created"
  else
    echo "[INFO] Key pair already exists"
  fi
}

function run-heat-script() {

  local stack_status=$(openstack stack show ${STACK_NAME})

  if [[ ! $stack_status ]]; then
    echo "[INFO] Create stack ${STACK_NAME}"
    openstack stack create --timeout 60 \
      --parameter external_network=${EXTERNAL_NETWORK} \
      --parameter ssh_key_name=${REGISTRY_KEYPAIR_NAME} \
      --parameter server_image=${IMAGE_ID} \
      --parameter instance_flavor=${INSTANCE_FLAVOR} \
      --parameter dns_nameserver=${DNS_SERVER} \
      --parameter k8s_version=${K8S_VERSION} \
      --parameter etcd_version=${ETCD_VERSION} \
      --parameter flannel_version=${FLANNEL_VERSION} \
      --parameter fixed_network_cidr=${FIXED_NETWORK_CIDR} \
      --template registry.yaml \
      ${STACK_NAME}
  else
    echo "[INFO] Stack ${STACK_NAME} already exists"
    openstack stack show ${STACK_NAME}
  fi
}

# Periodically checks if stack was created
#
# Assumed vars:
#   STACK_CREATE_TIMEOUT
#   STACK_NAME
function validate-instance() {
  local sp="/-\|"
  SECONDS=0
  while (( ${SECONDS} < ${STACK_CREATE_TIMEOUT}*60 )) ;do
     local status=$(openstack stack show "${STACK_NAME}" | awk '$2=="stack_status" {print $4}')
     if [[ $status ]]; then
        if [ $status = "CREATE_COMPLETE" ]; then
          echo "Registry instance status ${status}"
          break
        elif [ $status = "CREATE_FAILED" ]; then
          echo "Instance not created. Please check stack logs to find the problem"
          break
        fi
     else
       echo "Instance not created. Please verify if process started correctly"
       break
     fi
     printf "\b${sp:SECONDS%${#sp}:1}"
     sleep 1
  done
}


echo "... calling verify-prereqs" >&2
verify-prereqs

echo "... calling add-keypair" >&2
add-keypair

echo "... calling run-heat-script" >&2
run-heat-script

echo "... calling validate-instance" >&2
validate-instance

exit 0

