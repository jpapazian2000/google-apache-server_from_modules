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
2. For this demo to work...it should be in an initial **WRONG STATE:**
   - Set the following variables (in the HCP Terraform variables):
     - `machine_type` = `n1-standard-2`
     - `sysops_info` = `{ "APPLI1 DEV AZURE" : "LOW", "APPLI3 DEV AZURE" : "HIGH" }`
   - Change the following code in your favorite code editor in the `main.tf` file of the `workspace_repo` subfolder:
     - uncomment lines 7 to 9 (`required_providers` block for kubernetes)
     - uncomment lines 21 to 27 (declares an unauthorized provider and modules). *DO NOT COMMIT YET THE CODE TO YOUR VCS* 
   - You also need to create at least 2 versions of your packer image. On my side, I have also created 2 channels (on top of the existing `latest`): `prod` and `dev`
     - Then I move the oldest version to channel `prod` and I revoke it (in 1mn)

We're now all set!
The demo runs as follow:
1. go back to your editor where you modified your code, and add/commit/push to your git repo:
````
git add .
git commit -m "initial provisionning"
git push -u origin main
````
A provisionning should start in HCP Terraform. If that's the first one, it should just push the code and populate the variables, and you will have to ***manually** trigger a `terraform run` to see the provisionning.
The provisionning should fail because of the `HCP Packer run task` notifying you that the version you want to deploy is revoked and a newer is available.

2. Go in HCP Packer, and assign the most recent version to your `prod` channel. Then execute the `terraform run` again.
It should go fine through the `post plan` phase, and it should stop at the `sentinel policies` phase.
The policies are the following:
   - `restrict use of only autorized providers: HARD-MANDATORY` : will prevent the apply if any none authorized providers are used (default allowed: `hcp` and `google`. The modules uses : `kubernetes` as well which is not allowed)
   - `makes sure that all mandatory labels are present: SOFT-MANDATORY`: the ubuntu image created declares 2 labels : 
   - `requires all modules to be called from private registry only: HARD-MANDATORY`: will prevent the apply if any public modules are used (the code uses: `"Kalepa/uuid/random"` which is public)  
Correct them one at a time, and trigger a `terraform run` after each change. For the modules and provider policies, and git add/commit/push to show a full VCS workflow.
For the last sentinel policy `servicenow`, it is a soft-mandatory one. Whether you do not want to show such integration, or you want to demo the `soft-mandatory` execution mode you can do either.

3. I tend also to leverage the HCP Terraform `explorer saved views` very recent announcement.
   -  For this, I craft a request on all workspaces with the `infra_module` version equal to 1.1.0.
   - Then I create a new version of my module (let's say the actual version is `1.1.0` then I create `1.1.1`). In the terraform code for the module I reference explicitely the latest version of the gcp image used. To make sure of this, I manually increase a counter in the web page of my VM image `"echo \"<h1>Terraform Ready for ${var.customer} VERSION 4.0</h1>\"` 
   It is the `VERSION 4.0` that I increase. 
   That allows me to show all the modules where an old version of my image is provisionned. 
