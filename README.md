```markdown
# Indras-k8

Indras-k8

## Setting the Project Locally

### Install Terraform

#### macOS:

```bash
brew tap hashicorp/tap
brew install hashicorp/tap/terraform
brew update
brew upgrade hashicorp/tap/terraform
terraform -help
```

```bash
cd cluster-setup
terraform init
```

For installation on other host machines, refer to:
[HashiCorp Learn - AWS CLI Installation](https://learn.hashicorp.com/tutorials/aws-get-started/install-cli)

### Create a User in AWS to Connect to Terraform

1. Go to [AWS IAM Console](https://console.aws.amazon.com/iam/home?region=us-east-2#/users) after logging in to the AWS console.

### Setting Up Environment Variables for Connecting to AWS

- Create a user 'Terraform' with Admin access policy (Note: Admin access is suitable for local/pet projects but not for production apps).
- Once created, download the secret key and access key.

Set the environment variables:

```bash
export AWS_ACCESS_KEY_ID="<your-access-key-id>"
export AWS_SECRET_ACCESS_KEY="<your-secret-access-key>"
export AWS_DEFAULT_REGION="your-region" # set the default region, e.g., us-west-1
```

### Replace Public Key and IP CIDR

Replace the following placeholders with your specific details:

- `public_key`: Replace with your SSH public key.
- `ip_cidr`: Replace with your IP address followed by `/32` for variable security_group_cidr value in master.tf and worker.tf (e.g., `yourip/32`).

### Create SSH Key Pair

1. Generate an SSH key pair using `ssh-keygen`:
   ```bash
   ssh-keygen
   ```
 Specify your directory to store the files example /Users/<>/tf-key/ec2key Hit enter and use the default vaues( make sure your file is created before using here)
2. Store the generated keys for connecting to instances once generated and use them to replace the variable value public_key in master.tf and workers.tf

### Store Terraform State Locally

- Configure Terraform to store the state file locally in a specific local directory in providers.tf file.(replace the path accordingly)

### To Create Your Servers

Run Terraform Plan:

```bash
terraform plan
```

Check if it runs without errors. The response should be:
`Plan: 3 to add, 0 to change, 0 to destroy.`
```
finally
```bash
terraform apply
```
