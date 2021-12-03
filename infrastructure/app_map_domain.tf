#
# you might want to disable this if you do not have a
# validated domain configured for Google Cloud
#
variable "app_fqdn" {
  description = "Postfacto FQDN"  
  type        = string
}

resource "google_cloud_run_domain_mapping" "default" {
  location = var.region
  name     = var.app_fqdn

  metadata {
    namespace = data.google_project.project.number
  }

  spec {
    route_name = google_cloud_run_service.postfacto.name
  }
}