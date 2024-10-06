data "aws_caller_identity" "current" {}


data "aws_msk_cluster" "msk_cluster" {
  cluster_name = var.msk_cluster_name
}

