#
# existing network to deploy the db to
#
data "google_compute_network" "db_private_network" {
	name = "default"
}

#
# Private Service Connection, so we can connect to the DB using a private IP
#
resource "google_compute_global_address" "private_ip_address" {
  name          = "private-ip-address"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = data.google_compute_network.db_private_network.id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = data.google_compute_network.db_private_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_vpc_access_connector" "connector" {
  name          = "serverless-vpc-connector"
  ip_cidr_range = "10.8.0.0/28"
  network       = "default"
}