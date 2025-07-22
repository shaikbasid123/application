terraform {
  backend "gcs" {
    bucket = "data-store-939"
    prefix = "terraform-state-files"
  }
}
