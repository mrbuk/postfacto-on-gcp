provider "google" {
	region = "europe-west1"
	zone   = "europe-west1-c"
}

variable "terraform_state_bucket" {
  description = "Name of the GCS bucket where the Terraform state will be stored"
  type        = string
}

terraform {
  backend "gcs" {
    bucket  = var.terraform_state_bucket
    prefix  = "postfacto-on-gcp/terraform"
  }
}