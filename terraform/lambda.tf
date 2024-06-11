resource "aws_lambda_function" "maosproject_function" {
  function_name = "${ var.environment }-${ var.project_name }"
  role          = aws_iam_role.lambda_execution_role.arn
  package_type  = "Image"
  image_uri     = "${aws_ecr_repository.maosproject.repository_url}:latest"

  environment {
    variables = {
      PULUMI_ACCESS_TOKEN = var.pulumi_access_token
    }
  }

  tags = var.tags

  depends_on = [ aws_ecr_repository.maosproject ]

}