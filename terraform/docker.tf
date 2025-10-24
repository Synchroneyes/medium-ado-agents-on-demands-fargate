resource "null_resource" "build_and_push_docker_image" {

  triggers = {
    dockerfile_hash = filemd5("${path.module}/../docker/Dockerfile")
  }

  provisioner "local-exec" {
    command     = <<EOT
      #!/bin/bash
      set -e

      IMAGE_TAG=${aws_ecr_repository.on_demands_repository.repository_url}:latest

      # Authenticate Docker to the ECR registry
      aws ecr get-login-password --region ${data.aws_region.current.region} | docker login --username AWS --password-stdin ${aws_ecr_repository.on_demands_repository.repository_url}

      # Build the Docker image
      docker build -t $IMAGE_TAG ${path.module}/../docker

      # Push the Docker image to ECR
      docker push $IMAGE_TAG
    EOT
    interpreter = ["/bin/bash", "-c"]
  }

  depends_on = [aws_ecr_repository.on_demands_repository]

}
