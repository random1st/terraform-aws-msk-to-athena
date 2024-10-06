data "aws_iam_policy_document" "s3_sink_lambda_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]
    principals {
      type = "Service"
      identifiers = ["lambda.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "s3_sink_lambda_execution_role" {
  name               = "${var.name}-s3-sink-lambda-role"
  assume_role_policy = data.aws_iam_policy_document.s3_sink_lambda_assume_role_policy.json
}

data "aws_iam_policy_document" "s3_sink_lambda_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "logs:CreateLogGroup",
      "logs:CreateLogStream",
      "logs:PutLogEvents"
    ]
    resources = ["arn:aws:logs:*:*:*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "kafka:DescribeCluster",
      "kafka:DescribeClusterV2",
      "kafka:GetBootstrapBrokers"
    ]
    resources = [data.aws_msk_cluster.msk_cluster.arn]
  }

  statement {
    effect = "Allow"
    actions = [
      "ec2:DescribeNetworkInterfaces",
      "ec2:CreateNetworkInterface",
      "ec2:DeleteNetworkInterface",
      "ec2:DescribeSecurityGroups",
      "ec2:DescribeSubnets",
      "ec2:DescribeVpcs"
    ]
    resources = ["*"]
  }

  statement {
    effect = "Allow"
    actions = [
      "s3:PutObject",
    ]
    resources = [
      aws_s3_bucket.msk_sink_bucket.arn,
      "${aws_s3_bucket.msk_sink_bucket.arn}/*"
    ]
  }
}

resource "aws_iam_policy" "s3_sink_lambda_policy" {
  name   = "${var.name}-s3-sink-lambda-policy"
  policy = data.aws_iam_policy_document.s3_sink_lambda_policy_document.json
}

resource "aws_iam_role_policy_attachment" "s3_sink_lambda_policy_attachment" {
  role       = aws_iam_role.s3_sink_lambda_execution_role.name
  policy_arn = aws_iam_policy.s3_sink_lambda_policy.arn
}

resource "aws_lambda_function" "s3_sink_connector" {
  for_each = toset(var.topic_names)

  function_name = "${var.name}-${each.value}-lambda"
  package_type  = "Image"
  image_uri     = var.image_uri
  architectures = [var.arch]
  timeout       = var.timeout
  role          = aws_iam_role.s3_sink_lambda_execution_role.arn

  environment {
    variables = {
      BUCKET_NAME = aws_s3_bucket.msk_sink_bucket.bucket
    }
  }

  vpc_config {
    subnet_ids         = var.subnet_ids
    security_group_ids = var.security_group_ids
  }
}

resource "aws_lambda_event_source_mapping" "msk_event_source" {
  for_each = toset(var.topic_names)

  event_source_arn                   = data.aws_msk_cluster.msk_cluster.arn
  function_name                      = aws_lambda_function.s3_sink_connector[each.key].arn
  starting_position                  = "LATEST"
  topics = [each.key]
  batch_size                         = var.batch_size
  maximum_batching_window_in_seconds = var.maximum_batching_window_in_seconds
}

