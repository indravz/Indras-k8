# Indras-k8
Indras-k8


******Setting the project locally*****

***Install terraform**

**Macos:**
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew update
brew upgrade hashicorp/tap/terraform
terraform -help

cd cluster-setup

terraform init

Please refer to below for other host machines:
https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli


Create a User in AWS to connect to Terraform
Go to https://us-east-1.console.aws.amazon.com/iam/home?region=us-east-2#/users  once you login to aws console




**Setting up ENV variables for connecting to aws**
Create user - Terraform with Admin access policy (Admin access is fine for local/pet project, but not for a production app)
Once created, download the secret key and access key


export AWS_ACCESS_KEY_ID="<your-access-key-id>"
export AWS_SECRET_ACCESS_KEY="<your-secret-access-key>"
export AWS_DEFAULT_REGION="your-region" #set the default region, example: us-west-1


**To create your servers***
terraform plan ( check if you can run with out errors) 

Response should be Plan: 3 to add, 0 to change, 0 to destroy.





