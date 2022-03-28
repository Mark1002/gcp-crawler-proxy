## GCP crawler proxy
### Introduction
This project is a crawler proxy project base on GCP.
Use Squid, the forword proxy server as the docker image running on VM group,
and use GCP tcp proxy load balancer as the access entrypoint.

### Build and deploy
1. build sqiud forword proxy docker image.
```
$ ./script/build_docker_push.sh
```
2. create tf backend gcs and add backend.cof
```
$ ./script/create_state_bucket.sh 
```
backend.conf
```
bucket  = "<tf backend gcs>"
prefix  = "<terraform state prefix>"
```
3. init terraform
```
$ terraform init -backend-config=backend.conf
```
4. apply terraform
```
$ terraform apply
```
### Usage
```python
import requests

proxies = {
  'https': 'http://35.190.69.208:8085', # your gcp tcp proxy address
}

res = requests.get('https://ifconfig.me/', proxies=proxies)
print(res.text)

```

### reference

1. https://harry-lin.blogspot.com/2019/05/docker-azuredockersquid-proxy.html
2. https://github.com/sameersbn/docker-squid#configuration
3. https://medium.com/google-cloud/squid-proxy-cluster-with-ssl-bump-on-google-cloud-7871ee257c27
4. https://cloud.google.com/load-balancing/docs/tcp/setting-up-tcp#configuring_the_load_balancer

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/Mark1002/gcp-crawler-proxy.git)
