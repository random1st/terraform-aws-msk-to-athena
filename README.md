# AWS MSK to S3 Sink with Glue and Athena Module

This Terraform module sets up AWS infrastructure to transfer data from Amazon MSK (Managed Streaming for Apache Kafka)
to Amazon S3 using AWS Lambda for data processing, AWS Glue for schema management, and Amazon Athena for querying.

## Features

- **Amazon S3 Bucket** for storing data from MSK topics.
- **AWS Lambda Functions** to process MSK events and write to S3.
- **AWS Glue Crawler** to automatically create and update table schemas.
- **Amazon Athena Workgroup** for querying data stored in S3.
- **IAM Roles and Policies** for necessary permissions for Lambda, Glue, and Athena.

## Usage

```hcl
module "msk_glue_athena" {
  source                            = "./aws-msk-glue-athena"
  msk_cluster_name                  = var.msk_cluster_name
  topic_names                       = var.topic_names
  bucket_name                       = var.bucket_name
  database_name                     = var.database_name
  region                            = var.region
  name                              = var.name
  subnet_ids                        = var.subnet_ids
  security_group_ids                = var.security_group_ids
  image_uri                         = var.image_uri
  batch_size                        = var.batch_size
  maximum_batching_window_in_seconds = var.maximum_batching_window_in_seconds
  arch                              = var.arch
  timeout                           = var.timeout
}
```

## Inputs

| Name                                 | Description                                               | Type           | Default                           | Required |
|--------------------------------------|-----------------------------------------------------------|----------------|-----------------------------------|----------|
| `msk_cluster_name`                   | The name of the MSK cluster                               | `string`       | -                                 | yes      |
| `topic_names`                        | Set of MSK topic names                                    | `set(string)`  | -                                 | yes      |
| `bucket_name`                        | Name of the S3 bucket for storing data                    | `string`       | -                                 | yes      |
| `database_name`                      | Glue database name                                        | `string`       | -                                 | yes      |
| `region`                             | AWS region for resources                                  | `string`       | `"us-east-1"`                     | no       |
| `name`                               | The name of the MSK Lambda SE Athena Pipeline             | `string`       | `"msk-lambda-se-athena-pipeline"` | no       |
| `subnet_ids`                         | List of subnet IDs for the Lambda function                | `list(string)` | -                                 | yes      |
| `security_group_ids`                 | List of security group IDs for the Lambda function        | `list(string)` | -                                 | yes      |
| `image_uri`                          | ECR repository URI for the Lambda image                   | `string`       | -                                 | yes      |
| `batch_size`                         | Number of records to include in each batch sent to Lambda | `number`       | `100`                             | no       |
| `maximum_batching_window_in_seconds` | Maximum wait time before processing a batch               | `number`       | `5`                               | no       |
| `arch`                               | Architecture for the Lambda function                      | `string`       | `"arm64"`                         | no       |
| `timeout`                            | Timeout for the Lambda function                           | `number`       | `300`                             | no       |

## Outputs

| Name                    | Description                                         |
|-------------------------|-----------------------------------------------------|
| `glue_database_name`    | The name of the created Glue database               |
| `athena_workgroup_name` | The name of the created Athena workgroup            |
| `s3_bucket_arn`         | The ARN of the S3 bucket                            |
| `lambda_function_arns`  | ARNs of the Lambda functions created for each topic |

### Build Docker Image

```bash
docker build  . -t <image-name>:<tag>
```

### Connector development and testing

```bash
cd msks2s3
poetry install
poetry run ruff format
poetry run ruff check
poetry run pytest
```

