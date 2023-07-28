terraform {
  backend "gcs" {
    bucket = var.terraform_state_bucket_name
    # prefix - (Optional) GCS prefix inside the bucket.
    prefix = var.terraform_state_bucket_name_prefix
  }
  required_providers {
    datadog = {
      source = "Datadog/datadog"
      version= "3.28.0"
    }
  }
}