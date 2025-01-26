resource "aws_iam_role" "iam_role" {
  name = var.role_name

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = var.assume_role_services
        }
        Action = "sts:AssumeRole"
      }
    ]
  })
}

resource "aws_iam_policy" "iam_policy" {
  name        = var.policy_name
  description = var.policy_description

  policy = jsondecode(var.policy_statements)
}

resource "aws_iam_role_policy_attachment" "attach_role_policy" {
  role       = aws_iam_role.iam_role.name
  policy_arn = aws_iam_policy.iam_policy.arn
}
