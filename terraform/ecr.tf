resource "aws_ecr_repository" "maosproject" {
  name = var.project_name

  image_scanning_configuration {
    scan_on_push = true
  }

  image_tag_mutability = "MUTABLE"
}
