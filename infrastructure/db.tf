# All DB related configuration

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

variable "db_schema" {
    description = "Postfacto Database Schema (withing postgres)"
    type        = string
    default     = "postgres"
}

# generate a suffix as in case of recreation the DB instance name
# cannot be reused for 1 week
resource "random_id" "db_name_suffix" {
  byte_length = 4
}

#
# smallest possible postgres instance
# 
resource "google_sql_database_instance" "postfacto" {
  name             = "postfacto-instance-${random_id.db_name_suffix.hex}"
  database_version = "POSTGRES_13"

  settings {
    tier = "db-f1-micro"

    ip_configuration {
        ipv4_enabled    = true
    }
  }
}

resource "google_sql_user" "users" {
  name     = var.db_user
  password = var.db_password

  instance = google_sql_database_instance.postfacto.name
}