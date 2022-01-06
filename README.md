# automation-lab-tfc-bootstrap

This setup leverages Terraform Cloud to deploy labs. A Terraform Cloud workspace per student will be created.

1. Sign up for a [Terraform Cloud](https://app.terraform.io/signup/account) account. There is a free tier available.
2. Login to Terraform Cloud via CLI
    ```
    terraform login
    ```
3. Create a Azure Service Principal with a Client Secret -https://registry.terraform.io/providers/hashicorp/azurerm/latest/docs/guides/service_principal_client_secret
4. Export the environment variables
    ```bash
    export TF_VAR_ARM_CLIENT_ID=xxx-xxxx-xxxxx
    export TF_VAR_ARM_SUBSCRIPTION_ID=xxx-xxxx-xxxxx
    export TF_VAR_ARM_TENANT_ID=xxx-xxxx-xxxxx
    export TF_VAR_ARM_CLIENT_SECRET=xxx-xxxx-xxxxx
    ```
5. Configure GitHub.com Access (OAuth) for Terraform Cloud - https://www.terraform.io/cloud-docs/vcs/github
6. Export the oauth ID as an environment variable
    ```
    export TF_VAR_oauth_token_id=xxx-xxxxx
    ```
7. Populate the `input.yml` file with to reflect the number of lab environments required for the classroom.
    > `location` variable indicated the Azure region to use for the deployment. If left empty the region will default to `East US 2`

    > `global_allow_inbound_mgmt_ips` accepts a list of IP addresses. This controls the allowed source IP ranges for management access of bastion host and the VM-Series firewall via public IPs. For instance This can be a set of Global Protect IPs.

    > If required you can also specify a  granular set of allow IPs per student via `allow_inbound_mgmt_ips` variable.

8. Deploy the labs
    ```hcl
    terraform init
    terraform apply
    ```

9. View lab login details
    ```hcl
    terraform output lab_details
    ```

> A random password will be generated for each student and this will be the password for both bastion host and the VM-Series firewall

> Each student will have its own Azure Resource Group with the student names specified on the `input.yml' file

#
## Lab Cleanup

> Note: Terraform destroy will not destroy lab infrastructure deployed on Azure. This either has to be done manually by deleting each Azure Resource Group manually or by queueing a destroy plan via Terraform Cloud workspace - https://learn.hashicorp.com/tutorials/terraform/cloud-destroy. This part can be automated via Terraform Cloud API if required.

Once all the Azure infrastructure is destroyed destroy the Terraform workspaces 

    ```hcl
    terraform destroy
    ```