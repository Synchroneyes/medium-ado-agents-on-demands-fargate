resource "aws_dynamodb_table" "agents_on_demand_table" {
  name         = "agents-on-demand-table"
  billing_mode = "PAY_PER_REQUEST"
  hash_key     = "taskId"

  attribute {
    name = "taskId"
    type = "S"
  }

  ttl {
    enabled        = true
    attribute_name = "expirationTime"
  }

}
