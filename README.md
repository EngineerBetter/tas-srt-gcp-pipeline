# **Tanzu Application Service (for VMs!) Small Footprint pipeline**

This is a [Concourse CI](https://concourse-ci.org/) pipeline that deploys the [small footprint version](https://docs.pivotal.io/application-service/2-10/operating/small-footprint.html) of VMware Tanzu Application Service for VMs on six virtual machines on Google Cloud. TAS is VMware's paid-for distribution of Cloud Foundry, and normally deploys on 40+ VMs.

Because we wrote this pipeline for ourselves, the pipeline assumes you have a parent DNS zone defined in AWS route53 (something.com) in which we can create an NS record to delegate to a child zone that the pipeline is going to create in Google Cloud DNS (somethingelse.something.com). In the likely event that this is not the case for you, you will need to fork the repo and [adapt the terraform](./tf/project-account-and-bucket/dns.tf) to work with your current DNS provider.

This repo is intended for development/POC purposes only, and _definitely_ not for production use unless you are a cowboy :cowboy_hat_face:

## **Prerequisites**

* Concourse CI running ≥ v6.0.0 with [Credhub]((https://github.com/cloudfoundry-incubator/credhub)) deployed as an integrated secrets manager.
* A version of Concourse's `fly` CLI in your local PATH matching the version of your Concourse server. Download it [here](https://github.com/concourse/concourse/releases).
* The following for a Google Cloud account:
  - Billing account ID
  - User account with privileges to create projects
  - The ID of an existing [GCP organization](https://cloud.google.com/resource-manager/docs/creating-managing-organization) in which to create projects
* A parent DNS zone defined in AWS route53 that will be used to delegate to the DNS zone that will be created in GCP as part of this pipeline.

## **Preparing to deploy**

### **Create GCP folder, parent project and service account**

The pipeline depends on a handful of resources already existing in your Google Cloud organization before it runs for the first time. Run [this bash script](https://github.com/EngineerBetter/concourse-gcp-tf-bootstrap#inception-script) to create the following, details of which we'll need in the next step:
* A folder
* project
* A service account in the project that is able to create new projects

### **Write variables file**

Create a new yaml file in `/vars` named after your environment - e.g. `poc.yml` based on the following template:

```yaml
env: #name you choose for your environment

concourse_team: #concourse team in which to set pipeline e.g. 'main'
concourse_pipeline: #name you choose for your pipeline
gcp_project_id: # ID you choose for a project (unique across all of google cloud)
project_name: # name you choose for a new google cloud project (unique across all of google cloud)
region: # google cloud region in which to deploy
zone: # google cloud zone within the above region
folder_name: # google cloud folder created in the previous step
bucket_location: # google cloud location in which to create storage bucket. Choose "EU", "US" or "ASIA".
parent_domain: # parent DNS zone in route53 in which we will create an NS record to delegate to the GCP zone created in this pipeline
tas_version: # version of TAS to deploy
opsman_version: # version of Opsman to deploy. If in doubt, use the same as the above.
tas_stemcell: # stemcell to deploy with TAS. Choose a version compatible with your TAS version on Tanzu Network: https://network.pivotal.io/products/elastic-runtime: (see right side of screen under 'Pivotal Stemcells').
```
### **Add values to secrets manager**

In addition to variables that we provide in a file, Concourse retrieves the values for some pipeline variables directly from its integrated secrets manager. Create a file locally based on the template below, and fill in the appropriate values. Replace `((concourse_team))` with the name of your Concourse team (if you're not sure, use the default `main` team), and `((concourse_pipeline))` with whatever name you want to use for your pipeline. Then use the [Credhub CLI](https://github.com/cloudfoundry-incubator/credhub-cli) to authenticate with Credhub.

When you're authenticated, set the credentials with the following command:

```sh
$ credhub import --file creds.yml
```

```yaml
# creds.yml
---
credentials:
- name: /concourse/((concourse_team))/((concourse_pipeline))/credhub
  type: json
  value:
    client: # client name for integrated credhub
    secret: # client secret
    server: # credhub URL
    ca_cert: # certificate authority certificate for credhub

- name: /concourse/((concourse_team))/((concourse_pipeline))/inception_gcp_credentials_json
  type: json
  value: |-
    # paste multiline JSON for service account key here, indented two
    spaces to the right of the 'value' field above.

- name: /concourse/((concourse_team))/((concourse_pipeline))/git_private_key
  type: value
  value: |-
    # paste multiline private SSH key matching a public key linked to a
    GitHub account, indented two spaces to the right of the 'value' field
    above.

- name: /concourse/((concourse_team))/((concourse_pipeline))/pivnet_token
  type: value
  value: # A UAA API Token for accessing Tanzu Network - see https://network.pivotal.io/docs/api

- name: /concourse/((concourse_team))/((concourse_pipeline))/organization_id
  type: value
  value: # ID of Google Cloud organization whose existence is a prerequisite

- name: /concourse/((concourse_team))/((concourse_pipeline))/aws_access_key_id
  type: value
  value: # Acccess key for an AWS user with permissions to create records in route53

- name: /concourse/((concourse_team))/((concourse_pipeline))/aws_secret_access_key
  type: value
  value: # Secret access key for above AWS user

- name: /concourse/((concourse_team))/((concourse_pipeline))/aws_default_region
  type: value
  value: # AWS region for your existing parent DNS zone, in which we will create an NS record delegating to Google Cloud DNS
```

## **Deploy**

### Set-pipeline

Once you've [created a Google Cloud folder, project and service account](#create-gcp-folder-parent-project-and-service-account), written a [variables file](#write-variables-file) and [uploaded the required secrets to credhub](#add-values-to-secrets-manager), we're ready to run the pipeline.

Assuming you have the [fly CLI](https://concourse-ci.org/fly.html) in your local PATH, run the following:

```sh
$ fly --target # name-of-your-concourse-target \
  set-pipeline \
  --pipeline # pipeline name that must match ((concourse_pipeline)) in the names of the secrets you uploaded to credhub \
  --config ci/pipeline.yml \
  --load-vars-from vars/((env)).yml \ #where ((env)) is your chosen environment name

$ fly --target # name-of-your-concourse-target \
  unpause-pipeline \
  --pipeline # pipeline-name
```

After this, login to Concourse in your browser and you should see your pipeline. The pipeline has been written to set itself when there are new commits to this repository, so you should not need to set it manually again.

## **Teardown**

The pipeline includes a number of jobs to automate the teardown of what you have created. Note that other than resources created inside the Google Cloud project that the pipeline makes for you (which can all be killed by deleting that project), the pipeline also creates credentials in your Credhub and a single NS record in AWS route53.

Also note that if you delete your Google Cloud project you will need to update your variables file to choose a new project name/ID, as names of recently-deleted projects cannot be immediately reused.