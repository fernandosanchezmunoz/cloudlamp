# Cloud LAMP

[![N|GCP](https://cloud.google.com/_static/images/cloud/icons/favicons/onecloud/apple-icon.png)](https://cloud.google.com) [![N|GCP](https://www.silhouette-illust.com/wp-content/uploads/2016/06/3423-300x300.jpg)](https://cloud.google.com) 

This project aims to provide a modern cloud based implementation of the [LAMP](https://en.wikipedia.org/wiki/LAMP) stack (Linux, Apache, MySQL and PHP). In particular, it implements the following improvements over a traditional monolithic LAMP deployment:

  - Containerize the frontend and app layers in order to leverage consistent environments via immutable infrastructure.
  - Leverage a managed cloud-based container orchestration service in order to eliminate operations overhead and provide seamless elastic, on-demand scalability.
  - Leverage managed and distributed cloud database and storage backends, in order to eliminate operations overhead, increase resilience and availablity, and provide elastic, on-demand scalabliity.
  - Fully automate the infrastructure deployment leveraging Infrastructure-as-Code technology.

## Components

Following on the design principles/goals stated above, below are the implementation details for each components in each solution

#### Common

| Component | Implementation detail | Current version |
| ------ | ------ | ------ |
| Installer packaging | Docker | -
| Infrastructure deployment | Terraform | GCP, Kubernetes providers
| Container orchestration | Google Kubernetes Engine | v1.8.8
| Database backend | Google Cloud SQL | MySQL 5.6
| Storage backend (default) | Rook | Ceph
| Storage backend (NFS option) | NFS | NFS on GCE VM


#### Drupal
| Component | Implementation detail | Current version |
| ------ | ------ | ------ |
| Frontend + App  | Drupal docker container | Bitnami v8.3.7r0

## Usage

#### Pre-requisites

##### Install Docker

This deployment method requires a working Docker installation on the host where it’s run from. In order to install Docker on your platform, refer to this [installation procedure](https://docs.docker.com/install/).

##### Create a GCP project and enable billing
It is recommended that you create a separate GCP project for this deployment. It is possible to use an existing project but that may cause unknown issues due to unexpected existing conditions.
You can create a new project from the Google Cloud console following [these instructions](https://cloud.google.com/resource-manager/docs/creating-managing-projects).
You can enable billing on your project in the Google Cloud console following [these instructions](https://cloud.google.com/billing/docs/how-to/modify-project).

##### Clone the repo, configure and deploy

The installation procedure will check whether the following environment variables are defined; otherwise it will ask interactively for these values :

|  Variable Name | Meaning and how to set it for your environment 
| ------ | ------ |
| `ACCOUNT_ID` | Your username in GCP, usually your email address.
| `ORG_ID` | Your GCP organization ID. You can find it by going into the Google Cloud console, clicking on the top bar’s “project selection” menu, and finding your organization alongside the rest of the projects. It will usually be a 12 digit number placed at the right of your organization’s domain.
| `PROJECT` | Project ID (not the project’s name, although it can be the same if the name is unique across GCP) that was created previously. It can be found in the same “project selection” menu as the organization ID, placed at the right of your project’s name. Usually has the format “your-project-name[-NUMBERS]”
| `REGION` | Region where you want your resources deployed (e.g. “us-east4”)
| `ZONE` | Zone where you want your resources deployed (e.g. “us-east4-c”)
| `MASTER_PASSWORD` | Password to be used across the different components, including the Drupal installation itself or the backend database. This value has a **minimum length of 20 characters**.

If you’d rather not have to enter these values interactively, you can export them as environment variables in your system:
```sh
export ACCOUNT_ID=\
[YOUR_GCP_ACCOUNT_EMAIL_ADDRESS]
export ORG_ID=\
[YOUR_GCP_ORGANIZATION_ID]
export BILLING_ACCOUNT=\
[YOUR_BILLING_ACCOUNT]
export PROJECT=\
[GCP_PROJECT_TO_BE_USED]
export REGION=\
[GCP_REGION_TO_BE_USED]
export ZONE=\
[GCP_ZONE_TO_BE_USED]
export MASTER_PASSWORD=\
[PASSWORD_OF_AT_LEAST_20_CHARACTERS]
```

Clone the deployment:
```sh
git clone http://github.com/fernandosanchezmunoz/cloudlamp
```
Change directory to the desired version, for example:
```sh
cd drupal/drupal-rook
```
Deploy!
```sh
./run_docker.sh
```
##### Access Drupal
Once deployment is completed (usually after 5-10 minutes), deployment results are displayed:
```sh
gke_endpoint = 35.199.51.252
lb_ip = 35.199.47.176
network = https://www.googleapis.com/compute/v1/projects/$PROJECT/global/networks/$NETWORK
self_link_sql_instance = https://www.googleapis.com/sql/v1beta4/projects/$PROJECT/instances/$PROJECT-sql2
sql_user = cloudsqlproxy
subnetwork = https://www.googleapis.com/compute/v1/projects/$PROJECT/regions/us-east4/subnetworks/$PROJECT-subnet
```
The service is available at the "lb_ip" in the output above. Alternatively, you can check this IP in the "Services" tab of Kubernetes Enginer in the Google Cloud Console.

## Known issues
#### Failed Terraform deployment
Apparently due to a race condition, it usually happens that the firewall rules are deployed before the private network has finished deploying. If the deployment fails with the error:
```sh
google_compute_firewall.external: Error creating firewall: googleapi: Error 404: The resource '$NETWORK' was not found, notFound
```
Simply run again with:
```sh
./run_docker.sh
```
 The private network should have finished deploying and the deployment should now continue until completion.
 
#### Temporary restarts of the Drupal GKE service
The Drupal image currently being used seems to require a few restarts to successfully complete the “install wizard” it comes with. 
If you look inside the Replication Controller pods’ logs, you will notice how the “drupal” containers in the pods inside the GKE replication controller restart, usually 5 or 6 times each deployment (approx. 10 minutes), with the error message
```sh
Error executing 'postInstallation': No INPUT matching 'site_name'
```
Eventually the pods are able to complete the Wizard and Drupal comes up, usually on run number 5 or 6

#### Access denied for 'bn_drupal' database username
For reasons currently unknown, the Drupal container sometimes fails to use the  database username passed as an environment variable and uses the default `bn_drupal` username. You can detect a deployment failing for this reason by checking the logs of the "drupal" container inside any of the Deployment's pods. You can detect this error by finding an error message like:
```sh
ERROR 1045 (28000): Access denied for user 'bn_drupal'@'cloudsqlproxy~35.188.254.190' (using password: YES)
```
There is currently no solution to this issue other than destroying the deployment and re-deploying.

## Contributing

PRs and issue reports are very welcome!
