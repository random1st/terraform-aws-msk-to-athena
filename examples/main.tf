terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = ">= 4.1.0"
    }
  }
}

module "msk_glue_athena" {
  source                             = "./."
  msk_cluster_name                   = "msk-kafka"
  topic_names                        = ["kafka-topic"]
  bucket_name                        = "msk-sink-bucket"
  database_name                      = "msk_sink_database"
  region                             = "us-east-1"
  name                               = "msk-pipeline-dev"
  subnet_ids                         = ["subnet-04d62a3d235966202", "subnet-08321eef5c78ea9ff"]
  security_group_ids                 = ["sg-09db881111389e29f", "sg-0eaa32238733183ec"]
  batch_size                         = 100
  maximum_batching_window_in_seconds = 5
}

output "athena_query_results" {
  value = module.msk_glue_athena.athena_query_results
}