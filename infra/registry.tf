resource "aws_ecr_repository" "app" {
  name                 = "vulnlab"
  image_tag_mutability = "IMMUTABLE"
  force_delete         = false

  encryption_configuration {
    encryption_type = "AES256"
  }

  image_scanning_configuration {
    scan_on_push = true
  }
}

data "aws_iam_policy_document" "host_ecr_pull" {
  statement {
    sid       = "RegistryAuthentication"
    actions   = ["ecr:GetAuthorizationToken"]
    resources = ["*"]

    condition {
      test     = "StringEquals"
      variable = "aws:RequestedRegion"
      values   = ["us-east-1"]
    }
  }

  statement {
    sid = "PullVulnLabImage"

    actions = [
      "ecr:BatchCheckLayerAvailability",
      "ecr:GetDownloadUrlForLayer",
      "ecr:BatchGetImage",
    ]

    resources = [aws_ecr_repository.app.arn]
  }
}

resource "aws_iam_role_policy" "host_ecr_pull" {
  name   = "vulnlab-ecr-pull"
  role   = aws_iam_role.host.id
  policy = data.aws_iam_policy_document.host_ecr_pull.json
}