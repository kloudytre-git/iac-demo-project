variable "region" {
  type    = string
  default = "us-east-1"
}

variable "project" {
  type    = string
  default = "iac-portfolio"
}

variable "environment" {
  type    = string
  default = "staging" # <-- CHANGED (was "dev")
}