variable "db_user" {
    description = "Postfacto Database Username"
    type        = string
    default     = "postfacto-db-user"
}

variable "db_password" {
    description = "Postfacto Database Password"
    type        = string
    sensitive   = true
}

variable "db_instance" {
    description = "Postfacto Database Instance (withing postgres)"
    type        = string
    default     = "postgres"
}

#
# smallest possible postgres instance
# public ip disabled to safe 0,10 USD per hour :)
# 
resource "google_sql_database_instance" "postfacto" {
  name             = "postfacto-instance"
  database_version = "POSTGRES_11"

  depends_on = [google_service_networking_connection.private_vpc_connection]


  settings {
    tier = "db-f1-micro"

    ip_configuration {
        ipv4_enabled    = false
        private_network = data.google_compute_network.db_private_network.id
    }
  }
}

resource "google_sql_user" "users" {
  name     = var.db_user
  password = var.db_password

  instance = google_sql_database_instance.postfacto.name
}