variable "msk_cluster_name" {
  type        = string
  description = "MSK Cluster Name"
}

variable "topic_names" {
  type = set(string)
  description = "Set of MSK Topic Names"
}


variable "bucket_name" {
  type        = string
  description = "S3 Bucket Name"
}

variable "database_name" {
  type        = string
  description = "Glue Database Name"
}


variable "region" {
  type        = string
  description = "AWS Region"
  default     = "us-east-1"
}
variable "name" {
  type        = string
  description = "Name of the MSK Lambda SE Athena Pipeline"
  default     = "msk-lambda-se-athena-pipeline"
}

variable "subnet_ids" {
  type = list(string)
  description = "List of Subnet IDs"
}

variable "security_group_ids" {
  type = list(string)
  description = "List of Security Group IDs"
}

variable "image_uri" {
  type        = string
  description = "ECR repository URI for Lambda image"
  default = "random1st/msk2s3:0.0.1"
}


variable "batch_size" {
  type        = number
  description = "Number of records to include in each batch sent to the function"
  default     = 100
}

variable "maximum_batching_window_in_seconds" {
  type        = number
  description = "Maximum amount of time to wait before processing a batch"
  default     = 5
}

variable "arch" {
  type        = string
  description = "Architecture of the Lambda function"
  default     = "arm64"
}
variable "timeout" {
  type        = number
  description = "Timeout for the Lambda function"
  default     = 300
}