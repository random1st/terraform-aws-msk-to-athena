resource "aws_athena_workgroup" "athena_workgroup" {
  name        = "${var.database_name}-workgroup"
  description = "Workgroup for querying MSK sink data."
  state       = "ENABLED"

  configuration {
    result_configuration {
      output_location = "s3://${aws_s3_bucket.msk_sink_bucket.bucket}/query-results/"
    }
    enforce_workgroup_configuration = true
  }
}