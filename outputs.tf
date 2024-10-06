output "glue_database_name" {
  value = aws_glue_catalog_database.glue_database.name
}

output "athena_workgroup_name" {
  value = aws_athena_workgroup.athena_workgroup.name
}

output "athena_query_results" {
  value = "s3://${aws_s3_bucket.msk_sink_bucket.bucket}/query-results/"
}