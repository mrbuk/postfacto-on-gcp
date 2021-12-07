variable "lb_name" {
  type = string
  default = "postfacto-lb"
}

variable "app_fqdn" {
  description = "Postfacto FQDN"  
  type        = string
}

variable "app_oauth_client_id" {
  description = "Postfacto Google OAuth Client ID used for Google Login"
  type        = string
}

variable "app_oauth_client_secret" {
  description = "Postfacto Google OAuth Client Secret used for Google Login"
  type        = string
  sensitive   = true
}

variable "iap_members" {
  type    = list(string)
}

resource "google_compute_region_network_endpoint_group" "serverless_neg" {
  name                  = "serverless-neg"
  network_endpoint_type = "SERVERLESS"
  region                = var.region
  cloud_run {
    service = google_cloud_run_service.postfacto.name
  }
}

module "lb-http" {
  source  = "GoogleCloudPlatform/lb-http/google//modules/serverless_negs"
  version = "6.1.1"

  project = data.google_project.project.number
  name    = var.lb_name

  ssl                             = true
  ssl_policy                      = "tls-1-2"
  managed_ssl_certificate_domains = [var.app_fqdn]
  https_redirect                  = true

  backends = {
    default = {
      description = null
      groups = [
        {
          group = google_compute_region_network_endpoint_group.serverless_neg.id
        }
      ]
      enable_cdn             = false
      security_policy        = null
      custom_request_headers = null
      custom_response_headers = null

      iap_config = {
        enable               = true
        oauth2_client_id     = var.app_oauth_client_id
        oauth2_client_secret = var.app_oauth_client_secret
      }
      log_config = {
        enable      = false
        sample_rate = null
      }
    }
  }
}

data "google_iam_policy" "iap" {
  binding {
    role = "roles/iap.httpsResourceAccessor"
    members = var.iap_members
  }
}

resource "google_iap_web_backend_service_iam_policy" "policy" {
  project             = data.google_project.project.number
  web_backend_service = "${var.lb_name}-backend-default"
  policy_data         = data.google_iam_policy.iap.policy_data
  depends_on = [
    module.lb-http
  ]
}

output "load-balancer-ip" {
  value = module.lb-http.external_ip
}

output "oauth2-redirect-uri" {
  value = "https://iap.googleapis.com/v1/oauth/clientIds/${var.app_oauth_client_id}:handleRedirect"
}