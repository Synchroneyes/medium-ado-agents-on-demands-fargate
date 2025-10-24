resource "null_resource" "install_python_requirements" {

  triggers = {
    always_run = "${timestamp()}"
  }

  count = strcontains(var.lambda_runtime, "python") && var.lambda_install_requirements ? 1 : 0
  provisioner "local-exec" {
    command = "pip install -r ${var.lambda_code_path}/${var.lambda_requirements_file_name} -t ${var.lambda_code_path}/package"
  }
}

resource "null_resource" "copy_lambda_code" {

  depends_on = [null_resource.install_python_requirements]

  triggers = {
    always_run = "${timestamp()}"
  }


  count = strcontains(var.lambda_runtime, "python") && var.lambda_install_requirements ? 1 : 0
  provisioner "local-exec" {
    command = "cp -r ${var.lambda_code_path}/*.py ${var.lambda_code_path}/package/"
  }
}

data "archive_file" "lambda_package_python" {
  count = strcontains(var.lambda_runtime, "python") && var.lambda_install_requirements ? 1 : 0

  type        = "zip"
  source_dir  = "${var.lambda_code_path}/package"
  output_path = "${var.lambda_code_path}/package.zip"

  depends_on = [null_resource.copy_lambda_code, null_resource.install_python_requirements]
}

resource "null_resource" "clean_package" {
  depends_on = [aws_lambda_function.lambda_function]
  triggers = {
    always_run = "${timestamp()}"
  }

  provisioner "local-exec" {
    command = "rm -rf ${var.lambda_code_path}/package && rm -f ${var.lambda_code_path}/package.zip"
  }
}
