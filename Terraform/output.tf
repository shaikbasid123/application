output "vpc_network_name" {
  value = google_compute_network.vpc_network.name
}

output "public_subnet" {
  value = google_compute_subnetwork.public_subnet.name
}

output "private_subnet" {
  value = google_compute_subnetwork.private_subnet.name
}

output "gke_cluster_endpoint" {
  value = google_container_cluster.primary.endpoint
}

output "mysql_instance_connection_name" {
  value = google_sql_database_instance.mysql_instance.connection_name
}

output "db_private_ip" {
  value = google_sql_database_instance.mysql_instance.private_ip_address
}


# db_private_ip = "10.241.0.3"
# gke_cluster_endpoint = "34.72.61.133"
# mysql_instance_connection_name = "my-app-458011:us-central1:tf-mysql-instance"
# private_subnet = "private-subnet"
# public_subnet = "public-subnet"
# vpc_network_name = "tf-vpc"
