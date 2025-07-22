resource "google_compute_network" "vpc_network" {
  name = var.network_name
  auto_create_subnetworks = false
  project = var.project_id
}

resource "google_compute_subnetwork" "public_subnet" {
  name          = "public-subnet"
  ip_cidr_range = "10.0.1.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.self_link
}

resource "google_compute_subnetwork" "private_subnet" {
  name          = "private-subnet"
  ip_cidr_range = "10.0.2.0/24"
  region        = var.region
  network       = google_compute_network.vpc_network.self_link
  private_ip_google_access = true
  secondary_ip_range {
  range_name    = "pods"
  ip_cidr_range = "10.0.3.0/24"
  }

  secondary_ip_range {
  range_name    = "services"
  ip_cidr_range = "10.0.4.0/24"
  }

}

resource "google_container_cluster" "primary" {
  name     = var.gke_cluster_name
  location = var.zone

  network    = google_compute_network.vpc_network.id
  subnetwork = google_compute_subnetwork.private_subnet.id

  remove_default_node_pool = true
  initial_node_count       = 1

  ip_allocation_policy {
    cluster_secondary_range_name  = "pods"
    services_secondary_range_name = "services"
  }

}

resource "google_container_node_pool" "primary_nodes" {
  name       = "primary-node-pool"
  cluster    = google_container_cluster.primary.name
  location   = var.zone

  node_config {
    machine_type = "e2-medium"
    disk_size_gb = 20
    oauth_scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  initial_node_count = 1
}

resource "google_compute_global_address" "private_ip_address" {
  name          = "cloud-sql-private-ip"
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.vpc_network.id
  project       = var.project_id
}

resource "google_service_networking_connection" "private_vpc_connection" {
  network                 = google_compute_network.vpc_network.id
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.private_ip_address.name]
}

resource "google_sql_database_instance" "mysql_instance" {
  name             = var.db_instance_name
  region           = var.region
  project          = var.project_id
  database_version = "MYSQL_8_0"

  settings {
    tier = "db-f1-micro"

    ip_configuration {
      ipv4_enabled                                  = false
      private_network                               = google_compute_network.vpc_network.id
      enable_private_path_for_google_cloud_services = true
    }
  }

  depends_on = [google_service_networking_connection.private_vpc_connection]
}


resource "google_sql_user" "users" {
  name     = var.db_user
  instance = google_sql_database_instance.mysql_instance.name
  password = var.db_password
}

resource "google_sql_database" "app_db" {
  name     = var.db_name
  instance = google_sql_database_instance.mysql_instance.name
}

resource "google_compute_firewall" "allow_http" {
  name    = "allow-http"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["80", "443"]
  }

  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "allow_ssh" {
  name    = "allow-ssh"
  network = google_compute_network.vpc_network.name

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  direction = "INGRESS"
  source_ranges = ["0.0.0.0/0"]
}

