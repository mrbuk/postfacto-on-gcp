variable "region" {
  description = "Default region to be used"
  type        = string
  default     = "europe-west1"
}

variable "zone" {
  description = "Default zone to be used"
  type        = string
  default     = "europe-west1-c"
}

variable "multiregion" {
  description = "Multi-region e.g. EU, US, Asia for GCS or similar"
  type        = string
  default     = "eu"
}

provider "google" {
	region = var.region
	zone   = var.zone
}

data "google_project" "project" {
}
