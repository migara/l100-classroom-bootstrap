provider "tfe" {}

locals {
  config = yamldecode(file("./input.yml"))
}


resource "tfe_workspace" "main" {
  for_each     = { for k, v in local.config.students : k => v }
  name         = "${each.key}-L100"
  organization = "panw-bridgecrew"
  auto_apply   = true

  vcs_repo {
    identifier         = var.repo
    oauth_token_id     = var.oauth_token_id
    ingress_submodules = true
  }
}

resource "random_password" "this" {
  for_each         = tfe_workspace.main
  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  override_special = "_%@"
}

resource "tfe_variable" "arm_client_id" {
  for_each     = tfe_workspace.main
  key          = "ARM_CLIENT_ID"
  value        = var.ARM_CLIENT_ID
  category     = "env"
  workspace_id = each.value.id
  sensitive    = true
}

resource "tfe_variable" "arm_subscription_id" {
  for_each     = tfe_workspace.main
  key          = "ARM_SUBSCRIPTION_ID"
  value        = var.ARM_SUBSCRIPTION_ID
  category     = "env"
  workspace_id = each.value.id
  sensitive    = true
}

resource "tfe_variable" "arm_tenant_id" {
  for_each     = tfe_workspace.main
  key          = "ARM_TENANT_ID"
  value        = var.ARM_TENANT_ID
  category     = "env"
  workspace_id = each.value.id
  sensitive    = true
}

resource "tfe_variable" "arm_client_secret" {
  for_each     = tfe_workspace.main
  key          = "ARM_CLIENT_SECRET"
  value        = var.ARM_CLIENT_SECRET
  category     = "env"
  workspace_id = each.value.id
  sensitive    = true
}

resource "tfe_variable" "allow_inbound_mgmt_ips" {
  for_each     = tfe_workspace.main
  key          = "allow_inbound_mgmt_ips"
  value        = jsonencode(concat(local.config.global_allow_inbound_mgmt_ips, local.config.students[each.key].allow_inbound_mgmt_ips))
  hcl          = true
  category     = "terraform"
  workspace_id = each.value.id
}

resource "tfe_variable" "location" {
  for_each     = tfe_workspace.main
  key          = "location"
  value        = coalesce(local.config.location, "East US 2")
  category     = "terraform"
  workspace_id = each.value.id
}


resource "tfe_variable" "rg" {
  for_each     = tfe_workspace.main
  key          = "resource_group_name"
  value        = each.key
  category     = "terraform"
  workspace_id = each.value.id
}

resource "tfe_variable" "password" {
  for_each     = tfe_workspace.main
  key          = "password"
  value        = random_password.this[each.key].result
  category     = "terraform"
  workspace_id = each.value.id
}

# resource "tfe_variable" "cli-args" {
#   for_each     = tfe_workspace.main
#   key          = "TF_CLI_ARGS"
#   value        = "-var-file=example.tfvars"
#   category     = "terraform"
#   workspace_id = each.value.id
# }



data "tfe_outputs" "foo" {
  for_each     = tfe_workspace.main
  organization = "panw-bridgecrew"
  workspace    = each.value.name
}

output "lab_details" {
  value     = { for k, v in data.tfe_outputs.foo : k => merge(v.values, { password : random_password.this[k].result }) }
  sensitive = true
}

