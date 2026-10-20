variable "primary_region" {
  description = "The primary region for the infrastructure."
  type        = string
  default     = "malaysiawest"
}

variable "secondary_region" {
    description = "The secondary region for the infrastructure."
    type        = string
    default     = "southeastasia"
}

variable "prefix" {
    description = "The prefix for the resource names."
    type        = string
    default     = "azha"
}

variable "environment" {
    description = "The environment for the infrastructure."
    type        = string
    default     = "prod"
}