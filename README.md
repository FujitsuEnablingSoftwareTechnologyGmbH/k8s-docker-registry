# Getting started with k8s-docker-registry

This guide will take you through the steps of deploying Docker registry to Openstack. The registry server provides hypercube, etcd and flannel images.

This guide assumes you have a working OpenStack cluster.

## Pre-Requisites


### Install OpenStack CLI tools

- openstack >= 2.4.0
- nova >= 3.2.0
```
 sudo pip install -U python-openstackclient

 sudo pip install -U python-novaclient
```


### Configure Openstack CLI tools

 Please get your OpenStack credential and modify the variables in the following files:

 - **config-default.sh** Sets all parameters needed for heat template.
 - **openrc-default.sh** Sets environment variables for communicating to OpenStack. These are consumed by the cli tools (heat, nova).


## Starting a Docker registry


Execute command:

```
./create.sh
```

When your settings are correct you should see installation progress. Script checks if cluster is available as a final step.

```
... calling verify-prereqs
openstack client installed
nova client installed
... calling add-keypair
[INFO] Key pair already exists
... calling run-heat-script
Stack not found: k8s-docker-registry
[INFO] Create stack k8s-docker-registry
+---------------------+--------------------------------------+
| Field               | Value                                |
+---------------------+--------------------------------------+
| id                  | 006f88a6-15d6-4a01-beba-56e31b81901a |
| stack_name          | k8s-docker-registry                  |
| description         | Docker private registry.             |
|                     |                                      |
| creation_time       | 2016-05-06T05:31:58Z                 |
| updated_time        | None                                 |
| stack_status        | CREATE_IN_PROGRESS                   |
| stack_status_reason |                                      |
+---------------------+--------------------------------------+
... calling validate-instance
Registry instance status CREATE_COMPLETE
```

## Docker configuration for private registry

 It’s not possible to use an insecure registry with basic authentication. On client side user must add the **--insecure-registry** flag
 to Docker start parameters.
 
 1 Open /lib/systemd/system/docker.service and add **--insecure-registry** flag to **ExecStart**
 ```
 ExecStart=/usr/bin/docker daemon --insecure-registry=172.24.4.17:5000 -H fd://
 ```

 where IP address 172.24.4.17 is a floating IP for registry instance.

 2 Restart your Docker daemon
 ```
 sudo systemctl daemon-reload
 sudo systemctl restart docker
 ```

 You can now use private registry with your docker.

 ```
 docker pull 172.24.4.17:5000/etcd-amd64:2.2.1
 docker pull 172.24.4.17:5000/flannel:0.5.5
 docker pull 172.24.4.17:5000/hyperkube-amd64:v1.2.0
 ```
 
 
 
