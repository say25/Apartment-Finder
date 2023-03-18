###########################
# Core Metadata Variables #
###########################

variable "application_name" {
  type        = string
  default     = "apartment-finder"
  description = "The name to use within resource creation."
}

variable "environment" {
  type        = string
  description = "Valid values: production"
  validation {
    condition     = can(regex("production", var.environment))
    error_message = "Must use a valid environment value."
  }
}

########################
# PagerDuty Variables #
########################

variable "pagerduty_integration_keys" {
  type        = map(any)
  description = "The integration keys defined for your PagerDuty service integrations with CloudWatch. Leave it empty for an environment to not get alerted."
  default = {
    production-monitoring = ""
    production-matching   = ""
  }
}


############
# AWS Tags #
############

locals {
  tags = {
    Application = var.application_name
    Environment = var.environment
  }
}