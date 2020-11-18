  variable "ibm_api_key" {
  description = "API key."
}
variable "ibm_region" {
  type        = string
  default     = "eu-de"
}
variable "log_mon_ns" {
  type        = string
  default     = "namespest"
}


variable provision_activity_tracker {
    type        = bool
    default     = false
}

variable activity_tracker_name {
    type        = string
    default     = "activity-tracker"
}


variable bring_your_own_logging {
  type        = bool
  default     = false
}


variable logging_instance_name {
    type        = string
   # default     = "logDna-cluster"
}

variable logging_agent_image {
    description = "ICR image link for logdna agent"
    type        = string
    default     = "icr.io/ext/logdna-agent:latest"
}

variable logging_endpoint {
    description = "API endpoint prefix for LogDNA (private, public)"
    type        = string
    default     = "private"
}

variable logging_plan {
    type        = string
    default     = "lite"
}
