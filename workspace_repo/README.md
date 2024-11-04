# google-apache-server_from_modules


There are a couple of things for this demo to work
First you need to have an HCP Account and provision an HCP Packer image.
As the demo is focused on google, on my side, I have created an image in google cloud with packer.
The packer file is in the following git repo:
- gcp_ubuntu.pkr.hcl
In order to provision this image, you have to do a couple of settings:
1. create a google service account with proper access rights : https://developer.hashicorp.com/packer/integrations/hashicorp/googlecompute#running-outside-of-google-cloud

2. Once this is achieved, you have to export also you HCP_CLIENT_ID and HCP_CLIENT_SECRET variable.
3. then you can run:
````
packer init
packer validate .
packer build .
````

From there, next step would be to clone the github repo, and ```cd init_repo```
You are now going to provision the environment in HCP Terraform.
For this you need a token, that you can obtain with ```terraform login```
Next create a ```terraform.auto.tfvars``` file in this folder and add the following content:
````
tfe_token = <the token from above>
sysops_info = "{ \"APPLI1 DEV AZURE\" : \"LOW\", \"APPLI2 DEV AZURE\" : \"HIGH\" }"
oauth_token = <github oauth token for terraform to connect to github>

gcp_project_id = <your gcp project id: hc-somenumber>
````
Before you can run ```terraform init, plan, apply``` commands, one needs also to configure google credentials for the settings of the Workload Identity Federation between HCP Terraform and Google.
For this, simply run the following 2 commands:
````
unset GOOGLE_APPLICATION_CREDENTIALS
gcloud auth application-default login
````
Now, you can run:
````
terraform init
terraform plan
terraform apply -auto-approve
````
This will create a workspace ```another_google_ubuntu_workspace``` in the project ```dyn_creds_gcp``` (workspace name has been provided in the terraform variables default values, feel free to change if needed.)

You can now in your HCP Terraform go in this workspace and provision a run. 

# Main Steps for the demo

## Preparation
1. Make sur you have a variable with your google credentials. On my side, I have created a variable_set `GOOGLE_CREDENTIALS` with all 3 variables:
````
google_project
google_region
google_zone
````
2. For this demo to work...it should be in an initial **`#FF0000`WRONG STATE** 
