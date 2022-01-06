variable "oauth_token_id" {}

variable "repo" {
  default = "migara/L100-automation-lab"
}

variable "ARM_CLIENT_ID" {}

variable "ARM_SUBSCRIPTION_ID" {}

variable "ARM_TENANT_ID" {}

variable "ARM_CLIENT_SECRET" {}

variable "students" {
  default = {}
}

variable "location" {
  default = null
  type    = string
}

