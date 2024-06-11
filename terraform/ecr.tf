resource "aws_ecr_repository" "maosproject" {
  name = "${var.environment}-${var.project_name}"

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"

  tags = var.tags
}

resource "null_resource" "pull_and_push_alpine" {
  provisioner "local-exec" {
    command = <<EOT
      # Login to ECR
      aws ecr get-login-password --region ${var.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.maosproject.repository_url}

      # Pull the Alpine image
      docker pull alpine:latest

      # Tag the image for ECR
      docker tag alpine:latest ${aws_ecr_repository.maosproject.repository_url}:latest

      # Push the image to ECR
      docker push ${aws_ecr_repository.maosproject.repository_url}:latest
    EOT

  }

  depends_on = [aws_ecr_repository.maosproject]
}
