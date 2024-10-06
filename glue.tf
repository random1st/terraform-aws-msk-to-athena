data "aws_iam_policy_document" "glue_crawler_assume_role_policy" {
  statement {
    actions = ["sts:AssumeRole"]

    principals {
      type = "Service"
      identifiers = ["glue.amazonaws.com"]
    }
  }
}

resource "aws_iam_role" "glue_crawler_role" {
  name               = "${var.name}-glue-crawler-role"
  assume_role_policy = data.aws_iam_policy_document.glue_crawler_assume_role_policy.json
}

data "aws_iam_policy_document" "glue_crawler_policy_document" {
  statement {
    effect = "Allow"
    actions = [
      "glue:CreateTable",
      "glue:UpdateTable",
      "glue:DeleteTable",
      "glue:GetTable",
      "glue:BatchGetPartition",
      "glue:BatchCreatePartition",
      "glue:BatchDeletePartition"
    ]
    resources = [
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:database/${var.database_name}",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:table/${var.database_name}/*"
    ]
  }

  statement {
    effect = "Allow"
    actions = [
      "glue:CreateDatabase",
      "glue:GetDatabase",
      "glue:UpdateDatabase"
    ]
    resources = [
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:catalog",
      "arn:aws:glue:${var.region}:${data.aws_caller_identity.current.account_id}:database/${var.database_name}"
    ]
  }

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
      "s3:GetObject",
      "s3:PutObject",
      "s3:ListBucket"
    ]
    resources = [
      aws_s3_bucket.msk_sink_bucket.arn,
      "${aws_s3_bucket.msk_sink_bucket.arn}/*"
    ]
  }

  dynamic "statement" {
    for_each = var.topic_names
    content {
      effect = "Allow"
      actions = ["s3:GetObject", "s3:ListBucket"]
      resources = ["${aws_s3_bucket.msk_sink_bucket.arn}/${statement.value}/*"]
    }
  }
}

resource "aws_iam_policy" "glue_crawler_policy" {
  name   = "${var.name}-glue-crawler-policy"
  policy = data.aws_iam_policy_document.glue_crawler_policy_document.json
}

resource "aws_iam_role_policy_attachment" "glue_crawler_policy_attachment" {
  role       = aws_iam_role.glue_crawler_role.name
  policy_arn = aws_iam_policy.glue_crawler_policy.arn
}

resource "aws_glue_catalog_database" "glue_database" {
  name = var.database_name
}

resource "aws_glue_crawler" "glue_crawler" {
  for_each = var.topic_names

  name          = "${var.database_name}-crawler-${each.key}"
  database_name = aws_glue_catalog_database.glue_database.name
  role          = aws_iam_role.glue_crawler_role.arn
  schedule      = "cron(0 0 * * ? *)"

  s3_target {
    path = "s3://${aws_s3_bucket.msk_sink_bucket.bucket}/${each.value}"
  }

  schema_change_policy {
    update_behavior = "LOG"
    delete_behavior = "LOG"
  }
}