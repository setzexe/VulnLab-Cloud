# CloudWatch's default encryption used at rest.

#trivy:ignore:AWS-0017
resource "aws_cloudwatch_log_group" "application" {
  name              = "/vulnlab/application"
  retention_in_days = 7
}

data "aws_iam_policy_document" "host_application_logs" {
  statement {
    sid = "WriteApplicationLogs"

    actions = [
      "logs:CreateLogStream",
      "logs:PutLogEvents",
    ]

    resources = [
      "${aws_cloudwatch_log_group.application.arn}:log-stream:*",
    ]
  }
}

resource "aws_iam_role_policy" "host_application_logs" {
  name   = "vulnlab-application-logs"
  role   = aws_iam_role.host.id
  policy = data.aws_iam_policy_document.host_application_logs.json
}

resource "aws_cloudwatch_log_metric_filter" "failed_logins" {
  name           = "vulnlab-failed-logins"
  log_group_name = aws_cloudwatch_log_group.application.name
  pattern        = "{ $.event = \"auth.login_failed\" && $.outcome = \"failure\" }"

  metric_transformation {
    name          = "FailedLogins"
    namespace     = "VulnLab/Security"
    value         = "1"
    default_value = 0
    unit          = "Count"
  }
}

resource "aws_cloudwatch_metric_alarm" "failed_logins" {
  alarm_name        = "vulnlab-failed-logins"
  alarm_description = "Three or more failed application logins in a five-minute evaluation period."

  namespace   = "VulnLab/Security"
  metric_name = "FailedLogins"
  statistic   = "Sum"
  unit        = "Count"

  period              = 300
  evaluation_periods  = 1
  datapoints_to_alarm = 1

  comparison_operator = "GreaterThanOrEqualToThreshold"
  threshold           = 3
  treat_missing_data  = "notBreaching"

  depends_on = [
    aws_cloudwatch_log_metric_filter.failed_logins,
  ]
}