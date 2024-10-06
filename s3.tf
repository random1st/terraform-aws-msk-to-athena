
resource "aws_s3_bucket" "msk_sink_bucket" {
  bucket = "${var.bucket_name}-msk-sink"
}