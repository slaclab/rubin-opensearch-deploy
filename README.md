# rubin-opensearch-deploy

## Deployment framework for Rubin USDF OpenSearch

This project requires a Kubernetes cluster with permissions to run operators as needed. Once you have access to your Kubernetes cluster, you can deploy Rucio for a given overlay using the Makefile found there with:

> make apply

This will run mutltiple steps, downloading secrets from Vault and using Kustomise to create / update OpenSearch and the namespace it uses. This project includes the configuration for master nodes, worker nodes, and OpenSearch Dashboards.



This framework uses kustomize to allow modification of Helm template outputs from the official OpenSearch Helm chart. Secrets stored in Vault are downloaded by the controlling Makefile for a given overlay. Secrets are then created in the cluster and provided to the OpenSearch application through a combination of Kustomize creating the Secret objects, and the OpenSearch Helm chart values determining which containers those secrets are mounted to.

If any updates are made to the values-*.yaml files, ensure that the delpoyments are updated using
> make opensearch


There are a number of config files that can be mounted into Opensearch to override defaults. These are found in the Vault and can be gotten by running:
> make get-config
they can then be edited and updated in the Vault with 
> make put-config
and will be uopdated on the cluster next time you run 
> make apply

These config values currently ensure the admin account is not default, as well as creating a rucio and panda user that can be used to write to indexes that start with those names (e.g. rucio-*)