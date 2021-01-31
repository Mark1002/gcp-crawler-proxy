## GCP crawler proxy
### introduction
This project is a crawler proxy project base on GCP.
Use Squid, the forword proxy server as the docker image running on VM group,
and use GCP tcp proxy load balancer as the access entrypoint.


### reference

1. https://harry-lin.blogspot.com/2019/05/docker-azuredockersquid-proxy.html
2. https://github.com/sameersbn/docker-squid#configuration
3. https://medium.com/google-cloud/squid-proxy-cluster-with-ssl-bump-on-google-cloud-7871ee257c27
4. https://cloud.google.com/load-balancing/docs/tcp/setting-up-tcp#configuring_the_load_balancer

[![Open in Cloud Shell](https://gstatic.com/cloudssh/images/open-btn.svg)](https://ssh.cloud.google.com/cloudshell/editor?cloudshell_git_repo=https://github.com/Mark1002/gcp-crawler-proxy.git)