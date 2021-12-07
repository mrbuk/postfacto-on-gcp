# All Cloud Run related configuration

variable "app_secret_key_base" {
  description = "Postfacto Secret Key Base (Rails specific). Generate is once an reuse it."
  type        = string
  sensitive   = true
}

variable "app_hosted_domain" {
  description = "Postfacto should restrict logins via Google to this domain only"
  type        = string
}

data "google_container_registry_image" "postfacto" {
  region = var.multiregion
  name = "mrbuk/postfacto"
  tag = "4.3.11-cloudsqlproxy"
}

# IAM for what the Cloud Run service can do
#  ensure we use a service account that can connect to Cloud SQL
resource "google_service_account" "postfacto" {
  account_id   = "postfacto-sa"
  display_name = "Postfacto Service Account mainly used for Cloud Run"
}

resource "google_project_iam_binding" "postfacto_sa_cloudsql_client" {
  project =  data.google_project.project.number
  role    = "roles/cloudsql.client"
  members = [
    "serviceAccount:${google_service_account.postfacto.email}"
  ]
}

resource "google_cloud_run_service" "postfacto" {
  name     = "postfacto-01"
  location = var.region

  metadata {
      annotations = {
        "run.googleapis.com/ingress"  = "internal-and-cloud-load-balancing"
      }
    }

  template {
    spec {
      containers {
        image = data.google_container_registry_image.postfacto.image_url
        ports {
          container_port = 3000
        }
        env {
          name = "USE_POSTGRES_FOR_ACTION_CABLE"
          value = "true"
        }
        env {
          name = "SECRET_KEY_BASE"
          value = var.app_secret_key_base
        }
        env {
          name = "HOSTED_DOMAIN"
          value = var.app_hosted_domain
        }
        env {
          name = "DB_USER"
          value = var.db_user
        }
        env {
          name = "DB_PASSWORD"
          value = var.db_password
        }
        env {
          name = "DB_DATABASE"
          value = var.db_schema
        }
        env {
          name = "DB_INSTANCE_CONNECTION_NAME"
          value = google_sql_database_instance.postfacto.connection_name
        }
        env {
          name = "GOOGLE_OAUTH_CLIENT_ID"
          value = var.app_oauth_client_id
        }
      }
      service_account_name = google_service_account.postfacto.account_id
    }

    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"      = "50"
        "run.googleapis.com/cloudsql-instances" = google_sql_database_instance.postfacto.connection_name
      }
    }
  }
}

